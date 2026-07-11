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
using LinearAlgebra

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
const CHI0   = 1.0         # crisis-liquidity multiplier, actuarial lower bound
const ZETA_H = 0.5         # issuer capture share, reported over [0.25, 1]
const MGRID  = [1.0, 1.5, 2.5]   # network multiplier variants (baseline 1.5)
const M0     = 1.5

kappa() = CY0 / N0

sanctions_wedge(sbar::Real, p::Real; omega::Real = OMEGA,
                 phi::Real = PHI, chi::Real = CHI0) =
    Float64(omega * sbar * p * phi * chi)

function heterogeneous_local_response(
        kappas::Vector{Float64}, loadings::Vector{Float64},
        exposure::Vector{Float64}, crisis_multipliers::Vector{Float64},
        convenience_slope::Float64)
    n = length(kappas)
    all(length(v) == n for v in (loadings, exposure, crisis_multipliers)) ||
        throw(DimensionMismatch("heterogeneous arrays must have equal length"))
    all(kappas .> 0) || throw(ArgumentError("portfolio curvatures must be positive"))
    direct = -sum(exposure .* crisis_multipliers ./ kappas) / n
    network_loading = sum(loadings ./ kappas) / n
    denominator = 1 - convenience_slope * network_loading
    denominator > 0 || throw(ArgumentError("the local aggregate response is unstable"))
    multiplier = 1 / denominator
    (direct = direct, multiplier = multiplier, total = direct * multiplier,
     network_loading = network_loading)
end

function heterogeneous_dynamics(
        kappas::Vector{Float64}, adjustment_costs::Vector{Float64},
        loadings::Vector{Float64}, reserve_weights::Vector{Float64},
        convenience_slope::Float64;
        beta::Float64 = BETA_C,
        contrast::Union{Nothing,Vector{Float64}} = nothing)
    n = length(kappas)
    all(length(vector) == n for vector in
        (adjustment_costs, loadings, reserve_weights)) ||
        throw(DimensionMismatch("heterogeneous arrays must have equal length"))
    all(kappas .> 0) || throw(ArgumentError(
        "portfolio curvatures must be positive"))
    all(adjustment_costs .> 0) || throw(ArgumentError(
        "adjustment costs must be positive"))
    all(reserve_weights .>= 0) || throw(ArgumentError(
        "reserve weights must be nonnegative"))
    isapprox(sum(reserve_weights), 1.0; atol = 1e-12) ||
        throw(ArgumentError("reserve weights must sum to one"))
    0 < beta < 1 || throw(ArgumentError("beta must lie in (0,1)"))
    isnothing(contrast) || length(contrast) == n || throw(DimensionMismatch(
        "the contrast must match the number of reserve managers"))

    forward = Diagonal(beta .* adjustment_costs)
    current = Diagonal(kappas .+ (1 + beta) .* adjustment_costs) .-
        convenience_slope .* loadings * reserve_weights'
    lagged = Diagonal(adjustment_costs)
    companion = [forward \ current -(forward \ lagged);
                 Matrix{Float64}(I, n, n) zeros(n, n)]
    decomposition = eigen(companion)
    stable_indices = findall(abs.(decomposition.values) .< 1 - 1e-10)
    length(stable_indices) == n || throw(ArgumentError(
        "the linearized system must have exactly n stable roots"))
    stable_roots = decomposition.values[stable_indices]
    stable_vectors = decomposition.vectors[1:n, stable_indices]

    function observable_persistence(observable::Vector{Float64})
        mode_loadings = abs.(vec(observable' * stable_vectors))
        cutoff = max(maximum(mode_loadings) * 1e-8, 1e-12)
        active = findall(mode_loadings .> cutoff)
        isempty(active) && return 0.0
        maximum(abs.(stable_roots[active]))
    end

    stable_transition = stable_vectors * Diagonal(stable_roots) *
        inv(stable_vectors)
    imaginary_residual = maximum(abs.(imag.(stable_transition)))
    transition = imaginary_residual < 1e-10 ?
        real.(stable_transition) : stable_transition
    (companion = companion,
     stable_roots = stable_roots,
     transition = transition,
     aggregate_persistence = observable_persistence(reserve_weights),
     contrast_persistence = isnothing(contrast) ? NaN :
        observable_persistence(contrast))
end

function multiplier_identified_set(direct_decline::Tuple{Float64,Float64},
                                   aggregate_decline::Tuple{Float64,Float64})
    direct_lower, direct_upper = direct_decline
    total_lower, total_upper = aggregate_decline
    0 < direct_lower <= direct_upper || throw(ArgumentError(
        "the direct-response interval must be positive and ordered"))
    0 < total_lower <= total_upper || throw(ArgumentError(
        "the aggregate-response interval must be positive and ordered"))
    lower = max(1.0, total_lower / direct_upper)
    upper = total_upper / direct_lower
    lower <= upper || throw(ArgumentError(
        "the response intervals have an empty multiplier set"))
    (lower = lower, upper = upper)
end

function minimum_reputation_beta(flow_gap::Float64,
                                 deviation_gain::Float64,
                                 forgiveness::Float64 = 0.0)
    flow_gap > 0 || throw(ArgumentError("flow_gap must be positive"))
    deviation_gain >= 0 || throw(ArgumentError(
        "deviation_gain must be nonnegative"))
    0 <= forgiveness <= 1 || throw(ArgumentError(
        "forgiveness must lie in [0,1]"))
    deviation_gain /
        (flow_gap + deviation_gain * (1 - forgiveness))
end

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
privilege(N::Real, cb; zeta::Real = ZETA_H) =
    Float64(zeta * (cb.l0 + cb.l1 * N) * N * W)

function ss(pihat::Float64, cb; rbar::Float64 = 0.0, zeta::Float64 = ZETA_H)
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
    (aE = aE, aA = aA, N = N, cy = cy,
     gross_priv = cy * N * W, priv = privilege(N, cb; zeta = zeta))
end

pihat_of(sbar, p; phi = PHI, chi = CHI0) =
    sanctions_wedge(sbar, p; phi = phi, chi = chi)

function global_calib(m::Float64; tau::Float64 = 0.002,
                      lmin::Float64 = 0.001, lmax::Float64 = 0.012,
                      convenience::Symbol = :logistic,
                      cost::Symbol = :cubic)
    lmin < CY0 < lmax || throw(ArgumentError("CY0 must lie between the bounds"))
    tau >= 0 || throw(ArgumentError("tau must be nonnegative"))
    convenience in (:logistic, :hill, :power) || throw(ArgumentError(
        "unknown convenience closure"))
    cost in (:quadratic, :cubic, :quintic) || throw(ArgumentError(
        "unknown portfolio-cost closure"))
    local_cb = calib(m)
    share = (CY0 - lmin) / (lmax - lmin)
    steepness = local_cb.l1 / ((lmax - lmin) * share * (1 - share))
    center = steepness == 0 ? N0 :
        N0 - log(share / (1 - share)) / steepness
    hill_elasticity = local_cb.l1 == 0 ? 1.0 :
        local_cb.l1 * N0 / ((lmax - lmin) * share * (1 - share))
    hill_scale = N0 * ((1 - share) / share)^(1 / hill_elasticity)
    power_exponent = local_cb.l1 == 0 ? 1.0 :
        local_cb.l1 * N0 / (CY0 - lmin)
    power_scale = (CY0 - lmin) / N0^power_exponent
    cost_power = cost === :quintic ? 5 : 3
    effective_tau = cost === :quadratic ? 0.0 : tau
    quadratic = local_cb.kap -
        cost_power * effective_tau * N0^(cost_power - 1)
    quadratic > 0 || throw(ArgumentError("tau makes the quadratic curvature negative"))
    rbar = quadratic * N0 + effective_tau * N0^cost_power - CY0
    (m = m, lmin = lmin, lmax = lmax, steepness = steepness,
     center = center, hill_elasticity = hill_elasticity,
     hill_scale = hill_scale, power_exponent = power_exponent,
     power_scale = power_scale, convenience = convenience,
     cost = cost, cost_power = cost_power,
     quadratic = quadratic, tau = effective_tau, rbar = rbar,
     local_model = local_cb)
end

function global_convenience(N::Real, gc)
    gc.local_model.l1 == 0 && return CY0
    if gc.convenience === :logistic
        return gc.lmin + (gc.lmax - gc.lmin) /
            (1 + exp(-gc.steepness * (N - gc.center)))
    elseif gc.convenience === :hill
        numerator = N^gc.hill_elasticity
        return gc.lmin + (gc.lmax - gc.lmin) * numerator /
            (gc.hill_scale^gc.hill_elasticity + numerator)
    end
    gc.lmin + gc.power_scale * N^gc.power_exponent
end

function global_convenience_slope(N::Real, gc)
    gc.local_model.l1 == 0 && return 0.0
    if gc.convenience === :logistic
        share = (global_convenience(N, gc) - gc.lmin) /
            (gc.lmax - gc.lmin)
        return (gc.lmax - gc.lmin) * gc.steepness * share * (1 - share)
    elseif gc.convenience === :hill
        N == 0 && return gc.hill_elasticity < 1 ? Inf : 0.0
        share = (global_convenience(N, gc) - gc.lmin) /
            (gc.lmax - gc.lmin)
        return (gc.lmax - gc.lmin) * gc.hill_elasticity *
            share * (1 - share) / N
    end
    N == 0 && return gc.power_exponent < 1 ? Inf :
        gc.power_scale * gc.power_exponent
    gc.power_scale * gc.power_exponent * N^(gc.power_exponent - 1)
end

global_marginal_cost(a::Real, gc) =
    gc.quadratic * a + gc.tau * a^gc.cost_power
global_marginal_cost_slope(a::Real, gc) =
    gc.quadratic + gc.cost_power * gc.tau * a^(gc.cost_power - 1)

function global_share(net::Float64, wedge::Float64, gc)
    benefit = gc.rbar + global_convenience(net, gc) - wedge
    benefit <= 0 && return 0.0
    benefit >= global_marginal_cost(1.0, gc) && return 1.0
    lo, hi = 0.0, 1.0
    for _ in 1:80
        mid = (lo + hi) / 2
        global_marginal_cost(mid, gc) < benefit ? (lo = mid) : (hi = mid)
    end
    (lo + hi) / 2
end

function global_residual(net::Float64, wedge::Float64, gc;
                         mu::Float64 = MU)
    mu * global_share(net, wedge, gc) +
        (1 - mu) * global_share(net, 0.0, gc) - net
end

function global_roots(wedge::Float64, gc;
                      mu::Float64 = MU,
                      grid_points::Int = 20_001)
    grid_points >= 3 || throw(ArgumentError("grid_points must be at least three"))
    grid = range(0.0, 1.0, length = grid_points)
    residuals = [global_residual(Float64(net), wedge, gc; mu = mu)
                 for net in grid]
    roots = Float64[]
    for index in 1:grid_points-1
        left = Float64(grid[index])
        right = Float64(grid[index + 1])
        fleft = residuals[index]
        fright = residuals[index + 1]
        abs(fleft) < 1e-12 && push!(roots, left)
        signbit(fleft) == signbit(fright) && continue
        for _ in 1:80
            midpoint = (left + right) / 2
            fmid = global_residual(midpoint, wedge, gc; mu = mu)
            if signbit(fmid) == signbit(fleft)
                left = midpoint
                fleft = fmid
            else
                right = midpoint
            end
        end
        push!(roots, (left + right) / 2)
    end
    abs(residuals[end]) < 1e-12 && push!(roots, 1.0)
    sort!(roots)
    unique_roots = Float64[]
    for root in roots
        (isempty(unique_roots) || abs(root - unique_roots[end]) > 1e-8) &&
            push!(unique_roots, root)
    end
    unique_roots
end

function global_ss(wedge::Float64, gc; mu::Float64 = MU,
                   zeta::Float64 = ZETA_H)
    0 <= mu <= 1 || throw(ArgumentError("mu must lie in [0,1]"))
    N = N0
    for _ in 1:100_000
        aE = global_share(N, wedge, gc)
        aA = global_share(N, 0.0, gc)
        updated = mu * aE + (1 - mu) * aA
        abs(updated - N) < 1e-13 && begin
            N = updated
            break
        end
        N = 0.5 * N + 0.5 * updated
    end
    aE = global_share(N, wedge, gc)
    aA = global_share(N, 0.0, gc)
    cy = global_convenience(N, gc)
    (aE = aE, aA = aA, N = N, cy = cy,
     gross_priv = cy * N * W, priv = zeta * cy * N * W)
end

function gamma_threshold(p::Float64, gc; zeta::Float64 = ZETA_H,
                         chi::Float64 = CHI0, mu::Float64 = MU,
                         phi::Float64 = PHI)
    baseline = global_ss(0.0, gc; mu = mu, zeta = zeta)
    sanctioned = global_ss(
        sanctions_wedge(1.0, p; phi = phi, chi = chi), gc;
        mu = mu, zeta = zeta)
    2 * (baseline.priv - sanctioned.priv) / OMEGA
end

function break_even_breadth(gc; gam::Float64 = GAM,
                            zeta::Float64 = ZETA_H,
                            chi::Float64 = CHI0,
                            mu::Float64 = MU,
                            phi::Float64 = PHI)
    net_value(p) = global_hflow(
        1.0, p, gc; gam = gam, zeta = zeta, chi = chi, mu = mu,
        phi = phi) -
        global_hflow(
            0.0, p, gc; gam = gam, zeta = zeta, chi = chi, mu = mu,
            phi = phi)
    left = 0.0
    right = 1.0
    net_value(left) >= 0 || throw(ArgumentError(
        "full intensity must weakly dominate at zero breadth"))
    net_value(right) <= 0 || return NaN
    for _ in 1:100
        midpoint = (left + right) / 2
        if net_value(midpoint) > 0
            left = midpoint
        else
            right = midpoint
        end
    end
    (left + right) / 2
end

function global_hflow(sbar::Float64, p::Float64, gc; gam::Float64 = GAM,
                      zeta::Float64 = ZETA_H, chi::Float64 = CHI0,
                      mu::Float64 = MU, phi::Float64 = PHI)
    allocation = global_ss(
        sanctions_wedge(sbar, p; chi = chi, phi = phi), gc;
        mu = mu, zeta = zeta)
    allocation.priv + OMEGA * gam * (sbar - 0.5 * sbar^2)
end

function global_ramsey(p::Float64, gc; gam::Float64 = GAM,
                       zeta::Float64 = ZETA_H, chi::Float64 = CHI0)
    best_s, best_value = 0.0, -Inf
    for sanction in 0.0:0.0005:1.0
        value = global_hflow(
            sanction, p, gc; gam = gam, zeta = zeta, chi = chi)
        if value > best_value
            best_s, best_value = sanction, value
        end
    end
    (s = best_s, v = best_value)
end

# hegemon flow value (bn USD per year) at anticipated rule sbar, breadth p
function hflow(sbar::Float64, p::Float64, cb; gam = GAM,
               zeta::Float64 = ZETA_H, chi::Float64 = CHI0)
    s = ss(pihat_of(sbar, p; chi = chi), cb; zeta = zeta)
    s.priv + OMEGA * gam * (sbar - 0.5 * sbar^2)
end

"Ramsey rule: maximize steady-state flow value over sbar on a fine grid
(closed form exists in the interior region; the grid handles corners)."
function ramsey(p::Float64, cb; gam = GAM, zeta::Float64 = ZETA_H,
                chi::Float64 = CHI0)
    sgrid = 0.0:0.0005:1.0
    best_s, best_v = 0.0, -Inf
    for sb in sgrid
        v = hflow(sb, p, cb; gam = gam, zeta = zeta, chi = chi)
        if v > best_v
            best_v, best_s = v, sb
        end
    end
    (s = best_s, v = best_v)
end

# ------------------------------------------------------------------ dynamics
"Perfect-foresight path after a permanent jump of the exposed loss rate from
0 to pihat at t=1, starting from the pre-shock steady state (interior case)."
function transition(pihat::Float64, cb; T::Int = 31, zeta::Float64 = ZETA_H)
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
    priv = [zeta * cy[t] * Npath[t] * W for t in 1:T]
    Dict("N" => Npath, "aE" => aE, "aA" => aA, "cy" => cy, "priv" => priv)
end

# ----------------------------------------------------------------------- run
function main()
    results = Dict{String,Any}()
    cb0 = calib(M0)
    gc0 = global_calib(M0)
    results["calibration"] = Dict(
        "kappa" => cb0.kap, "l0" => cb0.l0, "l1" => cb0.l1, "nu" => cb0.nu,
        "lamN" => cb0.lamN, "lamD" => cb0.lamD, "beta_c" => BETA_C,
        "CY0" => CY0, "N0" => N0, "mu" => MU, "W" => W, "omega" => OMEGA,
        "phi" => PHI, "chi" => CHI0, "zeta_h" => ZETA_H,
        "p_single" => PSING, "half_life" => HL, "gamma" => GAM,
        "multiplier" => M0, "pihat_single" => pihat_of(1.0, PSING),
        "global_lmin" => gc0.lmin, "global_lmax" => gc0.lmax,
        "global_steepness" => gc0.steepness,
        "global_center" => gc0.center, "global_tau" => gc0.tau)

    # steady states: pre, post single-use (sbar=1), post routine breadth
    PROUT = 0.25
    pre = ss(0.0, cb0)
    post1 = ss(pihat_of(1.0, PSING), cb0)
    postR = global_ss(pihat_of(1.0, PROUT), gc0)
    softR = global_ss(pihat_of(1.0, PSING; phi = 0.15), gc0)
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

    # Global sanctions-use frontier with bounded convenience and convex costs.
    pgrid = collect(0.0:0.01:0.5)
    frontier = Dict{String,Any}("p" => pgrid)
    frontier["v_weaponize"] = [global_hflow(1.0, p, gc0) for p in pgrid]
    frontier["v_restraint"] = [global_hflow(0.0, p, gc0) for p in pgrid]
    frontier["N_weaponize"] = [global_ss(pihat_of(1.0, p), gc0).N for p in pgrid]
    frontier["s_R"] = [global_ramsey(p, gc0).s for p in pgrid]
    frontier["gamma_threshold"] = [gamma_threshold(p, gc0) for p in pgrid]
    results["frontier"] = frontier

    threshold = Dict{String,Any}()
    for zeta in (0.25, 0.5, 1.0), chi in (1.0, 2.0, 4.0)
        key = "zeta_$(zeta)_chi_$(chi)"
        threshold[key] = Dict(
            "gamma_at_p_0.02" => gamma_threshold(
                PSING, gc0; zeta = zeta, chi = chi),
            "gamma_at_p_0.10" => gamma_threshold(
                0.10, gc0; zeta = zeta, chi = chi),
            "gamma_at_p_0.25" => gamma_threshold(
                PROUT, gc0; zeta = zeta, chi = chi))
    end
    results["geopolitical_thresholds"] = threshold

    functional_forms = Dict{String,Any}()
    routine_wedge = sanctions_wedge(1.0, PROUT)
    for convenience in (:logistic, :hill, :power)
        for cost in (:quadratic, :cubic, :quintic)
            alternative = global_calib(
                M0; convenience = convenience, cost = cost)
            roots = global_roots(routine_wedge, alternative)
            key = "$(convenience)_$(cost)"
            functional_forms[key] = Dict(
                "break_even_breadth" => break_even_breadth(alternative),
                "gamma_threshold_p_0.10" => gamma_threshold(0.10, alternative),
                "routine_root_count" => length(roots),
                "routine_roots" => roots,
                "continued_routine_share" =>
                    global_ss(routine_wedge, alternative).N,
            )
        end
    end
    results["functional_forms"] = functional_forms

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

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
