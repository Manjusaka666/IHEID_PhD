# Simulated-moment calibration for the long-duration diagnostic model.
# Data targets are the Argentina moments reported by Chatterjee and Eyigungor
# (2012). Return predictability remains an untargeted validation moment until a
# matched EMBI total-return sample is supplied.

include("solve_long_bonds_ce.jl")

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
