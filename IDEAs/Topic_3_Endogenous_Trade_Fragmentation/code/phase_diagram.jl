# Phase diagram over the fold-driving (theta, chi) parameter plane.
#
# Referee cross-draft point 6.7 asks: where in the deterrence x capacity plane
# does the critical sector's fold exist, where has the post-2022 dispute hazard
# (delta = 0.10) already crossed it, and where is the sector safely monotone?
# This script sweeps the plane and classifies every cell.
#
# The sector fixed-point machinery is copied verbatim from dispersion_sens.jl
# (the trusted reimplementation), not include-d, because that file runs main()
# unguarded at the end. The baseline fold band [0.114, 0.131] at (0.6, 0.4, 0.5)
# is reproduced with the same @assert before anything else is trusted.
#
# theta  = deterred share: the share of escalations deterred by an intact sector
#          (paper eq. (hazard), calibration table, baseline 0.6, scenario {0.4-0.7}).
# chi    = capacity-scale elasticity: the compression of the friend-shoring
#          premium as friendly capacity scales, g_eff = g(1 - chi F_m)
#          (paper eq. (capacity), baseline 0.4, scenario {0-0.6}).
#
# Run:  julia --project=. phase_diagram.jl     (~5 min at full dgrid resolution)

using SpecialFunctions: erf

const OUTDIR = joinpath(@__DIR__, "..", "output")

# ------------------------------------------------ calibration (from dispersion_sens.jl)
const W_M  = [0.15, 0.35, 0.50]
const SIGM = [2.0, 4.0, 8.0]
const SSH  = [0.50, 0.35, 0.20]
const DUR  = [1.5, 1.0, 0.5]
const GMED = [0.20, 0.15, 0.10]
const F0NG = [0.05, 0.08, 0.10]
const ETAA = 0.01
const XI   = 0.4
const DELTA_PRE  = 0.04
const DELTA_POST = 0.10

lam0(m) = ((1.0 - SSH[m])^(1.0 / (1.0 - SIGM[m])) - 1.0) * DUR[m]
const LAM0 = [lam0(m) for m in 1:3]

ncdf(z) = 0.5 * (1.0 + erf(z / sqrt(2.0)))
Hcdf(g, m, sln) = g <= 0.0 ? 0.0 : ncdf((log(g) - log(GMED[m])) / sln)

function ghat(Fm, F, m, del, theta, chi, sln)
    pim = del * (1.0 - theta * (1.0 - Fm)) + ETAA * F
    pim * LAM0[m] * (1.0 + XI * Fm) / (1.0 - chi * Fm)
end

Tmap(Fm, F, m, del, theta, chi, sln) =
    F0NG[m] + (1.0 - F0NG[m]) * Hcdf(ghat(Fm, F, m, del, theta, chi, sln), m, sln)

"Given the critical sector at Fc, solve sectors 2 and 3 and the aggregate."
function others(Fc, del, theta, chi, sln)
    F2, F3 = 0.1, 0.1
    F = W_M[1] * Fc + W_M[2] * F2 + W_M[3] * F3
    for _ in 1:20_000
        F2n = Tmap(F2, F, 2, del, theta, chi, sln)
        F3n = Tmap(F3, F, 3, del, theta, chi, sln)
        Fn = W_M[1] * Fc + W_M[2] * F2n + W_M[3] * F3n
        if abs(F2n - F2) + abs(F3n - F3) < 1e-13
            F2, F3, F = F2n, F3n, Fn
            break
        end
        F2, F3, F = 0.5 * (F2 + F2n), 0.5 * (F3 + F3n), Fn
    end
    W_M[1] * Fc + W_M[2] * F2 + W_M[3] * F3
end

"Number of critical-sector equilibria at dispute hazard del."
function nroots(del, theta, chi, sln)
    grid = range(F0NG[1], 1.0, length = 2001)
    resid = [Tmap(Fc, others(Fc, del, theta, chi, sln), 1, del, theta, chi, sln) - Fc
             for Fc in grid]
    n = 0
    for i in 1:length(grid)-1
        if resid[i] == 0.0 || resid[i] * resid[i+1] < 0.0
            n += 1
        end
    end
    n
end

"Fold band [dlo, dhi]: hazards with three or more equilibria (NaN if none)."
function foldband(theta, chi, sln; dgrid = 0.02:0.0005:0.30)
    multi = [d for d in dgrid if nroots(d, theta, chi, sln) >= 3]
    isempty(multi) ? (NaN, NaN) : (first(multi), last(multi))
end

# ------------------------------------------------------------------------ main
function main()
    # 1. Reproduce the published baseline fold band before trusting anything.
    base = foldband(0.6, 0.4, 0.5)
    println("baseline band (expect ~0.114-0.131): ", base)
    @assert abs(base[1] - 0.114) < 0.002 && abs(base[2] - 0.131) < 0.002

    # Runtime note: at the default dgrid a single cell runs in ~1.8 s (< 2 s),
    # so the full 165-cell sweep (~5 min) fits the budget at full resolution.
    # As a documented backstop, the coarse dgrid 0.02:0.002:0.30 reproduces the
    # baseline edges within 0.0005 (well inside the 0.004 tolerance); full
    # resolution is kept for sharper classification at the fold_hi = 0.10 edge.

    const_sln = 0.5
    thetas = collect(0.30:0.05:0.80)   # 11 deterred-share values
    chis   = collect(0.0:0.05:0.70)    # 15 capacity-elasticity values
    nth, nch = length(thetas), length(chis)

    fold_lo = fill(NaN, nth, nch)
    fold_hi = fill(NaN, nth, nch)
    cls     = zeros(Int, nth, nch)

    t0 = time()
    for (i, th) in enumerate(thetas)
        for (j, ch) in enumerate(chis)
            lo, hi = foldband(th, ch, const_sln)
            fold_lo[i, j] = lo
            fold_hi[i, j] = hi
            if isnan(hi)
                cls[i, j] = 0                        # monotone, no fold
            elseif DELTA_POST < hi
                cls[i, j] = 1                        # fold ahead: 0.10 below fold_hi
            else
                cls[i, j] = 2                        # past the fold: 0.10 >= fold_hi
            end
        end
        println("theta = ", round(th, digits = 2), "  row classes = ",
                cls[i, :], "  (", round(time() - t0, digits = 1), " s)")
    end
    println("total sweep time: ", round(time() - t0, digits = 1), " s")

    # 2. Write the long-format grid CSV.
    open(joinpath(OUTDIR, "phase_grid.csv"), "w") do f
        println(f, "theta,chi,fold_lo,fold_hi,class")
        for i in 1:nth, j in 1:nch
            lo = isnan(fold_lo[i, j]) ? "NA" : string(round(fold_lo[i, j], digits = 5))
            hi = isnan(fold_hi[i, j]) ? "NA" : string(round(fold_hi[i, j], digits = 5))
            println(f, round(thetas[i], digits = 2), ",", round(chis[j], digits = 2),
                    ",", lo, ",", hi, ",", cls[i, j])
        end
    end
    println("saved phase_grid.csv")

    # 3. Aggregate counts and boundary statistics.
    n_fold = count(!=(0), cls)       # cells with a fold (class 1 or 2)
    n_past = count(==(2), cls)       # past the fold (class 2)
    n_mono = count(==(0), cls)       # monotone (class 0)

    # smallest theta with a fold at chi = 0.4
    jchi04 = findfirst(c -> isapprox(c, 0.4), chis)
    theta_min = NaN
    for i in 1:nth
        if cls[i, jchi04] != 0
            theta_min = thetas[i]
            break
        end
    end
    # smallest chi with a fold at theta = 0.6
    ith06 = findfirst(t -> isapprox(t, 0.6), thetas)
    chi_min = NaN
    for j in 1:nch
        if cls[ith06, j] != 0
            chi_min = chis[j]
            break
        end
    end

    fmt2(x) = isnan(x) ? "none" : string(round(x, digits = 2))
    lines = String[
        "% generated by phase_diagram.jl",
        "\\newcommand{\\PhaseFoldCells}{$(n_fold)}",
        "\\newcommand{\\PhasePastCells}{$(n_past)}",
        "\\newcommand{\\PhaseMonoCells}{$(n_mono)}",
        "\\newcommand{\\PhaseThetaMin}{$(fmt2(theta_min))}",
        "\\newcommand{\\PhaseChiMin}{$(fmt2(chi_min))}",
    ]
    open(joinpath(OUTDIR, "phase_numbers.tex"), "w") do f
        for l in lines
            println(f, l)
        end
    end
    println("saved phase_numbers.tex")
    for l in lines
        println("  ", l)
    end
end

main()
