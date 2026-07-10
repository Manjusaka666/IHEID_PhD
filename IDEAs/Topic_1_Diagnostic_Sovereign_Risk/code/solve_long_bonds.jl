# Long-duration implementation of the diagnostic sovereign default model.
# A fraction maturity of each bond matures next period. The remaining fraction
# pays coupon and retains the successor-market price. Bond parameters follow
# Chatterjee and Eyigungor (2012): maturity = 0.05 and coupon = 0.03 quarterly.

if !isdefined(Main, :build_kernels)
    include("solve_model.jl")
end

const LONG_MATURITY = 0.05
const LONG_COUPON = 0.03
const LONG_BETA = 0.95460
const LONG_D0 = -0.18845
const LONG_D1 = 0.24559
const LONG_REENTRY = 0.0385
const LONG_RSTAR = 0.01
const LONG_RHO = 0.948503
const LONG_SIGE = 0.027092
const LONG_SIGMA_M = 0.003
const LONG_TRUNCATION = 3.0
const LONG_NM = 15
const LONG_NB = 50
const LONG_BMAX = 1.50

function long_transition_from_means(x::Vector{Float64},
                                    means::Vector{Float64},
                                    sigma::Float64)
    step = x[2] - x[1]
    P = zeros(length(means), length(x))
    @inbounds for i in eachindex(means)
        z = (x .- means[i]) ./ sigma
        for j in 2:length(x)-1
            P[i, j] = Phi(z[j] + 0.5 * step / sigma) -
                Phi(z[j] - 0.5 * step / sigma)
        end
        P[i, 1] = Phi(z[1] + 0.5 * step / sigma)
        P[i, end] = 1 - Phi(z[end] - 0.5 * step / sigma)
    end
    P
end

function build_long_kernels(theta::Float64)
    stdx = LONG_SIGE / sqrt(1 - LONG_RHO^2)
    x = collect(range(-MT * stdx, MT * stdx, length = NY))
    P = long_transition_from_means(x, LONG_RHO .* x, LONG_SIGE)
    Pd = zeros(NY, NY, NY)
    @inbounds for ih in 1:NY
        means = LONG_RHO .* x .+ theta * LONG_RHO .* (x .- x[ih])
        Pd[:, ih, :] = long_transition_from_means(x, means, LONG_SIGE)
    end
    x, P, Pd
end

function standard_normal_quantile(probability::Float64)
    0 < probability < 1 || throw(ArgumentError("probability must lie in (0,1)"))
    lo = -8.0
    hi = 8.0
    for _ in 1:60
        mid = (lo + hi) / 2
        if Phi(mid) < probability
            lo = mid
        else
            hi = mid
        end
    end
    (lo + hi) / 2
end

function transitory_grid(nm::Int, sigma_m::Float64)
    nm == 1 && return ([0.0], [1.0])
    nm >= 3 || throw(ArgumentError("quadrature requires at least three nodes"))
    lower = Phi(-LONG_TRUNCATION)
    mass = Phi(LONG_TRUNCATION) - lower
    probabilities = [lower + mass * (i - 0.5) / nm for i in 1:nm]
    nodes = sigma_m .* standard_normal_quantile.(probabilities)
    nodes, fill(1 / nm, nm)
end

function truncated_normal_cdf(m::Float64, sigma_m::Float64)
    lower = Phi(-LONG_TRUNCATION)
    mass = Phi(LONG_TRUNCATION) - lower
    clamp((Phi(m / sigma_m) - lower) / mass, 0.0, 1.0)
end

long_riskfree_price(maturity::Float64, coupon::Float64,
                    rstar::Float64 = LONG_RSTAR) =
    (maturity + (1 - maturity) * coupon) / (maturity + rstar)

function long_action_value(action::Int, m::Float64, ib::Int, ix::Int, ih::Int,
                           b::Vector{Float64}, y::Vector{Float64},
                           q::Array{Float64,3}, W::Matrix{Float64},
                           Vd::Vector{Float64}, payment::Float64,
                           maturity::Float64, beta::Float64)
    action == 0 && return Vd[ix]
    net_issue = b[action] - (1 - maturity) * b[ib]
    c = y[ix] + m - payment * b[ib] + q[action, ix, ih] * net_issue
    util(c) + beta * W[action, ix]
end

@inline function long_repayment_choice(
        m::Float64, ib::Int, ix::Int, ih::Int, b::Vector{Float64},
        y::Vector{Float64}, q::Array{Float64,3}, W::Matrix{Float64},
        Vd::Vector{Float64}, payment::Float64, maturity::Float64,
        beta::Float64, first_action::Int, last_action::Int)
    1 <= first_action <= last_action <= length(b) ||
        throw(ArgumentError("invalid repayment action range"))
    best = -Inf
    ibest = first_action
    @inbounds for action in first_action:last_action
        value = long_action_value(action, m, ib, ix, ih, b, y, q, W, Vd,
                                  payment, maturity, beta)
        if value > best
            best = value
            ibest = action
        end
    end
    best, ibest
end

@inline function long_choice_at_m_range(
        m::Float64, ib::Int, ix::Int, ih::Int, b::Vector{Float64},
        y::Vector{Float64}, q::Array{Float64,3}, W::Matrix{Float64},
        Vd::Vector{Float64}, payment::Float64, maturity::Float64,
        beta::Float64, first_action::Int, last_action::Int)
    best, ibest = long_repayment_choice(
        m, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        first_action, last_action)
    (Vd[ix] > best ? 0 : ibest), ibest
end

function long_choice_at_m(m::Float64, ib::Int, ix::Int, ih::Int,
                          b::Vector{Float64}, y::Vector{Float64},
                          q::Array{Float64,3}, W::Matrix{Float64},
                          Vd::Vector{Float64}, payment::Float64,
                          maturity::Float64, beta::Float64)
    action, _ = long_choice_at_m_range(
        m, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta, 1, length(b))
    action
end

function long_choice_boundary(left_action::Int, right_action::Int,
                              lo::Float64, hi::Float64, ib::Int, ix::Int,
                              ih::Int, b::Vector{Float64}, y::Vector{Float64},
                              q::Array{Float64,3}, W::Matrix{Float64},
                              Vd::Vector{Float64}, payment::Float64,
                              maturity::Float64, beta::Float64)
    difference(m) = long_action_value(left_action, m, ib, ix, ih, b, y, q,
                                      W, Vd, payment, maturity, beta) -
        long_action_value(right_action, m, ib, ix, ih, b, y, q, W, Vd,
                          payment, maturity, beta)
    dlo = difference(lo)
    dhi = difference(hi)
    if dlo < 0 || dhi > 0
        return (lo + hi) / 2
    end
    for _ in 1:45
        mid = (lo + hi) / 2
        if difference(mid) >= 0
            lo = mid
        else
            hi = mid
        end
    end
    (lo + hi) / 2
end

function long_choice_payoff(action::Int, ix::Int, ih::Int,
                            q::Array{Float64,3}, maturity::Float64,
                            coupon::Float64)
    action == 0 && return 0.0
    maturity + (1 - maturity) * (coupon + q[action, ix, ih])
end

function long_collect_switches!(thresholds::Vector{Float64},
                                actions::Vector{Int}, lo::Float64,
                                left_action::Int, hi::Float64,
                                right_action::Int, ib::Int, ix::Int, ih::Int,
                                b::Vector{Float64}, y::Vector{Float64},
                                q::Array{Float64,3}, W::Matrix{Float64},
                                Vd::Vector{Float64}, payment::Float64,
                                maturity::Float64, beta::Float64,
                                depth::Int)
    left_action == right_action && return
    depth <= 64 || error("policy-envelope recursion exceeded floating-point depth")
    boundary = long_choice_boundary(left_action, right_action, lo, hi, ib, ix,
                                    ih, b, y, q, W, Vd, payment, maturity,
                                    beta)
    width = hi - lo
    epsilon = max(1e-11, 1e-7 * width)
    left_probe = max(lo, boundary - epsilon)
    right_probe = min(hi, boundary + epsilon)
    probe_left_action = long_choice_at_m(left_probe, ib, ix, ih, b, y, q, W,
                                         Vd, payment, maturity, beta)
    probe_right_action = long_choice_at_m(right_probe, ib, ix, ih, b, y, q, W,
                                          Vd, payment, maturity, beta)
    boundary_action = long_choice_at_m(boundary, ib, ix, ih, b, y, q, W, Vd,
                                       payment, maturity, beta)

    if probe_left_action == left_action && probe_right_action == right_action &&
            (boundary_action == left_action || boundary_action == right_action)
        push!(thresholds, boundary)
        push!(actions, right_action)
        return
    end

    mid = (lo + hi) / 2
    mid_action = long_choice_at_m(mid, ib, ix, ih, b, y, q, W, Vd, payment,
                                  maturity, beta)
    if mid == lo || mid == hi
        push!(thresholds, mid)
        push!(actions, right_action)
        return
    end
    long_collect_switches!(thresholds, actions, lo, left_action, mid,
                           mid_action, ib, ix, ih, b, y, q, W, Vd, payment,
                           maturity, beta, depth + 1)
    long_collect_switches!(thresholds, actions, mid, mid_action, hi,
                           right_action, ib, ix, ih, b, y, q, W, Vd, payment,
                           maturity, beta, depth + 1)
end

function long_policy_segments(ib::Int, ix::Int, ih::Int,
                              b::Vector{Float64}, y::Vector{Float64},
                              q::Array{Float64,3}, W::Matrix{Float64},
                              Vd::Vector{Float64}, payment::Float64,
                              maturity::Float64, beta::Float64,
                              sigma_m::Float64)
    sigma_m > 0 || throw(ArgumentError("sigma_m must be positive"))
    lo = -LONG_TRUNCATION * sigma_m
    hi = LONG_TRUNCATION * sigma_m
    left_action = long_choice_at_m(lo, ib, ix, ih, b, y, q, W, Vd, payment,
                                   maturity, beta)
    right_action = long_choice_at_m(hi, ib, ix, ih, b, y, q, W, Vd, payment,
                                    maturity, beta)
    thresholds = Float64[]
    actions = Int[left_action]
    long_collect_switches!(thresholds, actions, lo, left_action, hi,
                           right_action, ib, ix, ih, b, y, q, W, Vd, payment,
                           maturity, beta, 1)
    thresholds, actions
end

function long_expected_payoff_continuous_reference(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64)
    thresholds, actions = long_policy_segments(
        ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta, sigma_m)
    value = 0.0
    last_probability = 0.0
    @inbounds for k in eachindex(thresholds)
        probability = truncated_normal_cdf(thresholds[k], sigma_m)
        value += (probability - last_probability) *
            long_choice_payoff(actions[k], ix, ih, q, maturity, coupon)
        last_probability = probability
    end
    value + (1 - last_probability) *
        long_choice_payoff(actions[end], ix, ih, q, maturity, coupon)
end

function long_expected_payoff_interval(
        lo::Float64, left_action::Int, left_repayment::Int, hi::Float64,
        right_action::Int, right_repayment::Int,
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64, depth::Int)
    probability_lo = truncated_normal_cdf(lo, sigma_m)
    probability_hi = truncated_normal_cdf(hi, sigma_m)
    if left_action == right_action
        return (probability_hi - probability_lo) *
            long_choice_payoff(left_action, ix, ih, q, maturity, coupon)
    end
    depth <= 64 || error("policy-envelope recursion exceeded floating-point depth")

    boundary = long_choice_boundary(left_action, right_action, lo, hi, ib, ix,
                                    ih, b, y, q, W, Vd, payment, maturity,
                                    beta)
    epsilon = max(1e-11, 1e-7 * (hi - lo))
    left_probe = max(lo, boundary - epsilon)
    right_probe = min(hi, boundary + epsilon)
    first_action = min(left_repayment, right_repayment)
    last_action = max(left_repayment, right_repayment)
    probe_left_action, _ = long_choice_at_m_range(
        left_probe, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        first_action, last_action)
    probe_right_action, _ = long_choice_at_m_range(
        right_probe, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        first_action, last_action)
    boundary_action, _ = long_choice_at_m_range(
        boundary, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        first_action, last_action)

    if probe_left_action == left_action && probe_right_action == right_action &&
            (boundary_action == left_action || boundary_action == right_action)
        probability_boundary = truncated_normal_cdf(boundary, sigma_m)
        return (probability_boundary - probability_lo) *
            long_choice_payoff(left_action, ix, ih, q, maturity, coupon) +
            (probability_hi - probability_boundary) *
            long_choice_payoff(right_action, ix, ih, q, maturity, coupon)
    end

    mid = (lo + hi) / 2
    if mid == lo || mid == hi
        probability_mid = truncated_normal_cdf(mid, sigma_m)
        return (probability_mid - probability_lo) *
            long_choice_payoff(left_action, ix, ih, q, maturity, coupon) +
            (probability_hi - probability_mid) *
            long_choice_payoff(right_action, ix, ih, q, maturity, coupon)
    end
    mid_action, mid_repayment = long_choice_at_m_range(
        mid, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        first_action, last_action)
    long_expected_payoff_interval(
        lo, left_action, left_repayment, mid, mid_action, mid_repayment, ib,
        ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m,
        depth + 1) +
    long_expected_payoff_interval(
        mid, mid_action, mid_repayment, hi, right_action, right_repayment, ib,
        ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m,
        depth + 1)
end

function long_expected_payoff_continuous_fast(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64, low_repayment_hint::Int,
        high_repayment_hint::Int)
    sigma_m > 0 || throw(ArgumentError("sigma_m must be positive"))
    1 <= low_repayment_hint <= length(b) ||
        throw(ArgumentError("invalid low-income repayment hint"))
    1 <= high_repayment_hint <= length(b) ||
        throw(ArgumentError("invalid high-income repayment hint"))
    lo = -LONG_TRUNCATION * sigma_m
    hi = LONG_TRUNCATION * sigma_m
    left_action, left_repayment = long_choice_at_m_range(
        lo, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta,
        low_repayment_hint, length(b))
    right_action, right_repayment = long_choice_at_m_range(
        hi, ib, ix, ih, b, y, q, W, Vd, payment, maturity, beta, 1,
        high_repayment_hint)
    long_expected_payoff_interval(
        lo, left_action, left_repayment, hi, right_action, right_repayment,
        ib, ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m, 1)
end

@inline function long_expected_payoff_continuous_fast(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64)
    long_expected_payoff_continuous_fast(
        ib, ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m,
        1, length(b))
end

@inline function long_expected_payoff_continuous(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64)
    long_expected_payoff_continuous_fast(
        ib, ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m)
end

@inline function long_expected_payoff_continuous(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, W::Matrix{Float64}, Vd::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64, low_repayment_hint::Int,
        high_repayment_hint::Int)
    long_expected_payoff_continuous_fast(
        ib, ix, ih, b, y, q, W, Vd, payment, maturity, coupon, beta, sigma_m,
        low_repayment_hint, high_repayment_hint)
end

struct LongSolution
    x::Vector{Float64}
    P::Matrix{Float64}
    Pd::Array{Float64,3}
    y::Vector{Float64}
    b::Vector{Float64}
    mgrid::Vector{Float64}
    mprob::Vector{Float64}
    V::Array{Float64,4}
    Vd::Vector{Float64}
    q::Array{Float64,3}
    d::Array{Bool,4}
    pol::Array{Int,4}
    theta::Float64
    beta::Float64
    phi::Float64
    d0::Float64
    d1::Float64
    reentry::Float64
    rstar::Float64
    calibration::Symbol
    maturity::Float64
    coupon::Float64
    sigma_m::Float64
    iters::Int
end

function long_default_income(y::Vector{Float64}, P::Matrix{Float64},
                             phi::Float64, d0::Float64, d1::Float64,
                             sigma_m::Float64, calibration::Symbol)
    if calibration === :ce
        loss = max.(0.0, d0 .* y .+ d1 .* y .^ 2)
        return max.(CMIN, y .- loss .- LONG_TRUNCATION * sigma_m)
    elseif calibration === :short
        Ey = dot(ergodic(P), y)
        return min.(y, phi * Ey)
    end
    throw(ArgumentError("calibration must be :ce or :short"))
end

function solve_long_picard(theta::Float64; maturity::Float64 = LONG_MATURITY,
                    coupon::Float64 = LONG_COUPON, beta::Float64 = LONG_BETA,
                    phi::Float64 = PHI, d0::Float64 = LONG_D0,
                    d1::Float64 = LONG_D1,
                    reentry::Float64 = LONG_REENTRY,
                    rstar::Float64 = LONG_RSTAR,
                    calibration::Symbol = :ce, nb::Int = LONG_NB,
                    bmax::Float64 = LONG_BMAX, tol::Float64 = 5e-8,
                    maxit::Int = 2500, damp::Float64 = 0.9,
                    q0::Union{Symbol,Array{Float64,3}} = :riskfree,
                    trace::Bool = false, nm::Int = LONG_NM,
                    sigma_m::Float64 = LONG_SIGMA_M,
                    anderson_memory::Int = 4)
    0 < maturity <= 1 || throw(ArgumentError("maturity must lie in (0,1]"))
    coupon >= 0 || throw(ArgumentError("coupon must be nonnegative"))
    0 < beta < 1 || throw(ArgumentError("beta must lie in (0,1)"))
    0 < reentry <= 1 || throw(ArgumentError("reentry must lie in (0,1]"))
    rstar > 0 || throw(ArgumentError("rstar must be positive"))

    x, P, Pd = calibration === :ce ? build_long_kernels(theta) : build_kernels(theta)
    y = exp.(x)
    ydef = long_default_income(y, P, phi, d0, d1, sigma_m, calibration)
    b = collect(range(0.0, bmax, length = nb))
    mgrid, mprob = transitory_grid(nm, sigma_m)
    qbar = long_riskfree_price(maturity, coupon, rstar)
    q = if q0 === :riskfree
        fill(qbar, nb, NY, NY)
    elseif q0 === :zero
        zeros(nb, NY, NY)
    elseif q0 isa Array{Float64,3}
        size(q0) == (nb, NY, NY) || throw(DimensionMismatch("q0 has the wrong dimensions"))
        copy(q0)
    else
        throw(ArgumentError("q0 must be :riskfree, :zero, or a price array"))
    end

    V = zeros(nb, NY, NY, nm)
    Vd = [util(ydef[ix]) / (1 - beta) for ix in 1:NY]
    d = zeros(Bool, nb, NY, NY, nm)
    pol = ones(Int, nb, NY, NY, nm)
    W = zeros(nb, NY)
    Vr = similar(V)
    Vnew = similar(V)
    Vdnew = similar(Vd)
    dnew = similar(d)
    qnew = similar(q)
    expected_payoff = zeros(nb, NY, NY)
    payment = maturity + (1 - maturity) * coupon
    R = 1 + rstar
    iters = 0
    state_history = Any[]
    image_history = Any[]
    previous_residual = Inf
    stable_policy_iterations = 0

    for it in 1:maxit
        iters = it
        fill!(W, 0.0)
        for ix in 1:NY, j in 1:NY
            p = P[ix, j]
            @inbounds for im in 1:nm
                weight = p * mprob[im]
                @simd for ib in 1:nb
                    W[ib, ix] += weight * V[ib, j, ix, im]
                end
            end
        end
        for ix in 1:NY
            ev0 = 0.0
            evd = 0.0
            @inbounds for j in 1:NY
                for im in 1:nm
                    ev0 += P[ix, j] * mprob[im] * V[1, j, ix, im]
                end
                evd += P[ix, j] * Vd[j]
            end
            Vdnew[ix] = util(ydef[ix]) +
                beta * (reentry * ev0 + (1 - reentry) * evd)
        end

        Threads.@threads for ix in 1:NY
            @inbounds for ih in 1:NY, ib in 1:nb
                upper_action = nb
                for im in 1:nm
                    best, ibest = long_repayment_choice(
                        mgrid[im], ib, ix, ih, b, y, q, W, Vdnew, payment,
                        maturity, beta, 1, upper_action)
                    Vr[ib, ix, ih, im] = best
                    pol[ib, ix, ih, im] = ibest
                    upper_action = ibest
                end
            end
        end

        @inbounds for ih in 1:NY, ix in 1:NY, im in 1:nm, ib in 1:nb
            if Vdnew[ix] > Vr[ib, ix, ih, im]
                Vnew[ib, ix, ih, im] = Vdnew[ix]
                dnew[ib, ix, ih, im] = true
            else
                Vnew[ib, ix, ih, im] = Vr[ib, ix, ih, im]
                dnew[ib, ix, ih, im] = false
            end
        end

        if sigma_m == 0
            @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
                value = 0.0
                for j in 1:NY
                    if !dnew[ibp, j, ix, 1]
                        ibpp = pol[ibp, j, ix, 1]
                        payoff = maturity + (1 - maturity) *
                            (coupon + q[ibpp, j, ix])
                        value += Pd[ix, ih, j] * payoff
                    end
                end
                qnew[ibp, ix, ih] = value / R
            end
        else
            Threads.@threads for ix in 1:NY
                @inbounds for ih in 1:NY, ib in 1:nb
                    expected_payoff[ib, ix, ih] =
                        long_expected_payoff_continuous(
                            ib, ix, ih, b, y, q, W, Vdnew, payment, maturity,
                            coupon, beta, sigma_m, pol[ib, ix, ih, 1],
                            pol[ib, ix, ih, nm])
                end
            end
            Threads.@threads for ix in 1:NY
                @inbounds for ih in 1:NY, ibp in 1:nb
                    value = 0.0
                    for j in 1:NY
                        value += Pd[ix, ih, j] * expected_payoff[ibp, j, ix]
                    end
                    qnew[ibp, ix, ih] = value / R
                end
            end
        end

        dV = max(maximum(abs.(Vnew .- V)), maximum(abs.(Vdnew .- Vd)))
        dq = maximum(abs.(qnew .- q))
        default_changes = count(dnew .!= d)
        if trace && (it <= 5 || it % 100 == 0 || it == maxit)
            println("it=$it dV=$dV dq=$dq default_changes=$default_changes qrange=$(extrema(qnew))")
        end
        copyto!(d, dnew)
        Vpic = @. damp * V + (1 - damp) * Vnew
        Vdpic = @. damp * Vd + (1 - damp) * Vdnew
        qpic = @. damp * q + (1 - damp) * qnew
        if sigma_m > 0 && dq < 0.01 && default_changes == 0
            stable_policy_iterations += 1
        else
            stable_policy_iterations = 0
            empty!(state_history)
            empty!(image_history)
        end
        memory = stable_policy_iterations >= 20 ? anderson_memory : 1
        if max(dV, dq) > 1.5 * previous_residual
            empty!(state_history)
            empty!(image_history)
        end
        push!(state_history, (V = copy(V), Vd = copy(Vd), q = copy(q)))
        push!(image_history, (V = copy(Vpic), Vd = copy(Vdpic), q = copy(qpic)))
        length(state_history) > memory && popfirst!(state_history)
        length(image_history) > memory && popfirst!(image_history)
        if memory >= 2 && length(state_history) >= 2
            candidate = anderson_state_candidate(state_history, image_history)
            if all(isfinite, candidate.V) && all(isfinite, candidate.Vd) &&
                    all(isfinite, candidate.q)
                @. V = 0.5 * candidate.V + 0.5 * Vpic
                @. Vd = 0.5 * candidate.Vd + 0.5 * Vdpic
                @. q = clamp(0.5 * candidate.q + 0.5 * qpic, 0.0, qbar)
            else
                copyto!(V, Vpic)
                copyto!(Vd, Vdpic)
                copyto!(q, qpic)
                empty!(state_history)
                empty!(image_history)
            end
        else
            copyto!(V, Vpic)
            copyto!(Vd, Vdpic)
            copyto!(q, qpic)
        end
        previous_residual = max(dV, dq)
        if dV < tol && dq < tol
            break
        end
    end
    iters < maxit || error("long-bond solver did not converge")
    LongSolution(x, P, Pd, y, b, mgrid, mprob, V, Vd, q, d, pol, theta,
                 beta, phi, d0, d1, reentry, rstar, calibration, maturity,
                 coupon, sigma_m, iters)
end

function anderson_state_candidate(state_history::Vector,
                                  image_history::Vector)
    k = length(state_history)
    k == length(image_history) || throw(DimensionMismatch("Anderson histories differ"))
    k >= 2 || return image_history[end]
    gram = zeros(k, k)
    @inbounds for i in 1:k, j in i:k
        ri = image_history[i]
        xi = state_history[i]
        rj = image_history[j]
        xj = state_history[j]
        value = dot(vec(ri.V .- xi.V), vec(rj.V .- xj.V)) / length(xi.V) +
            dot(ri.Vd .- xi.Vd, rj.Vd .- xj.Vd) / length(xi.Vd) +
            dot(vec(ri.q .- xi.q), vec(rj.q .- xj.q)) / length(xi.q)
        gram[i, j] = value
        gram[j, i] = value
    end
    scale = max(maximum(diag(gram)), 1.0)
    @inbounds for i in 1:k
        gram[i, i] += 1e-12 * scale
    end
    system = zeros(k + 1, k + 1)
    system[1:k, 1:k] .= gram
    system[1:k, k + 1] .= 1.0
    system[k + 1, 1:k] .= 1.0
    rhs = zeros(k + 1)
    rhs[k + 1] = 1.0
    weights = (system \ rhs)[1:k]
    V = zeros(size(image_history[end].V))
    Vd = zeros(size(image_history[end].Vd))
    q = zeros(size(image_history[end].q))
    @inbounds for i in 1:k
        @. V += weights[i] * image_history[i].V
        @. Vd += weights[i] * image_history[i].Vd
        @. q += weights[i] * image_history[i].q
    end
    (V = V, Vd = Vd, q = q)
end

function solve_long_government(q::Array{Float64,3}, b::Vector{Float64},
                               y::Vector{Float64}, ydef::Vector{Float64},
                               P::Matrix{Float64}, mgrid::Vector{Float64},
                               mprob::Vector{Float64}, maturity::Float64,
                               coupon::Float64, beta::Float64;
                               V0::Union{Nothing,Array{Float64,4}} = nothing,
                               Vd0::Union{Nothing,Vector{Float64}} = nothing,
                               tol::Float64 = 1e-10, maxit::Int = 5000)
    nb = length(b)
    nm = length(mgrid)
    V = isnothing(V0) ? zeros(nb, NY, NY, nm) : copy(V0)
    Vd = isnothing(Vd0) ? [util(ydef[ix]) / (1 - beta) for ix in 1:NY] : copy(Vd0)
    W = zeros(nb, NY)
    Vnew = similar(V)
    Vdnew = similar(Vd)
    d = zeros(Bool, nb, NY, NY, nm)
    pol = ones(Int, nb, NY, NY, nm)
    payment = maturity + (1 - maturity) * coupon
    residual = Inf
    iterations = 0

    for it in 1:maxit
        iterations = it
        fill!(W, 0.0)
        @inbounds for ix in 1:NY, j in 1:NY, im in 1:nm
            weight = P[ix, j] * mprob[im]
            @simd for ib in 1:nb
                W[ib, ix] += weight * V[ib, j, ix, im]
            end
        end
        @inbounds for ix in 1:NY
            ev0 = 0.0
            evd = 0.0
            for j in 1:NY
                for im in 1:nm
                    ev0 += P[ix, j] * mprob[im] * V[1, j, ix, im]
                end
                evd += P[ix, j] * Vd[j]
            end
            Vdnew[ix] = util(ydef[ix]) + beta * (LAM * ev0 + (1 - LAM) * evd)
        end
        Threads.@threads for ix in 1:NY
            @inbounds for ih in 1:NY, ib in 1:nb
                upper_action = nb
                for im in 1:nm
                    best, ibest = long_repayment_choice(
                        mgrid[im], ib, ix, ih, b, y, q, W, Vdnew, payment,
                        maturity, beta, 1, upper_action)
                    pol[ib, ix, ih, im] = ibest
                    upper_action = ibest
                    if Vdnew[ix] > best
                        Vnew[ib, ix, ih, im] = Vdnew[ix]
                        d[ib, ix, ih, im] = true
                    else
                        Vnew[ib, ix, ih, im] = best
                        d[ib, ix, ih, im] = false
                    end
                end
            end
        end
        residual = max(maximum(abs.(Vnew .- V)), maximum(abs.(Vdnew .- Vd)))
        copyto!(V, Vnew)
        copyto!(Vd, Vdnew)
        residual < tol && break
    end
    residual < tol || error("government problem did not converge")

    fill!(W, 0.0)
    @inbounds for ix in 1:NY, j in 1:NY, im in 1:nm
        weight = P[ix, j] * mprob[im]
        @simd for ib in 1:nb
            W[ib, ix] += weight * V[ib, j, ix, im]
        end
    end
    (V = V, Vd = Vd, d = d, pol = pol, W = W,
     iterations = iterations, residual = residual)
end

function long_price_map(q::Array{Float64,3}, government, b::Vector{Float64},
                        y::Vector{Float64}, Pd::Array{Float64,3},
                        maturity::Float64, coupon::Float64, beta::Float64,
                        sigma_m::Float64)
    nb = length(b)
    qnew = similar(q)
    R = 1 + RSTAR
    if sigma_m == 0
        @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
            value = 0.0
            for j in 1:NY
                if !government.d[ibp, j, ix, 1]
                    ibpp = government.pol[ibp, j, ix, 1]
                    value += Pd[ix, ih, j] *
                        long_choice_payoff(ibpp, j, ix, q, maturity, coupon)
                end
            end
            qnew[ibp, ix, ih] = value / R
        end
        return qnew
    end

    payment = maturity + (1 - maturity) * coupon
    expected = zeros(nb, NY, NY)
    Threads.@threads for ix in 1:NY
        @inbounds for ih in 1:NY, ib in 1:nb
            expected[ib, ix, ih] = long_expected_payoff_continuous(
                ib, ix, ih, b, y, q, government.W, government.Vd, payment,
                maturity, coupon, beta, sigma_m,
                government.pol[ib, ix, ih, 1],
                government.pol[ib, ix, ih, size(government.pol, 4)])
        end
    end
    Threads.@threads for ix in 1:NY
        @inbounds for ih in 1:NY, ibp in 1:nb
            value = 0.0
            for j in 1:NY
                value += Pd[ix, ih, j] * expected[ibp, j, ix]
            end
            qnew[ibp, ix, ih] = value / R
        end
    end
    qnew
end

function anderson_price_candidate(qhistory::Vector{Array{Float64,3}},
                                  ghistory::Vector{Array{Float64,3}})
    k = length(qhistory)
    k == length(ghistory) || throw(DimensionMismatch("Anderson histories differ"))
    k >= 2 || return copy(ghistory[end])
    gram = zeros(k, k)
    @inbounds for i in 1:k, j in i:k
        value = dot(vec(ghistory[i] .- qhistory[i]),
                    vec(ghistory[j] .- qhistory[j]))
        gram[i, j] = value
        gram[j, i] = value
    end
    scale = max(maximum(diag(gram)), 1.0)
    @inbounds for i in 1:k
        gram[i, i] += 1e-12 * scale
    end
    system = zeros(k + 1, k + 1)
    system[1:k, 1:k] .= gram
    system[1:k, k + 1] .= 1.0
    system[k + 1, 1:k] .= 1.0
    rhs = zeros(k + 1)
    rhs[k + 1] = 1.0
    weights = (system \ rhs)[1:k]
    candidate = zeros(size(ghistory[end]))
    @inbounds for i in 1:k
        @. candidate += weights[i] * ghistory[i]
    end
    candidate
end

function solve_long_nested(theta::Float64; maturity::Float64 = LONG_MATURITY,
                    coupon::Float64 = LONG_COUPON, beta::Float64 = 0.969,
                    phi::Float64 = 0.910, nb::Int = LONG_NB,
                    bmax::Float64 = LONG_BMAX, tol::Float64 = 5e-8,
                    maxit::Int = 400, damp::Float64 = 0.5,
                    q0::Union{Symbol,Array{Float64,3}} = :riskfree,
                    trace::Bool = false, nm::Int = 5,
                    sigma_m::Float64 = LONG_SIGMA_M,
                    anderson_memory::Int = 4)
    0 < maturity <= 1 || throw(ArgumentError("maturity must lie in (0,1]"))
    coupon >= 0 || throw(ArgumentError("coupon must be nonnegative"))
    0 < beta < 1 || throw(ArgumentError("beta must lie in (0,1)"))
    0 <= damp < 1 || throw(ArgumentError("damp must lie in [0,1)"))
    anderson_memory >= 1 || throw(ArgumentError("anderson_memory must be positive"))

    x, P, Pd = build_kernels(theta)
    y = exp.(x)
    Ey = dot(ergodic(P), y)
    ydef = min.(y, phi * Ey)
    b = collect(range(0.0, bmax, length = nb))
    mgrid, mprob = transitory_grid(nm, sigma_m)
    qbar = long_riskfree_price(maturity, coupon)
    q = if q0 === :riskfree
        fill(qbar, nb, NY, NY)
    elseif q0 === :zero
        zeros(nb, NY, NY)
    elseif q0 isa Array{Float64,3}
        size(q0) == (nb, NY, NY) || throw(DimensionMismatch("q0 has the wrong dimensions"))
        clamp.(copy(q0), 0.0, qbar)
    else
        throw(ArgumentError("q0 must be :riskfree, :zero, or a price array"))
    end

    qhistory = Array{Float64,3}[]
    ghistory = Array{Float64,3}[]
    Vwarm = nothing
    Vdwarm = nothing
    previous_residual = Inf
    government = nothing

    for outer in 1:maxit
        government = solve_long_government(
            q, b, y, ydef, P, mgrid, mprob, maturity, coupon, beta;
            V0 = Vwarm, Vd0 = Vdwarm, tol = min(1e-10, tol / 20))
        Vwarm = government.V
        Vdwarm = government.Vd
        g = long_price_map(q, government, b, y, Pd, maturity, coupon, beta,
                           sigma_m)
        residual = maximum(abs.(g .- q))
        if trace && (outer <= 5 || outer % 10 == 0 || residual < tol)
            println("outer=$outer price_residual=$residual inner_iterations=$(government.iterations) qrange=$(extrema(g))")
        end
        if residual < tol
            return LongSolution(x, P, Pd, y, b, mgrid, mprob, government.V,
                                government.Vd, q, government.d, government.pol,
                                theta, beta, phi, maturity, coupon, sigma_m, outer)
        end

        if residual > 1.5 * previous_residual
            empty!(qhistory)
            empty!(ghistory)
        end
        push!(qhistory, copy(q))
        push!(ghistory, copy(g))
        length(qhistory) > anderson_memory && popfirst!(qhistory)
        length(ghistory) > anderson_memory && popfirst!(ghistory)

        picard = @. damp * q + (1 - damp) * g
        if length(qhistory) >= 2
            candidate = anderson_price_candidate(qhistory, ghistory)
            if all(isfinite, candidate)
                @. q = clamp(0.8 * candidate + 0.2 * picard, 0.0, qbar)
            else
                copyto!(q, picard)
                empty!(qhistory)
                empty!(ghistory)
            end
        else
            copyto!(q, picard)
        end
        previous_residual = residual
    end
    error("long-bond outer price solver did not converge")
end

solve_long(theta::Float64; kwargs...) = solve_long_picard(theta; kwargs...)

function long_fixed_point_residual(sol::LongSolution)
    nb = length(sol.b)
    nm = length(sol.mgrid)
    payment = sol.maturity + (1 - sol.maturity) * sol.coupon
    R = 1 + sol.rstar
    ydef = long_default_income(sol.y, sol.P, sol.phi, sol.d0, sol.d1,
                               sol.sigma_m, sol.calibration)
    W = zeros(nb, NY)
    for ix in 1:NY, j in 1:NY
        p = sol.P[ix, j]
        @inbounds for im in 1:nm
            weight = p * sol.mprob[im]
            @simd for ib in 1:nb
                W[ib, ix] += weight * sol.V[ib, j, ix, im]
            end
        end
    end
    Vdnew = similar(sol.Vd)
    for ix in 1:NY
        ev0 = 0.0
        evd = 0.0
        @inbounds for j in 1:NY
            for im in 1:nm
                ev0 += sol.P[ix, j] * sol.mprob[im] * sol.V[1, j, ix, im]
            end
            evd += sol.P[ix, j] * sol.Vd[j]
        end
        Vdnew[ix] = util(ydef[ix]) + sol.beta *
            (sol.reentry * ev0 + (1 - sol.reentry) * evd)
    end
    Vnew = similar(sol.V)
    dnew = similar(sol.d)
    polnew = similar(sol.pol)
    @inbounds for ih in 1:NY, ix in 1:NY, im in 1:nm, ib in 1:nb
        best = -Inf
        ibest = 1
        for ibp in 1:nb
            net_issue = sol.b[ibp] - (1 - sol.maturity) * sol.b[ib]
            c = sol.y[ix] + sol.mgrid[im] - payment * sol.b[ib] +
                sol.q[ibp, ix, ih] * net_issue
            value = util(c) + sol.beta * W[ibp, ix]
            if value > best
                best = value
                ibest = ibp
            end
        end
        polnew[ib, ix, ih, im] = ibest
        if Vdnew[ix] > best
            Vnew[ib, ix, ih, im] = Vdnew[ix]
            dnew[ib, ix, ih, im] = true
        else
            Vnew[ib, ix, ih, im] = best
            dnew[ib, ix, ih, im] = false
        end
    end
    qnew = similar(sol.q)
    if sol.sigma_m == 0
        @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
            value = 0.0
            for j in 1:NY
                if !dnew[ibp, j, ix, 1]
                    ibpp = polnew[ibp, j, ix, 1]
                    payoff = sol.maturity + (1 - sol.maturity) *
                        (sol.coupon + sol.q[ibpp, j, ix])
                    value += sol.Pd[ix, ih, j] * payoff
                end
            end
            qnew[ibp, ix, ih] = value / R
        end
    else
        expected = zeros(nb, NY, NY)
        Threads.@threads for ix in 1:NY
            @inbounds for ih in 1:NY, ib in 1:nb
                expected[ib, ix, ih] = long_expected_payoff_continuous(
                    ib, ix, ih, sol.b, sol.y, sol.q, W, Vdnew, payment,
                    sol.maturity, sol.coupon, sol.beta, sol.sigma_m,
                    polnew[ib, ix, ih, 1], polnew[ib, ix, ih, nm])
            end
        end
        @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
            value = 0.0
            for j in 1:NY
                value += sol.Pd[ix, ih, j] * expected[ibp, j, ix]
            end
            qnew[ibp, ix, ih] = value / R
        end
    end
    Dict(
        "bellman" => max(maximum(abs.(Vnew .- sol.V)),
                          maximum(abs.(Vdnew .- sol.Vd))),
        "price" => maximum(abs.(qnew .- sol.q)),
        "default_policy_changes" => count(dnew .!= sol.d),
        "debt_policy_changes" => count(polnew .!= sol.pol),
    )
end

function long_minimum_repayment_consumption(sol::LongSolution)
    payment = sol.maturity + (1 - sol.maturity) * sol.coupon
    cmin = Inf
    nb = length(sol.b)
    nm = length(sol.mgrid)
    @inbounds for ih in 1:NY, ix in 1:NY, im in 1:nm, ib in 1:nb
        sol.d[ib, ix, ih, im] && continue
        ibp = sol.pol[ib, ix, ih, im]
        net_issue = sol.b[ibp] - (1 - sol.maturity) * sol.b[ib]
        c = sol.y[ix] + sol.mgrid[im] - payment * sol.b[ib] +
            sol.q[ibp, ix, ih] * net_issue
        cmin = min(cmin, c)
    end
    cmin
end

function long_spread(q::Float64, maturity::Float64, coupon::Float64,
                     rstar::Float64 = LONG_RSTAR)
    q > 1e-10 || return Inf
    yield_q = (maturity + (1 - maturity) * coupon) / q - maturity
    (1 + yield_q)^4 - (1 + rstar)^4
end

function long_expected_excess_returns(sol::LongSolution)
    nb = length(sol.b)
    nm = length(sol.mgrid)
    returns = fill(NaN, nb, NY, NY)
    R = 1 + sol.rstar
    @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
        sol.q[ibp, ix, ih] > 1e-10 || continue
        payoff = 0.0
        for j in 1:NY
            for im in 1:nm
                if !sol.d[ibp, j, ix, im]
                    ibpp = sol.pol[ibp, j, ix, im]
                    cash = sol.maturity + (1 - sol.maturity) *
                        (sol.coupon + sol.q[ibpp, j, ix])
                    payoff += sol.P[ix, j] * sol.mprob[im] * cash
                end
            end
        end
        returns[ibp, ix, ih] = payoff / sol.q[ibp, ix, ih] - R
    end
    returns
end

function simulate_long(sol::LongSolution; T::Int = 500_000,
                       burn::Int = 1_000, seed::Int = SEED)
    rngx = Xoshiro(seed)
    rngd = Xoshiro(seed + 1)
    rngm = Xoshiro(seed + 2)
    cumP = cumsum(sol.P, dims = 2)
    n = T + burn
    ix = Vector{Int}(undef, n)
    ix[1] = (NY + 1) ÷ 2
    for t in 2:n
        row = view(cumP, ix[t - 1], :)
        ix[t] = min(searchsortedfirst(row, rand(rngx)), NY)
    end
    ih = similar(ix)
    ih[1] = ix[1]
    ih[2:end] = ix[1:end - 1]
    nm = length(sol.mgrid)
    cumm = cumsum(sol.mprob)
    im = [min(searchsortedfirst(cumm, rand(rngm)), nm) for _ in 1:n]
    ib = ones(Int, n)
    access = trues(n)
    dflt = falses(n)
    for t in 1:n - 1
        if access[t]
            if sol.d[ib[t], ix[t], ih[t], im[t]]
                dflt[t] = true
                access[t + 1] = false
                ib[t + 1] = 1
            else
                ib[t + 1] = sol.pol[ib[t], ix[t], ih[t], im[t]]
                access[t + 1] = true
            end
        else
            ib[t + 1] = 1
            access[t + 1] = rand(rngd) < sol.reentry
        end
    end

    sl = burn + 1:n
    ixs = ix[sl]
    ihs = ih[sl]
    ibs = ib[sl]
    ims = im[sl]
    acc = access[sl]
    dfl = dflt[sl]
    issue = acc .& .!dfl
    ibp = [issue[t] ? sol.pol[ibs[t], ixs[t], ihs[t], ims[t]] : 1 for t in 1:T]
    qpath = [sol.q[ibp[t], ixs[t], ihs[t]] for t in 1:T]
    spr = [long_spread(qpath[t], sol.maturity, sol.coupon, sol.rstar) for t in 1:T]
    news = sol.x[ixs] .- sol.x[ihs]
    payment = sol.maturity + (1 - sol.maturity) * sol.coupon
    current_y = sol.y[ixs] .+ sol.mgrid[ims]
    debt_y = sol.b[ibs] ./ current_y
    service_y = payment .* sol.b[ibs] ./ current_y
    expected_returns = long_expected_excess_returns(sol)
    rex = [expected_returns[ibp[t], ixs[t], ihs[t]] for t in 1:T]

    m = [t for t in 1:T if issue[t] && isfinite(spr[t]) && isfinite(rex[t])]
    sprbp = winsorize(spr[m] .* 1e4, 0.01)
    nu = news[m]
    cellid = ibp[m] .* (NY + 1) .+ ixs[m]
    spr_dm = demean_within(sprbp, cellid)
    nu_dm = demean_within(nu, cellid)
    beta_news = dot(nu_dm, spr_dm) / dot(nu_dm, nu_dm)
    good = [rex[t] for t in m if news[t] > 0]
    bad = [rex[t] for t in m if news[t] < 0]

    moments = Dict{String,Any}(
        "median_spread" => median(spr[m]),
        "mean_spread" => mean(winsorize(spr[m], 0.01)),
        "sd_spread" => std(sprbp) / 1e4,
        "corr_spread_y" => cor(sprbp, sol.x[ixs[m]]),
        "corr_spread_dy" => cor(sprbp, news[m]),
        "mean_debt_y" => mean(debt_y[acc]),
        "mean_debt_service_y" => mean(service_y[acc]),
        "defaults_per_100y" => sum(dfl) / (T / 400),
        "frac_access" => mean(acc),
        "bp_per_1sd_news" => beta_news * std(news[m]),
        "mean_expected_excess_good" => mean(good),
        "mean_expected_excess_bad" => mean(bad),
        "average_maturity_years" => 1 / (4 * sol.maturity),
        "zero_price_share" => mean(qpath .<= 1e-10),
    )
    paths = (ix = ixs, ih = ihs, im = ims, ib = ibs, ibp = ibp, acc = acc,
             dfl = dfl, issue = issue, spr = spr, news = news)
    moments, paths
end

function write_long_macros(results::Dict{String,Any})
    m0 = results["theta_0.0"]["moments"]
    m5 = results["theta_0.5"]["moments"]
    init = results["initialization_check"]
    residual = max(results["theta_0.0"]["residual"]["bellman"],
                   results["theta_0.0"]["residual"]["price"],
                   results["theta_0.5"]["residual"]["bellman"],
                   results["theta_0.5"]["residual"]["price"])
    fmt(x, d) = string(round(x, digits = d))
    maturity_years = m5["average_maturity_years"]
    def_re = m0["defaults_per_100y"]
    def_diag = m5["defaults_per_100y"]
    spread_med_re = m0["median_spread"]
    spread_med_diag = m5["median_spread"]
    spread_sd_diag = m5["sd_spread"]
    debt_diag = m5["mean_debt_y"]
    service_diag = m5["mean_debt_service_y"]
    news_bp = abs(m5["bp_per_1sd_news"])
    return_good = m5["mean_expected_excess_good"]
    return_bad = m5["mean_expected_excess_bad"]
    init_diff = max(init["riskfree_vs_zero_q"], init["riskfree_vs_rational_q"])
    lines = [
        "% generated by solve_long_bonds.jl",
        "\\newcommand{\\LongMaturityYears}{$(fmt(maturity_years, 1))}",
        "\\newcommand{\\LongCouponAnnual}{$(fmt(4 * LONG_COUPON * 100, 1))}",
        "\\newcommand{\\LongDefRE}{$(fmt(def_re, 1))}",
        "\\newcommand{\\LongDefDiag}{$(fmt(def_diag, 1))}",
        "\\newcommand{\\LongSpreadMedRE}{$(fmt(spread_med_re * 100, 2))}",
        "\\newcommand{\\LongSpreadMedDiag}{$(fmt(spread_med_diag * 100, 2))}",
        "\\newcommand{\\LongSpreadSdDiag}{$(fmt(spread_sd_diag * 100, 2))}",
        "\\newcommand{\\LongDebtDiag}{$(fmt(debt_diag * 100, 1))}",
        "\\newcommand{\\LongDebtServiceDiag}{$(fmt(service_diag * 100, 1))}",
        "\\newcommand{\\LongNewsBp}{$(round(Int, news_bp))}",
        "\\newcommand{\\LongReturnGood}{$(fmt(return_good * 10_000, 1))}",
        "\\newcommand{\\LongReturnBad}{$(fmt(return_bad * 10_000, 1))}",
        "\\newcommand{\\FPResidual}{$(fmt(residual, 9))}",
        "\\newcommand{\\FPInitDiff}{$(fmt(init_diff, 9))}",
    ]
    open(joinpath(OUTDIR, "long_bond_numbers.tex"), "w") do io
        foreach(line -> println(io, line), lines)
    end
end

function main_long()
    t0 = time()
    results = Dict{String,Any}(
        "calibration" => Dict("maturity" => LONG_MATURITY,
                              "coupon" => LONG_COUPON,
                              "beta" => 0.969, "phi" => 0.910,
                              "nb" => LONG_NB, "bmax" => LONG_BMAX),
    )
    sols = Dict{Float64,LongSolution}()
    paths = Dict{Float64,Any}()
    for theta in (0.0, 0.5)
        println("solving long bonds theta=$theta")
        sol = solve_long(theta)
        moments, path = simulate_long(sol)
        sols[theta] = sol
        paths[theta] = path
        results["theta_$(theta)"] = Dict("moments" => moments,
                                          "residual" => long_fixed_point_residual(sol),
                                          "iters" => sol.iters)
    end
    from_zero = solve_long(0.5; q0 = :zero)
    from_rational = solve_long(0.5; q0 = sols[0.0].q)
    results["initialization_check"] = Dict(
        "riskfree_vs_zero_q" => maximum(abs.(sols[0.5].q .- from_zero.q)),
        "riskfree_vs_rational_q" => maximum(abs.(sols[0.5].q .- from_rational.q)),
        "riskfree_vs_zero_default_changes" => count(sols[0.5].d .!= from_zero.d),
        "riskfree_vs_rational_default_changes" => count(sols[0.5].d .!= from_rational.d),
    )
    results["boom_events"] = boom_episodes(paths, sols)
    results["runtime_sec"] = time() - t0
    open(joinpath(OUTDIR, "results_long.json"), "w") do io
        JSON.print(io, results, 1)
    end
    write_long_macros(results)
    println("saved results_long.json and long_bond_numbers.tex")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_long()
end
