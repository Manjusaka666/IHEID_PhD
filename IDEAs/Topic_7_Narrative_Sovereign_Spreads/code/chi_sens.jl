# Debt-service-feedback sensitivity under exact one-year bond pricing.
#
# The attention technology is normalized once at the baseline chi = 0.12.
# Stable sensitivity uses chi in [0.10, 0.20]. The script reports chi = 0.30
# separately because its global pricing gain crosses the contraction bound.

using SpecialFunctions: erfc
using Random
using Printf

Phi(x) = 0.5 * erfc(-x / sqrt(2))
phi(x) = exp(-0.5x^2) / sqrt(2pi)

const RHO_S = 0.90
const SIG_S = 0.05
const THSS_S = 0.15
const REC_S = 0.60
const XI_S = 0.03
const SHIFT_S = RHO_S * XI_S / SIG_S
const GAMA_S = 0.15
const GAMN_S = 0.30
const ACCEPTANCE_S = 0.60
const R0PEAK_S = 4.0
const A0SEED_S = 0.08
const N0SEED_S = 0.02
const RHOM_S = RHO_S^(1 / 12)
const SIGM_S = SIG_S * sqrt((1 - RHOM_S^2) / (1 - RHO_S^2))

zfun_s(th, spread, chi) =
    (-RHO_S * th - (1 - RHO_S) * THSS_S + chi * spread) / SIG_S
pbar_s(th, spread, n, chi) = (1 - n) * Phi(zfun_s(th, spread, chi)) +
    n * Phi(zfun_s(th, spread, chi) + SHIFT_S)
credit_spread_s(probability) = -log1p(-(1 - REC_S) * clamp(probability, 0, 1))
spread_slope_s(probability) =
    (1 - REC_S) / (1 - (1 - REC_S) * probability)

function sstar_s(th, n, chi; cap = Inf)
    spread = 0.0
    for _ in 1:2_000
        candidate = min(credit_spread_s(pbar_s(th, spread, n, chi)), cap)
        abs(candidate - spread) < 1e-12 && return candidate
        spread = 0.5 * (spread + candidate)
    end
    error("pricing failed at chi = $chi")
end

function multiplier_s(th, n, chi; cap = Inf)
    spread = sstar_s(th, n, chi; cap = cap)
    spread >= cap - 1e-12 && return 1.0
    z = zfun_s(th, spread, chi)
    probability = pbar_s(th, spread, n, chi)
    density = (1 - n) * phi(z) + n * phi(z + SHIFT_S)
    1 / (1 - spread_slope_s(probability) * density * chi / SIG_S)
end

function relevance_s(th, n, chi; cap = Inf)
    spread = sstar_s(th, n, chi; cap = cap)
    spread >= cap - 1e-12 && return 0.0
    z = zfun_s(th, spread, chi)
    probability = pbar_s(th, spread, n, chi)
    spread_slope_s(probability) * (Phi(z + SHIFT_S) - Phi(z)) *
        multiplier_s(th, n, chi; cap = cap)
end

relref_s(chi) = maximum(relevance_s(th, 0.0, chi) for th in -0.05:0.001:0.30)
const RELREF_BASE_S = relref_s(0.12)
attention_s(th, n, chi, normalization; A = 1.0, cap = Inf) =
    A * R0PEAK_S * GAMN_S * relevance_s(th, n, chi; cap = cap) /
    (ACCEPTANCE_S * normalization)

function awareness_belief_flow_s(a, n, encounter; substeps = 16)
    h = 1 / substeps
    state = [a, n]
    drift(x) = begin
        aa = clamp(x[1], 0, 1)
        nn = clamp(x[2], 0, aa)
        flow = encounter * nn * (1 - aa)
        [flow - GAMA_S * aa, ACCEPTANCE_S * flow - GAMN_S * nn]
    end
    for _ in 1:substeps
        k1 = drift(state)
        k2 = drift(state + 0.5h * k1)
        k3 = drift(state + 0.5h * k2)
        k4 = drift(state + h * k3)
        state += h * (k1 + 2k2 + 2k3 + k4) / 6
        state[1] = clamp(state[1], 0, 1)
        state[2] = clamp(state[2], 0, state[1])
    end
    state
end

function gainmax_s(chi)
    maximum(begin
        probability = (1 - n) * Phi(z) + n * Phi(z + SHIFT_S)
        density = (1 - n) * phi(z) + n * phi(z + SHIFT_S)
        spread_slope_s(probability) * density * chi / SIG_S
    end for z in -8:0.005:8, n in 0:0.01:1)
end

function zone_s(chi, normalization)
    points = [th for th in -0.05:0.0005:0.30 if
        ACCEPTANCE_S * attention_s(th, 0, chi, normalization) / GAMN_S >= 1]
    isempty(points) ? nothing : (minimum(points), maximum(points))
end

const TH_GRID_S = collect(-0.10:0.002:0.35)
const N_GRID_S = collect(0.0:0.02:1.0)

function tabulate_s(chi, normalization; cap = Inf)
    spreads = [sstar_s(th, n, chi; cap = cap) for th in TH_GRID_S, n in N_GRID_S]
    encounters = [attention_s(th, n, chi, normalization; cap = cap)
                  for th in TH_GRID_S, n in N_GRID_S]
    spreads, encounters
end

function interpolate_s(table, th, n)
    th = clamp(th, first(TH_GRID_S), last(TH_GRID_S))
    n = clamp(n, first(N_GRID_S), last(N_GRID_S))
    i = min(searchsortedlast(TH_GRID_S, th), length(TH_GRID_S) - 1)
    j = min(searchsortedlast(N_GRID_S, n), length(N_GRID_S) - 1)
    wt = (th - TH_GRID_S[i]) / (TH_GRID_S[i + 1] - TH_GRID_S[i])
    wn = (n - N_GRID_S[j]) / (N_GRID_S[j + 1] - N_GRID_S[j])
    (1 - wt) * (1 - wn) * table[i, j] + wt * (1 - wn) * table[i + 1, j] +
        (1 - wt) * wn * table[i, j + 1] + wt * wn * table[i + 1, j + 1]
end

const NPATH_S = 8_000
const HORIZON_S = 24
const EPS_S = randn(MersenneTwister(42), NPATH_S, HORIZON_S)

function default_probability_s(th0, a0, n0, chi; tables, cap_month = 0,
                               cap_tables = nothing)
    chim = chi * (1 - RHOM_S) / (1 - RHO_S)
    defaults = 0
    for path in 1:NPATH_S
        th, a, n = th0, a0, n0
        dead = false
        for month in 1:HORIZON_S
            if th < 0
                dead = true
                break
            end
            active = cap_month > 0 && month >= cap_month ? cap_tables : tables
            spread = interpolate_s(active[1], th, n)
            encounter = interpolate_s(active[2], th, n)
            a, n = awareness_belief_flow_s(a, n, encounter)
            th = RHOM_S * th + (1 - RHOM_S) * THSS_S - chim * spread +
                SIGM_S * EPS_S[path, month]
        end
        (dead || th < 0) && (defaults += 1)
    end
    defaults / NPATH_S
end

function magnitudes_s(chi)
    tables = tabulate_s(chi, RELREF_BASE_S)
    cap_tables = tabulate_s(chi, RELREF_BASE_S; cap = 0.04)
    theta_grid = collect(0.0:0.01:0.20)
    narrative = [default_probability_s(
        th, A0SEED_S, N0SEED_S, chi; tables = tables) for th in theta_grid]
    no_story = [default_probability_s(
        th, 0.0, 0.0, chi; tables = tables) for th in theta_grid]
    wedge = narrative - no_story
    peak_index = argmax(wedge)
    timing_theta = theta_grid[peak_index]
    timing = [default_probability_s(
        timing_theta, A0SEED_S, N0SEED_S, chi; tables = tables,
        cap_month = month, cap_tables = cap_tables) for month in 1:2:13]
    (chi = chi, wedge_peak = maximum(wedge),
     delay = last(timing) - first(timing), gain = gainmax_s(chi),
     relevance = 1_000 * relref_s(chi), zone = zone_s(chi, RELREF_BASE_S))
end

low = magnitudes_s(0.10)
high = magnitudes_s(0.20)
boundary_gain = gainmax_s(0.30)

fmt0(x) = @sprintf("%.0f", x)
fmt1(x) = @sprintf("%.1f", x)
fmt2(x) = @sprintf("%.2f", x)
fmt3(x) = @sprintf("%.3f", x)
zone_high(result) = isnothing(result.zone) ? "--" : fmt3(result.zone[2])

lines = [
    "\\newcommand{\\ChiGFNLo}{$(fmt2(low.chi))}",
    "\\newcommand{\\ChiGFNHi}{$(fmt2(high.chi))}",
    "\\newcommand{\\ChiBoundary}{$(fmt2(0.30))}",
    "\\newcommand{\\WedgeChiLo}{$(fmt1(100low.wedge_peak))}",
    "\\newcommand{\\WedgeChiHi}{$(fmt1(100high.wedge_peak))}",
    "\\newcommand{\\DelayChiLo}{$(fmt0(100low.delay))}",
    "\\newcommand{\\DelayChiHi}{$(fmt0(100high.delay))}",
    "\\newcommand{\\GainChiHi}{$(fmt2(high.gain))}",
    "\\newcommand{\\GainChiBoundary}{$(fmt2(boundary_gain))}",
    "\\newcommand{\\ZoneHiChiLo}{$(zone_high(low))}",
    "\\newcommand{\\ZoneHiChiHi}{$(zone_high(high))}",
    "\\newcommand{\\RelPeakChiLo}{$(fmt0(low.relevance))}",
    "\\newcommand{\\RelPeakChiHi}{$(fmt0(high.relevance))}",
]

output = joinpath(@__DIR__, "..", "output", "chi_numbers.tex")
open(output, "w") do io
    foreach(line -> println(io, line), lines)
end

println("baseline normalization = ", RELREF_BASE_S)
println("low = ", low)
println("high = ", high)
println("chi 0.30 boundary gain = ", boundary_gain)
println("wrote chi_numbers.tex")
