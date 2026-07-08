# Sensitivity of the headline narrative-contagion magnitudes to the fundamentals
# feedback parameter chi, in response to the referee's request that chi be
# COMPUTED from gross-financing-need arithmetic rather than asserted.
#
# ---------------------------------------------------------------------------
# WHERE chi COMES FROM (gross-financing-need arithmetic).
#
# Fundamentals theta are measured in units of annual resources (fiscal
# capacity). A sovereign spread s (decimal p.a.) raises the cost of the debt
# that must be rolled over at the new rate within the year. The extra annual
# debt service, as a share of annual resources, is therefore
#
#       s  x  (debt refinanced within a year / annual resources)
#     = s  x  GFN,          GFN = gross financing need as a share of annual GDP.
#
# Since theta is in units of annual resources, the drag on theta per unit of
# spread is exactly the GFN ratio:   chi = GFN.  This replaces the old verbal
# justification ("a year at 500 bp drains one percent of annual capacity",
# which is just chi = 0.20 x 0.05 = 0.01 restated).
#
# IMF Fiscal Monitor gross-financing-need ranges for high-debt sovereigns:
#     ~10% of GDP   moderate-debt                  -> chi = 0.10   (low end)
#     ~20% of GDP   representative high-debt        -> chi = 0.20   (baseline)
#     ~30% of GDP   crisis-level (Italy/Greece 2011-12) -> chi = 0.30 (high end)
# So chi = 0.20 is the point estimate and [0.10, 0.30] is the examined band.
#
# ---------------------------------------------------------------------------
# CALIBRATION RULE HELD FIXED WHILE chi VARIES.
#
# The epidemic block sets beta = A * R0PEAK * gam * rel(theta,n) / RELREF, where
# RELREF is the peak price relevance (max over theta of ds/dn at n=0) and
# R0PEAK = 4 is the CALIBRATED peak reproduction number AT the baseline chi.
# R0PEAK pins down the structural amplification constant  mbar * A * h'(.)  of
# the adoption technology; that constant is a property of how agents react to
# the story, not of the sovereign's financing need. It must therefore stay
# FIXED as chi varies. Operationally this means RELREF is frozen at its
# chi = 0.20 baseline value in every beta evaluation (zone AND Monte Carlo)
# for chi = 0.10 and chi = 0.30. (If instead RELREF were recomputed at each
# chi, R0PEAK = 4 would be silently re-imposed at every chi, re-calibrating the
# amplification to the new pricing block -- exactly what must not happen.)
#
# The "peak price relevance" reported per chi (RelPeakChi*) is a property of
# the PRICING block and DOES move with chi; it is the model's own RELREF at
# that chi (= max ds/dn), used only for reporting, not for normalising beta.
#
# This file first reproduces the published chi = 0.20 baseline and @asserts
# agreement with output/quant_numbers.tex, then recomputes across the band and
# writes output/chi_numbers.tex. It does NOT overwrite results.json.

using SpecialFunctions, Random, Printf

Phi(x) = 0.5 * erfc(-x / sqrt(2.0))
phi(x) = exp(-0.5 * x^2) / sqrt(2.0 * pi)

# ----------------------------------------------------------- fixed parameters
# (identical to solve_model.jl; only chi -- and the derived CHIM -- vary)
const RHO  = 0.90
const SIG  = 0.05
const THSS = 0.15
const THB  = 0.0
const REC  = 0.60
const XI   = 0.03
const SHIFT = RHO * XI / SIG

const GAM0   = 0.30
const R0PEAK = 4.0
const N0SEED = 0.02

const RHOM = RHO^(1 / 12)
const SIGM = SIG / sqrt(12)

# ------------------------------------------------------- pricing fixed point
# All pricing objects are parameterized by chi (the annual feedback intensity).
zfun(th, s, chi) = (THB - RHO * th - (1 - RHO) * THSS + chi * s) / SIG
pbar(th, s, n, chi) = (1 - n) * Phi(zfun(th, s, chi)) + n * Phi(zfun(th, s, chi) + SHIFT)

"""equilibrium spread (decimal p.a.); cap = facility ceiling (Inf if none)"""
function sstar(th, n, chi; cap = Inf)
    s = 0.0
    for _ in 1:200
        snew = min((1 - REC) * pbar(th, s, n, chi), cap)
        abs(snew - s) < 1e-12 && return snew
        s = snew
    end
    return s
end

"""pricing (doom-loop) multiplier 1/(1 - gain) at the equilibrium"""
function mult(th, n, chi; cap = Inf)
    s = sstar(th, n, chi; cap = cap)
    s >= cap - 1e-12 && return 1.0
    z = zfun(th, s, chi)
    gain = (1 - REC) * ((1 - n) * phi(z) + n * phi(z + SHIFT)) * chi / SIG
    return 1 / (1 - gain)
end

"""price relevance of the story: ds/dn (discrete, h=0.05), in decimal"""
function rel(th, n, chi; cap = Inf)
    h = 0.05
    n2 = min(n + h, 1.0)
    n2 <= n && return 0.0
    (sstar(th, n2, chi; cap = cap) - sstar(th, n, chi; cap = cap)) / (n2 - n)
end

"""peak price relevance (max ds/dn over theta at n=0) -- the model's own RELREF"""
relref_of(chi) = maximum(rel(th, 0.0, chi) for th in -0.05:0.001:0.30)

# contagion rate: adoption prob proportional to price relevance of acting.
# relref is passed in explicitly so the amplification normalization can be held
# fixed at the baseline value while chi varies (see header).
beta_c(th, n, chi, relref; A = 1.0, cap = Inf) =
    A * R0PEAK * GAM0 * rel(th, n, chi; cap = cap) / relref

"""max pricing loop gain over states (uniqueness margin of the fixed point)"""
gainmax_of(chi) = maximum((1 - REC) * phi(z) * chi / SIG for z in -4:0.01:4)

"""susceptible zone {theta: R0 >= 1} for amplification A, given (chi, relref)"""
function zone(A, chi, relref)
    inz = [th for th in -0.05:0.0005:0.30 if beta_c(th, 0.0, chi, relref; A = A) >= GAM0]
    isempty(inz) ? nothing : [minimum(inz), maximum(inz)]
end

# ------------------------------------------------- state-grid interpolation
const THG = collect(-0.10:0.002:0.35)
const NG  = collect(0.0:0.02:1.0)
function tabulate(chi, relref; cap = Inf, A = 1.0)
    stab = [sstar(th, n, chi; cap = cap) for th in THG, n in NG]
    btab = [beta_c(th, n, chi, relref; A = A, cap = cap) for th in THG, n in NG]
    (stab, btab)
end
function interp(tab, th, n)
    th = clamp(th, THG[1], THG[end]); n = clamp(n, NG[1], NG[end])
    i = min(searchsortedlast(THG, th), length(THG) - 1)
    j = min(searchsortedlast(NG, n), length(NG) - 1)
    wt = (th - THG[i]) / (THG[i+1] - THG[i]); wn = (n - NG[j]) / (NG[j+1] - NG[j])
    (1-wt)*(1-wn)*tab[i,j] + wt*(1-wn)*tab[i+1,j] + (1-wt)*wn*tab[i,j+1] + wt*wn*tab[i+1,j+1]
end

# ------------------------------------------------ deterministic outbreak path
"""48-month path with no fundamentals shocks; returns theta series. CHIM=chi/12."""
function detpath_theta(th0, n0, chi, relref; gam = GAM0, cap = Inf, A = 1.0, T = 48)
    chim = chi / 12
    stab, btab = tabulate(chi, relref; cap = cap, A = A)
    ths = zeros(T)
    th = th0; n = n0
    for t in 1:T
        s = interp(stab, th, n); b = interp(btab, th, n)
        ths[t] = th
        if th < THB
            ths[t:end] .= th
            break
        end
        n  = clamp(n + b * n * (1 - n) - gam * n, 0.0, 1.0)
        th = RHOM * th + (1 - RHOM) * THSS - chim * s
    end
    ths
end

"""first month in which the zone-scenario path (th0=0.06, n0=seed) has theta<0"""
function zone_def_month(chi, relref)
    ths = detpath_theta(0.06, N0SEED, chi, relref)
    idx = findfirst(<(0), ths)
    idx === nothing ? -1 : idx
end

# ----------------------------------------------- Monte Carlo: crisis hazard
# EXACT reproduction of solve_model.jl's common-random-numbers scheme: same
# seed, same NPATH x HOR draw order, same EPS[i,t] indexing.
const NPATH = 8000; const HOR = 24
const RNG = MersenneTwister(42)
const EPS = randn(RNG, NPATH, HOR)

"""P(default within HOR months) from th0 under a configuration (see solve_model.jl)."""
function pdef(th0, n0, chi; gam = GAM0, cap = Inf, A = 1.0, tabs = nothing,
              relref = 0.0, cutk = 0, cutfrac = 0.75, capk = 0, tabs2 = nothing)
    chim = chi / 12
    stab, btab = tabs === nothing ? tabulate(chi, relref; cap = cap, A = A) : tabs
    nd = 0
    for i in 1:NPATH
        th = th0; n = n0; dead = false
        for t in 1:HOR
            if th < THB; dead = true; break; end
            t == cutk && (n *= 1 - cutfrac)
            st, bt = (capk > 0 && t >= capk) ? tabs2 : (stab, btab)
            s = interp(st, th, n); b = interp(bt, th, n)
            n  = clamp(n + b * n * (1 - n) - gam * n, 0.0, 1.0)
            th = RHOM * th + (1 - RHOM) * THSS - chim * s + SIGM * EPS[i, t]
        end
        (dead || th < THB) && (nd += 1)
    end
    nd / NPATH
end

const TH0G     = collect(0.0:0.01:0.20)
const KGRID    = collect(1:2:13)
const TH_TIMING = 0.04

"""Full set of headline magnitudes at feedback chi, with beta normalized by
   relref_norm (frozen at the baseline for chi != 0.20). Returns a NamedTuple."""
function magnitudes(chi, relref_norm)
    tab_base = tabulate(chi, relref_norm)
    tab_cap  = tabulate(chi, relref_norm; cap = 0.04)

    # (d) 24-month narrative default wedge over theta0 (same MC design/seed)
    narr   = [pdef(t0, N0SEED, chi; tabs = tab_base) for t0 in TH0G]
    nonarr = [pdef(t0, 0.0,    chi; tabs = tab_base) for t0 in TH0G]
    wedge  = narr .- nonarr
    iw = argmax(wedge)
    wedge_peak = wedge[iw]; wedge_arg = TH0G[iw]

    # (e) policy-timing (Draghi) experiment: spread cap arrives in month k
    cap_k = [pdef(TH_TIMING, N0SEED, chi; tabs = tab_base, capk = k, tabs2 = tab_cap)
             for k in KGRID]
    delay_cost = 100 * (cap_k[end] - cap_k[1])       # pp per 12 months of delay

    # (a) max loop gain; (b) peak price relevance; (c) zone (relref frozen)
    gmax  = gainmax_of(chi)
    rpeak = relref_of(chi) * 1e3                      # bp per 10pp prevalence
    z     = zone(1.0, chi, relref_norm)

    (; chi, wedge_peak, wedge_arg, cap_k, delay_cost, gmax, rpeak, zone = z,
       pcap_early = 100 * cap_k[1], pcap_late = 100 * cap_k[end],
       zdef = zone_def_month(chi, relref_norm))
end

# =====================================================================
# 1) BASELINE chi = 0.20 -- reproduce and assert against quant_numbers.tex
# =====================================================================
const RELREF_BASE = relref_of(0.20)                  # frozen amplification norm
println("RELREF_BASE (chi=0.20) = ", RELREF_BASE, "  (", round(RELREF_BASE*1e4, digits=1), " bp/unit n)")

t0 = time()
base = magnitudes(0.20, RELREF_BASE)

println("\n--- baseline chi=0.20 recomputed ---")
println("GainMax      = ", round(base.gmax, digits = 4), "  -> ", round(base.gmax, digits = 2))
println("RelPeakTen   = ", round(base.rpeak, digits = 3), "  -> ", round(Int, round(base.rpeak)))
println("zone[1.0]    = ", base.zone)
println("WedgePeak    = ", round(100*base.wedge_peak, digits = 4), "pp at th0=", base.wedge_arg)
println("PCapEarly    = ", round(base.pcap_early, digits = 3))
println("PCapLate     = ", round(base.pcap_late, digits = 3))
println("DelayCost    = ", round(base.delay_cost, digits = 3))
println("ZoneDefMonth = ", base.zdef)

# Deterministic objects: tight tolerance. MC objects: assert the PUBLISHED
# rounded values (paper rounded to 1 dp), since same-seed CRN makes them exact.
@assert round(base.gmax, digits = 2) == 0.64           "GainMax mismatch"
@assert round(Int, round(base.rpeak)) == 229           "RelPeakTen mismatch"
@assert isapprox(base.zone[1], 0.0015; atol = 1e-9)    "ZoneLo mismatch"
@assert isapprox(base.zone[2], 0.070;  atol = 1e-9)    "ZoneHi mismatch"
@assert round(100*base.wedge_peak, digits = 1) == 5.2  "WedgePeak mismatch"
@assert base.wedge_arg == 0.04                         "WedgeArg mismatch"
@assert round(base.pcap_early, digits = 1) == 46.3     "PCapEarly mismatch"
@assert round(base.pcap_late,  digits = 1) == 63.4     "PCapLate mismatch"
@assert round(Int, round(base.delay_cost)) == 17       "DelayCost mismatch"
@assert base.zdef == 42                                "ZoneDefMonth mismatch"
println("\nBASELINE REPRODUCTION: all @asserts PASSED.")

# =====================================================================
# 2) CHI BAND -- recompute at chi = 0.10 and chi = 0.30 (RELREF frozen)
# =====================================================================
lo = magnitudes(0.10, RELREF_BASE)
hi = magnitudes(0.30, RELREF_BASE)

for m in (lo, hi)
    println("\n--- chi = ", m.chi, " (RELREF frozen at baseline) ---")
    println("  max loop gain      = ", round(m.gmax, digits = 4),
            "   (multiplier 1/(1-gain) = ", round(1/(1-m.gmax), digits = 2), ")")
    println("  RelPeak (bp/10pp)  = ", round(m.rpeak, digits = 1))
    println("  susceptible zone   = ", m.zone === nothing ? "EMPTY" : m.zone)
    println("  wedge peak (pp)    = ", round(100*m.wedge_peak, digits = 2), " at th0=", m.wedge_arg)
    println("  delay cost (pp/yr) = ", round(m.delay_cost, digits = 2),
            "   (early=", round(m.pcap_early, digits=1), " late=", round(m.pcap_late, digits=1), ")")
    println("  zone default month = ", m.zdef)
end

# =====================================================================
# 3) WRITE output/chi_numbers.tex
# =====================================================================
# Formatting conventions follow quant_numbers.tex:
#   wedge/delay : 1 dp (like \WedgePeak, \DelayCost is integer -> 0 dp)
#   gain        : 2 dp (like \GainMax; a single dp would round 0.96 -> 1.0 and
#                       falsely suggest the multiplicity frontier is reached)
#   bp figures  : integer (like \RelPeakTen)
#   zone bounds : 3 dp (like \ZoneLo/\ZoneHi)
f1(x) = @sprintf("%.1f", x)
f2(x) = @sprintf("%.2f", x)
f3(x) = @sprintf("%.3f", x)
f0(x) = @sprintf("%.0f", x)

zhi(m) = m.zone === nothing ? "--" : f3(m.zone[2])

lines = [
    "\\newcommand{\\ChiGFNLo}{$(f2(0.10))}",
    "\\newcommand{\\ChiGFNHi}{$(f2(0.30))}",
    "\\newcommand{\\WedgeChiLo}{$(f1(100*lo.wedge_peak))}",
    "\\newcommand{\\WedgeChiHi}{$(f1(100*hi.wedge_peak))}",
    "\\newcommand{\\DelayChiLo}{$(f0(lo.delay_cost))}",
    "\\newcommand{\\DelayChiHi}{$(f0(hi.delay_cost))}",
    "\\newcommand{\\GainChiHi}{$(f2(hi.gmax))}",
    "\\newcommand{\\ZoneHiChiLo}{$(zhi(lo))}",
    "\\newcommand{\\ZoneHiChiHi}{$(zhi(hi))}",
    "\\newcommand{\\RelPeakChiLo}{$(f0(lo.rpeak))}",
    "\\newcommand{\\RelPeakChiHi}{$(f0(hi.rpeak))}",
]

outpath = joinpath(@__DIR__, "..", "output", "chi_numbers.tex")
open(outpath, "w") do io
    for l in lines; println(io, l); end
end

println("\n=== output/chi_numbers.tex ===")
for l in lines; println(l); end
println("\nruntime = ", round(time() - t0, digits = 1), " s")
