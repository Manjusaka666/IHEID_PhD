# Monthly fixed-event survey transformation for the diagnostic-expectations
# coefficient. The code simulates a monthly AR(1), constructs forecasts of
# current-year and next-year annual-average growth, applies the rolling
# twelve-month weights used in the paper, and estimates the population
# forecast-error-on-revision coefficient.

using Random
using JSON

const SURVEY_OUTDIR = joinpath(@__DIR__, "..", "output")
const SURVEY_CACHE = Dict{Tuple{Int,Int,Float64},NamedTuple}()

year_of_month(t::Int) = fld(t - 1, 12) + 1
months_left_weight(t::Int) = (13 - (mod(t - 1, 12) + 1)) / 12

function conditional_month(x::Vector{Float64}, t::Int, k::Int, rho::Float64)
    k <= t ? x[k] : rho^(k - t) * x[t]
end

function expected_annual_average(x::Vector{Float64}, t::Int, year::Int,
                                 rho::Float64)
    first_month = 12 * (year - 1) + 1
    last_month = first_month + 11
    total = 0.0
    @inbounds for k in first_month:last_month
        total += conditional_month(x, t, k, rho)
    end
    total / 12
end

function expected_annual_growth(x::Vector{Float64}, t::Int, year::Int,
                                rho::Float64)
    expected_annual_average(x, t, year, rho) -
        expected_annual_average(x, t, year - 1, rho)
end

function realized_annual_growth(x::Vector{Float64}, year::Int)
    first_month = 12 * (year - 1) + 1
    current = sum(@view x[first_month:first_month + 11]) / 12
    previous = sum(@view x[first_month - 12:first_month - 1]) / 12
    current - previous
end

"Rational forecast and diagnostic-update component of the rolling target."
function converted_forecast_components(x::Vector{Float64}, t::Int,
                                       rho::Float64)
    year = year_of_month(t)
    weight = months_left_weight(t)
    current_t = expected_annual_growth(x, t, year, rho)
    next_t = expected_annual_growth(x, t, year + 1, rho)
    current_lag = expected_annual_growth(x, t - 1, year, rho)
    next_lag = expected_annual_growth(x, t - 1, year + 1, rho)
    rational = weight * current_t + (1 - weight) * next_t
    diagnostic_update = weight * (current_t - current_lag) +
        (1 - weight) * (next_t - next_lag)
    rational, diagnostic_update
end

function realized_rolling_target(x::Vector{Float64}, t::Int)
    year = year_of_month(t)
    weight = months_left_weight(t)
    weight * realized_annual_growth(x, year) +
        (1 - weight) * realized_annual_growth(x, year + 1)
end

function survey_components(; nmonths::Int = 240_000, seed::Int = 20260710,
                           rho_q::Float64 = 0.945)
    key = (nmonths, seed, rho_q)
    haskey(SURVEY_CACHE, key) && return SURVEY_CACHE[key]

    rho = rho_q^(1 / 3)
    stationary_sd = 0.025 / sqrt(1 - rho_q^2)
    sigma = stationary_sd * sqrt(1 - rho^2)
    padding = 120
    total = nmonths + 2 * padding + 24
    rng = Xoshiro(seed)
    x = zeros(total)
    x[1] = stationary_sd * randn(rng)
    for t in 2:total
        x[t] = rho * x[t - 1] + sigma * randn(rng)
    end

    first_t = padding + 1
    last_t = first_t + nmonths - 1
    rev0 = Vector{Float64}(undef, nmonths)
    rev1 = similar(rev0)
    err0 = similar(rev0)
    err1 = similar(rev0)
    for (i, t) in enumerate(first_t:last_t)
        f0, f1 = converted_forecast_components(x, t, rho)
        lag0, lag1 = converted_forecast_components(x, t - 1, rho)
        rev0[i] = f0 - lag0
        rev1[i] = f1 - lag1
        err0[i] = realized_rolling_target(x, t) - f0
        err1[i] = -f1
    end
    components = (rev0 = rev0, rev1 = rev1, err0 = err0, err1 = err1)
    SURVEY_CACHE[key] = components
    components
end

function slope_with_intercept(y::Vector{Float64}, x::Vector{Float64})
    mx = sum(x) / length(x)
    my = sum(y) / length(y)
    denominator = sum((x .- mx) .^ 2)
    denominator > 0 || throw(ArgumentError("forecast revisions have zero variance"))
    sum((x .- mx) .* (y .- my)) / denominator
end

function survey_beta(theta::Float64; nmonths::Int = 240_000,
                     seed::Int = 20260710, rho_q::Float64 = 0.945)
    theta >= 0 || throw(ArgumentError("theta must be nonnegative"))
    c = survey_components(nmonths = nmonths, seed = seed, rho_q = rho_q)
    revision = c.rev0 .+ theta .* c.rev1
    error = c.err0 .+ theta .* c.err1
    slope_with_intercept(error, revision)
end

function invert_survey_beta(target::Float64; nmonths::Int = 240_000,
                            seed::Int = 20260710, rho_q::Float64 = 0.945,
                            upper::Float64 = 2.0)
    beta_zero = survey_beta(0.0; nmonths = nmonths, seed = seed, rho_q = rho_q)
    target >= beta_zero && return 0.0
    beta_upper = survey_beta(upper; nmonths = nmonths, seed = seed, rho_q = rho_q)
    target >= beta_upper || throw(ArgumentError("target lies below the inversion range"))
    lo = 0.0
    hi = upper
    for _ in 1:60
        mid = (lo + hi) / 2
        beta_mid = survey_beta(mid; nmonths = nmonths, seed = seed, rho_q = rho_q)
        if beta_mid > target
            lo = mid
        else
            hi = mid
        end
    end
    (lo + hi) / 2
end

function main_survey()
    mkpath(SURVEY_OUTDIR)
    nmonths = 240_000
    rows = Dict{String,Any}()
    for theta in (0.0, 0.25, 0.5, 1.0)
        beta = survey_beta(theta; nmonths = nmonths)
        recovered = invert_survey_beta(beta; nmonths = nmonths)
        rows["theta_$(theta)"] = Dict("beta" => beta, "recovered_theta" => recovered)
    end
    open(joinpath(SURVEY_OUTDIR, "survey_mapping.json"), "w") do io
        JSON.print(io, Dict("nmonths" => nmonths, "rows" => rows), 1)
    end

    beta_half = rows["theta_0.5"]["beta"]
    recovered_half = rows["theta_0.5"]["recovered_theta"]
    recovery_error = abs(recovered_half - 0.5)
    lines = [
        "% generated by survey_mapping_mc.jl",
        "\\newcommand{\\SurveyBetaHalf}{$(round(beta_half, digits = 3))}",
        "\\newcommand{\\SurveyThetaRecovered}{$(round(recovered_half, digits = 3))}",
        "\\newcommand{\\SurveyRecoveryError}{$(round(recovery_error, digits = 4))}",
        "\\newcommand{\\SurveyMonths}{$(nmonths)}",
    ]
    open(joinpath(SURVEY_OUTDIR, "survey_mapping_numbers.tex"), "w") do io
        foreach(line -> println(io, line), lines)
    end
    println("saved survey_mapping.json and survey_mapping_numbers.tex")
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_survey()
end
