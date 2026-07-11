# Simulated-moment calibration for the long-duration diagnostic model.
# Data targets are the Argentina moments reported by Chatterjee and Eyigungor
# (2012). Return predictability remains an untargeted validation moment until a
# matched EMBI total-return sample is supplied.

include("solve_long_bonds_ce.jl")

using LinearAlgebra

const LONG_DATA_TARGETS = Dict{String,Float64}(
    "mean_spread" => 0.0815,
    "sd_spread" => 0.0443,
    "mean_debt_y" => 0.70,
    "mean_debt_service_y" => 0.055,
    "defaults_per_100y" => 6.6,
    "corr_spread_y" => -0.79,
)

const LONG_PARAMETER_BOUNDS = Dict(
    :beta => (0.90, 0.99),
    :d0 => (-0.35, -0.05),
    :d1 => (0.10, 0.40),
)

const LONG_MOMENT_ORDER = (
    "mean_spread",
    "sd_spread",
    "mean_debt_y",
    "mean_debt_service_y",
    "defaults_per_100y",
    "corr_spread_y",
)

long_moment_vector(moments::Dict{String,<:Any}) =
    Float64[moments[name] for name in LONG_MOMENT_ORDER]

function central_difference_jacobian(parameters::Vector{Float64},
                                     steps::Vector{Float64}, evaluator)
    length(parameters) == length(steps) || throw(DimensionMismatch(
        "parameters and steps must have equal length"))
    all(steps .> 0) || throw(ArgumentError("finite-difference steps must be positive"))
    baseline = Float64.(evaluator(parameters))
    jacobian = Matrix{Float64}(undef, length(baseline), length(parameters))
    for index in eachindex(parameters)
        plus = copy(parameters)
        minus = copy(parameters)
        plus[index] += steps[index]
        minus[index] -= steps[index]
        jacobian[:, index] .=
            (Float64.(evaluator(plus)) .- Float64.(evaluator(minus))) ./
            (2 * steps[index])
    end
    jacobian
end

function smm_weight_matrices(moment_covariance::Matrix{Float64};
                             targets::Dict{String,Float64} = LONG_DATA_TARGETS,
                             eigenvalue_floor::Float64 = 1e-10)
    number_of_moments = length(LONG_MOMENT_ORDER)
    size(moment_covariance) == (number_of_moments, number_of_moments) ||
        throw(DimensionMismatch("moment covariance has the wrong dimensions"))
    covariance = Symmetric((moment_covariance + moment_covariance') / 2)
    decomposition = eigen(covariance)
    largest = maximum(abs.(decomposition.values))
    floor_value = max(eigenvalue_floor, largest * 1e-10)
    regularized_values = max.(decomposition.values, floor_value)
    optimal = decomposition.vectors * Diagonal(1.0 ./ regularized_values) *
        decomposition.vectors'
    scales = [max(abs(targets[name]), 0.01) for name in LONG_MOMENT_ORDER]
    Dict(
        "scale_diagonal" => Diagonal(1.0 ./ scales .^ 2) |> Matrix,
        "covariance_optimal" => Matrix(Symmetric(optimal)),
    )
end

function smm_local_diagnostics(jacobian::Matrix{Float64},
                               moment_covariance::Matrix{Float64},
                               weight::Matrix{Float64},
                               parameters::Vector{Float64};
                               sample_size::Int = 1)
    number_of_moments, number_of_parameters = size(jacobian)
    size(moment_covariance) == (number_of_moments, number_of_moments) ||
        throw(DimensionMismatch("moment covariance has the wrong dimensions"))
    size(weight) == (number_of_moments, number_of_moments) ||
        throw(DimensionMismatch("weight matrix has the wrong dimensions"))
    length(parameters) == number_of_parameters || throw(DimensionMismatch(
        "parameter vector has the wrong length"))
    sample_size >= 1 || throw(ArgumentError("sample_size must be positive"))

    singular_values = svdvals(jacobian)
    tolerance = maximum(size(jacobian)) * eps(Float64) *
        max(first(singular_values), 1.0)
    local_rank = count(value -> value > tolerance, singular_values)
    condition_number = local_rank == number_of_parameters ?
        first(singular_values) / last(singular_values) : Inf
    information = jacobian' * weight * jacobian
    inverse_information = pinv(Symmetric(information))
    covariance = inverse_information * jacobian' * weight *
        moment_covariance * weight * jacobian * inverse_information /
        sample_size
    covariance = Matrix(Symmetric((covariance + covariance') / 2))
    standard_errors = sqrt.(max.(diag(covariance), 0.0))
    Dict{String,Any}(
        "rank" => local_rank,
        "singular_values" => singular_values,
        "condition_number" => condition_number,
        "covariance" => covariance,
        "standard_errors" => standard_errors,
        "lower_95" => parameters .- 1.959963984540054 .* standard_errors,
        "upper_95" => parameters .+ 1.959963984540054 .* standard_errors,
    )
end

function continue_long_parameters(solution::LongCESolution,
                                  target::Vector{Float64};
                                  steps::Int = 4,
                                  tol::Float64 = 2e-5)
    length(target) == 3 || throw(DimensionMismatch(
        "target must contain beta, d0, and d1"))
    steps >= 1 || throw(ArgumentError("continuation steps must be positive"))
    origin = [solution.beta, solution.d0, solution.d1]
    current = solution
    for share in range(0.0, 1.0, length = steps + 1)[2:end]
        parameters = origin .+ share .* (target .- origin)
        current = solve_long_ce(
            solution.theta,
            beta = parameters[1],
            d0 = parameters[2],
            d1 = parameters[3],
            reentry = solution.reentry,
            rstar = solution.rstar,
            maturity = solution.maturity,
            coupon = solution.coupon,
            sigma_m = solution.sigma_m,
            nb = length(solution.b),
            bmax = solution.b[end],
            initial = current,
            tol = tol,
        )
    end
    current
end

function central_long_jacobian(solution::LongCESolution;
                               steps::Vector{Float64} = [0.001, 0.01, 0.01],
                               continuation_steps::Int = 4,
                               T::Int = 500_000,
                               seed::Int = SEED)
    parameters = [solution.beta, solution.d0, solution.d1]
    endpoints = Dict{String,Any}()
    jacobian = Matrix{Float64}(undef, length(LONG_MOMENT_ORDER), 3)
    for index in eachindex(parameters)
        plus = copy(parameters)
        minus = copy(parameters)
        plus[index] += steps[index]
        minus[index] -= steps[index]
        plus_solution = continue_long_parameters(
            solution, plus; steps = continuation_steps)
        minus_solution = continue_long_parameters(
            solution, minus; steps = continuation_steps)
        plus_moments, _ = simulate_long_ce(plus_solution; T = T, seed = seed)
        minus_moments, _ = simulate_long_ce(minus_solution; T = T, seed = seed)
        jacobian[:, index] .=
            (long_moment_vector(plus_moments) .-
             long_moment_vector(minus_moments)) ./ (2 * steps[index])
        endpoints["plus_$index"] = plus_moments
        endpoints["minus_$index"] = minus_moments
    end
    jacobian, endpoints
end

function long_smm_loss(moments::Dict{String,Any};
                       targets::Dict{String,Float64} = LONG_DATA_TARGETS)
    loss = 0.0
    contributions = Dict{String,Float64}()
    for (name, target) in targets
        scale = max(abs(target), 0.01)
        contribution = ((Float64(moments[name]) - target) / scale)^2
        contributions[name] = contribution
        loss += contribution
    end
    loss, contributions
end

function evaluate_long_parameters(beta::Float64, d0::Float64, d1::Float64;
                                  theta::Float64 = 0.5,
                                  T::Int = 200_000, seed::Int = SEED,
                                  nb::Int = LONG_NB,
                                  bmax::Float64 = LONG_BMAX)
    solution = solve_long_ce_path(
        theta; beta = beta, d0 = d0, d1 = d1, nb = nb, bmax = bmax)
    moments, _ = simulate_long_ce(solution; T = T, seed = seed)
    loss, contributions = long_smm_loss(moments)
    Dict{String,Any}(
        "parameters" => Dict("beta" => beta, "d0" => d0, "d1" => d1),
        "loss" => loss,
        "contributions" => contributions,
        "moments" => moments,
        "residual" => ce_fixed_point_residual(solution),
        "iterations" => solution.iters,
    )
end

function within_bounds(name::Symbol, value::Float64)
    lower, upper = LONG_PARAMETER_BOUNDS[name]
    lower <= value <= upper
end

function calibrate_long_ce(; theta::Float64 = 0.5, T::Int = 200_000,
                           seed::Int = SEED, nb::Int = LONG_NB,
                           bmax::Float64 = LONG_BMAX,
                           rounds::Int = 5)
    current = (beta = LONG_BETA, d0 = LONG_D0, d1 = LONG_D1)
    steps = (beta = 0.01, d0 = 0.04, d1 = 0.04)
    cache = Dict{NTuple{3,Float64},Dict{String,Any}}()

    function evaluate(parameters)
        key = (round(parameters.beta, digits = 8),
               round(parameters.d0, digits = 8),
               round(parameters.d1, digits = 8))
        get!(cache, key) do
            evaluate_long_parameters(
                key[1], key[2], key[3]; theta = theta, T = T, seed = seed,
                nb = nb, bmax = bmax)
        end
    end

    best = evaluate(current)
    for _ in 1:rounds
        improved = true
        while improved
            improved = false
            for name in (:beta, :d0, :d1), direction in (-1.0, 1.0)
                proposal_value = getproperty(current, name) +
                    direction * getproperty(steps, name)
                within_bounds(name, proposal_value) || continue
                proposal = merge(current, NamedTuple{(name,)}((proposal_value,)))
                candidate = evaluate(proposal)
                if candidate["loss"] < best["loss"]
                    current = proposal
                    best = candidate
                    improved = true
                end
            end
        end
        steps = (beta = steps.beta / 2, d0 = steps.d0 / 2,
                 d1 = steps.d1 / 2)
    end
    Dict{String,Any}(
        "targets" => LONG_DATA_TARGETS,
        "best" => best,
        "evaluations" => length(cache),
        "theta" => theta,
        "simulation_quarters" => T,
        "seed" => seed,
        "grid" => Dict("nb" => nb, "bmax" => bmax),
    )
end

function main_estimation()
    results = calibrate_long_ce()
    open(joinpath(OUTDIR, "estimation_long.json"), "w") do io
        JSON.print(io, results, 1)
    end
    println("saved estimation_long.json")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_estimation()
end
