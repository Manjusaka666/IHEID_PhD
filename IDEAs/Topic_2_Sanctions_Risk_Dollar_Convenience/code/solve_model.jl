# Sanctions Risk and Dollar Convenience: quantitative model.
#
# Linear-quadratic reserve-portfolio model with a dollar network externality
# and a hegemon that chooses sanctions intensity. Two country types: exposed
# (mass mu, sanctions loss rate pihat = omega * sbar * p * phi) and aligned
# (loss rate 0). Countries choose the dollar share a of reserves with flow
# payoff  a*(l(N) - w) - kap*a^2/2 - nu*(a - a_{-1})^2/2,  l(N) = l0 + l1*N,
# N = aggregate dollar share. All dynamics are closed-form saddle paths;
# steady states with corners solve by damped fixed point.
#
# The hegemon: flow privilege Omega(N) = l(N)*N*W (bn USD per year) plus, in
# crisis periods (prob omega), net geopolitical benefit G(s) = gam*(s - s^2/2).
# Discretion: s_D = 1 (beliefs taken as given). Ramsey: internalizes N(sbar).
#
# Run:  julia --project=. solve_model.jl     Output: ../output/results.json

using JSON

const OUTDIR = joinpath(@__DIR__, "..", "output")
mkpath(OUTDIR)

# ---------------------------------------------------------------- calibration
const BETA_C = 0.96        # country discount factor (annual)
const CY0    = 0.0073      # pre-2022 Treasury convenience yield (KVJ level)
const N0     = 0.59        # pre-2022 dollar share of allocated reserves
const MU     = 0.5         # reserve-weighted mass of exposed countries
const W      = 12_000.0    # world official reserves, bn USD
const OMEGA  = 0.05        # annual probability of a sanctions crisis
const PHI    = 0.5         # share of target's dollar reserves frozen (Russia 2022)
const PSING  = 0.02        # single-use breadth: P(exposed country is the target)
const HL     = 3.0         # calibrated half-life of aggregate adjustment (years)
const GAM    = 200.0       # crisis geopolitical stakes, bn USD (G(1) = GAM/2)
const RH     = 0.04        # hegemon discount rate for present values
const MGRID  = [1.0, 1.5, 2.5]   # network multiplier variants (baseline 1.5)
const M0     = 1.5

kappa() = CY0 / N0

"Calibrated (l0, l1, nu, lamN, lamD) for a given target multiplier m."
function calib(m::Float64)
    kap = kappa()
    l1 = kap * (1.0 - 1.0 / m)
    l0 = CY0 - l1 * N0
    lam = 0.5^(1.0 / HL)
    nu = (kap - l1) * lam / ((1.0 - lam) * (1.0 - BETA_C * lam))
    # aggregate stable root (should equal lam by construction)
    B = kap + nu + BETA_C * nu - l1
    lamN = (B - sqrt(B^2 - 4.0 * BETA_C * nu^2)) / (2.0 * BETA_C * nu)
    Bd = kap + nu + BETA_C * nu
    lamD = (Bd - sqrt(Bd^2 - 4.0 * BETA_C * nu^2)) / (2.0 * BETA_C * nu)
    (kap = kap, l0 = l0, l1 = l1, nu = nu, lamN = lamN, lamD = lamD, m = m)
end

# ------------------------------------------------------------- steady states
"Corner-safe steady-state shares given exposed loss rate pihat. rbar is the
financial return spread of dollar over outside reserves (0 in the baseline)."
function ss(pihat::Float64, cb; rbar::Float64 = 0.0)
    aE, aA = 0.5, 0.5
    for _ in 1:200_000
        N = MU * aE + (1.0 - MU) * aA
        cy = cb.l0 + cb.l1 * N
        aE2 = clamp((rbar + cy - pihat) / cb.kap, 0.0, 1.0)
        aA2 = clamp((rbar + cy) / cb.kap, 0.0, 1.0)
        if abs(aE2 - aE) + abs(aA2 - aA) < 1e-15
            aE, aA = aE2, aA2
            break
        end
        aE = 0.5 * (aE + aE2)
        aA = 0.5 * (aA + aA2)
    end
    N = MU * aE + (1.0 - MU) * aA
    cy = cb.l0 + cb.l1 * N
    (aE = aE, aA = aA, N = N, cy = cy, priv = cy * N * W)
end

pihat_of(sbar, p) = OMEGA * sbar * p * PHI

# hegemon flow value (bn USD per year) at anticipated rule sbar, breadth p
function hflow(sbar::Float64, p::Float64, cb; gam = GAM)
    s = ss(pihat_of(sbar, p), cb)
    s.priv + OMEGA * gam * (sbar - 0.5 * sbar^2)
end

"Ramsey rule: maximize steady-state flow value over sbar on a fine grid
(closed form exists in the interior region; the grid handles corners)."
function ramsey(p::Float64, cb; gam = GAM)
    sgrid = 0.0:0.0005:1.0
    best_s, best_v = 0.0, -Inf
    for sb in sgrid
        v = hflow(sb, p, cb; gam = gam)
        if v > best_v
            best_v, best_s = v, sb
        end
    end
    (s = best_s, v = best_v)
end

# ------------------------------------------------------------------ dynamics
"Perfect-foresight path after a permanent jump of the exposed loss rate from
0 to pihat at t=1, starting from the pre-shock steady state (interior case)."
function transition(pihat::Float64, cb; T::Int = 31)
    pre = ss(0.0, cb)
    post = ss(pihat, cb)
    dinf = post.aE - post.aA
    Npath = zeros(T); dpath = zeros(T)
    Npath[1] = pre.N; dpath[1] = pre.aE - pre.aA
    for t in 2:T
        Npath[t] = post.N + cb.lamN * (Npath[t-1] - post.N)
        dpath[t] = dinf + cb.lamD * (dpath[t-1] - dinf)
    end
    aA = [Npath[t] - MU * dpath[t] for t in 1:T]
    aE = [aA[t] + dpath[t] for t in 1:T]
    cy = [cb.l0 + cb.l1 * Npath[t] for t in 1:T]
    priv = [cy[t] * Npath[t] * W for t in 1:T]
    Dict("N" => Npath, "aE" => aE, "aA" => aA, "cy" => cy, "priv" => priv)
end

# ----------------------------------------------------------------------- run
function main()
    results = Dict{String,Any}()
    cb0 = calib(M0)
    results["calibration"] = Dict(
        "kappa" => cb0.kap, "l0" => cb0.l0, "l1" => cb0.l1, "nu" => cb0.nu,
        "lamN" => cb0.lamN, "lamD" => cb0.lamD, "beta_c" => BETA_C,
        "CY0" => CY0, "N0" => N0, "mu" => MU, "W" => W, "omega" => OMEGA,
        "phi" => PHI, "p_single" => PSING, "half_life" => HL, "gamma" => GAM,
        "multiplier" => M0, "pihat_single" => pihat_of(1.0, PSING))

    # steady states: pre, post single-use (sbar=1), post routine breadth
    PROUT = 0.25
    pre = ss(0.0, cb0)
    post1 = ss(pihat_of(1.0, PSING), cb0)
    postR = ss(pihat_of(1.0, PROUT), cb0)
    softR = ss(OMEGA * 1.0 * PSING * 0.15, cb0)          # phi = 0.15
    results["ss"] = Dict(
        "pre" => Dict(pairs(pre)), "post_single" => Dict(pairs(post1)),
        "post_routine" => Dict(pairs(postR)), "post_soft" => Dict(pairs(softR)),
        "p_routine" => PROUT)

    # multiplier sensitivity: long-run effects of the single-use shock
    mult = Dict{String,Any}()
    for m in MGRID
        cb = calib(m)
        a = ss(0.0, cb); b = ss(pihat_of(1.0, PSING), cb)
        mult["m_$(m)"] = Dict(
            "dN_pp" => (b.N - a.N) * 100, "dcy_bp" => (b.cy - a.cy) * 1e4,
            "daE_pp" => (b.aE - a.aE) * 100, "daA_pp" => (b.aA - a.aA) * 100,
            "dpriv_bn" => b.priv - a.priv, "lamN" => cb.lamN)
    end
    results["multiplier"] = mult

    # transition paths (baseline and multiplier variants)
    paths = Dict{String,Any}()
    for m in MGRID
        paths["m_$(m)"] = transition(pihat_of(1.0, PSING), calib(m))
    end
    results["paths"] = paths

    # policy: discretion vs Ramsey at single-use breadth, gamma sensitivity
    pol = Dict{String,Any}()
    for gam in [50.0, 100.0, 200.0, 400.0, 800.0]
        r = ramsey(PSING, cb0; gam = gam)
        vD = hflow(1.0, PSING, cb0; gam = gam)
        pol["gam_$(Int(gam))"] = Dict(
            "s_R" => r.s, "bias" => 1.0 - r.s, "v_R" => r.v, "v_D" => vD,
            "commit_flow_bn" => r.v - vD, "commit_pv_bn" => (r.v - vD) / RH)
    end
    results["policy"] = pol

    # P5: Ramsey intensity falls with the network multiplier
    p5 = Dict{String,Any}()
    for m in [1.0, 1.25, 1.5, 2.0, 2.5, 3.0]
        r = ramsey(PSING, calib(m))
        p5["m_$(m)"] = Dict("s_R" => r.s, "bias" => 1.0 - r.s)
    end
    results["p5"] = p5

    # Laffer curve in breadth p at sbar = 1, and Ramsey rule by breadth
    pgrid = collect(0.0:0.01:0.5)
    laffer = Dict{String,Any}("p" => pgrid)
    laffer["v_weaponize"] = [hflow(1.0, p, cb0) for p in pgrid]
    laffer["v_restraint"] = [hflow(0.0, p, cb0) for p in pgrid]
    laffer["N_weaponize"] = [ss(pihat_of(1.0, p), cb0).N for p in pgrid]
    laffer["s_R"] = [ramsey(p, cb0).s for p in pgrid]
    results["laffer"] = laffer

    # counterfactual: deeper outside asset market. Lower diversification cost
    # kappa by 30 percent and recalibrate the financial spread rbar so that
    # the pre-shock equilibrium still matches (N0, CY0); the same sanctions
    # shock then meets a more elastic demand.
    kap2 = cb0.kap * 0.7
    cbk = (kap = kap2, l0 = cb0.l0, l1 = cb0.l1, nu = cb0.nu,
           lamN = cb0.lamN, lamD = cb0.lamD, m = M0)
    rbar2 = kap2 * N0 - CY0
    ak = ss(0.0, cbk; rbar = rbar2)
    bk = ss(pihat_of(1.0, PSING), cbk; rbar = rbar2)
    results["outside"] = Dict("dN_pp" => (bk.N - ak.N) * 100,
                              "N_pre" => ak.N, "N_post" => bk.N,
                              "rbar_bp" => rbar2 * 1e4,
                              "dpriv_bn" => bk.priv - ak.priv)

    open(joinpath(OUTDIR, "results.json"), "w") do f
        JSON.print(f, results, 1)
    end
    println("saved results.json")
    println("pre N=", round(pre.N, digits = 4), " post1 N=", round(post1.N, digits = 4),
            " postR N=", round(postR.N, digits = 4))
    println("s_R(gam=200)=", pol["gam_200"]["s_R"], " commit flow bn=",
            round(pol["gam_200"]["commit_flow_bn"], digits = 2))
end

main()
