# Endogenous Trade Fragmentation: quantitative model.
#
# Firms sourcing a key input cross-bloc face a geopolitical disruption hazard
# pi_m(F_m, F) and can friend-shore at an idiosyncratic premium g ~ H_m
# (lognormal). Three feedback channels make friend-shoring a strategic
# complement:
#   (i)   deterrence erosion:  pi_m = delta*(1 - THETA*(1 - F_m)) + ETAA*F
#         (escalation is deterred by the trade it would destroy);
#   (ii)  route thinning:      disruption loss lam_m(F_m) = lam0_m*(1 + XI*F_m);
#   (iii) capacity scale:      effective premium g*(1 - CHI*F_m).
# A firm friend-shores iff g*(1-CHI*Fm) < pi_m*lam_m, i.e. g < ghat_m. Sector
# equilibrium: F_m = f0_m + (1-f0_m)*H_m(ghat_m(F_m, F)). Folds (tipping) and
# hysteresis arise when the map's slope exceeds one.
#
# Run:  julia --project=. solve_model.jl     Output: ../output/results.json

using JSON
using SpecialFunctions: erf

const OUTDIR = joinpath(@__DIR__, "..", "output")
mkpath(OUTDIR)

# ---------------------------------------------------------------- calibration
const W_M   = [0.15, 0.35, 0.50]   # cross-bloc trade weights: critical/middle/flexible
const SIGM  = [2.0, 4.0, 8.0]      # substitution elasticities
const SSH   = [0.50, 0.35, 0.20]   # cross-bloc share in the input bundle
const DUR   = [1.5, 1.0, 0.5]      # expected disruption duration, years
const GMED  = [0.20, 0.15, 0.10]   # median friend-shoring premium (ad valorem)
const SLN   = 0.5                  # lognormal sigma of premia
const F0NG  = [0.05, 0.08, 0.10]   # pre-existing non-geopolitical diversification
const THETA = 0.6                  # share of escalations deterred at F=0
const ETAA  = 0.01                 # cross-sector (systemic) feedback
const XI    = 0.4                  # route-thinning elasticity of loss
const CHI   = 0.4                  # capacity-scale discount on the premium
const RHO   = 0.25                 # annual reconsideration rate (4-year links)
const DELTA_PRE  = 0.04            # dispute hazard, pre-2022
const DELTA_POST = 0.10            # dispute hazard, post-2022 reassessment
const ALPHA_XB   = 0.04            # cross-bloc intermediates / world GDP

lam0(m) = ((1.0 - SSH[m])^(1.0 / (1.0 - SIGM[m])) - 1.0) * DUR[m]
const LAM0 = [lam0(m) for m in 1:3]

ncdf(z) = 0.5 * (1.0 + erf(z / sqrt(2.0)))
npdf(z) = exp(-0.5 * z^2) / sqrt(2.0 * pi)
Hcdf(g, m) = g <= 0.0 ? 0.0 : ncdf((log(g) - log(GMED[m])) / SLN)
Hpdf(g, m) = g <= 0.0 ? 0.0 : npdf((log(g) - log(GMED[m])) / SLN) / (g * SLN)
# E[g 1{g<x}] for lognormal(log gmed, SLN)
Hpartial(x, m) = x <= 0.0 ? 0.0 :
    exp(log(GMED[m]) + SLN^2 / 2) * ncdf((log(x) - log(GMED[m]) - SLN^2) / SLN)

# policy levers: subs = share of premium paid by a friend-shoring subsidy;
# lscale = scale on the disruption loss (stockpiles < 1); tau = per-period
# subsidy to maintained cross-bloc trade (ad valorem)
struct Pol
    subs::Float64
    lscale::Float64
    tau::Float64
end
const NOPOL = Pol(0.0, 1.0, 0.0)

pim(Fm, F, m, del) = del * (1.0 - THETA * (1.0 - Fm)) + ETAA * F
lamm(Fm, m, pol) = LAM0[m] * pol.lscale * (1.0 + XI * Fm)

function ghat(Fm, F, m, del, pol)
    net = pim(Fm, F, m, del) * lamm(Fm, m, pol) - pol.tau
    net <= 0.0 && return 0.0
    net / ((1.0 - CHI * Fm) * (1.0 - pol.subs))
end

fmap(Fm, F, m, del, pol) = F0NG[m] + (1.0 - F0NG[m]) * Hcdf(ghat(Fm, F, m, del, pol), m)

# ---------------------------------------------------- sector/aggregate solvers
"Fixed point of sector m given aggregate F, by damped iteration from Fm0."
function solve_sector(F, m, del, pol; Fm0 = 0.1)
    Fm = Fm0
    for _ in 1:100_000
        Fm2 = fmap(Fm, F, m, del, pol)
        abs(Fm2 - Fm) < 1e-14 && return Fm2
        Fm = 0.5 * (Fm + Fm2)
    end
    Fm
end

"Aggregate F consistent with a given critical-sector value Fc (sectors 2, 3
are far from their folds and have unique fixed points)."
function agg_given_Fc(Fc, del, pol)
    F = Fc * W_M[1] + 0.1
    for _ in 1:10_000
        F2 = solve_sector(F, 2, del, pol)
        F3 = solve_sector(F, 3, del, pol)
        Fnew = W_M[1] * Fc + W_M[2] * F2 + W_M[3] * F3
        abs(Fnew - F) < 1e-13 && return Fnew
        F = 0.5 * (F + Fnew)
    end
    F
end

"All critical-sector equilibria at dispute hazard del: scan for sign changes
of R(Fc) = Fc - f_c(Fc, F(Fc)), refine by bisection, classify stability."
function equilibria(del, pol)
    R(Fc) = Fc - fmap(Fc, agg_given_Fc(Fc, del, pol), 1, del, pol)
    grid = collect(0.0:0.002:1.0)
    roots = Float64[]
    for i in 1:length(grid)-1
        a, b = grid[i], grid[i+1]
        Ra, Rb = R(a), R(b)
        if Ra == 0.0
            push!(roots, a)
        elseif Ra * Rb < 0.0
            for _ in 1:80
                c = 0.5 * (a + b)
                (R(a) * R(c) <= 0.0) ? (b = c) : (a = c)
            end
            push!(roots, 0.5 * (a + b))
        end
    end
    # stability: slope of the sector map at the root
    out = NamedTuple[]
    for r in roots
        eps = 1e-6
        T(x) = fmap(x, agg_given_Fc(x, del, pol), 1, del, pol)
        slope = (T(r + eps) - T(r - eps)) / (2 * eps)
        push!(out, (Fc = r, slope = slope, stable = slope < 1.0))
    end
    out
end

"Full-economy steady state started from initial conditions (history selects
the branch): damped simultaneous iteration."
function steady(del, pol; init = fill(0.05, 3))
    Fm = copy(init)
    for _ in 1:200_000
        F = sum(W_M .* Fm)
        Fm2 = [fmap(Fm[m], F, m, del, pol) for m in 1:3]
        if maximum(abs.(Fm2 .- Fm)) < 1e-14
            Fm = Fm2
            break
        end
        Fm = 0.5 .* (Fm .+ Fm2)
    end
    F = sum(W_M .* Fm)
    (Fm = Fm, F = F, pic = pim(Fm[1], F, 1, del))
end

# ------------------------------------------------------------------- dynamics
"Adaptive path: each year a fraction RHO of firms reconsider."
function simulate(delpath::Vector{Float64}, pol; init = fill(0.02, 3))
    T = length(delpath)
    Fm = zeros(T, 3)
    Fm[1, :] .= init
    for t in 2:T
        F = sum(W_M .* Fm[t-1, :])
        for m in 1:3
            Fm[t, m] = (1 - RHO) * Fm[t-1, m] +
                       RHO * fmap(Fm[t-1, m], F, m, delpath[t], pol)
        end
    end
    Fagg = [sum(W_M .* Fm[t, :]) for t in 1:T]
    (Fm = Fm, F = Fagg)
end

# ------------------------------------------------------------ welfare objects
"Geopolitical burden per unit of sector-m cross-bloc trade value at sector
state Fm (aggregate F), counting only geopolitically motivated switchers."
function burden(Fm, F, m, del, pol)
    gh = ghat(Fm, F, m, del, NOPOL)   # resource cost uses the undistorted premium
    ghp = ghat(Fm, F, m, del, pol)    # participation threshold under policy
    prem = (1.0 - F0NG[m]) * (1.0 - CHI * Fm) * Hpartial(ghp, m)
    exposed = (1.0 - fmap(Fm, F, m, del, pol)) * pim(Fm, F, m, del) * lamm(Fm, m, pol)
    prem + exposed
end

"Planner: minimize sector burden over Fm (threshold-implementable), given
that sectors 2, 3 and the aggregate respond as in equilibrium."
function planner(del, m)
    grid = 0.0:0.001:1.0
    best_F, best_B = 0.0, Inf
    for Fm in grid
        Fm < F0NG[m] && continue
        F = agg_given_Fc(Fm, del, NOPOL)   # for m = 1
        gh = quantile_g(Fm, m)
        prem = (1.0 - F0NG[m]) * (1.0 - CHI * Fm) * Hpartial(gh, m)
        exposed = (1.0 - Fm) * pim(Fm, F, m, del) * lamm(Fm, m, NOPOL)
        B = prem + exposed
        if B < best_B
            best_B, best_F = B, Fm
        end
    end
    (F = best_F, B = best_B)
end

"Premium threshold that implements sector share Fm."
function quantile_g(Fm, m)
    p = clamp((Fm - F0NG[m]) / (1.0 - F0NG[m]), 1e-12, 1 - 1e-12)
    # inverse lognormal cdf
    z = sqrt(2.0) * erfinv_(2p - 1.0)
    exp(log(GMED[m]) + SLN * z)
end

# rational-approx inverse erf (Winitzki), adequate for reporting
function erfinv_(x)
    a = 0.147
    ln1mx2 = log(1.0 - x^2)
    t1 = 2.0 / (pi * a) + ln1mx2 / 2.0
    sign(x) * sqrt(sqrt(t1^2 - ln1mx2 / a) - t1)
end

"Corrective per-period wedge tau on maintained cross-bloc trade that moves the
decentralized sector equilibrium to the planner's F (negative = switching
subsidy). Solved by bisection on tau."
function pigou(del, m, Ftarget; lo = -0.2, hi = 0.2)
    for _ in 1:200
        mid = 0.5 * (lo + hi)
        pol = Pol(0.0, 1.0, mid)
        s = steady(del, pol; init = fill(0.02, 3))
        # higher tau -> less exit -> lower Fm
        (s.Fm[m] > Ftarget) ? (lo = mid) : (hi = mid)
    end
    0.5 * (lo + hi)
end

# ------------------------------------------------------------------ fold scan
"Bifurcation data over a delta grid; returns branches and the fold band."
function bifurcation(pol; dgrid = collect(0.02:0.0005:0.30))
    low = fill(NaN, length(dgrid))
    mid = fill(NaN, length(dgrid))
    high = fill(NaN, length(dgrid))
    nroots = zeros(Int, length(dgrid))
    for (i, d) in enumerate(dgrid)
        eq = equilibria(d, pol)
        nroots[i] = length(eq)
        st = [e.Fc for e in eq if e.stable]
        un = [e.Fc for e in eq if !e.stable]
        if length(st) >= 1
            low[i] = minimum(st)
            high[i] = maximum(st)
        end
        if !isempty(un)
            mid[i] = un[1]
        end
    end
    multi = [i for i in eachindex(dgrid) if nroots[i] >= 3]
    band = isempty(multi) ? (NaN, NaN) : (dgrid[multi[1]], dgrid[multi[end]])
    (dgrid = dgrid, low = low, mid = mid, high = high, band = band)
end

# ---------------------------------------------------------------------- main
function main()
    results = Dict{String,Any}()
    results["calibration"] = Dict(
        "w" => W_M, "sigma" => SIGM, "s_share" => SSH, "dur" => DUR,
        "lam0" => LAM0, "gmed" => GMED, "sln" => SLN, "f0" => F0NG,
        "theta" => THETA, "etaa" => ETAA, "xi" => XI, "chi" => CHI,
        "rho" => RHO, "delta_pre" => DELTA_PRE, "delta_post" => DELTA_POST,
        "alpha_xb" => ALPHA_XB)

    # steady states pre and post 2022 (low branch: history starts low)
    pre = steady(DELTA_PRE, NOPOL; init = fill(0.02, 3))
    post = steady(DELTA_POST, NOPOL; init = pre.Fm)
    results["ss"] = Dict(
        "pre"  => Dict("Fm" => pre.Fm, "F" => pre.F, "pic" => pre.pic,
                       "pic0" => DELTA_PRE * (1 - THETA * (1 - pre.Fm[1]))),
        "post" => Dict("Fm" => post.Fm, "F" => post.F, "pic" => post.pic))

    # multipliers: equilibrium vs direct (fixed-F) response to a small d-delta
    eps = 1e-4
    postp = steady(DELTA_POST + eps, NOPOL; init = post.Fm)
    equil_dF = (postp.Fm[1] - post.Fm[1]) / eps
    gh = ghat(post.Fm[1], post.F, 1, DELTA_POST, NOPOL)
    direct_dF = (1 - F0NG[1]) * Hpdf(gh, 1) *
                (1 - THETA * (1 - post.Fm[1])) * lamm(post.Fm[1], 1, NOPOL) /
                ((1 - CHI * post.Fm[1]))
    # aggregate multiplier
    aggp = (postp.F - post.F) / eps
    direct_agg = sum((1 - F0NG[m]) *
                     Hpdf(ghat(post.Fm[m], post.F, m, DELTA_POST, NOPOL), m) *
                     (1 - THETA * (1 - post.Fm[m])) * lamm(post.Fm[m], m, NOPOL) /
                     (1 - CHI * post.Fm[m]) * W_M[m] for m in 1:3)
    results["multiplier"] = Dict(
        "crit_equil" => equil_dF, "crit_direct" => direct_dF,
        "M_crit" => equil_dF / direct_dF,
        "agg_equil" => aggp, "agg_direct" => direct_agg,
        "M_agg" => aggp / direct_agg)

    # bifurcation and fold band (baseline and policies)
    bif = bifurcation(NOPOL)
    results["bifurcation"] = Dict(
        "delta" => bif.dgrid, "low" => bif.low, "mid" => bif.mid,
        "high" => bif.high, "band_lo" => bif.band[1], "band_hi" => bif.band[2])
    # distance consumed by the 2022 reassessment
    results["distance"] = Dict(
        "fold_hi" => bif.band[2], "fold_lo" => bif.band[1],
        "consumed" => (DELTA_POST - DELTA_PRE) / (bif.band[2] - DELTA_PRE))

    # sector cascade: stable low-branch f_m over delta (from low history)
    dg2 = collect(0.02:0.002:0.30)
    casc = Dict("delta" => dg2)
    Fmprev = fill(0.02, 3)
    fm1 = Float64[]; fm2 = Float64[]; fm3 = Float64[]; fagg = Float64[]
    for d in dg2
        s = steady(d, NOPOL; init = Fmprev)   # continuation: history from below
        Fmprev = s.Fm
        push!(fm1, s.Fm[1]); push!(fm2, s.Fm[2]); push!(fm3, s.Fm[3])
        push!(fagg, s.F)
    end
    casc["f_crit"] = fm1; casc["f_mid"] = fm2; casc["f_flex"] = fm3
    casc["F_agg"] = fagg
    results["cascade"] = casc

    # S-curve data for the critical sector at three delta values
    dstar = bif.band[2]
    Fgrid = collect(0.0:0.005:1.0)
    scurve = Dict{String,Any}("F" => Fgrid, "delta_star" => dstar)
    for (tag, d) in [("pre", DELTA_PRE), ("post", DELTA_POST), ("fold", dstar)]
        scurve[tag] = [fmap(F, agg_given_Fc(F, d, NOPOL), 1, d, NOPOL) for F in Fgrid]
    end
    results["scurve"] = scurve

    # hysteresis experiment: temporary spike above the fold, return inside band
    dmid = 0.5 * (bif.band[1] + bif.band[2])
    dspike = bif.band[2] + 0.07
    T = 81
    base = fill(DELTA_POST, T)
    ctrl = copy(base); ctrl[16:end] .= dmid                    # drift up, no spike
    spik = copy(base); spik[16:27] .= dspike; spik[28:end] .= dmid
    s0 = steady(DELTA_POST, NOPOL; init = fill(0.02, 3))
    pc = simulate(ctrl, NOPOL; init = s0.Fm)
    ps = simulate(spik, NOPOL; init = s0.Fm)
    results["hysteresis"] = Dict(
        "T" => T, "d_mid" => dmid, "d_spike" => dspike,
        "spike_on" => 16, "spike_off" => 27,
        "Fc_ctrl" => pc.Fm[:, 1], "Fc_spike" => ps.Fm[:, 1],
        "F_ctrl" => pc.F, "F_spike" => ps.F)

    # transition after the 2022 reassessment (permanent delta_pre -> delta_post)
    dpath = vcat(fill(DELTA_PRE, 5), fill(DELTA_POST, 36))
    sp = simulate(dpath, NOPOL; init = pre.Fm)
    results["transition"] = Dict("Fc" => sp.Fm[:, 1], "F" => sp.F,
                                 "shock_at" => 6)

    # policy experiments: friend-shoring subsidy vs stockpile
    polS = Pol(0.25, 1.0, 0.0)        # pays 25 percent of the premium
    polK = Pol(0.0, 2.0/3.0, 0.0)     # stockpile: cuts disruption loss by 1/3
    bifS = bifurcation(polS)
    bifK = bifurcation(polK)
    ssS = steady(DELTA_POST, polS; init = pre.Fm)
    ssK = steady(DELTA_POST, polK; init = pre.Fm)
    results["policy"] = Dict(
        "baseline" => Dict("band_lo" => bif.band[1], "band_hi" => bif.band[2],
                           "Fc" => post.Fm[1], "pic" => post.pic),
        "subsidy"  => Dict("band_lo" => bifS.band[1], "band_hi" => bifS.band[2],
                           "Fc" => ssS.Fm[1], "pic" => ssS.pic),
        "stockpile" => Dict("band_lo" => bifK.band[1], "band_hi" => bifK.band[2],
                            "Fc" => ssK.Fm[1], "pic" => ssK.pic))

    # planner vs market and the corrective wedge, along delta
    wedge = Dict{String,Any}("delta" => Float64[], "tau" => Float64[],
                             "F_plan" => Float64[], "F_mkt" => Float64[])
    for d in [0.06, 0.08, 0.10, 0.12, 0.16, 0.20, 0.24]
        pl = planner(d, 1)
        mk = steady(d, NOPOL; init = fill(0.02, 3))
        tau = pigou(d, 1, pl.F)
        push!(wedge["delta"], d); push!(wedge["tau"], tau)
        push!(wedge["F_plan"], pl.F); push!(wedge["F_mkt"], mk.Fm[1])
    end
    results["wedge"] = wedge

    # welfare: burden at low vs high branch at d_mid (the trap premium)
    eqm = equilibria(dmid, NOPOL)
    stables = [e.Fc for e in eqm if e.stable]
    Flo, Fhi = minimum(stables), maximum(stables)
    Blo = burden(Flo, agg_given_Fc(Flo, dmid, NOPOL), 1, dmid, NOPOL)
    Bhi = burden(Fhi, agg_given_Fc(Fhi, dmid, NOPOL), 1, dmid, NOPOL)
    results["welfare"] = Dict(
        "d_mid" => dmid, "F_lo" => Flo, "F_hi" => Fhi,
        "B_lo" => Blo, "B_hi" => Bhi,
        "trap_cost_sector" => Bhi - Blo,
        "trap_cost_gdp_pct" => (Bhi - Blo) * W_M[1] * ALPHA_XB * 100,
        "pic_lo" => pim(Flo, agg_given_Fc(Flo, dmid, NOPOL), 1, dmid),
        "pic_hi" => pim(Fhi, agg_given_Fc(Fhi, dmid, NOPOL), 1, dmid))

    # sensitivity: fold location over (theta, chi)
    sens = Dict{String,Any}()
    for th in [0.4, 0.5, 0.6, 0.7], ch in [0.0, 0.2, 0.4, 0.6]
        # rebuild closures via global-constant workaround: brute local recompute
        sens["th$(th)_chi$(ch)"] = fold_sens(th, ch)
    end
    results["sensitivity"] = sens

    open(joinpath(OUTDIR, "results.json"), "w") do f
        JSON.print(f, denan(results), 1)
    end
    println("saved results.json")
    println("pre:  Fc=", round(pre.Fm[1], digits=4), "  F=", round(pre.F, digits=4))
    println("post: Fc=", round(post.Fm[1], digits=4), "  F=", round(post.F, digits=4),
            "  pic=", round(post.pic, digits=4))
    println("fold band: ", bif.band, "  M_crit=", round(equil_dF/direct_dF, digits=2),
            "  M_agg=", round(aggp/direct_agg, digits=2))
    println("trap cost (sector value/yr): ", round(Bhi-Blo, digits=4),
            "  wedge taus: ", [round(t, digits=4) for t in wedge["tau"]])
end

# JSON cannot carry NaN: convert to null recursively
denan(x::Float64) = isnan(x) ? nothing : x
denan(x::AbstractVector) = [denan(v) for v in x]
denan(x::Dict) = Dict(k => denan(v) for (k, v) in x)
denan(x) = x

# fold location with alternative (theta, chi): local re-implementation of the
# critical-sector fixed-point scan holding other parameters at baseline
function fold_sens(th, ch)
    pim2(Fm, del) = del * (1.0 - th * (1.0 - Fm))              # drop small ETAA
    gh2(Fm, del) = pim2(Fm, del) * LAM0[1] * (1.0 + XI * Fm) / (1.0 - ch * Fm)
    f2(Fm, del) = F0NG[1] + (1.0 - F0NG[1]) * Hcdf(gh2(Fm, del), 1)
    function nrootsat(del)
        R(F) = F - f2(F, del)
        n = 0
        grid = 0.0:0.002:1.0
        vals = [R(F) for F in grid]
        for i in 1:length(grid)-1
            if vals[i] * vals[i+1] < 0.0
                n += 1
            end
        end
        n
    end
    dg = 0.02:0.0005:0.40
    multi = [d for d in dg if nrootsat(d) >= 3]
    isempty(multi) ? Dict("band_lo" => NaN, "band_hi" => NaN) :
        Dict("band_lo" => minimum(multi), "band_hi" => maximum(multi))
end

main()
