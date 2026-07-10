# Narrative contagion at the sovereign default boundary: numerical solution.
#
# Pricing block: one-period debt, default next year iff theta' < THB.
#   p(theta, s)      = Phi((THB - RHO*theta - (1-RHO)*THSS + CHI*s)/SIG)
#   infected belief  = p evaluated at theta - XI  (z shifted by SHIFT = RHO*XI/SIG)
#   pbar             = (1-n) p + n p_inf ;  s = (1-REC) pbar  (fixed point in s)
# Narrative block (continuous time, evaluated at monthly intervals):
#   dn/dt = beta(theta,n) n (1-n) - gam n
#   beta = A * R0PEAK * gam * rel(theta,n)/RELREF,  rel = price gap per unit n
# Fundamentals (monthly): theta' = RHOM theta + (1-RHOM) THSS - CHIM s + SIGM eps
#
# Writes output/results.json. The numerical inputs define a transparent
# scenario. The empirical section of the paper specifies their data targets.

using SpecialFunctions, JSON, Random

Phi(x) = 0.5 * erfc(-x / sqrt(2.0))
phi(x) = exp(-0.5 * x^2) / sqrt(2.0 * pi)

# ----------------------------------------------------------------- parameters
const RHO  = 0.90     # annual persistence of fundamentals
const SIG  = 0.05     # annual innovation sd
const THSS = 0.15     # long-run mean of theta
const THB  = 0.0      # default boundary
const REC  = 0.60     # recovery in default (haircut 40%)
const XI   = 0.03     # narrative pessimism: perceived theta shift
const CHI  = 0.20     # annual fundamentals drag per unit spread
const SHIFT = RHO * XI / SIG

const GAM0   = 0.30   # monthly narrative abandonment rate
const R0PEAK = 4.0    # peak reproduction number at A = 1 (modern amplification)
const N0SEED = 0.02   # narrative seed after a viral event

const RHOM = RHO^(1 / 12)
const SIGM = SIG * sqrt((1 - RHOM^2) / (1 - RHO^2))
const CHIM = CHI * (1 - RHOM) / (1 - RHO)

# ------------------------------------------------------- pricing fixed point
zfun(th, s) = (THB - RHO * th - (1 - RHO) * THSS + CHI * s) / SIG
pbar(th, s, n) = (1 - n) * Phi(zfun(th, s)) + n * Phi(zfun(th, s) + SHIFT)

"""equilibrium spread (decimal p.a.); cap = facility ceiling (Inf if none)"""
function sstar(th, n; cap = Inf)
    s = 0.0
    for _ in 1:200
        snew = min((1 - REC) * pbar(th, s, n), cap)
        abs(snew - s) < 1e-12 && return snew
        s = snew
    end
    return s
end

"""pricing (doom-loop) multiplier 1/(1 - gain) at the equilibrium"""
function mult(th, n; cap = Inf)
    s = sstar(th, n; cap = cap)
    s >= cap - 1e-12 && return 1.0
    z = zfun(th, s)
    gain = (1 - REC) * ((1 - n) * phi(z) + n * phi(z + SHIFT)) * CHI / SIG
    return 1 / (1 - gain)
end

"""Analytical price relevance ds/dn, in decimal spread units."""
function rel(th, n; cap = Inf)
    s = sstar(th, n; cap = cap)
    s >= cap - 1e-12 && return 0.0
    z = zfun(th, s)
    (1 - REC) * (Phi(z + SHIFT) - Phi(z)) * mult(th, n; cap = cap)
end

"""One-month flow of the continuous-time logistic adoption equation."""
function prevalence_flow(n, beta, gamma; dt = 1.0)
    0 <= n <= 1 || throw(ArgumentError("prevalence must lie in [0,1]"))
    beta >= 0 && gamma >= 0 || throw(ArgumentError("rates must be nonnegative"))
    n == 0 && return 0.0
    r = beta - gamma
    if abs(r) < 1e-12
        return n / (1 + beta * n * dt)
    end
    growth = exp(r * dt)
    n * growth / (1 + beta * n * (growth - 1) / r)
end

# contagion rate: adoption prob proportional to price relevance of acting
const RELREF = maximum(rel(th, 0.0) for th in -0.05:0.001:0.30)
beta_c(th, n; A = 1.0, cap = Inf) = A * R0PEAK * GAM0 * rel(th, n; cap = cap) / RELREF

# uniqueness margin of the pricing fixed point (max gain over states)
const GAINMAX = maximum((1 - REC) * phi(z) * CHI / SIG for z in -4:0.01:4)

gap(z) = Phi(z + SHIFT) - Phi(z)
gap1(z) = phi(z + SHIFT) - phi(z)
gap2(z) = -(z + SHIFT) * phi(z + SHIFT) + z * phi(z)
density_mix(z, n) = (1 - n) * phi(z) + n * phi(z + SHIFT)
density_mix1(z, n) = -(1 - n) * z * phi(z) - n * (z + SHIFT) * phi(z + SHIFT)
density_mix2(z, n) = (1 - n) * (z^2 - 1) * phi(z) +
    n * ((z + SHIFT)^2 - 1) * phi(z + SHIFT)

"""Derivative of the log-slope condition for a unique equilibrium hump."""
function log_slope_derivative(z, n)
    G = gap(z)
    a = (1 - REC) * CHI / SIG
    d = density_mix(z, n)
    d1 = density_mix1(z, n)
    d2 = density_mix2(z, n)
    (gap2(z) * G - gap1(z)^2) / G^2 +
        a * (d2 * (1 - a * d) + a * d1^2) / (1 - a * d)^2
end

const HUMP_MARGIN = maximum(log_slope_derivative(z, n)
    for z in -6:0.01:6, n in 0:0.02:1 if gap(z) > 1e-12)

# --------------------------------------------------------------- static hump
thgrid = collect(-0.05:0.0025:0.30)
hump = Dict(
    "theta"    => thgrid,
    "dsdn_bp"  => [rel(th, 0.0) * 1e4 for th in thgrid],       # bp per unit n
    "R0"       => [beta_c(th, 0.0) / GAM0 for th in thgrid],
    "spread_bp"=> [sstar(th, 0.0) * 1e4 for th in thgrid],
    "p"        => [pbar(th, sstar(th, 0.0), 0.0) for th in thgrid],
    "mult"     => [mult(th, 0.0) for th in thgrid],
)

"""susceptible zone {theta: R0 >= 1} for amplification A"""
function zone(A)
    inz = [th for th in -0.05:0.0005:0.30 if beta_c(th, 0.0; A = A) >= GAM0]
    isempty(inz) ? nothing : [minimum(inz), maximum(inz)]
end
AGRID = [0.25, 1.0, 1.5]                         # peak R0 = 1, 4, 6
zones = Dict(string(A) => zone(A) for A in AGRID)

# R0 curves for the zone figure
zone_fig = Dict(
    "theta" => thgrid,
    ["R0_$(round(A, digits=2))" => [beta_c(th, 0.0; A = A) / GAM0 for th in thgrid]
     for A in AGRID]...,
)

# ------------------------------------------------- state-grid interpolation
THG = collect(-0.10:0.002:0.35); NG = collect(0.0:0.02:1.0)
function tabulate(; cap = Inf, A = 1.0)
    stab = [sstar(th, n; cap = cap) for th in THG, n in NG]
    btab = [beta_c(th, n; A = A, cap = cap) for th in THG, n in NG]
    (stab, btab)
end
function interp(tab, th, n)
    th = clamp(th, THG[1], THG[end]); n = clamp(n, NG[1], NG[end])
    i = min(searchsortedlast(THG, th), length(THG) - 1)
    j = min(searchsortedlast(NG, n), length(NG) - 1)
    wt = (th - THG[i]) / (THG[i+1] - THG[i]); wn = (n - NG[j]) / (NG[j+1] - NG[j])
    (1-wt)*(1-wn)*tab[i,j] + wt*(1-wn)*tab[i+1,j] + (1-wt)*wn*tab[i,j+1] + wt*wn*tab[i+1,j+1]
end

# ------------------------------------------------ deterministic outbreak paths
"""48-month path with no fundamentals shocks; returns (n, s_bp, theta) series"""
function detpath(th0, n0; gam = GAM0, cap = Inf, A = 1.0, T = 48)
    stab, btab = tabulate(cap = cap, A = A)
    ns = zeros(T); ss = zeros(T); ths = zeros(T)
    th = th0; n = n0
    for t in 1:T
        s = interp(stab, th, n); b = interp(btab, th, n)
        ns[t] = n; ss[t] = s * 1e4; ths[t] = th
        if th < THB    # default: freeze the path at the boundary
            ns[t:end] .= n; ss[t:end] .= s * 1e4; ths[t:end] .= th
            break
        end
        n  = prevalence_flow(n, b, gam)
        th = RHOM * th + (1 - RHOM) * THSS - CHIM * s
    end
    (ns, ss, ths)
end

SC = Dict("safe" => 0.15, "zone" => 0.06, "distressed" => 0.01)
paths = Dict()
for (name, th0) in SC
    n1, s1, t1 = detpath(th0, N0SEED)
    n2, s2, t2 = detpath(th0, 0.0)
    paths[name] = Dict("n" => n1, "s" => s1, "th" => t1,
                       "s0" => s2, "th0" => t2)
end
# headline: peak excess spread and peak prevalence in the zone path
pz = paths["zone"]
peak_excess = maximum(pz["s"] .- pz["s0"]); peak_n = maximum(pz["n"])

# ----------------------------------------------- Monte Carlo: crisis hazard
const NPATH = 8000; const HOR = 24
rng = MersenneTwister(42)
EPS = randn(rng, NPATH, HOR)     # common random numbers across configurations

"""P(default within HOR months) from th0 under a configuration.
   cutk: one-shot counter-narrative (n cut by cutfrac) in month cutk.
   capk: spread cap becomes available from month capk on (tabs2)."""
function pdef(th0, n0; gam = GAM0, cap = Inf, A = 1.0, tabs = nothing,
              cutk = 0, cutfrac = 0.75, capk = 0, tabs2 = nothing)
    stab, btab = tabs === nothing ? tabulate(cap = cap, A = A) : tabs
    nd = 0
    for i in 1:NPATH
        th = th0; n = n0; dead = false
        for t in 1:HOR
            if th < THB; dead = true; break; end
            t == cutk && (n *= 1 - cutfrac)
            st, bt = (capk > 0 && t >= capk) ? tabs2 : (stab, btab)
            s = interp(st, th, n); b = interp(bt, th, n)
            n  = prevalence_flow(n, b, gam)
            th = RHOM * th + (1 - RHOM) * THSS - CHIM * s + SIGM * EPS[i, t]
        end
        (dead || th < THB) && (nd += 1)
    end
    nd / NPATH
end

TH0G = collect(0.0:0.01:0.20)
tab_base = tabulate(); tab_cap = tabulate(cap = 0.04)
mc = Dict{String, Any}(
    "th0"      => TH0G,
    "nonarr"   => [pdef(t0, 0.0;    tabs = tab_base) for t0 in TH0G],
    "narr"     => [pdef(t0, N0SEED; tabs = tab_base) for t0 in TH0G],
    "transp"   => [pdef(t0, N0SEED; gam = 0.45, tabs = tab_base) for t0 in TH0G],
    "cap"      => [pdef(t0, N0SEED; tabs = tab_cap) for t0 in TH0G],
    "nonarr_cap" => [pdef(t0, 0.0;  tabs = tab_cap) for t0 in TH0G],
)
wedge = mc["narr"] .- mc["nonarr"]
iw = argmax(wedge)
mc["wedge_peak"] = wedge[iw]; mc["wedge_argmax"] = TH0G[iw]
mc["wedge_safe"] = wedge[findfirst(==(0.15), TH0G)]
# policy scorecard at the wedge peak: how much of the NARRATIVE wedge survives
mc["wedge_transp"] = mc["transp"][iw] - mc["nonarr"][iw]
mc["wedge_cap"]    = mc["cap"][iw]    - mc["nonarr_cap"][iw]
mc["fund_relief_cap"] = mc["nonarr"][iw] - mc["nonarr_cap"][iw]

# ---------------------------------------------------- policy timing window
# (a) backstop arrives in month k (Draghi counterfactual); (b) one-shot
# counter-narrative deletes 75% of prevalence in month k
const TH_TIMING = 0.04   # timing experiment at the MC wedge peak
KGRID = collect(1:2:13)
timing = Dict(
    "k"      => KGRID,
    "cap_k"  => [pdef(TH_TIMING, N0SEED; tabs = tab_base, capk = k, tabs2 = tab_cap) for k in KGRID],
    "cut_k"  => [pdef(TH_TIMING, N0SEED; tabs = tab_base, cutk = k) for k in KGRID],
    "never"  => pdef(TH_TIMING, N0SEED; tabs = tab_base),
    "nonarr" => pdef(TH_TIMING, 0.0;    tabs = tab_base),
)

# Deterministic vector field for the phase portrait.
phase_theta = collect(0.0:0.01:0.18)
phase_n = collect(0.0:0.05:0.80)
phase_dtheta = [[(RHOM - 1) * th + (1 - RHOM) * THSS -
    CHIM * sstar(th, n) for n in phase_n] for th in phase_theta]
phase_dn = [[beta_c(th, n) * n * (1 - n) - GAM0 * n
    for n in phase_n] for th in phase_theta]
phase = Dict("theta" => phase_theta, "n" => phase_n,
    "dtheta" => phase_dtheta, "dn" => phase_dn)

# -------------------------------------------------------------------- output
sz = sstar(SC["zone"], 0.0)
results = Dict(
    "calibration" => Dict(
        "rho" => RHO, "sig" => SIG, "thss" => THSS, "rec" => REC, "xi" => XI,
        "chi" => CHI, "shift" => SHIFT, "gam" => GAM0, "r0peak" => R0PEAK,
        "n0" => N0SEED, "gainmax" => GAINMAX, "multpeak" => 1 / (1 - GAINMAX),
        "sigm" => SIGM, "chim" => CHIM, "hump_margin" => HUMP_MARGIN,
        "input_class" => "scenario",
        "relref_bp" => RELREF * 1e4,
        "th_zone" => SC["zone"], "s_zone_bp" => sz * 1e4,
        "dsdn10_zone_bp" => rel(SC["zone"], 0.0) * 1e3,   # bp per 10pp of n
        "dsdn10_safe_bp" => rel(SC["safe"], 0.0) * 1e3,
        "dsdn10_peak_bp" => RELREF * 1e3,
    ),
    "hump" => hump, "zones" => zones, "zone_fig" => zone_fig,
    "paths" => paths,
    "peak_excess_bp" => peak_excess, "peak_n" => peak_n,
    "mc" => mc, "timing" => timing, "phase" => phase,
)

denan(x::AbstractFloat) = isnan(x) ? nothing : x
denan(x::AbstractArray) = [denan(v) for v in x]
denan(x::Dict) = Dict(k => denan(v) for (k, v) in x)
denan(x) = x

out = joinpath(@__DIR__, "..", "output", "results.json")
open(out, "w") do io; JSON.print(io, denan(results)); end

println("gainmax=$(round(GAINMAX, digits=3))  relref=$(round(RELREF*1e4, digits=0))bp/unit n")
println("zones: ", zones)
println("zone path: s=$(round(sz*1e4))bp  peak_n=$(round(peak_n, digits=2))  peak_excess=$(round(peak_excess))bp")
println("MC wedge: peak=$(round(mc["wedge_peak"], digits=3)) at th0=$(mc["wedge_argmax"])  safe=$(round(mc["wedge_safe"], digits=4))")
println("wedge under policy: transparency $(round(mc["wedge_transp"], digits=3)), cap $(round(mc["wedge_cap"], digits=3)); cap fundamentals relief $(round(mc["fund_relief_cap"], digits=3))")
println("timing cap_k: ", [round(p, digits = 3) for p in timing["cap_k"]])
println("timing cut_k: ", [round(p, digits = 3) for p in timing["cut_k"]],
        "  never=$(round(timing["never"], digits=3)) nonarr=$(round(timing["nonarr"], digits=3))")
