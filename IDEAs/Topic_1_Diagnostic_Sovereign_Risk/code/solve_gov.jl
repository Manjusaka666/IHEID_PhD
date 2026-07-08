# Diagnostic Sovereign Risk: who holds the distorted beliefs?
#
# Solves the model for the 2x2 of (government beliefs) x (lender beliefs),
# each rational (theta = 0) or diagnostic (theta = 0.5). The government's
# Bellman equation uses its own (possibly diagnostic) kernel; lenders price
# with theirs. True welfare of the induced policies is computed by policy
# evaluation under the true kernel, so the welfare numbers are comparable
# across cells. Debt-ceiling experiments run in every cell.
#
# Run (after solve_model.jl exists in this folder):
#   julia --project=. -t auto solve_gov.jl
# Outputs: ../output/results_gov.json

include("solve_model.jl")

const THETA_D = 0.5

"Solve with government kernel Pg and lender kernel Pl (both [x,h,x'])."
function solve_general(theta_gov::Float64, theta_lend::Float64;
                       bceil::Float64 = Inf, tol::Float64 = 5e-8,
                       maxit::Int = 2000, damp::Float64 = 0.5)
    x, P, Pg = build_kernels(theta_gov)
    _, _, Pl = build_kernels(theta_lend)
    y = exp.(x)
    Ey = dot(ergodic(P), y)
    ydef = min.(y, PHI * Ey)
    b = collect(range(0.0, BMAX, length = NB))
    nbmax = something(findlast(bb -> bb <= bceil + 1e-12, b), 1)
    R = 1.0 + RSTAR

    V   = zeros(NB, NY, NY)
    Vd2 = zeros(NY, NY)                      # default value: (x, h)
    for ihh in 1:NY, ix in 1:NY
        Vd2[ix, ihh] = util(ydef[ix]) / (1.0 - BETA)
    end
    q   = fill(1.0 / R, NB, NY, NY)
    d   = zeros(Bool, NB, NY, NY)
    pol = ones(Int, NB, NY, NY)

    u_def = util.(ydef)
    W = zeros(NB, NY, NY)
    Vr = zeros(NB, NY, NY)
    Vnew = similar(V)
    dnew = zeros(Bool, NB, NY, NY)
    qnew = similar(q)
    Vd2new = similar(Vd2)
    iters = 0

    for it in 1:maxit
        iters = it
        # W(b', x, h) = E_gov[V(b', x', h'=x) | x, h]
        Threads.@threads for ix in 1:NY
            @inbounds for ihh in 1:NY
                for ibp in 1:NB
                    W[ibp, ix, ihh] = 0.0
                end
                for j in 1:NY
                    p = Pg[ix, ihh, j]
                    p == 0.0 && continue
                    @simd for ibp in 1:NB
                        W[ibp, ix, ihh] += p * V[ibp, j, ix]
                    end
                end
            end
        end
        # default value under government beliefs
        @inbounds for ihh in 1:NY, ix in 1:NY
            ev0 = 0.0; evd = 0.0
            for j in 1:NY
                p = Pg[ix, ihh, j]
                ev0 += p * V[1, j, ix]
                evd += p * Vd2[j, ix]
            end
            Vd2new[ix, ihh] = u_def[ix] + BETA * (LAM * ev0 + (1.0 - LAM) * evd)
        end
        # repayment value and policy
        Threads.@threads for ix in 1:NY
            rev = Vector{Float64}(undef, NB)
            @inbounds for ihh in 1:NY
                for ibp in 1:NB
                    rev[ibp] = q[ibp, ix, ihh] * b[ibp]
                end
                for ib in 1:NB
                    res = y[ix] - b[ib]
                    best = -Inf; ibest = 1
                    for ibp in 1:nbmax
                        val = util(res + rev[ibp]) + BETA * W[ibp, ix, ihh]
                        if val > best
                            best = val; ibest = ibp
                        end
                    end
                    Vr[ib, ix, ihh] = best
                    pol[ib, ix, ihh] = ibest
                end
            end
        end
        @inbounds for ihh in 1:NY, ix in 1:NY, ib in 1:NB
            if Vd2new[ix, ihh] > Vr[ib, ix, ihh]
                dnew[ib, ix, ihh] = true
                Vnew[ib, ix, ihh] = Vd2new[ix, ihh]
            else
                dnew[ib, ix, ihh] = false
                Vnew[ib, ix, ihh] = Vr[ib, ix, ihh]
            end
        end
        # lender pricing
        Threads.@threads for ix in 1:NY
            acc = Vector{Float64}(undef, NB)
            @inbounds for ihh in 1:NY
                fill!(acc, 0.0)
                for j in 1:NY
                    pdj = Pl[ix, ihh, j]
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
        copyto!(Vd2, Vd2new)
        copyto!(d, dnew)
        @. q = damp * q + (1.0 - damp) * qnew
        if dV < tol && dq < tol
            break
        end
    end
    sol = Solution(x, P, y, b, V, zeros(NY), q, d, pol, theta_lend, iters)
    sol, Vd2
end

"True-measure welfare of the induced policies (policy evaluation under P)."
function eval_true(sol::Solution; tol::Float64 = 1e-9, maxit::Int = 5000)
    x, P, y, b, q, d, pol = sol.x, sol.P, sol.y, sol.b, sol.q, sol.d, sol.pol
    Ey = dot(ergodic(P), y)
    ydef = min.(y, PHI * Ey)
    u_def = util.(ydef)
    Wt = zeros(NB, NY, NY)
    WD = [u_def[j] / (1.0 - BETA) for j in 1:NY]
    Wtnew = similar(Wt)
    WDnew = similar(WD)
    ucur = zeros(NB, NY, NY)
    @inbounds for ihh in 1:NY, ix in 1:NY, ib in 1:NB
        ibp = pol[ib, ix, ihh]
        c = y[ix] - b[ib] + q[ibp, ix, ihh] * b[ibp]
        ucur[ib, ix, ihh] = util(c)
    end
    for _ in 1:maxit
        @inbounds for kx in 1:NY
            ev0 = 0.0; evd = 0.0
            for j in 1:NY
                ev0 += P[kx, j] * Wt[1, j, kx]
                evd += P[kx, j] * WD[j]
            end
            WDnew[kx] = u_def[kx] + BETA * (LAM * ev0 + (1.0 - LAM) * evd)
        end
        Threads.@threads for ix in 1:NY
            @inbounds for ihh in 1:NY, ib in 1:NB
                if d[ib, ix, ihh]
                    Wtnew[ib, ix, ihh] = WDnew[ix]
                else
                    ibp = pol[ib, ix, ihh]
                    cont = 0.0
                    for j in 1:NY
                        cont += P[ix, j] * Wt[ibp, j, ix]
                    end
                    Wtnew[ib, ix, ihh] = ucur[ib, ix, ihh] + BETA * cont
                end
            end
        end
        dW = maximum(abs.(Wtnew .- Wt))
        copyto!(Wt, Wtnew)
        copyto!(WD, WDnew)
        dW < tol && break
    end
    Wt
end

"Event study of debt and default hazard around boom reversals (common x path)."
function debt_events(p, sol::Solution; w_pre::Int = 4, w_post::Int = 8)
    ix = p.ix
    n = length(ix)
    ev = Int[]
    for t in 6:(n - w_post - 1)
        if ix[t] - ix[t-1] < 0 && ix[t-1] - ix[t-2] > 0 &&
           ix[t-2] - ix[t-3] > 0 && ix[t-3] - ix[t-4] > 0
            push!(ev, t)
        end
    end
    clean = [t for t in ev if all(p.acc[t-w_pre:t+w_post])]
    win = collect(-w_pre:w_post)
    debtm = Float64[]; dflm = Float64[]
    for k in win
        push!(debtm, mean(sol.b[p.ib[clean .+ k]]))
        push!(dflm, mean(Float64.(p.dfl[ev .+ k])))
    end
    Dict("win" => win, "debt" => debtm, "default_haz" => dflm,
         "n_events" => length(ev), "n_clean" => length(clean))
end

function main_gov()
    t0 = time()
    ixm = (NY + 1) ÷ 2
    cells = [("A_rat_rat", 0.0, 0.0), ("B_rat_diag", 0.0, THETA_D),
             ("C_diag_diag", THETA_D, THETA_D), ("D_diag_rat", THETA_D, 0.0)]
    ceil_grid = [0.02, 0.03, 0.04, 0.05, 0.06, 0.08, 0.10]
    results = Dict{String,Any}("theta_diag" => THETA_D,
                               "cells" => "name, theta_gov, theta_lend")
    for (name, tg, tl) in cells
        println("cell $name (gov=$tg, lend=$tl) ..."); flush(stdout)
        sol, _ = solve_general(tg, tl)
        Wt = eval_true(sol)
        w0 = Wt[1, ixm, ixm]
        mom, p = simulate(sol)
        cell = Dict{String,Any}(
            "theta_gov" => tg, "theta_lend" => tl,
            "moments" => mom, "iters" => sol.iters,
            "events" => debt_events(p, sol),
        )
        rows = Any[]
        for bc in ceil_grid
            sr, _ = solve_general(tg, tl; bceil = bc)
            Wr = eval_true(sr)
            ce = welfare_ce(Wr[1, ixm, ixm], w0)
            momr, _ = simulate(sr; T = 200_000)
            push!(rows, Dict("ceiling" => bc, "ce_pct" => ce * 100.0,
                             "mean_debt_y" => momr["mean_debt_y"],
                             "defaults_per_100y" => momr["defaults_per_100y"],
                             "median_spread" => momr["median_spread"]))
            println("  ceiling=$bc: CE=$(round(ce*100, digits=4))%"); flush(stdout)
        end
        cell["rule"] = rows
        results[name] = cell
    end
    results["runtime_sec"] = time() - t0

    clean2(o) = o
    clean2(o::AbstractFloat) = isfinite(o) ? o : nothing
    clean2(o::AbstractDict) = Dict(k => clean2(v) for (k, v) in o)
    clean2(o::AbstractVector) = [clean2(v) for v in o]

    open(joinpath(OUTDIR, "results_gov.json"), "w") do f
        JSON.print(f, clean2(results), 1)
    end
    println("saved results_gov.json ($(round(time()-t0, digits=0))s total)")
end

main_gov()
