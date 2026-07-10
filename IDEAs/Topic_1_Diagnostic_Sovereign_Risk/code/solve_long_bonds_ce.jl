# Continuous-shock long-duration solver following Chatterjee and Eyigungor
# (2012). The fixed-point objects are the ex ante continuation value, the
# autarky value, and the bond-price schedule. The transitory shock is integrated
# over exact policy intervals and therefore does not enlarge the state space.

if !isdefined(Main, :LongSolution)
    include("solve_long_bonds.jl")
end

using Serialization

const GL5_NODES = (-0.9061798459386640, -0.5384693101056831, 0.0,
                   0.5384693101056831, 0.9061798459386640)
const GL5_WEIGHTS = (0.2369268850561891, 0.4786286704993665,
                     0.5688888888888889, 0.4786286704993665,
                     0.2369268850561891)
const GL20_NODES = (-0.9931285991850949, -0.9639719272779138,
                    -0.9122344282513259, -0.8391169718222188,
                    -0.7463319064601508, -0.6360536807265150,
                    -0.5108670019508271, -0.3737060887154196,
                    -0.2277858511416451, -0.0765265211334973,
                    0.0765265211334973, 0.2277858511416451,
                    0.3737060887154196, 0.5108670019508271,
                    0.6360536807265150, 0.7463319064601508,
                    0.8391169718222188, 0.9122344282513259,
                    0.9639719272779138, 0.9931285991850949)
const GL20_WEIGHTS = (0.0176140071391521, 0.0406014298003869,
                      0.0626720483341091, 0.0832767415767048,
                      0.1019301198172404, 0.1181945319615184,
                      0.1316886384491766, 0.1420961093183821,
                      0.1491729864726037, 0.1527533871307258,
                      0.1527533871307258, 0.1491729864726037,
                      0.1420961093183821, 0.1316886384491766,
                      0.1181945319615184, 0.1019301198172404,
                      0.0832767415767048, 0.0626720483341091,
                      0.0406014298003869, 0.0176140071391521)
const CE_INTEGRATION_TOL = 1e-10

standard_normal_pdf(z::Float64) = exp(-0.5 * z^2) / sqrt(2pi)

struct LongCESolution
    x::Vector{Float64}
    P::Matrix{Float64}
    Pd::Array{Float64,3}
    y::Vector{Float64}
    b::Vector{Float64}
    Z::Matrix{Float64}
    Xbar::Vector{Float64}
    D::Vector{Float64}
    q::Array{Float64,3}
    Vbar::Array{Float64,3}
    payoffbar::Array{Float64,3}
    theta::Float64
    beta::Float64
    d0::Float64
    d1::Float64
    reentry::Float64
    rstar::Float64
    maturity::Float64
    coupon::Float64
    sigma_m::Float64
    iters::Int
end

function ce_autarky_flow(y_net::Float64, sigma_m::Float64)
    lo = -LONG_TRUNCATION * sigma_m
    hi = LONG_TRUNCATION * sigma_m
    midpoint = (lo + hi) / 2
    halfwidth = (hi - lo) / 2
    normalizer = Phi(LONG_TRUNCATION) - Phi(-LONG_TRUNCATION)
    value = 0.0
    @inbounds for k in eachindex(GL5_NODES)
        m = midpoint + halfwidth * GL5_NODES[k]
        density = standard_normal_pdf(m / sigma_m) / (sigma_m * normalizer)
        value += GL5_WEIGHTS[k] * density * util(y_net + m)
    end
    halfwidth * value
end

function ce_gauss_value(
        action::Int, lo::Float64, hi::Float64, ib::Int, ix::Int, ih::Int,
        b::Vector{Float64}, y::Vector{Float64}, q::Array{Float64,3},
        Z::Matrix{Float64}, D::Vector{Float64}, payment::Float64,
        maturity::Float64, beta::Float64, sigma_m::Float64)
    midpoint = (lo + hi) / 2
    halfwidth = (hi - lo) / 2
    normalizer = Phi(LONG_TRUNCATION) - Phi(-LONG_TRUNCATION)
    value = 0.0
    @inbounds for k in eachindex(GL5_NODES)
        m = midpoint + halfwidth * GL5_NODES[k]
        density = standard_normal_pdf(m / sigma_m) / (sigma_m * normalizer)
        choice_value = long_action_value(
            action, m, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta)
        value += GL5_WEIGHTS[k] * density * choice_value
    end
    halfwidth * value
end

function ce_gauss20_value(
        action::Int, lo::Float64, hi::Float64, ib::Int, ix::Int, ih::Int,
        b::Vector{Float64}, y::Vector{Float64}, q::Array{Float64,3},
        Z::Matrix{Float64}, D::Vector{Float64}, payment::Float64,
        maturity::Float64, beta::Float64, sigma_m::Float64)
    midpoint = (lo + hi) / 2
    halfwidth = (hi - lo) / 2
    normalizer = Phi(LONG_TRUNCATION) - Phi(-LONG_TRUNCATION)
    value = 0.0
    @inbounds for k in eachindex(GL20_NODES)
        m = midpoint + halfwidth * GL20_NODES[k]
        density = standard_normal_pdf(m / sigma_m) / (sigma_m * normalizer)
        choice_value = long_action_value(
            action, m, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta)
        value += GL20_WEIGHTS[k] * density * choice_value
    end
    halfwidth * value
end

function ce_adaptive_value(
        action::Int, lo::Float64, hi::Float64, whole::Float64,
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, Z::Matrix{Float64}, D::Vector{Float64},
        payment::Float64, maturity::Float64, beta::Float64,
        sigma_m::Float64, depth::Int)
    mid = (lo + hi) / 2
    left = ce_gauss_value(action, lo, mid, ib, ix, ih, b, y, q, Z, D,
                          payment, maturity, beta, sigma_m)
    right = ce_gauss_value(action, mid, hi, ib, ix, ih, b, y, q, Z, D,
                           payment, maturity, beta, sigma_m)
    refined = left + right
    if depth >= 12 || abs(refined - whole) <= CE_INTEGRATION_TOL * (1 + abs(refined))
        return refined
    end
    ce_adaptive_value(action, lo, mid, left, ib, ix, ih, b, y, q, Z, D,
                      payment, maturity, beta, sigma_m, depth + 1) +
    ce_adaptive_value(action, mid, hi, right, ib, ix, ih, b, y, q, Z, D,
                      payment, maturity, beta, sigma_m, depth + 1)
end

function ce_segment_moments(
        action::Int, lo::Float64, hi::Float64, ib::Int, ix::Int, ih::Int,
        b::Vector{Float64}, y::Vector{Float64}, q::Array{Float64,3},
        Z::Matrix{Float64}, D::Vector{Float64}, payment::Float64,
        maturity::Float64, coupon::Float64, beta::Float64,
        sigma_m::Float64)
    hi <= lo && return (0.0, 0.0)
    probability = truncated_normal_cdf(hi, sigma_m) -
        truncated_normal_cdf(lo, sigma_m)
    if action == 0
        return (probability * D[ix], 0.0)
    end

    value = ce_gauss20_value(action, lo, hi, ib, ix, ih, b, y, q, Z, D,
                             payment, maturity, beta, sigma_m)
    payoff = probability *
        long_choice_payoff(action, ix, ih, q, maturity, coupon)
    value, payoff
end

function ce_interval_moments(
        lo::Float64, left_action::Int, left_repayment::Int, hi::Float64,
        right_action::Int, right_repayment::Int, ib::Int, ix::Int, ih::Int,
        b::Vector{Float64}, y::Vector{Float64}, q::Array{Float64,3},
        Z::Matrix{Float64}, D::Vector{Float64}, payment::Float64,
        maturity::Float64, coupon::Float64, beta::Float64,
        sigma_m::Float64, depth::Int)
    if left_action == right_action
        return ce_segment_moments(
            left_action, lo, hi, ib, ix, ih, b, y, q, Z, D, payment,
            maturity, coupon, beta, sigma_m)
    end
    depth <= 64 || error("CE policy-envelope recursion exceeded floating-point depth")

    boundary = long_choice_boundary(
        left_action, right_action, lo, hi, ib, ix, ih, b, y, q, Z, D,
        payment, maturity, beta)
    first_action = min(left_repayment, right_repayment)
    last_action = max(left_repayment, right_repayment)
    epsilon = max(1e-11, 1e-7 * (hi - lo))
    probe_left, _ = long_choice_at_m_range(
        max(lo, boundary - epsilon), ib, ix, ih, b, y, q, Z, D, payment,
        maturity, beta, first_action, last_action)
    probe_right, _ = long_choice_at_m_range(
        min(hi, boundary + epsilon), ib, ix, ih, b, y, q, Z, D, payment,
        maturity, beta, first_action, last_action)
    boundary_action, _ = long_choice_at_m_range(
        boundary, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta,
        first_action, last_action)

    if probe_left == left_action && probe_right == right_action &&
            (boundary_action == left_action || boundary_action == right_action)
        vl, pl = ce_segment_moments(
            left_action, lo, boundary, ib, ix, ih, b, y, q, Z, D, payment,
            maturity, coupon, beta, sigma_m)
        vr, pr = ce_segment_moments(
            right_action, boundary, hi, ib, ix, ih, b, y, q, Z, D, payment,
            maturity, coupon, beta, sigma_m)
        return vl + vr, pl + pr
    end

    mid = (lo + hi) / 2
    if mid == lo || mid == hi
        vl, pl = ce_segment_moments(
            left_action, lo, mid, ib, ix, ih, b, y, q, Z, D, payment,
            maturity, coupon, beta, sigma_m)
        vr, pr = ce_segment_moments(
            right_action, mid, hi, ib, ix, ih, b, y, q, Z, D, payment,
            maturity, coupon, beta, sigma_m)
        return vl + vr, pl + pr
    end
    mid_action, mid_repayment = long_choice_at_m_range(
        mid, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta,
        first_action, last_action)
    vl, pl = ce_interval_moments(
        lo, left_action, left_repayment, mid, mid_action, mid_repayment, ib,
        ix, ih, b, y, q, Z, D, payment, maturity, coupon, beta, sigma_m,
        depth + 1)
    vr, pr = ce_interval_moments(
        mid, mid_action, mid_repayment, hi, right_action, right_repayment, ib,
        ix, ih, b, y, q, Z, D, payment, maturity, coupon, beta, sigma_m,
        depth + 1)
    vl + vr, pl + pr
end

function ce_state_moments(
        ib::Int, ix::Int, ih::Int, b::Vector{Float64}, y::Vector{Float64},
        q::Array{Float64,3}, Z::Matrix{Float64}, D::Vector{Float64},
        payment::Float64, maturity::Float64, coupon::Float64,
        beta::Float64, sigma_m::Float64)
    lo = -LONG_TRUNCATION * sigma_m
    hi = LONG_TRUNCATION * sigma_m
    left_action, left_repayment = long_choice_at_m_range(
        lo, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta, 1, length(b))
    right_action, right_repayment = long_choice_at_m_range(
        hi, ib, ix, ih, b, y, q, Z, D, payment, maturity, beta, 1, length(b))
    ce_interval_moments(
        lo, left_action, left_repayment, hi, right_action, right_repayment,
        ib, ix, ih, b, y, q, Z, D, payment, maturity, coupon, beta, sigma_m, 1)
end

function ce_operator!(Vbar::Array{Float64,3}, payoffbar::Array{Float64,3},
                      Znew::Matrix{Float64}, Xbarnew::Vector{Float64},
                      Ddecision::Vector{Float64},
                      qnew::Array{Float64,3}, Z::Matrix{Float64},
                      Xbar::Vector{Float64}, q::Array{Float64,3},
                      x::Vector{Float64}, P::Matrix{Float64},
                      Pd::Array{Float64,3}, b::Vector{Float64},
                      beta::Float64, d0::Float64, d1::Float64,
                      reentry::Float64, rstar::Float64, maturity::Float64,
                      coupon::Float64, sigma_m::Float64)
    y = exp.(x)
    payment = maturity + (1 - maturity) * coupon
    nb = length(b)
    loss = max.(0.0, d0 .* y .+ d1 .* y .^ 2)
    @inbounds for ix in 1:NY
        excluded = 0.0
        for j in 1:NY
            excluded += P[ix, j] * Xbar[j]
        end
        continuation = beta * ((1 - reentry) * excluded + reentry * Z[1, ix])
        Ddecision[ix] = util(y[ix] - loss[ix] -
                             LONG_TRUNCATION * sigma_m) + continuation
        Xbarnew[ix] = ce_autarky_flow(y[ix] - loss[ix], sigma_m) + continuation
    end
    Threads.@threads for ix in 1:NY
        @inbounds for ih in 1:NY, ib in 1:nb
            Vbar[ib, ix, ih], payoffbar[ib, ix, ih] = ce_state_moments(
                ib, ix, ih, b, y, q, Z, Ddecision, payment, maturity, coupon,
                beta, sigma_m)
        end
    end

    Threads.@threads for ix in 1:NY
        @inbounds for ib in 1:nb
            value = 0.0
            for j in 1:NY
                value += P[ix, j] * Vbar[ib, j, ix]
            end
            Znew[ib, ix] = value
        end
    end

    R = 1 + rstar
    Threads.@threads for ix in 1:NY
        @inbounds for ih in 1:NY, ibp in 1:nb
            value = 0.0
            for j in 1:NY
                value += Pd[ix, ih, j] * payoffbar[ibp, j, ix]
            end
            qnew[ibp, ix, ih] = value / R
        end
    end
    nothing
end

function solve_long_ce(theta::Float64; beta::Float64 = LONG_BETA,
                       d0::Float64 = LONG_D0, d1::Float64 = LONG_D1,
                       reentry::Float64 = LONG_REENTRY,
                       rstar::Float64 = LONG_RSTAR,
                       maturity::Float64 = LONG_MATURITY,
                       coupon::Float64 = LONG_COUPON,
                       sigma_m::Float64 = LONG_SIGMA_M,
                       nb::Int = LONG_NB, bmax::Float64 = LONG_BMAX,
                       tol::Float64 = 5e-8, maxit::Int = 80_000,
                       damp::Float64 = 0.0,
                       price_damp::Float64 = 0.99,
                       q0::Union{Symbol,Array{Float64,3}} = :riskfree,
                       initial::Union{Nothing,LongCESolution} = nothing,
                       trace::Bool = false)
    0 < beta < 1 || throw(ArgumentError("beta must lie in (0,1)"))
    0 < reentry <= 1 || throw(ArgumentError("reentry must lie in (0,1]"))
    0 <= damp < 1 || throw(ArgumentError("damp must lie in [0,1)"))
    0 <= price_damp < 1 || throw(ArgumentError("price_damp must lie in [0,1)"))
    sigma_m > 0 || throw(ArgumentError("sigma_m must be positive"))
    x, P, Pd = build_long_kernels(theta)
    y = exp.(x)
    b = collect(range(0.0, bmax, length = nb))
    qbar = long_riskfree_price(maturity, coupon, rstar)
    q = if !isnothing(initial)
        length(initial.b) == nb || throw(DimensionMismatch("initial solution has the wrong debt grid"))
        maximum(abs.(initial.b .- b)) < 1e-14 ||
            throw(DimensionMismatch("initial solution has different debt nodes"))
        copy(initial.q)
    elseif q0 === :riskfree
        fill(qbar, nb, NY, NY)
    elseif q0 === :zero
        zeros(nb, NY, NY)
    elseif q0 isa Array{Float64,3}
        size(q0) == (nb, NY, NY) || throw(DimensionMismatch("q0 has the wrong dimensions"))
        clamp.(copy(q0), 0.0, qbar)
    else
        throw(ArgumentError("q0 must be :riskfree, :zero, or a price array"))
    end

    loss = max.(0.0, d0 .* y .+ d1 .* y .^ 2)
    flow = [ce_autarky_flow(y[ix] - loss[ix], sigma_m) for ix in 1:NY]
    Xbar = isnothing(initial) ? flow ./ (1 - beta) : copy(initial.Xbar)
    Z = isnothing(initial) ? repeat(reshape(Xbar, 1, NY), nb, 1) : copy(initial.Z)
    Ddecision = similar(Xbar)
    Vbar = zeros(nb, NY, NY)
    payoffbar = zeros(nb, NY, NY)
    Znew = similar(Z)
    Xbarnew = similar(Xbar)
    qnew = similar(q)
    converged = false
    iterations = 0

    for it in 1:maxit
        iterations = it
        ce_operator!(Vbar, payoffbar, Znew, Xbarnew, Ddecision, qnew, Z,
                     Xbar, q, x, P, Pd, b, beta, d0, d1, reentry, rstar,
                     maturity, coupon, sigma_m)
        dZ = maximum(abs.(Znew .- Z))
        dX = maximum(abs.(Xbarnew .- Xbar))
        dq = maximum(abs.(qnew .- q))
        residual = max(dZ, dX, dq)
        if trace && (it <= 5 || it % 100 == 0 || residual < tol)
            println("it=$it dZ=$dZ dX=$dX dq=$dq damp=$damp price_damp=$price_damp qrange=$(extrema(qnew))")
        end
        @. Z = damp * Z + (1 - damp) * Znew
        @. Xbar = damp * Xbar + (1 - damp) * Xbarnew
        @. q = clamp(price_damp * q + (1 - price_damp) * qnew, 0.0, qbar)
        if residual < tol
            converged = true
            break
        end
    end
    converged || error("CE long-bond solver did not converge")
    ce_operator!(Vbar, payoffbar, Znew, Xbarnew, Ddecision, qnew, Z, Xbar, q,
                 x, P, Pd, b, beta, d0, d1, reentry, rstar, maturity, coupon,
                 sigma_m)
    LongCESolution(x, P, Pd, y, b, Z, Xbar, copy(Ddecision), q, Vbar,
                   payoffbar, theta, beta, d0, d1, reentry, rstar, maturity,
                   coupon, sigma_m, iterations)
end

function ce_interpolate_debt(values::AbstractArray{Float64}, old_b::Vector{Float64},
                             new_b::Vector{Float64})
    size(values, 1) == length(old_b) ||
        throw(DimensionMismatch("the first dimension must match the old debt grid"))
    output = Array{Float64}(undef, (length(new_b), size(values)[2:end]...))
    for (inew, debt) in enumerate(new_b)
        if debt <= old_b[1]
            output[inew, ntuple(_ -> Colon(), ndims(values) - 1)...] .=
                values[1, ntuple(_ -> Colon(), ndims(values) - 1)...]
            continue
        elseif debt >= old_b[end]
            output[inew, ntuple(_ -> Colon(), ndims(values) - 1)...] .=
                values[end, ntuple(_ -> Colon(), ndims(values) - 1)...]
            continue
        end
        left = searchsortedlast(old_b, debt)
        weight = (debt - old_b[left]) / (old_b[left + 1] - old_b[left])
        tails = ntuple(_ -> Colon(), ndims(values) - 1)
        @views output[inew, tails...] .=
            (1 - weight) .* values[left, tails...] .+
            weight .* values[left + 1, tails...]
    end
    output
end

function prolongate_long_ce(solution::LongCESolution, nb::Int,
                            bmax::Float64 = solution.b[end])
    nb >= 2 || throw(ArgumentError("nb must be at least two"))
    new_b = collect(range(0.0, bmax, length = nb))
    new_Z = ce_interpolate_debt(solution.Z, solution.b, new_b)
    new_q = ce_interpolate_debt(solution.q, solution.b, new_b)
    shape = (nb, NY, NY)
    LongCESolution(
        solution.x, solution.P, solution.Pd, solution.y, new_b, new_Z,
        copy(solution.Xbar), copy(solution.D), new_q, zeros(shape), zeros(shape),
        solution.theta, solution.beta, solution.d0, solution.d1,
        solution.reentry, solution.rstar, solution.maturity, solution.coupon,
        solution.sigma_m, solution.iters)
end

function solve_long_ce_path(theta::Float64;
                            start::Union{Nothing,LongCESolution} = nothing,
                            steps::Int = max(1, ceil(Int, abs(theta) / 0.025)),
                            tol::Float64 = 5e-8,
                            path_tol::Float64 = 2e-5,
                            kwargs...)
    steps >= 1 || throw(ArgumentError("steps must be positive"))
    solution = isnothing(start) ? solve_long_ce(0.0; kwargs...) : start
    origin = solution.theta
    values = range(origin, theta, length = steps + 1)[2:end]
    for (index, value) in enumerate(values)
        step_tolerance = index == length(values) ? tol : max(tol, path_tol)
        solution = solve_long_ce(
            Float64(value); initial = solution, tol = step_tolerance, kwargs...)
    end
    solution
end

function ce_fixed_point_residual(sol::LongCESolution)
    Znew = similar(sol.Z)
    Xbarnew = similar(sol.Xbar)
    Ddecision = similar(sol.D)
    qnew = similar(sol.q)
    Vbar = similar(sol.Vbar)
    payoffbar = similar(sol.payoffbar)
    ce_operator!(Vbar, payoffbar, Znew, Xbarnew, Ddecision, qnew, sol.Z,
                 sol.Xbar, sol.q, sol.x, sol.P, sol.Pd, sol.b, sol.beta,
                 sol.d0, sol.d1, sol.reentry, sol.rstar, sol.maturity,
                 sol.coupon, sol.sigma_m)
    Dict(
        "continuation" => maximum(abs.(Znew .- sol.Z)),
        "autarky" => maximum(abs.(Xbarnew .- sol.Xbar)),
        "default_decision" => maximum(abs.(Ddecision .- sol.D)),
        "price" => maximum(abs.(qnew .- sol.q)),
    )
end

function ce_expected_excess_returns(sol::LongCESolution)
    nb = length(sol.b)
    returns = fill(NaN, nb, NY, NY)
    R = 1 + sol.rstar
    @inbounds for ih in 1:NY, ix in 1:NY, ibp in 1:nb
        sol.q[ibp, ix, ih] > 1e-10 || continue
        payoff = 0.0
        for j in 1:NY
            payoff += sol.P[ix, j] * sol.payoffbar[ibp, j, ix]
        end
        returns[ibp, ix, ih] = payoff / sol.q[ibp, ix, ih] - R
    end
    returns
end

function draw_truncated_income!(rng::AbstractRNG, destination::Vector{Float64},
                                sigma_m::Float64)
    @inbounds for i in eachindex(destination)
        draw = randn(rng)
        while abs(draw) > LONG_TRUNCATION
            draw = randn(rng)
        end
        destination[i] = sigma_m * draw
    end
    destination
end

function simulate_long_ce(sol::LongCESolution; T::Int = 500_000,
                          burn::Int = 1_000, seed::Int = SEED)
    rngx = Xoshiro(seed)
    rngd = Xoshiro(seed + 1)
    rngm = Xoshiro(seed + 2)
    n = T + burn
    cumP = cumsum(sol.P, dims = 2)
    ix = Vector{Int}(undef, n)
    ix[1] = (NY + 1) ÷ 2
    @inbounds for t in 2:n
        ix[t] = min(searchsortedfirst(view(cumP, ix[t - 1], :), rand(rngx)), NY)
    end
    ih = similar(ix)
    ih[1] = ix[1]
    ih[2:end] = ix[1:end-1]
    m = draw_truncated_income!(rngm, Vector{Float64}(undef, n), sol.sigma_m)
    ib = ones(Int, n)
    ibp = ones(Int, n)
    access = trues(n)
    dflt = falses(n)
    payment = sol.maturity + (1 - sol.maturity) * sol.coupon
    @inbounds for t in 1:n-1
        if access[t]
            action = long_choice_at_m(
                m[t], ib[t], ix[t], ih[t], sol.b, sol.y, sol.q, sol.Z,
                sol.D, payment, sol.maturity, sol.beta)
            if action == 0
                dflt[t] = true
                access[t + 1] = false
                ibp[t] = 1
                ib[t + 1] = 1
            else
                ibp[t] = action
                ib[t + 1] = action
            end
        else
            ibp[t] = 1
            ib[t + 1] = 1
            access[t + 1] = rand(rngd) < sol.reentry
        end
    end

    sl = burn + 1:n
    ixs = ix[sl]
    ihs = ih[sl]
    ms = m[sl]
    ibs = ib[sl]
    ibps = ibp[sl]
    acc = access[sl]
    dfl = dflt[sl]
    issue = acc .& .!dfl
    qpath = [sol.q[ibps[t], ixs[t], ihs[t]] for t in 1:T]
    spr = [long_spread(qpath[t], sol.maturity, sol.coupon, sol.rstar) for t in 1:T]
    news = sol.x[ixs] .- sol.x[ihs]
    current_y = sol.y[ixs] .+ ms
    debt_y = sol.b[ibs] ./ current_y
    service_y = payment .* sol.b[ibs] ./ current_y
    expected_returns = ce_expected_excess_returns(sol)
    rex = [expected_returns[ibps[t], ixs[t], ihs[t]] for t in 1:T]
    sample = [t for t in 1:T if issue[t] && isfinite(spr[t]) && isfinite(rex[t])]
    sprbp = winsorize(spr[sample] .* 1e4, 0.01)
    cellid = ibps[sample] .* (NY + 1) .+ ixs[sample]
    spr_dm = demean_within(sprbp, cellid)
    news_dm = demean_within(news[sample], cellid)
    beta_news = dot(news_dm, spr_dm) / dot(news_dm, news_dm)
    good_returns = [rex[t] for t in sample if news[t] > 0]
    bad_returns = [rex[t] for t in sample if news[t] < 0]
    moments = Dict{String,Any}(
        "median_spread" => median(spr[sample]),
        "mean_spread" => mean(winsorize(spr[sample], 0.01)),
        "sd_spread" => std(sprbp) / 1e4,
        "corr_spread_y" => cor(sprbp, sol.x[ixs[sample]]),
        "corr_spread_dy" => cor(sprbp, news[sample]),
        "mean_debt_y" => mean(debt_y[acc]),
        "mean_debt_service_y" => mean(service_y[acc]),
        "defaults_per_100y" => sum(dfl) / (T / 400),
        "frac_access" => mean(acc),
        "bp_per_1sd_news" => beta_news * std(news[sample]),
        "mean_expected_excess_good" => mean(good_returns),
        "mean_expected_excess_bad" => mean(bad_returns),
        "average_maturity_years" => 1 / (4 * sol.maturity),
        "max_debt_index" => maximum(ibs[acc]),
        "top_grid_share" => mean(ibs[acc] .>= length(sol.b) - 1),
    )
    paths = (ix = ixs, ih = ihs, m = ms, ib = ibs, ibp = ibps, acc = acc,
             dfl = dfl, issue = issue, spr = spr, news = news, rex = rex)
    moments, paths
end

function ce_minimum_repayment_consumption(sol::LongCESolution;
                                          nodes::Int = 51)
    payment = sol.maturity + (1 - sol.maturity) * sol.coupon
    mgrid = range(-LONG_TRUNCATION * sol.sigma_m,
                  LONG_TRUNCATION * sol.sigma_m, length = nodes)
    minimum_consumption = Inf
    @inbounds for ih in 1:NY, ix in 1:NY, ib in eachindex(sol.b), m in mgrid
        action = long_choice_at_m(m, ib, ix, ih, sol.b, sol.y, sol.q, sol.Z,
                                  sol.D, payment, sol.maturity, sol.beta)
        action == 0 && continue
        net_issue = sol.b[action] - (1 - sol.maturity) * sol.b[ib]
        consumption = sol.y[ix] + m - payment * sol.b[ib] +
            sol.q[action, ix, ih] * net_issue
        minimum_consumption = min(minimum_consumption, consumption)
    end
    minimum_consumption
end

function write_ce_macros(results::Dict{String,Any})
    m0 = results["theta_0.0"]["moments"]
    m5 = results["theta_0.5"]["moments"]
    residual = maximum(vcat(
        collect(values(results["theta_0.0"]["residual"])),
        collect(values(results["theta_0.5"]["residual"]))))
    fmt(value, digits) = string(round(value, digits = digits))
    lines = [
        "% generated by solve_long_bonds_ce.jl",
        "\\newcommand{\\LongMaturityYears}{$(fmt(m5["average_maturity_years"], 1))}",
        "\\newcommand{\\LongDefRE}{$(fmt(m0["defaults_per_100y"], 2))}",
        "\\newcommand{\\LongDefDiag}{$(fmt(m5["defaults_per_100y"], 2))}",
        "\\newcommand{\\LongSpreadMedRE}{$(fmt(100 * m0["median_spread"], 2))}",
        "\\newcommand{\\LongSpreadMedDiag}{$(fmt(100 * m5["median_spread"], 2))}",
        "\\newcommand{\\LongSpreadSdDiag}{$(fmt(100 * m5["sd_spread"], 2))}",
        "\\newcommand{\\LongDebtDiag}{$(fmt(100 * m5["mean_debt_y"], 1))}",
        "\\newcommand{\\LongDebtServiceDiag}{$(fmt(100 * m5["mean_debt_service_y"], 1))}",
        "\\newcommand{\\LongNewsBp}{$(round(Int, abs(m5["bp_per_1sd_news"])))}",
        "\\newcommand{\\LongReturnGood}{$(fmt(10_000 * m5["mean_expected_excess_good"], 1))}",
        "\\newcommand{\\LongReturnBad}{$(fmt(10_000 * m5["mean_expected_excess_bad"], 1))}",
        "\\newcommand{\\LongFPResidual}{$(fmt(residual, 9))}",
        "\\newcommand{\\LongTopGridShare}{$(fmt(100 * m5["top_grid_share"], 4))}",
    ]
    open(joinpath(OUTDIR, "long_bond_numbers.tex"), "w") do io
        foreach(line -> println(io, line), lines)
    end
end

function main_ce()
    started = time()
    checkpoint_dir = joinpath(OUTDIR, "ce_checkpoints")
    mkpath(checkpoint_dir)
    checkpoint(name) = joinpath(checkpoint_dir, "gl20_" * name * ".bin")
    save_checkpoint(name, solution) = serialize(checkpoint(name), solution)
    load_checkpoint(name, theta, nb) = begin
        path = checkpoint(name)
        isfile(path) || return nothing
        solution = deserialize(path)
        solution isa LongCESolution || return nothing
        solution.theta == theta || return nothing
        length(solution.b) == nb || return nothing
        solution.sigma_m == LONG_SIGMA_M || return nothing
        solution
    end
    println("solving the rational multigrid benchmark")
    flush(stdout)
    rational20 = load_checkpoint("rational20", 0.0, 20)
    if isnothing(rational20)
        rational20 = solve_long_ce(0.0; nb = 20, tol = 2e-5)
        save_checkpoint("rational20", rational20)
    end
    rational50 = load_checkpoint("rational50", 0.0, 50)
    if isnothing(rational50)
        rational50 = solve_long_ce(
            0.0; nb = 50, initial = prolongate_long_ce(rational20, 50, LONG_BMAX),
            tol = 2e-5)
        save_checkpoint("rational50", rational50)
    end
    s0 = load_checkpoint("rational_final", 0.0, LONG_NB)
    if isnothing(s0)
        s0 = solve_long_ce(
            0.0; initial = prolongate_long_ce(rational50, LONG_NB, LONG_BMAX))
        save_checkpoint("rational_final", s0)
    end
    println("solving the diagnostic coarse-grid continuation path")
    flush(stdout)
    coarse5 = load_checkpoint("diagnostic12", 0.5, 12)
    if isnothing(coarse5)
        coarse0 = solve_long_ce(0.0; nb = 12, tol = 2e-5)
        coarse5 = solve_long_ce_path(0.5; start = coarse0, nb = 12, tol = 2e-5)
        save_checkpoint("diagnostic12", coarse5)
    end
    println("prolongating the diagnostic solution to 50 debt nodes")
    flush(stdout)
    middle5 = load_checkpoint("diagnostic50", 0.5, 50)
    if isnothing(middle5)
        middle_seed = prolongate_long_ce(coarse5, 50, LONG_BMAX)
        middle5 = solve_long_ce(
            0.5; nb = 50, initial = middle_seed, tol = 2e-5, trace = true)
        save_checkpoint("diagnostic50", middle5)
    end
    println("prolongating the diagnostic solution to the final debt grid")
    flush(stdout)
    s5 = load_checkpoint("diagnostic_final", 0.5, LONG_NB)
    if isnothing(s5)
        fine_seed = prolongate_long_ce(middle5, LONG_NB, LONG_BMAX)
        s5 = solve_long_ce(0.5; initial = fine_seed, trace = true)
        save_checkpoint("diagnostic_final", s5)
    end
    m0, _ = simulate_long_ce(s0)
    m5, _ = simulate_long_ce(s5)
    results = Dict{String,Any}(
        "calibration" => Dict(
            "beta" => LONG_BETA, "d0" => LONG_D0, "d1" => LONG_D1,
            "reentry" => LONG_REENTRY, "rstar" => LONG_RSTAR,
            "rho" => LONG_RHO, "sigma_e" => LONG_SIGE,
            "sigma_m" => LONG_SIGMA_M, "maturity" => LONG_MATURITY,
            "coupon" => LONG_COUPON, "nb" => LONG_NB,
            "bmax" => LONG_BMAX,
            "integration_tolerance" => CE_INTEGRATION_TOL,
            "multigrid_debt_nodes" => [12, LONG_NB],
        ),
        "theta_0.0" => Dict(
            "moments" => m0, "residual" => ce_fixed_point_residual(s0),
            "iterations" => s0.iters,
            "minimum_repayment_consumption" => ce_minimum_repayment_consumption(s0),
        ),
        "theta_0.5" => Dict(
            "moments" => m5, "residual" => ce_fixed_point_residual(s5),
            "iterations" => s5.iters,
            "minimum_repayment_consumption" => ce_minimum_repayment_consumption(s5),
        ),
        "runtime_sec" => time() - started,
    )
    open(joinpath(OUTDIR, "results_long.json"), "w") do io
        JSON.print(io, results, 1)
    end
    write_ce_macros(results)
    println("saved results_long.json and long_bond_numbers.tex")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_ce()
end
