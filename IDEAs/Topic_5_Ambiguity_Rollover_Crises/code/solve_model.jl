# Ambiguity, Investor Composition, and Sovereign Rollover Crises.
#
# Global game: creditors roll over (payoff R if survive, REC if fail) or run
# (payoff 1-KAP for sure). Survival iff run mass <= theta. Private signals
# x = theta + eps/sqrt(BET); public signal y with precision ALP. Type-k
# creditors are maxmin over the public signal's bias, y' in [y-del_k, y+del_k]:
# worst case y-del_k, so type k behaves as a Bayesian who heard news worse by
# del_k. Cutoff premium (ALP/BET)*del_k; run propensity at threshold t:
#   Phi( g(t) + (ALP/sqrt(BET))*del_k ),
#   g(t) = [ALP*(t - y) - zbar*sqrt(ALP+BET)] / sqrt(BET),
# zbar = Phi^{-1}(pbar), pbar = (R-(1-KAP))/(R-REC). Threshold t* solves
#   t = (1-mu)*Phi(g(t)) + mu*Phi(g(t) + (ALP/sqrt(BET))*del).
# Uniqueness: ALP/sqrt(BET) < sqrt(2*pi) (holds: 1.35 < 2.51).
#
# Run:  julia --project=. solve_model.jl     Output: ../output/results.json

using JSON
using SpecialFunctions: erf, erfinv

const OUTDIR = joinpath(@__DIR__, "..", "output")
mkpath(OUTDIR)

ncdf(z) = 0.5 * (1.0 + erf(z / sqrt(2.0)))
npdf(z) = exp(-0.5 * z^2) / sqrt(2.0 * pi)
nquant(p) = sqrt(2.0) * erfinv(2.0 * p - 1.0)

# ---------------------------------------------------------------- scenario inputs
const R    = 1.04      # promised gross return on rolled debt
const REC  = 0.60      # recovery in default (Cruces-Trebesch ~40% haircut)
const KAP  = 0.08      # exit cost of running (fire-sale discount)
const SIGX = 0.15      # private signal noise  -> BET = 1/SIGX^2
const SIGY = 1.0 / 3.0 # public signal noise   -> ALP = 1/SIGY^2
const DELF = 0.08      # fragile-type effective-pessimism radius
const DELS = 0.0       # stable-type ambiguity radius
const MU0  = 0.40      # fragile share of the maturing debt
const YCALM   = 1.10   # public signal, calm
const YSTRESS = 0.95   # public signal, stress

const BET = 1.0 / SIGX^2
const ALP = 1.0 / SIGY^2

function rollover_hurdle(R_, rec, q_survive, q_crisis)
    rollover_loss = R_ - rec
    exit_loss = q_survive - q_crisis
    rollover_loss > exit_loss ||
        throw(ArgumentError("rollover must be more crisis-exposed than exit"))
    hurdle = (R_ - q_survive) / (rollover_loss - exit_loss)
    0 < hurdle < 1 || throw(ArgumentError("the implied hurdle must lie in (0,1)"))
    hurdle
end

pbar(R_, rec, kap) = rollover_hurdle(R_, rec, 1.0 - kap, 1.0 - kap)

"Threshold with arbitrary creditor weights, ambiguity radii, and payoff hurdles."
function tstar_types(weights, y; dels, pbs, alp = ALP, bet = BET)
    n = length(weights)
    length(dels) == n && length(pbs) == n ||
        throw(DimensionMismatch("weights, ambiguity radii, and hurdles must align"))
    all(weights .>= 0) || throw(ArgumentError("type weights must be nonnegative"))
    isapprox(sum(weights), 1.0; atol = 1e-12) ||
        throw(ArgumentError("type weights must sum to one"))
    all(0 .< pbs .< 1) || throw(ArgumentError("hurdles must lie in (0,1)"))
    shifts = (alp / sqrt(bet)) .* dels
    intercepts = nquant.(pbs) .* sqrt(alp + bet)
    rhs(t) = sum(weights[k] * ncdf(
        (alp * (t - y) - intercepts[k]) / sqrt(bet) + shifts[k]) for k in 1:n)
    lo, hi = 0.0, 1.0
    for _ in 1:200
        mid = 0.5 * (lo + hi)
        rhs(mid) - mid > 0 ? (lo = mid) : (hi = mid)
    end
    0.5 * (lo + hi)
end

"Threshold t* by bisection. del = (del_S, del_F); pb = rollover hurdle."
function tstar(mu, y; delF = DELF, delS = DELS, alp = ALP, bet = BET,
               pb = pbar(R, REC, KAP))
    tstar_types([1 - mu, mu], y; dels = [delS, delF], pbs = [pb, pb],
                alp = alp, bet = bet)
end

"Crisis probability and spread (bp) at threshold t given public signal y."
crisisP(t, y; alp = ALP) = ncdf((t - y) * sqrt(alp))
spread_bp(P; rec = REC) = P * (1.0 - rec) / (1.0 - P * (1.0 - rec)) * 1e4

"Slope of the aggregate map at t (for the amplification multiplier)."
function slope_at(t, mu, y; delF = DELF, delS = DELS, alp = ALP, bet = BET,
                  pb = pbar(R, REC, KAP))
    zb = nquant(pb)
    g = (alp * (t - y) - zb * sqrt(alp + bet)) / sqrt(bet)
    sF = (alp / sqrt(bet)) * delF; sS = (alp / sqrt(bet)) * delS
    (alp / sqrt(bet)) * ((1.0 - mu) * npdf(g + sS) + mu * npdf(g + sF))
end

function main()
    res = Dict{String,Any}()
    pb = pbar(R, REC, KAP)
    res["calibration"] = Dict("R" => R, "REC" => REC, "KAP" => KAP,
        "sigx" => SIGX, "sigy" => SIGY, "alp" => ALP, "bet" => BET,
        "ratio" => ALP / sqrt(BET), "unique_bound" => sqrt(2.0 * pi),
        "pbar" => pb, "delF" => DELF, "mu0" => MU0,
        "input_class" => "scenario",
        "y_calm" => YCALM, "y_stress" => YSTRESS,
        "cutoff_premium" => (ALP / BET) * DELF,
        "shift" => (ALP / sqrt(BET)) * DELF)

    # baseline thresholds, crisis probs, spreads: calm and stress, with/without ambiguity
    base = Dict{String,Any}()
    for (tag, y) in [("calm", YCALM), ("stress", YSTRESS)]
        tA = tstar(MU0, y)                       # with ambiguity
        tB = tstar(MU0, y; delF = 0.0)           # Bayesian benchmark
        PA, PB = crisisP(tA, y), crisisP(tB, y)
        base[tag] = Dict("t_amb" => tA, "t_bay" => tB,
            "P_amb" => PA, "P_bay" => PB,
            "s_amb" => spread_bp(PA), "s_bay" => spread_bp(PB),
            "premium_bp" => spread_bp(PA) - spread_bp(PB),
            "mult" => 1.0 / (1.0 - slope_at(tA, MU0, y)))
    end
    res["base"] = base

    # fragility frontier: t*(mu) for three ambiguity radii, both regimes
    mugrid = collect(0.0:0.01:1.0)
    fr = Dict{String,Any}("mu" => mugrid)
    for del in [0.04, 0.08, 0.12]
        fr["t_calm_$(del)"] = [tstar(m, YCALM; delF = del) for m in mugrid]
        fr["t_stress_$(del)"] = [tstar(m, YSTRESS; delF = del) for m in mugrid]
        fr["s_stress_$(del)"] = [spread_bp(crisisP(tstar(m, YSTRESS; delF = del), YSTRESS)) for m in mugrid]
    end
    res["frontier"] = fr

    # transparency: dt*/dalpha sign map over (y, mu); credibility always helps
    ygrid = collect(0.70:0.005:1.30)
    mgrid = collect(0.0:0.02:1.0)
    dsign = zeros(length(ygrid), length(mgrid))
    eps = 1e-4
    for (i, y) in enumerate(ygrid), (j, m) in enumerate(mgrid)
        t1 = tstar(m, y; alp = ALP * (1 + eps))
        t0 = tstar(m, y; alp = ALP * (1 - eps))
        dsign[i, j] = (t1 - t0) / (2 * ALP * eps)
    end
    # store as vector of rows for JSON friendliness
    res["transparency"] = Dict("y" => ygrid, "mu" => mgrid,
        "dtda" => [dsign[i, :] for i in 1:length(ygrid)])
    # threshold news level y-dagger at mu0: where dt*/dalpha crosses zero
    ydag = NaN
    for i in 1:length(ygrid)-1
        j = argmin(abs.(mgrid .- MU0))
        if dsign[i, j] > 0 && dsign[i+1, j] <= 0
            ydag = ygrid[i]
        end
    end
    res["transparency_ydagger"] = ydag
    # credibility: dt*/ddelta at baseline (always positive)
    tS = tstar(MU0, YSTRESS)
    res["credibility"] = Dict(
        "dt_ddelta_stress" => (tstar(MU0, YSTRESS; delF = DELF + 0.01) - tS) / 0.01,
        "half_delta_spread_bp" =>
            spread_bp(crisisP(tstar(MU0, YSTRESS; delF = DELF / 2), YSTRESS)) -
            spread_bp(crisisP(tS, YSTRESS)))

    # ambiguity is not noise: t*(delta) linear vs public-variance increase
    dgrid = collect(0.0:0.005:0.15)
    res["amb_vs_noise"] = Dict("delta" => dgrid,
        "t_delta" => [tstar(MU0, YSTRESS; delF = d) for d in dgrid],
        # noise comparison: cut alpha so that sd of public signal rises by delta
        "t_noise" => [tstar(MU0, YSTRESS; delF = 0.0,
                            alp = 1.0 / (SIGY + d)^2) for d in dgrid])

    # directional test: effect on t* of ambiguity (delta = DELF) vs an equal
    # increase in the public signal's standard deviation, across news levels y
    ycomp = collect(0.68:0.01:1.30)
    res["directional"] = Dict("y" => ycomp,
        "d_amb" => [tstar(MU0, y) - tstar(MU0, y; delF = 0.0) for y in ycomp],
        "d_noise" => [tstar(MU0, y; delF = 0.0, alp = 1.0 / (SIGY + DELF)^2) -
                      tstar(MU0, y; delF = 0.0) for y in ycomp])

    # QT experiment: fragile share drifts 0.35 -> 0.65 over 8 years in calm;
    # a moderate fundamentals shock hits in year 7; debt-service doom loop
    T = 15
    TSHOCK = 7
    YSHOCK = 1.02
    DOOM = 0.0   # debt-service feedback: discussed qualitatively in the text
    mupath = [min(0.35 + 0.0375 * max(t - 1, 0), 0.65) for t in 1:T]
    function qtpath(mus)
        ybase = [t < TSHOCK ? YCALM : YSHOCK for t in 1:T]
        y = copy(ybase); s = zeros(T); tv = zeros(T)
        for t in 1:T
            tv[t] = tstar(mus[t], y[t])
            s[t] = spread_bp(crisisP(tv[t], y[t]))
            if t < T
                y[t+1] = ybase[t+1] - DOOM * max(s[t] - s[1], 0.0) / 1e4
            end
        end
        (y = y, s = s, t = tv)
    end
    qt = qtpath(mupath)
    noqt = qtpath(fill(0.35, T))
    firstcross(s, y, tv) = findfirst(t -> crisisP(tv[t], y[t]) > 0.25, 1:T)
    res["qt"] = Dict("T" => T, "t_shock" => TSHOCK, "mu" => mupath,
        "s_qt" => qt.s, "s_noqt" => noqt.s,
        "P_qt" => [crisisP(qt.t[t], qt.y[t]) for t in 1:T],
        "P_noqt" => [crisisP(noqt.t[t], noqt.y[t]) for t in 1:T],
        "s_preshock_qt" => qt.s[TSHOCK-1], "s_preshock_noqt" => noqt.s[TSHOCK-1],
        "s_end_qt" => qt.s[end], "s_end_noqt" => noqt.s[end],
        "cross_qt" => something(firstcross(qt.s, qt.y, qt.t), 0),
        "cross_noqt" => something(firstcross(noqt.s, noqt.y, noqt.t), 0))

    # CACs: recovery 0.60 -> 0.70; interaction with ambiguity
    cac = Dict{String,Any}()
    for (tag, rec) in [("base", REC), ("cac", 0.70)]
        pbc = pbar(R, rec, KAP)
        tA = tstar(MU0, YSTRESS; pb = pbc)
        tB = tstar(MU0, YSTRESS; pb = pbc, delF = 0.0)
        cac[tag] = Dict("t_amb" => tA, "t_bay" => tB,
            "P_amb" => crisisP(tA, YSTRESS),
            "s_amb" => spread_bp(crisisP(tA, YSTRESS); rec = rec),
            "amb_premium_t" => tA - tB)
    end
    res["cac"] = cac

    open(joinpath(OUTDIR, "results.json"), "w") do f
        JSON.print(f, res, 1)
    end
    println("saved results.json")
    b = res["base"]
    println("calm:   t*=", round(b["calm"]["t_amb"], digits=3), " s=",
            round(b["calm"]["s_amb"], digits=0), "bp  premium=",
            round(b["calm"]["premium_bp"], digits=1), "bp  mult=",
            round(b["calm"]["mult"], digits=2))
    println("stress: t*=", round(b["stress"]["t_amb"], digits=3), " s=",
            round(b["stress"]["s_amb"], digits=0), "bp  premium=",
            round(b["stress"]["premium_bp"], digits=1), "bp  mult=",
            round(b["stress"]["mult"], digits=2))
    println("ydagger=", res["transparency_ydagger"], "  QT cross=",
            res["qt"]["cross_qt"], " vs noQT=", res["qt"]["cross_noqt"])
    println("CAC: s ", round(cac["base"]["s_amb"], digits=0), " -> ",
            round(cac["cac"]["s_amb"], digits=0), "bp; amb premium in t: ",
            round(cac["base"]["amb_premium_t"], digits=4), " -> ",
            round(cac["cac"]["amb_premium_t"], digits=4))
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
