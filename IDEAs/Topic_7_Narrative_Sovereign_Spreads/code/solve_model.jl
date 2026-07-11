# Narrative contagion at the sovereign default boundary: numerical solution.
#
# Pricing block: one-year debt, default next year iff theta' < THB.
#   p(theta, s)      = Phi((THB - RHO*theta - (1-RHO)*THSS + CHI*s)/SIG)
#   infected belief  = p evaluated at theta - XI  (z shifted by SHIFT = RHO*XI/SIG)
#   pbar             = (1-n) p + n p_inf
#   s^D              = -log(1-(1-REC)pbar), solved as a fixed point in s^D
# Narrative block separates awareness a from belief n:
#   da/dt = kappa(theta,n)n(1-a) - gamma_a a
#   dn/dt = q kappa(theta,n)n(1-a) - gamma_n n
# where q is the probability that an attentive investor accepts the claim.
# Fundamentals (monthly): theta' = RHOM theta + (1-RHOM) THSS - CHIM s + SIGM eps
#
# Writes output/results.json. The numerical inputs define a transparent
# scenario. The empirical section of the paper specifies their data targets.

using SpecialFunctions, JSON, Random, LinearAlgebra

Phi(x) = 0.5 * erfc(-x / sqrt(2.0))
phi(x) = exp(-0.5 * x^2) / sqrt(2.0 * pi)

# ----------------------------------------------------------------- parameters
const RHO  = 0.90     # annual persistence of fundamentals
const SIG  = 0.05     # annual innovation sd
const THSS = 0.15     # long-run mean of theta
const THB  = 0.0      # default boundary
const REC  = 0.60     # recovery in default (haircut 40%)
const XI   = 0.03     # narrative pessimism: perceived theta shift
const CHI  = 0.12     # annual fundamentals drag per unit spread
const SHIFT = RHO * XI / SIG
const LIQUIDITY_PREMIUM = 0.0
const RISK_PREMIUM = 0.0

const GAMA   = 0.15   # monthly awareness decay rate
const GAMN   = 0.30   # monthly belief abandonment rate
const ACCEPTANCE = 0.60 # probability that verification supports acceptance
const R0PEAK = 4.0    # peak reproduction number at A = 1 (modern amplification)
const N0SEED = 0.02   # narrative seed after a viral event
const A0SEED = 0.08   # initially aware share after the same event

const RHOM = RHO^(1 / 12)
const SIGM = SIG * sqrt((1 - RHOM^2) / (1 - RHO^2))
const CHIM = CHI * (1 - RHOM) / (1 - RHO)

# ------------------------------------------------------- pricing fixed point
zfun(th, s) = (THB - RHO * th - (1 - RHO) * THSS + CHI * s) / SIG
pbar(th, s, n) = (1 - n) * Phi(zfun(th, s)) + n * Phi(zfun(th, s) + SHIFT)
credit_spread(p) = -log1p(-(1 - REC) * clamp(p, 0.0, 1.0))
credit_spread_derivative(p) = (1 - REC) / (1 - (1 - REC) * p)

"""Equilibrium annualized spread. Liquidity and risk premia are held fixed."""
function sstar(th, n; cap = Inf)
    s = LIQUIDITY_PREMIUM + RISK_PREMIUM
    for _ in 1:2_000
        default_component = credit_spread(pbar(th, s, n))
        snew = min(default_component + LIQUIDITY_PREMIUM + RISK_PREMIUM, cap)
        abs(snew - s) < 1e-12 && return snew
        s = 0.5 * (s + snew)
    end
    error("the pricing fixed point failed to converge")
end

"""pricing (doom-loop) multiplier 1/(1 - gain) at the equilibrium"""
function mult(th, n; cap = Inf)
    s = sstar(th, n; cap = cap)
    s >= cap - 1e-12 && return 1.0
    z = zfun(th, s)
    probability = pbar(th, s, n)
    gain = credit_spread_derivative(probability) *
        ((1 - n) * phi(z) + n * phi(z + SHIFT)) * CHI / SIG
    return 1 / (1 - gain)
end

"""Analytical price relevance ds/dn, in decimal spread units."""
function rel(th, n; cap = Inf)
    s = sstar(th, n; cap = cap)
    s >= cap - 1e-12 && return 0.0
    z = zfun(th, s)
    probability = pbar(th, s, n)
    credit_spread_derivative(probability) *
        (Phi(z + SHIFT) - Phi(z)) * mult(th, n; cap = cap)
end

function awareness_belief_drift(a, n, encounter;
                                acceptance = ACCEPTANCE,
                                gamma_a = GAMA, gamma_n = GAMN)
    0 <= n <= a <= 1 || throw(ArgumentError(
        "the state must satisfy 0 <= belief <= awareness <= 1"))
    encounter >= 0 || throw(ArgumentError("the encounter rate must be nonnegative"))
    0 <= acceptance <= 1 || throw(ArgumentError("acceptance must lie in [0,1]"))
    adoption_flow = encounter * n * (1 - a)
    da = adoption_flow - gamma_a * a
    dn = acceptance * adoption_flow - gamma_n * n
    (da, dn)
end

"""High-accuracy one-month RK4 flow for awareness and belief."""
function awareness_belief_flow(a, n, encounter; dt = 1.0, substeps = 16,
                               acceptance = ACCEPTANCE,
                               gamma_a = GAMA, gamma_n = GAMN)
    substeps >= 1 || throw(ArgumentError("substeps must be positive"))
    h = dt / substeps
    state = [a, n]
    drift(x) = collect(awareness_belief_drift(
        clamp(x[1], 0.0, 1.0), clamp(x[2], 0.0, clamp(x[1], 0.0, 1.0)),
        encounter; acceptance = acceptance, gamma_a = gamma_a,
        gamma_n = gamma_n))
    for _ in 1:substeps
        k1 = drift(state)
        k2 = drift(state + 0.5h * k1)
        k3 = drift(state + 0.5h * k2)
        k4 = drift(state + h * k3)
        state += (h / 6) * (k1 + 2k2 + 2k3 + k4)
        state[1] = clamp(state[1], 0.0, 1.0)
        state[2] = clamp(state[2], 0.0, state[1])
    end
    (state[1], state[2])
end

# Encounter intensity rises with the value of attending to the claim. The
# independent acceptance probability comes from heterogeneous verification
# signals and priors.
const RELREF = maximum(rel(th, 0.0) for th in -0.05:0.001:0.30)
attention_rate(th, n; A = 1.0, cap = Inf) =
    A * R0PEAK * GAMN * rel(th, n; cap = cap) /
    (ACCEPTANCE * RELREF)
reproduction_number(th; A = 1.0, cap = Inf) =
    ACCEPTANCE * attention_rate(th, 0.0; A = A, cap = cap) / GAMN

probability_index(z, n) = (1 - n) * Phi(z) + n * Phi(z + SHIFT)
gap(z) = Phi(z + SHIFT) - Phi(z)
gap1(z) = phi(z + SHIFT) - phi(z)
gap2(z) = -(z + SHIFT) * phi(z + SHIFT) + z * phi(z)
density_mix(z, n) = (1 - n) * phi(z) + n * phi(z + SHIFT)
density_mix1(z, n) = -(1 - n) * z * phi(z) - n * (z + SHIFT) * phi(z + SHIFT)
density_mix2(z, n) = (1 - n) * (z^2 - 1) * phi(z) +
    n * ((z + SHIFT)^2 - 1) * phi(z + SHIFT)

# Uniqueness margin of the pricing fixed point over the complete index grid.
const GAINMAX = maximum(
    credit_spread_derivative(probability_index(z, n)) *
    density_mix(z, n) * CHI / SIG
    for z in -8:0.005:8, n in 0:0.01:1)

"""Derivative of the log-slope condition for a unique equilibrium hump."""
function log_slope_derivative(z, n)
    G = gap(z)
    probability = probability_index(z, n)
    spread_slope = credit_spread_derivative(probability)
    kappa = CHI / SIG
    d = density_mix(z, n)
    d1 = density_mix1(z, n)
    d2 = density_mix2(z, n)
    denominator = 1 - spread_slope * kappa * d
    base = spread_slope^2 * d^2 + spread_slope * d1
    base_derivative = 2spread_slope^3 * d^3 +
        3spread_slope^2 * d * d1 + spread_slope * d2
    base + (gap2(z) * G - gap1(z)^2) / G^2 +
        kappa * (base_derivative * denominator + kappa * base^2) /
        denominator^2
end

const HUMP_MARGIN = maximum(log_slope_derivative(z, n)
    for z in -6:0.01:6, n in 0:0.02:1 if gap(z) > 1e-12)

# --------------------------------------------------------------- static hump
thgrid = collect(-0.05:0.0025:0.30)
hump = Dict(
    "theta"    => thgrid,
    "dsdn_bp"  => [rel(th, 0.0) * 1e4 for th in thgrid],       # bp per unit n
    "R0"       => [reproduction_number(th) for th in thgrid],
    "spread_bp"=> [sstar(th, 0.0) * 1e4 for th in thgrid],
    "p"        => [pbar(th, sstar(th, 0.0), 0.0) for th in thgrid],
    "mult"     => [mult(th, 0.0) for th in thgrid],
)

"""susceptible zone {theta: R0 >= 1} for amplification A"""
function zone(A)
    inz = [th for th in -0.05:0.0005:0.30 if reproduction_number(th; A = A) >= 1]
    isempty(inz) ? nothing : [minimum(inz), maximum(inz)]
end
AGRID = [0.25, 1.0, 1.5]                         # peak R0 = 1, 4, 6
zones = Dict(string(A) => zone(A) for A in AGRID)

# R0 curves for the zone figure
zone_fig = Dict(
    "theta" => thgrid,
    ["R0_$(round(A, digits=2))" => [reproduction_number(th; A = A) for th in thgrid]
     for A in AGRID]...,
)

# ------------------------------------------------- state-grid interpolation
THG = collect(-0.10:0.002:0.35); NG = collect(0.0:0.02:1.0)
function tabulate(; cap = Inf, A = 1.0)
    stab = [sstar(th, n; cap = cap) for th in THG, n in NG]
    encounter_tab = [attention_rate(th, n; A = A, cap = cap) for th in THG, n in NG]
    (stab, encounter_tab)
end
function interp(tab, th, n)
    th = clamp(th, THG[1], THG[end]); n = clamp(n, NG[1], NG[end])
    i = min(searchsortedlast(THG, th), length(THG) - 1)
    j = min(searchsortedlast(NG, n), length(NG) - 1)
    wt = (th - THG[i]) / (THG[i+1] - THG[i]); wn = (n - NG[j]) / (NG[j+1] - NG[j])
    (1-wt)*(1-wn)*tab[i,j] + wt*(1-wn)*tab[i+1,j] + (1-wt)*wn*tab[i,j+1] + wt*wn*tab[i+1,j+1]
end

# ------------------------------------------------ deterministic outbreak paths
"""Deterministic path for fundamentals, awareness, belief, and the spread."""
function detpath(th0, a0, n0; gamma_a = GAMA, gamma_n = GAMN,
                 cap = Inf, A = 1.0, T = 48, tabs = nothing)
    stab, encounter_tab = tabs === nothing ? tabulate(cap = cap, A = A) : tabs
    awareness = zeros(T); belief = zeros(T); spreads = zeros(T); fundamentals = zeros(T)
    th = th0; a = a0; n = n0
    for t in 1:T
        s = interp(stab, th, n)
        encounter = interp(encounter_tab, th, n)
        awareness[t] = a
        belief[t] = n
        spreads[t] = s * 1e4
        fundamentals[t] = th
        if th < THB    # default: freeze the path at the boundary
            awareness[t:end] .= a
            belief[t:end] .= n
            spreads[t:end] .= s * 1e4
            fundamentals[t:end] .= th
            break
        end
        a, n = awareness_belief_flow(
            a, n, encounter; gamma_a = gamma_a, gamma_n = gamma_n)
        th = RHOM * th + (1 - RHOM) * THSS - CHIM * s
    end
    (awareness, belief, spreads, fundamentals)
end

SC = Dict("safe" => 0.15, "zone" => 0.045, "distressed" => 0.01)
paths = Dict()
for (name, th0) in SC
    a1, n1, s1, t1 = detpath(th0, A0SEED, N0SEED)
    a2, n2, s2, t2 = detpath(th0, 0.0, 0.0)
    paths[name] = Dict("a" => a1, "n" => n1, "s" => s1, "th" => t1,
                       "a0" => a2, "n0" => n2, "s0" => s2, "th0" => t2)
end
# headline: peak excess spread and peak prevalence in the zone path
pz = paths["zone"]
peak_excess = maximum(pz["s"] .- pz["s0"]); peak_n = maximum(pz["n"])

# ----------------------------------------------- Monte Carlo: crisis hazard
const NPATH = 8000; const HOR = 24
rng = MersenneTwister(42)
EPS = randn(rng, NPATH, HOR)     # common random numbers across configurations

"""P(default within HOR months) from th0 under a configuration.
   cutk: one-shot intervention cuts awareness and belief in month cutk.
   capk: spread cap becomes available from month capk on (tabs2)."""
function pdef(th0, a0, n0; gamma_a = GAMA, gamma_n = GAMN,
              cap = Inf, A = 1.0, tabs = nothing,
              cutk = 0, cutfrac = 0.75, capk = 0, tabs2 = nothing)
    stab, encounter_tab = tabs === nothing ? tabulate(cap = cap, A = A) : tabs
    nd = 0
    for i in 1:NPATH
        th = th0; a = a0; n = n0; dead = false
        for t in 1:HOR
            if th < THB; dead = true; break; end
            if t == cutk
                a *= 1 - cutfrac
                n *= 1 - cutfrac
            end
            st, et = (capk > 0 && t >= capk) ? tabs2 : (stab, encounter_tab)
            s = interp(st, th, n)
            encounter = interp(et, th, n)
            a, n = awareness_belief_flow(
                a, n, encounter; gamma_a = gamma_a, gamma_n = gamma_n)
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
    "nonarr"   => [pdef(t0, 0.0, 0.0; tabs = tab_base) for t0 in TH0G],
    "narr"     => [pdef(t0, A0SEED, N0SEED; tabs = tab_base) for t0 in TH0G],
    "transp"   => [pdef(t0, A0SEED, N0SEED; gamma_a = 1.5GAMA,
                          gamma_n = 1.5GAMN, tabs = tab_base) for t0 in TH0G],
    "cap"      => [pdef(t0, A0SEED, N0SEED; tabs = tab_cap) for t0 in TH0G],
    "nonarr_cap" => [pdef(t0, 0.0, 0.0; tabs = tab_cap) for t0 in TH0G],
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
const TH_TIMING = mc["wedge_argmax"]
KGRID = collect(1:2:13)
timing = Dict(
    "k"      => KGRID,
    "cap_k"  => [pdef(TH_TIMING, A0SEED, N0SEED;
                       tabs = tab_base, capk = k, tabs2 = tab_cap) for k in KGRID],
    "cut_k"  => [pdef(TH_TIMING, A0SEED, N0SEED;
                       tabs = tab_base, cutk = k) for k in KGRID],
    "never"  => pdef(TH_TIMING, A0SEED, N0SEED; tabs = tab_base),
    "nonarr" => pdef(TH_TIMING, 0.0, 0.0; tabs = tab_base),
)

# Continuous monthly vector field. The default state is absorbing in the path
# solver, while the predefault attention-belief set is forward invariant.
function state_drift(th, a, n; A = 1.0, cap = Inf)
    s = sstar(th, n; cap = cap)
    encounter = attention_rate(th, n; A = A, cap = cap)
    da, dn = awareness_belief_drift(a, n, encounter)
    dtheta = (1 - RHOM) * (THSS - th) - CHIM * s
    [dtheta, da, dn]
end

# Phase portrait on the equilibrium-awareness projection a = (gamma_n /
# (acceptance gamma_a)) n implied by the two adoption nullclines.
phase_theta = collect(0.0:0.01:0.18)
phase_n = collect(0.0:0.02:0.30)
awareness_ratio = GAMN / (ACCEPTANCE * GAMA)
phase_a = [min(1.0, awareness_ratio * n) for n in phase_n]
phase_dtheta = [[state_drift(th, phase_a[j], n)[1]
    for (j, n) in enumerate(phase_n)] for th in phase_theta]
phase_dn = [[state_drift(th, phase_a[j], n)[3]
    for (j, n) in enumerate(phase_n)] for th in phase_theta]
phase = Dict("theta" => phase_theta, "a" => phase_a, "n" => phase_n,
    "dtheta" => phase_dtheta, "dn" => phase_dn)

# ------------------------------------------------ global phase audit
function raw_state_drift(th, a, n; A = 1.0, cap = Inf)
    s = sstar(th, n; cap = cap)
    encounter = attention_rate(th, n; A = A, cap = cap)
    adoption_flow = encounter * n * (1 - a)
    [(1 - RHOM) * (THSS - th) - CHIM * s,
     adoption_flow - GAMA * a,
     ACCEPTANCE * adoption_flow - GAMN * n]
end

function roots_on_interval(f, lo, hi; step = 0.001)
    grid = collect(lo:step:hi)
    roots = Float64[]
    values = f.(grid)
    for i in 1:length(grid)-1
        abs(values[i]) < 1e-12 && push!(roots, grid[i])
        values[i] * values[i + 1] >= 0 && continue
        left, right = grid[i], grid[i + 1]
        left_value = values[i]
        for _ in 1:70
            midpoint = (left + right) / 2
            midpoint_value = f(midpoint)
            if left_value * midpoint_value <= 0
                right = midpoint
            else
                left = midpoint
                left_value = midpoint_value
            end
        end
        push!(roots, (left + right) / 2)
    end
    unique(round.(roots, digits = 10))
end

function positive_equilibrium(guess)
    ratio = awareness_ratio
    upper_n = min(1 / ratio, 0.999999)
    x = collect(guess)
    residual(v) = begin
        th, n = v
        a = ratio * n
        drift = raw_state_drift(th, a, n)
        [drift[1], drift[3]]
    end
    for _ in 1:60
        f = residual(x)
        maximum(abs.(f)) < 1e-10 && break
        h = 1e-5
        jacobian = hcat(
            (residual(x + [h, 0]) - residual(x - [h, 0])) / (2h),
            (residual(x + [0, h]) - residual(x - [0, h])) / (2h),
        )
        step = try
            jacobian \ f
        catch
            return nothing
        end
        candidate = x - step
        candidate[1] = clamp(candidate[1], 1e-6, 0.35)
        candidate[2] = clamp(candidate[2], 1e-6, upper_n - 1e-6)
        old_norm = maximum(abs.(f))
        for _ in 1:12
            maximum(abs.(residual(candidate))) < old_norm && break
            candidate = 0.5 * (candidate + x)
        end
        x = candidate
    end
    maximum(abs.(residual(x))) < 1e-7 || return nothing
    (theta = x[1], awareness = ratio * x[2], belief = x[2])
end

function state_jacobian(state)
    x = [state.theta, state.awareness, state.belief]
    h = 1e-5
    hcat([(
        raw_state_drift((x + h * unit)[1], (x + h * unit)[2], (x + h * unit)[3]) -
        raw_state_drift((x - h * unit)[1], (x - h * unit)[2], (x - h * unit)[3])
    ) / (2h) for unit in ([1.0, 0, 0], [0, 1.0, 0], [0, 0, 1.0])]...)
end

function phase_equilibria()
    equilibria = NamedTuple[]
    no_story_roots = roots_on_interval(
        th -> raw_state_drift(th, 0.0, 0.0)[1], 0.0, 0.35)
    append!(equilibria, [
        (theta = th, awareness = 0.0, belief = 0.0) for th in no_story_roots])
    for th0 in 0.01:0.03:0.34, n0 in 0.01:0.025:0.29
        candidate = positive_equilibrium((th0, n0))
        isnothing(candidate) && continue
        any(maximum(abs.([candidate.theta - old.theta,
                          candidate.awareness - old.awareness,
                          candidate.belief - old.belief])) < 1e-5
            for old in equilibria) && continue
        push!(equilibria, candidate)
    end
    sort!(equilibria, by = equilibrium -> (equilibrium.theta, equilibrium.belief))
    [begin
        eigenvalues = eigvals(state_jacobian(equilibrium))
        (theta = equilibrium.theta, awareness = equilibrium.awareness,
         belief = equilibrium.belief,
         eigen_real = real.(eigenvalues), eigen_imag = imag.(eigenvalues),
         stable = maximum(real.(eigenvalues)) < 0)
    end for equilibrium in equilibria]
end

function deterministic_default(th0, n0; horizon = 240,
                               flow_substeps = 16, tabs = tab_base)
    stab, encounter_tab = tabs
    th = th0
    n = n0
    a = min(1.0, max(n, (A0SEED / N0SEED) * n))
    for _ in 1:horizon
        th < THB && return true
        s = interp(stab, th, n)
        encounter = interp(encounter_tab, th, n)
        a, n = awareness_belief_flow(
            a, n, encounter; substeps = flow_substeps)
        th = RHOM * th + (1 - RHOM) * THSS - CHIM * s
    end
    th < THB
end

function deterministic_default_month(th0, n0; horizon = 360,
                                     flow_substeps = 16, tabs = tab_base)
    stab, encounter_tab = tabs
    th = th0
    n = n0
    a = min(1.0, max(n, (A0SEED / N0SEED) * n))
    for month in 1:horizon
        th < THB && return month
        s = interp(stab, th, n)
        encounter = interp(encounter_tab, th, n)
        a, n = awareness_belief_flow(
            a, n, encounter; substeps = flow_substeps)
        th = RHOM * th + (1 - RHOM) * THSS - CHIM * s
    end
    th < THB ? horizon + 1 : 0
end

function seed_threshold(th0; horizon = 240, flow_substeps = 16)
    deterministic_default(
        th0, 0.0; horizon = horizon, flow_substeps = flow_substeps) && return 0.0
    upper = 0.25
    deterministic_default(
        th0, upper; horizon = horizon, flow_substeps = flow_substeps) || return NaN
    lower = 0.0
    for _ in 1:35
        midpoint = (lower + upper) / 2
        if deterministic_default(
                th0, midpoint; horizon = horizon,
                flow_substeps = flow_substeps)
            upper = midpoint
        else
            lower = midpoint
        end
    end
    (lower + upper) / 2
end

equilibrium_audit = phase_equilibria()
seed_theta_grid = collect(0.01:0.005:0.15)
seed_boundary = [seed_threshold(th) for th in seed_theta_grid]
zone_seed_audit = Dict(
    "horizon_120" => seed_threshold(SC["zone"]; horizon = 120),
    "horizon_240" => seed_threshold(SC["zone"]; horizon = 240),
    "horizon_360" => seed_threshold(SC["zone"]; horizon = 360),
    "substeps_8" => seed_threshold(SC["zone"]; flow_substeps = 8),
    "substeps_16" => seed_threshold(SC["zone"]; flow_substeps = 16),
    "substeps_32" => seed_threshold(SC["zone"]; flow_substeps = 32),
)
invariant_margin = minimum(begin
    encounter = attention_rate(th, n)
    da, dn = awareness_belief_drift(n, n, encounter)
    da - dn
end for th in 0.0:0.01:0.30, n in 0.0:0.01:1.0)
global_audit = Dict(
    "equilibria" => equilibrium_audit,
    "seed_theta" => seed_theta_grid,
    "seed_boundary" => seed_boundary,
    "zone_seed_audit" => zone_seed_audit,
    "zone_default_month" => deterministic_default_month(
        SC["zone"], N0SEED; horizon = 360),
    "invariant_margin" => invariant_margin,
    "awareness_face_drift" => -GAMA,
    "belief_zero_drift" => 0.0,
)

# -------------------------------------------------------------------- output
sz = sstar(SC["zone"], 0.0)
results = Dict(
    "calibration" => Dict(
        "rho" => RHO, "sig" => SIG, "thss" => THSS, "rec" => REC, "xi" => XI,
        "chi" => CHI, "shift" => SHIFT, "gamma_a" => GAMA,
        "gamma_n" => GAMN, "acceptance" => ACCEPTANCE,
        "r0peak" => R0PEAK, "a0" => A0SEED,
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
    "global_audit" => global_audit,
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
println("phase equilibria: ", [(round(e.theta, digits = 4),
    round(e.awareness, digits = 4), round(e.belief, digits = 4), e.stable)
    for e in equilibrium_audit])
println("zone seed audit: ", zone_seed_audit)
