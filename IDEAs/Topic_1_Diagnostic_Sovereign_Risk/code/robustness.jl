# Robustness computations for the diagnostic sovereign default paper.
#
# Referee-requested checks:
#   (1) grid-doubling verification of Assumption M (monotone default):
#       NY = 31, NB = 400 at theta in {0, 0.5, 1}, with key moments;
#   (2) monotonicity under an alternative (proportional) default cost;
#   (3) coarse recalibration of (beta, phi) at theta = 0.5 targeting the
#       Arellano (2008) default frequency (3 per century) and debt service
#       to output (5.5 percent), then a final theta in {0, 0.5} pair at the
#       recalibrated parameters with the boom-reversal event study.
#
# Run:  julia --project=. -t auto robustness.jl
# Outputs: ../output/robustness.json, ../output/robust_numbers.tex

using LinearAlgebra
using Random
using SpecialFunctions: erfc
using JSON

const OUTDIR = joinpath(@__DIR__, "..", "output")
mkpath(OUTDIR)

Base.@kwdef struct Pars
    gamma::Float64 = 2.0
    beta::Float64  = 0.953
    rstar::Float64 = 0.017
    rho::Float64   = 0.945
    sige::Float64  = 0.025
    lam::Float64   = 0.282
    phi::Float64   = 0.969   # asymmetric cost: ydef = min(y, phi * E[y])
    psi::Float64   = 0.0     # proportional cost: ydef = (1 - psi) * y (if costform = :prop)
    costform::Symbol = :arellano
    ny::Int = 21
    mt::Float64 = 3.0
    nb::Int = 200
    bmax::Float64 = 0.35
end

Phi(z) = 0.5 * erfc(-z / sqrt(2.0))

function tauchen_grid(pp::Pars)
    stdx = pp.sige / sqrt(1.0 - pp.rho^2)
    collect(range(-pp.mt * stdx, pp.mt * stdx, length = pp.ny))
end

function transition_from_means(pp::Pars, x::Vector{Float64}, means::Vector{Float64})
    ny = pp.ny
    step = x[2] - x[1]
    P = zeros(length(means), ny)
    for i in eachindex(means)
        z = (x .- means[i]) ./ pp.sige
        for j in 2:ny-1
            P[i, j] = Phi(z[j] + 0.5 * step / pp.sige) - Phi(z[j] - 0.5 * step / pp.sige)
        end
        P[i, 1] = Phi(z[1] + 0.5 * step / pp.sige)
        P[i, ny] = 1.0 - Phi(z[ny] - 0.5 * step / pp.sige)
    end
    P
end

function build_kernels(pp::Pars, theta::Float64)
    x = tauchen_grid(pp)
    P = transition_from_means(pp, x, pp.rho .* x)
    Pd = zeros(pp.ny, pp.ny, pp.ny)
    for ih in 1:pp.ny
        means = pp.rho .* x .+ theta * pp.rho .* (x .- x[ih])
        Pd[:, ih, :] = transition_from_means(pp, x, means)
    end
    x, P, Pd
end

util(pp::Pars, c::Float64) = c > 1e-8 ? c^(1.0 - pp.gamma) / (1.0 - pp.gamma) : -1e12

function ergodic(pp::Pars, P::Matrix{Float64})
    piv = fill(1.0 / pp.ny, pp.ny)
    for _ in 1:200_000
        pin = vec(piv' * P)
        if maximum(abs.(pin .- piv)) < 1e-14
            piv = pin
            break
        end
        piv = pin
    end
    piv ./ sum(piv)
end

spread_annual(pp::Pars, qv::Float64) = (1.0 / max(qv, 1e-6))^4 - (1.0 + pp.rstar)^4

struct Solution
    pp::Pars
    x::Vector{Float64}
    P::Matrix{Float64}
    y::Vector{Float64}
    b::Vector{Float64}
    V::Array{Float64,3}
    Vd::Vector{Float64}
    q::Array{Float64,3}
    d::Array{Bool,3}
    pol::Array{Int,3}
    theta::Float64
    iters::Int
end

function solve(pp::Pars, theta::Float64; tol::Float64 = 5e-8,
               maxit::Int = 2000, damp::Float64 = 0.5)
    ny, nb = pp.ny, pp.nb
    x, P, Pd = build_kernels(pp, theta)
    y = exp.(x)
    Ey = dot(ergodic(pp, P), y)
    ydef = pp.costform === :arellano ? min.(y, pp.phi * Ey) : (1.0 - pp.psi) .* y
    b = collect(range(0.0, pp.bmax, length = nb))
    R = 1.0 + pp.rstar

    V  = zeros(nb, ny, ny)
    Vd = [util(pp, ydef[j]) / (1.0 - pp.beta) for j in 1:ny]
    q  = fill(1.0 / R, nb, ny, ny)
    d  = zeros(Bool, nb, ny, ny)
    pol = ones(Int, nb, ny, ny)

    u_def = [util(pp, ydef[j]) for j in 1:ny]
    W = zeros(nb, ny)
    Vr = zeros(nb, ny, ny)
    Vnew = similar(V)
    dnew = zeros(Bool, nb, ny, ny)
    qnew = similar(q)
    Vdnew = similar(Vd)
    iters = 0

    for it in 1:maxit
        iters = it
        fill!(W, 0.0)
        for kx in 1:ny, j in 1:ny
            p = P[kx, j]
            p == 0.0 && continue
            @inbounds @simd for ib in 1:nb
                W[ib, kx] += p * V[ib, j, kx]
            end
        end
        for kx in 1:ny
            ev0 = 0.0; evd = 0.0
            @inbounds for j in 1:ny
                ev0 += P[kx, j] * V[1, j, kx]
                evd += P[kx, j] * Vd[j]
            end
            Vdnew[kx] = u_def[kx] + pp.beta * (pp.lam * ev0 + (1.0 - pp.lam) * evd)
        end
        Threads.@threads for ix in 1:ny
            vcont = Vector{Float64}(undef, nb)
            rev = Vector{Float64}(undef, nb)
            @inbounds for ibp in 1:nb
                vcont[ibp] = pp.beta * W[ibp, ix]
            end
            @inbounds for ihh in 1:ny
                for ibp in 1:nb
                    rev[ibp] = q[ibp, ix, ihh] * b[ibp]
                end
                for ib in 1:nb
                    res = y[ix] - b[ib]
                    best = -Inf; ibest = 1
                    for ibp in 1:nb
                        c = res + rev[ibp]
                        val = (c > 1e-8 ? c^(1.0 - pp.gamma) / (1.0 - pp.gamma) : -1e12) + vcont[ibp]
                        if val > best
                            best = val; ibest = ibp
                        end
                    end
                    Vr[ib, ix, ihh] = best
                    pol[ib, ix, ihh] = ibest
                end
            end
        end
        @inbounds for ihh in 1:ny, ix in 1:ny, ib in 1:nb
            if Vdnew[ix] > Vr[ib, ix, ihh]
                dnew[ib, ix, ihh] = true
                Vnew[ib, ix, ihh] = Vdnew[ix]
            else
                dnew[ib, ix, ihh] = false
                Vnew[ib, ix, ihh] = Vr[ib, ix, ihh]
            end
        end
        Threads.@threads for ix in 1:ny
            acc = Vector{Float64}(undef, nb)
            @inbounds for ihh in 1:ny
                fill!(acc, 0.0)
                for j in 1:ny
                    pdj = Pd[ix, ihh, j]
                    pdj == 0.0 && continue
                    @simd for ibp in 1:nb
                        acc[ibp] += pdj * (dnew[ibp, j, ix] ? 0.0 : 1.0)
                    end
                end
                for ibp in 1:nb
                    qnew[ibp, ix, ihh] = acc[ibp] / R
                end
            end
        end

        dV = maximum(abs.(Vnew .- V))
        dq = maximum(abs.(qnew .- q))
        copyto!(V, Vnew)
        copyto!(Vd, Vdnew)
        copyto!(d, dnew)
        @. q = damp * q + (1.0 - damp) * qnew
        if dV < tol && dq < tol
            break
        end
    end
    Solution(pp, x, P, y, b, V, Vd, q, d, pol, theta, iters)
end

median_(v) = (s = sort(v); n = length(s); isodd(n) ? s[(n+1)÷2] : 0.5 * (s[n÷2] + s[n÷2+1]))
mean_(v) = sum(v) / length(v)
std_(v) = (mu = mean_(v); sqrt(sum((v .- mu) .^ 2) / (length(v) - 1)))

function winsorize(v::Vector{Float64}, p::Float64)
    s = sort(v)
    n = length(s)
    lo = s[max(1, ceil(Int, p * n))]
    hi = s[min(n, floor(Int, (1 - p) * n) + 1)]
    clamp.(v, lo, hi)
end

function demean_within(v::Vector{Float64}, id::Vector{Int})
    sums = Dict{Int,Float64}()
    cnts = Dict{Int,Int}()
    for (i, g) in enumerate(id)
        sums[g] = get(sums, g, 0.0) + v[i]
        cnts[g] = get(cnts, g, 0) + 1
    end
    out = similar(v)
    for (i, g) in enumerate(id)
        out[i] = v[i] - sums[g] / cnts[g]
    end
    out
end

function simulate(sol::Solution; T::Int = 500_000, burn::Int = 1_000, seed::Int = 20260703)
    pp = sol.pp
    ny = pp.ny
    rngx = Xoshiro(seed)
    rngd = Xoshiro(seed + 1)
    cumP = cumsum(sol.P, dims = 2)
    n = T + burn
    ix = Vector{Int}(undef, n)
    ix[1] = (ny + 1) ÷ 2
    for t in 2:n
        u = rand(rngx)
        row = view(cumP, ix[t-1], :)
        ix[t] = min(searchsortedfirst(row, u), ny)
    end
    ih = similar(ix)
    ih[1] = ix[1]
    ih[2:end] = ix[1:end-1]

    ib = ones(Int, n)
    access = trues(n)
    dflt = falses(n)
    for t in 1:n-1
        if access[t]
            if sol.d[ib[t], ix[t], ih[t]]
                dflt[t] = true
                access[t+1] = false
                ib[t+1] = 1
            else
                ib[t+1] = sol.pol[ib[t], ix[t], ih[t]]
                access[t+1] = true
            end
        else
            ib[t+1] = 1
            access[t+1] = rand(rngd) < pp.lam
        end
    end

    sl = burn+1:n
    ixs = ix[sl]; ihs = ih[sl]; ibs = ib[sl]
    acc = access[sl]; dfl = dflt[sl]
    issue = acc .& .!dfl
    ibp = [issue[t] ? sol.pol[ibs[t], ixs[t], ihs[t]] : 1 for t in 1:T]
    qpath = [sol.q[ibp[t], ixs[t], ihs[t]] for t in 1:T]
    spr = [spread_annual(pp, qv) for qv in qpath]
    news = sol.x[ixs] .- sol.x[ihs]
    debty = sol.b[ibs] ./ sol.y[ixs]

    m = findall(issue)
    sprbp = winsorize(spr[m] .* 1e4, 0.01)
    nu = news[m]
    cellid = ibp[m] .* (ny + 1) .+ ixs[m]
    spr_dm = demean_within(sprbp, cellid)
    nu_dm = demean_within(nu, cellid)
    beta_news = dot(nu_dm, spr_dm) / dot(nu_dm, nu_dm)

    moments = Dict(
        "median_spread" => median_(spr[m]),
        "sd_spread" => std_(sprbp) / 1e4,
        "mean_debt_y" => mean_(debty[acc]),
        "defaults_per_100y" => sum(dfl) / (T / 400.0),
        "sd_news" => std_(news[m]),
        "bp_per_1sd_news" => beta_news * std_(news[m]),
        "frac_access" => mean_(Float64.(acc)),
    )
    paths = (ix = ixs, ih = ihs, ib = ibs, ibp = ibp, acc = acc, dfl = dfl,
             issue = issue, spr = spr, news = news)
    moments, paths
end

"Reversal-quarter default hazard: three or more consecutive up-moves in x
followed by a down-move, hazard measured in the reversal quarter."
function reversal_hazard(p)
    ix = p.ix
    n = length(ix)
    ev = Int[]
    for t in 6:(n - 9)
        if ix[t] - ix[t-1] < 0 && ix[t-1] - ix[t-2] > 0 &&
           ix[t-2] - ix[t-3] > 0 && ix[t-3] - ix[t-4] > 0
            push!(ev, t)
        end
    end
    isempty(ev) ? (0.0, 0) : (mean_(Float64.(p.dfl[ev])), length(ev))
end

function monotonicity_check(s::Solution)
    ny, nb = s.pp.ny, s.pp.nb
    viol_x = 0
    for ihh in 1:ny, ib in 1:nb
        for j in 1:ny-1
            if s.d[ib, j, ihh] < s.d[ib, j+1, ihh]
                viol_x += 1
                break
            end
        end
    end
    viol_b = 0
    for ihh in 1:ny, ix in 1:ny
        for i in 1:nb-1
            if s.d[i, ix, ihh] > s.d[i+1, ix, ihh]
                viol_b += 1
                break
            end
        end
    end
    Dict("frac_viol_x" => viol_x / (ny * nb), "frac_viol_b" => viol_b / (ny * ny))
end

fmt(x, d) = replace(string(round(x, digits = d)), r"\.0+$" => d == 0 ? "" : "")
function fmt1(x)
    s = string(round(x, digits = 1))
    endswith(s, ".0") ? s : s
end

function main()
    t0 = time()
    res = Dict{String,Any}()

    # ---- (1) grid-doubling ------------------------------------------------
    println("grid-doubling checks (ny = 31, nb = 400) ..."); flush(stdout)
    gd = Dict{String,Any}()
    ppgd = Pars(ny = 31, nb = 400)
    gdhaz = Dict{Float64,Float64}()
    for th in [0.0, 0.5, 1.0]
        s = solve(ppgd, th)
        mom, p = simulate(s)
        haz, nev = reversal_hazard(p)
        gdhaz[th] = haz
        gd["theta_$(th)"] = Dict("moments" => mom,
                                 "monotone" => monotonicity_check(s),
                                 "reversal_hazard" => haz, "n_events" => nev,
                                 "iters" => s.iters)
        println("  theta=$th done ($(s.iters) iters, haz=$(round(haz*100, digits=1))%, $(round(time()-t0)) s)")
        flush(stdout)
    end
    res["grid_doubled"] = gd

    # ---- (2) alternative default cost ------------------------------------
    println("alternative (proportional) default cost ..."); flush(stdout)
    alt = Dict{String,Any}()
    for psi in [0.02, 0.05]
        ppalt = Pars(costform = :prop, psi = psi)
        s = solve(ppalt, 0.5)
        mom, _ = simulate(s; T = 200_000)
        alt["psi_$(psi)"] = Dict("moments" => mom,
                                 "monotone" => monotonicity_check(s))
        println("  psi=$psi done")
        flush(stdout)
    end
    res["alt_cost"] = alt

    # ---- (3) recalibration of (beta, phi) at theta = 0.5 -------------------
    println("recalibration grid search ..."); flush(stdout)
    target_def = 3.0    # defaults per century (Arellano 2008 target)
    target_debt = 5.5   # debt service to output, percent
    best = nothing
    grid_rows = Any[]
    for beta in [0.945, 0.953, 0.961, 0.969, 0.977],
        phi in [0.880, 0.895, 0.910, 0.925, 0.945, 0.969]
        pp = Pars(beta = beta, phi = phi)
        s = solve(pp, 0.5)
        mom, _ = simulate(s; T = 200_000)
        def = mom["defaults_per_100y"]
        dby = mom["mean_debt_y"] * 100.0
        loss = 4.0 * ((def - target_def) / target_def)^2 + ((dby - target_debt) / target_debt)^2
        push!(grid_rows, Dict("beta" => beta, "phi" => phi, "def" => def,
                              "debty" => dby, "loss" => loss,
                              "mono" => monotonicity_check(s)))
        if best === nothing || loss < best[1]
            best = (loss, beta, phi)
        end
        println("  beta=$beta phi=$phi def=$(round(def, digits=1)) debty=$(round(dby, digits=1)) loss=$(round(loss, digits=3))")
        flush(stdout)
    end
    res["recal_grid"] = grid_rows
    _, bbest, pbest = best
    res["recal_best"] = Dict("beta" => bbest, "phi" => pbest)
    println("best: beta=$bbest phi=$pbest"); flush(stdout)

    # final pair at recalibrated parameters, full simulation and event study
    println("final recalibrated pair ..."); flush(stdout)
    ppre = Pars(beta = bbest, phi = pbest)
    fin = Dict{String,Any}()
    hazs = Dict{Float64,Float64}()
    for th in [0.0, 0.5]
        s = solve(ppre, th)
        mom, p = simulate(s)
        haz, nev = reversal_hazard(p)
        hazs[th] = haz
        fin["theta_$(th)"] = Dict("moments" => mom,
                                  "monotone" => monotonicity_check(s),
                                  "reversal_hazard" => haz, "n_events" => nev)
        println("  theta=$th: def=$(round(mom["defaults_per_100y"], digits=1)), haz=$(round(haz*100, digits=1))%")
        flush(stdout)
    end
    res["recal_final"] = fin
    res["runtime_sec"] = time() - t0

    clean(o) = o
    clean(o::AbstractFloat) = isfinite(o) ? o : nothing
    clean(o::AbstractDict) = Dict(k => clean(v) for (k, v) in o)
    clean(o::AbstractVector) = [clean(v) for v in o]
    open(joinpath(OUTDIR, "robustness.json"), "w") do f
        JSON.print(f, clean(res), 1)
    end

    # ---- macros ------------------------------------------------------------
    g5 = gd["theta_0.5"]; g0 = gd["theta_0.0"]; g1 = gd["theta_1.0"]
    mono_max_05 = max(g0["monotone"]["frac_viol_x"], g0["monotone"]["frac_viol_b"],
                      g5["monotone"]["frac_viol_x"], g5["monotone"]["frac_viol_b"])
    mono_one = max(g1["monotone"]["frac_viol_x"], g1["monotone"]["frac_viol_b"])
    alt_max = maximum([max(v["monotone"]["frac_viol_x"], v["monotone"]["frac_viol_b"])
                       for v in values(alt)])
    f5 = fin["theta_0.5"]["moments"]; f0 = fin["theta_0.0"]["moments"]
    comma(x) = replace(string(x), r"(\d)(?=(\d{3})+$)" => s"\1,")
    lines = String[
        "% generated by robustness.jl",
        "\\newcommand{\\NewsBpDiagGD}{$(comma(string(abs(round(Int, g5["moments"]["bp_per_1sd_news"])))))}",
        "\\newcommand{\\SprSdDiagGD}{$(fmt(g5["moments"]["sd_spread"] * 100, 1))}",
        "\\newcommand{\\SprMedDiagGD}{$(fmt(g5["moments"]["median_spread"] * 100, 1))}",
        "\\newcommand{\\DefFreqDiagGD}{$(fmt(g5["moments"]["defaults_per_100y"], 1))}",
        "\\newcommand{\\NewsBpREGD}{$(fmt(g0["moments"]["bp_per_1sd_news"], 1))}",
        "\\newcommand{\\MonoViolGDpct}{$(fmt(mono_max_05 * 100, 2))}",
        "\\newcommand{\\MonoViolGDOnepct}{$(fmt(mono_one * 100, 2))}",
        "\\newcommand{\\MonoViolAltpct}{$(fmt(alt_max * 100, 2))}",
        "\\newcommand{\\BetaRecal}{$(fmt(bbest, 3))}",
        "\\newcommand{\\PhiRecal}{$(fmt(pbest, 3))}",
        "\\newcommand{\\DefFreqRecal}{$(fmt(f5["defaults_per_100y"], 1))}",
        "\\newcommand{\\DefFreqRecalRE}{$(fmt(f0["defaults_per_100y"], 1))}",
        "\\newcommand{\\DebtYRecal}{$(fmt(f5["mean_debt_y"] * 100, 1))}",
        "\\newcommand{\\SprMedRecal}{$(fmt(f5["median_spread"] * 100, 1))}",
        "\\newcommand{\\SprSdRecal}{$(fmt(f5["sd_spread"] * 100, 1))}",
        "\\newcommand{\\NewsBpRecalAbs}{$(comma(string(abs(round(Int, f5["bp_per_1sd_news"])))))}",
        "\\newcommand{\\HazPeakRecalDiag}{$(fmt(hazs[0.5] * 100, 1))}",
        "\\newcommand{\\HazPeakRecalRE}{$(fmt(hazs[0.0] * 100, 1))}",
        "\\newcommand{\\FracAccessRecal}{$(fmt(f5["frac_access"] * 100, 1))}",
        "\\newcommand{\\HazPeakDiagGD}{$(fmt(gdhaz[0.5] * 100, 1))}",
        "\\newcommand{\\HazPeakREGD}{$(fmt(gdhaz[0.0] * 100, 1))}",
    ]
    open(joinpath(OUTDIR, "robust_numbers.tex"), "w") do f
        for l in lines
            println(f, l)
        end
    end
    println("saved robustness.json and robust_numbers.tex ($(round(time()-t0)) s total)")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
