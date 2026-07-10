# Diagnostic Sovereign Risk: quantitative model.
#
# Solves an Eaton-Gersovitz / Arellano (2008) one-period-bond sovereign
# default model in which competitive risk-neutral lenders price debt under
# diagnostic expectations (Bordalo-Gennaioli-Shleifer 2018). Lenders' one-step
# density for log income x' is the true AR(1) kernel tilted by the likelihood
# ratio [p(x'|x)/p(x'|h)]^theta, h = lagged log income. In the Gaussian case
# this shifts the conditional mean to rho*x + theta*rho*(x-h) and leaves the
# variance unchanged, so the lenders' belief state is (x, h).
#
# State: (b, x, h), b = debt due (>= 0), x = log y_t, h = log y_{t-1}.
# The sovereign is rational; only market pricing is diagnostic.
#
# Run:  julia --project=. -t auto solve_model.jl
# Outputs: ../output/results.json

using LinearAlgebra
using Random
using SpecialFunctions: erfc
using JSON

const OUTDIR = joinpath(@__DIR__, "..", "output")
mkpath(OUTDIR)

# --------------------------------------------------------------------------
# Calibration (Arellano 2008, quarterly, Argentina)
# --------------------------------------------------------------------------
const GAMMA = 2.0      # CRRA
const BETA  = 0.953    # discount factor
const RSTAR = 0.017    # quarterly risk-free rate
const RHO   = 0.945    # AR(1) log income
const SIGE  = 0.025    # sd of income innovation
const LAM   = 0.282    # re-entry probability
const PHI   = 0.969    # default cost: y_def = min(y, PHI * E[y])

const NY = 21          # income grid points
const MT = 3.0         # Tauchen span in unconditional sds
const NB = 200         # debt grid points
const BMAX = 0.35      # debt upper bound (quarterly output units)

const THETAS = [0.0, 0.5, 1.0]
const SEED = 20260703
const TSIM = 500_000
const TBURN = 1_000
const CMIN = 1e-8

Phi(z) = 0.5 * erfc(-z / sqrt(2.0))

function tauchen_grid()
    stdx = SIGE / sqrt(1.0 - RHO^2)
    collect(range(-MT * stdx, MT * stdx, length = NY))
end

"Transition rows onto grid x for N(means[i], SIGE^2)."
function transition_from_means(x::Vector{Float64}, means::Vector{Float64})
    step = x[2] - x[1]
    P = zeros(length(means), NY)
    for i in eachindex(means)
        z = (x .- means[i]) ./ SIGE
        for j in 2:NY-1
            P[i, j] = Phi(z[j] + 0.5 * step / SIGE) - Phi(z[j] - 0.5 * step / SIGE)
        end
        P[i, 1] = Phi(z[1] + 0.5 * step / SIGE)
        P[i, NY] = 1.0 - Phi(z[NY] - 0.5 * step / SIGE)
    end
    P
end

"True kernel P[x, x'] and diagnostic kernel Pd[x, h, x']."
function build_kernels(theta::Float64)
    x = tauchen_grid()
    P = transition_from_means(x, RHO .* x)
    Pd = zeros(NY, NY, NY)
    for ih in 1:NY
        means = RHO .* x .+ theta * RHO .* (x .- x[ih])
        Pd[:, ih, :] = transition_from_means(x, means)
    end
    x, P, Pd
end

function util(c::Float64)
    if c >= CMIN
        return c^(1.0 - GAMMA) / (1.0 - GAMMA)
    end
    umin = CMIN^(1.0 - GAMMA) / (1.0 - GAMMA)
    marginal = CMIN^(-GAMMA)
    umin + marginal * (c - CMIN)
end

function ergodic(P::Matrix{Float64})
    piv = fill(1.0 / NY, NY)
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

spread_annual(qv::Float64) = (1.0 / max(qv, 1e-6))^4 - (1.0 + RSTAR)^4

# --------------------------------------------------------------------------
# Model solution
# --------------------------------------------------------------------------
struct Solution
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

function solve(theta::Float64; bceil::Float64 = Inf, tol::Float64 = 5e-8,
               maxit::Int = 2000, damp::Float64 = 0.5,
               q0::Union{Symbol,Array{Float64,3}} = :riskfree)
    x, P, Pd = build_kernels(theta)
    y = exp.(x)
    Ey = dot(ergodic(P), y)
    ydef = min.(y, PHI * Ey)
    b = collect(range(0.0, BMAX, length = NB))
    nbmax = something(findlast(bb -> bb <= bceil + 1e-12, b), 1)
    R = 1.0 + RSTAR

    V  = zeros(NB, NY, NY)
    Vd = [util(ydef[j]) / (1.0 - BETA) for j in 1:NY]
    q = if q0 === :riskfree
        fill(1.0 / R, NB, NY, NY)
    elseif q0 === :zero
        zeros(NB, NY, NY)
    elseif q0 isa Array{Float64,3}
        size(q0) == (NB, NY, NY) || throw(DimensionMismatch("q0 has the wrong dimensions"))
        copy(q0)
    else
        throw(ArgumentError("q0 must be :riskfree, :zero, or a price array"))
    end
    d  = zeros(Bool, NB, NY, NY)
    pol = ones(Int, NB, NY, NY)

    u_def = util.(ydef)
    W = zeros(NB, NY)
    Vr = zeros(NB, NY, NY)
    Vnew = similar(V)
    dnew = zeros(Bool, NB, NY, NY)
    qnew = similar(q)
    Vdnew = similar(Vd)
    iters = 0

    for it in 1:maxit
        iters = it
        # W(b', x) = E_true[V(b', x', h'=x) | x]
        fill!(W, 0.0)
        for kx in 1:NY, j in 1:NY
            p = P[kx, j]
            p == 0.0 && continue
            @inbounds @simd for ib in 1:NB
                W[ib, kx] += p * V[ib, j, kx]
            end
        end
        # default value: Vd(x) = u(ydef) + beta * E[ lam V(0,x',x) + (1-lam) Vd(x') | x ]
        for kx in 1:NY
            ev0 = 0.0; evd = 0.0
            @inbounds for j in 1:NY
                ev0 += P[kx, j] * V[1, j, kx]
                evd += P[kx, j] * Vd[j]
            end
            Vdnew[kx] = u_def[kx] + BETA * (LAM * ev0 + (1.0 - LAM) * evd)
        end
        # repayment value and policy
        Threads.@threads for ix in 1:NY
            vcont = Vector{Float64}(undef, NB)
            rev = Vector{Float64}(undef, NB)
            @inbounds for ibp in 1:NB
                vcont[ibp] = BETA * W[ibp, ix]
            end
            @inbounds for ihh in 1:NY
                for ibp in 1:NB
                    rev[ibp] = q[ibp, ix, ihh] * b[ibp]
                end
                for ib in 1:NB
                    res = y[ix] - b[ib]
                    best = -Inf; ibest = 1
                    for ibp in 1:nbmax
                        val = util(res + rev[ibp]) + vcont[ibp]
                        if val > best
                            best = val; ibest = ibp
                        end
                    end
                    Vr[ib, ix, ihh] = best
                    pol[ib, ix, ihh] = ibest
                end
            end
        end
        # default decision and value
        @inbounds for ihh in 1:NY, ix in 1:NY, ib in 1:NB
            if Vdnew[ix] > Vr[ib, ix, ihh]
                dnew[ib, ix, ihh] = true
                Vnew[ib, ix, ihh] = Vdnew[ix]
            else
                dnew[ib, ix, ihh] = false
                Vnew[ib, ix, ihh] = Vr[ib, ix, ihh]
            end
        end
        # price update: q(b', x, h) = E_diag[1 - d(b', x', h'=x) | x, h] / R
        Threads.@threads for ix in 1:NY
            acc = Vector{Float64}(undef, NB)
            @inbounds for ihh in 1:NY
                fill!(acc, 0.0)
                for j in 1:NY
                    pdj = Pd[ix, ihh, j]
                    pdj == 0.0 && continue
                    @simd for ibp in 1:NB
                        acc[ibp] += pdj * (dnew[ibp, j, ix] ? 0.0 : 1.0)
                    end
                end
                for ibp in 1:NB
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
    Solution(x, P, y, b, V, Vd, q, d, pol, theta, iters)
end

"Evaluate one undamped Bellman-price update at a computed solution."
function fixed_point_residual(sol::Solution; bceil::Float64 = Inf)
    _, _, Pd = build_kernels(sol.theta)
    y, b, P, q, V, Vd = sol.y, sol.b, sol.P, sol.q, sol.V, sol.Vd
    Ey = dot(ergodic(P), y)
    ydef = min.(y, PHI * Ey)
    nbmax = something(findlast(bb -> bb <= bceil + 1e-12, b), 1)
    R = 1.0 + RSTAR

    W = zeros(NB, NY)
    for ix in 1:NY, j in 1:NY
        p = P[ix, j]
        @inbounds @simd for ib in 1:NB
            W[ib, ix] += p * V[ib, j, ix]
        end
    end

    Vdnew = similar(Vd)
    for ix in 1:NY
        ev0 = 0.0
        evd = 0.0
        @inbounds for j in 1:NY
            ev0 += P[ix, j] * V[1, j, ix]
            evd += P[ix, j] * Vd[j]
        end
        Vdnew[ix] = util(ydef[ix]) + BETA * (LAM * ev0 + (1.0 - LAM) * evd)
    end

    Vnew = similar(V)
    dnew = similar(sol.d)
    @inbounds for ih in 1:NY, ix in 1:NY, ib in 1:NB
        best = -Inf
        for ibp in 1:nbmax
            c = y[ix] + q[ibp, ix, ih] * b[ibp] - b[ib]
            best = max(best, util(c) + BETA * W[ibp, ix])
        end
        if Vdnew[ix] > best
            Vnew[ib, ix, ih] = Vdnew[ix]
            dnew[ib, ix, ih] = true
        else
            Vnew[ib, ix, ih] = best
            dnew[ib, ix, ih] = false
        end
    end

    qnew = similar(q)
    @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:NB
        repayment = 0.0
        for j in 1:NY
            repayment += Pd[ix, ih, j] * (dnew[ibp, j, ix] ? 0.0 : 1.0)
        end
        qnew[ibp, ix, ih] = repayment / R
    end

    Dict(
        "bellman" => max(maximum(abs.(Vnew .- V)), maximum(abs.(Vdnew .- Vd))),
        "price" => maximum(abs.(qnew .- q)),
        "default_policy_changes" => count(dnew .!= sol.d),
    )
end

"Smallest consumption chosen in repayment states."
function minimum_repayment_consumption(sol::Solution)
    cmin = Inf
    @inbounds for ih in 1:NY, ix in 1:NY, ib in 1:NB
        sol.d[ib, ix, ih] && continue
        ibp = sol.pol[ib, ix, ih]
        c = sol.y[ix] + sol.q[ibp, ix, ih] * sol.b[ibp] - sol.b[ib]
        cmin = min(cmin, c)
    end
    cmin
end

# --------------------------------------------------------------------------
# Simulation under the TRUE income process (two rng streams so the x path
# is identical across theta)
# --------------------------------------------------------------------------
function simulate(sol::Solution; T::Int = TSIM, burn::Int = TBURN, seed::Int = SEED)
    rngx = Xoshiro(seed)
    rngd = Xoshiro(seed + 1)
    cumP = cumsum(sol.P, dims = 2)
    n = T + burn
    ix = Vector{Int}(undef, n)
    ix[1] = (NY + 1) ÷ 2
    for t in 2:n
        u = rand(rngx)
        row = view(cumP, ix[t-1], :)
        ix[t] = min(searchsortedfirst(row, u), NY)
    end
    ih = similar(ix)
    ih[1] = ix[1]
    ih[2:end] = ix[1:end-1]

    ib = ones(Int, n)                 # index into b (1 = zero debt)
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
            access[t+1] = rand(rngd) < LAM
        end
    end

    sl = burn+1:n
    ixs = ix[sl]; ihs = ih[sl]; ibs = ib[sl]
    acc = access[sl]; dfl = dflt[sl]
    issue = acc .& .!dfl
    ibp = [issue[t] ? sol.pol[ibs[t], ixs[t], ihs[t]] : 1 for t in 1:T]
    qpath = [sol.q[ibp[t], ixs[t], ihs[t]] for t in 1:T]
    spr = spread_annual.(qpath)
    news = sol.x[ixs] .- sol.x[ihs]
    debty = sol.b[ibs] ./ sol.y[ixs]

    m = findall(issue)
    sprbp = winsorize(spr[m] .* 1e4, 0.01)
    # within-(b',x)-cell estimator: the model counterpart of conditioning on
    # debt and output nonparametrically. Under rational expectations the
    # spread is a function of (b',x) alone, so the within-cell news slope is
    # exactly zero; under diagnostic pricing it identifies the schedule shift.
    nu = news[m]
    # linear specification for contrast: picks up curvature of the spread
    # schedule even at theta = 0, unlike the within-cell estimator above
    Xlin = hcat(ones(length(m)), sol.x[ixs[m]], sol.b[ibp[m]], nu)
    blin = Xlin \ sprbp
    cellid = ibp[m] .* (NY + 1) .+ ixs[m]
    spr_dm = demean_within(sprbp, cellid)
    nu_dm = demean_within(nu, cellid)
    beta_news = dot(nu_dm, spr_dm) / dot(nu_dm, nu_dm)
    pos_dm = demean_within(max.(nu, 0.0), cellid)
    neg_dm = demean_within(min.(nu, 0.0), cellid)
    Xa = hcat(pos_dm, neg_dm)
    beta_asym = Xa \ spr_dm

    moments = Dict(
        "mean_spread" => mean(sprbp) / 1e4,
        "median_spread" => median(spr[m]),
        "sd_spread" => std(sprbp) / 1e4,
        "corr_spread_y" => cor(sprbp, sol.x[ixs[m]]),
        "mean_debt_y" => mean(debty[acc]),
        "defaults_per_100y" => sum(dfl) / (T / 400.0),
        "sd_news" => std(news[m]),
        "reg_news_bp" => beta_news,
        "bp_per_1sd_news" => beta_news * std(news[m]),
        "bp_per_1sd_news_linear" => blin[4] * std(news[m]),
        "reg_pos_bp" => beta_asym[1] * std(news[m]),
        "reg_neg_bp" => beta_asym[2] * std(news[m]),
        "frac_access" => mean(acc),
    )
    paths = (ix = ixs, ih = ihs, ib = ibs, ibp = ibp, acc = acc, dfl = dfl,
             issue = issue, spr = spr, news = news)
    moments, paths
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

function winsorize(v::Vector{Float64}, p::Float64)
    s = sort(v)
    n = length(s)
    lo = s[max(1, ceil(Int, p * n))]
    hi = s[min(n, floor(Int, (1 - p) * n) + 1)]
    clamp.(v, lo, hi)
end

function median(v)
    s = sort(v)
    n = length(s)
    isodd(n) ? s[(n+1)÷2] : 0.5 * (s[n÷2] + s[n÷2+1])
end

mean(v) = sum(v) / length(v)
function std(v)
    mu = mean(v)
    sqrt(sum((v .- mu) .^ 2) / (length(v) - 1))
end
function cor(a, b)
    ma, mb = mean(a), mean(b)
    num = sum((a .- ma) .* (b .- mb))
    num / sqrt(sum((a .- ma) .^ 2) * sum((b .- mb) .^ 2))
end

# --------------------------------------------------------------------------
# Event study around boom-reversal episodes on the COMMON x path:
# three or more consecutive up-moves in x followed by a down-move.
# --------------------------------------------------------------------------
function boom_episodes(paths_by_theta::Dict, sols::Dict; w_pre::Int = 4, w_post::Int = 8)
    ref = paths_by_theta[0.0]
    ix = ref.ix
    n = length(ix)
    ev = Int[]
    for t in 6:(n - w_post - 1)
        if ix[t] - ix[t-1] < 0 && ix[t-1] - ix[t-2] > 0 &&
           ix[t-2] - ix[t-3] > 0 && ix[t-3] - ix[t-4] > 0
            push!(ev, t)
        end
    end
    res = Dict{String,Any}()
    for (th, p) in paths_by_theta
        sol = sols[th]
        win = collect(-w_pre:w_post)
        # clean windows (market access throughout) for spread and debt paths;
        # unconditional windows for the default hazard
        clean = [t for t in ev if all(p.acc[t-w_pre:t+w_post])]
        sprm = Union{Float64,Nothing}[]
        debtm = Float64[]
        dflm = Float64[]
        sprmean = Union{Float64,Nothing}[]
        for k in win
            cidx = clean .+ k
            oks = [i for i in cidx if p.issue[i]]
            push!(sprm, isempty(oks) ? nothing : median(p.spr[oks]))
            push!(sprmean, isempty(oks) ? nothing :
                  mean(winsorize(collect(p.spr[oks]), 0.01)))
            push!(debtm, isempty(cidx) ? NaN : mean(sol.b[p.ib[cidx]]))
            idx = ev .+ k
            push!(dflm, mean(Float64.(p.dfl[idx])))
        end
        res["theta_$(th)"] = Dict("win" => win, "spread" => sprm,
                                  "spread_mean" => sprmean,
                                  "debt" => debtm, "default_haz" => dflm,
                                  "n_events" => length(ev),
                                  "n_clean" => length(clean))
    end
    res
end

"Check Assumption M in the computed equilibrium: default nonincreasing in x
(for fixed b, h) and nondecreasing in b (for fixed x, h)."
function monotonicity_check(s::Solution)
    viol_x = 0
    for ihh in 1:NY, ib in 1:NB
        for j in 1:NY-1
            if s.d[ib, j, ihh] < s.d[ib, j+1, ihh]
                viol_x += 1
                break
            end
        end
    end
    viol_b = 0
    for ihh in 1:NY, ix in 1:NY
        for i in 1:NB-1
            if s.d[i, ix, ihh] > s.d[i+1, ix, ihh]
                viol_b += 1
                break
            end
        end
    end
    Dict("frac_viol_x" => viol_x / (NY * NB), "frac_viol_b" => viol_b / (NY * NY))
end

# Model-implied Coibion-Gorodnichenko coefficient at horizon one
# (BGMS fixed-target convention).
cg_coefficient(theta) = -theta * (1 + theta) / ((1 + theta)^2 + theta^2 * RHO^2)

# Consumption-equivalent gain of V1 over V0 (CRRA, gamma != 1).
welfare_ce(V1, V0) = (V1 / V0)^(1.0 / (1.0 - GAMMA)) - 1.0

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
function main()
    t0 = time()
    results = Dict{String,Any}(
        "calibration" => Dict("gamma" => GAMMA, "beta" => BETA, "rstar" => RSTAR,
                              "rho" => RHO, "sige" => SIGE, "lam" => LAM,
                              "phi" => PHI, "NY" => NY, "NB" => NB, "BMAX" => BMAX),
        "threads" => Threads.nthreads(),
    )
    sols = Dict{Float64,Solution}()
    paths = Dict{Float64,Any}()
    for th in THETAS
        println("solving theta=$th ..."); flush(stdout)
        s = solve(th)
        sols[th] = s
        mom, p = simulate(s)
        paths[th] = p
        mom["cg_beta"] = cg_coefficient(th)
        mom["iters"] = s.iters
        mom["fixed_point_residual"] = fixed_point_residual(s)
        results["theta_$(th)"] = mom
        results["monotone_theta_$(th)"] = monotonicity_check(s)
        println("  done in $(s.iters) iters"); flush(stdout)
    end

    s5_zero = solve(0.5; q0 = :zero)
    s5_rational = solve(0.5; q0 = sols[0.0].q)
    results["initialization_check"] = Dict(
        "riskfree_vs_zero_q" => maximum(abs.(sols[0.5].q .- s5_zero.q)),
        "riskfree_vs_rational_q" => maximum(abs.(sols[0.5].q .- s5_rational.q)),
        "riskfree_vs_zero_default_changes" => count(sols[0.5].d .!= s5_zero.d),
        "riskfree_vs_rational_default_changes" => count(sols[0.5].d .!= s5_rational.d),
    )

    results["boom_events"] = boom_episodes(paths, sols)

    # price schedules and default boundaries for figures
    s5 = sols[0.5]; s0 = sols[0.0]
    ixm = (NY + 1) ÷ 2
    stp = 3
    ih_lo = ixm + stp   # h > x: arrived from above, bad news
    ih_hi = ixm - stp   # h < x: arrived from below, good news
    results["fig_price"] = Dict(
        "b" => s5.b,
        "q_re" => s0.q[:, ixm, ixm],
        "q_good" => s5.q[:, ixm, ih_hi],
        "q_neutral" => s5.q[:, ixm, ixm],
        "q_bad" => s5.q[:, ixm, ih_lo],
        "news_size" => s5.x[ixm] - s5.x[ih_hi],
    )

    function boundary(sol::Solution, ih_of_ix::Function)
        bnd = Union{Float64,Nothing}[]
        for i in 1:NY
            dd = view(sol.d, :, i, ih_of_ix(i))
            k = findfirst(dd)
            push!(bnd, k === nothing ? nothing : sol.b[k])
        end
        bnd
    end
    results["fig_defaultset"] = Dict(
        "y" => exp.(s5.x),
        "b_re" => boundary(s0, i -> i),
        "b_good" => boundary(s5, i -> max(i - stp, 1)),
        "b_bad" => boundary(s5, i -> min(i + stp, NY)),
    )

    # fiscal rule: debt ceilings
    ceil_grid = [0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10]
    rule = Dict{String,Any}()
    for th in [0.0, 0.5]
        base = sols[th]
        v0 = base.V[1, ixm, ixm]
        rows = Any[]
        for bc in ceil_grid
            sr = solve(th; bceil = bc)
            ce = welfare_ce(sr.V[1, ixm, ixm], v0)
            momr, _ = simulate(sr; T = 200_000)
            push!(rows, Dict("ceiling" => bc, "ce_pct" => ce * 100.0,
                             "mean_debt_y" => momr["mean_debt_y"],
                             "defaults_per_100y" => momr["defaults_per_100y"],
                             "mean_spread" => momr["mean_spread"]))
            println("  theta=$th ceiling=$bc: CE=$(round(ce*100, digits=4))%")
            flush(stdout)
        end
        rule["theta_$(th)"] = rows
    end
    results["rule"] = rule
    results["runtime_sec"] = time() - t0

    clean(o) = o
    clean(o::AbstractFloat) = isfinite(o) ? o : nothing
    clean(o::AbstractDict) = Dict(k => clean(v) for (k, v) in o)
    clean(o::AbstractVector) = [clean(v) for v in o]

    open(joinpath(OUTDIR, "results.json"), "w") do f
        JSON.print(f, clean(results), 1)
    end
    println("saved results.json ($(round(time()-t0, digits=0))s total)")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
