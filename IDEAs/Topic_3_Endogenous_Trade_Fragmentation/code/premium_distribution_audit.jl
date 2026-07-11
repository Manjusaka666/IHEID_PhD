# Premium-distribution robustness for the fragmentation model.
#
# Each parametric family matches the baseline median and interquartile range.
# The sieve cdf averages narrow logistic kernels over fixed quantile knots. It
# supplies a smooth nonparametric approximation that enters the same coupled
# fixed-point problem as the parametric cdfs.

using SpecialFunctions: erf, erfinv

const OUTDIR_AUDIT = joinpath(@__DIR__, "..", "output")
const W_AUDIT = [0.15, 0.35, 0.50]
const SIGMA_AUDIT = [2.0, 4.0, 8.0]
const SHARE_AUDIT = [0.50, 0.35, 0.20]
const DURATION_AUDIT = [1.5, 1.0, 0.5]
const MEDIAN_AUDIT = [0.20, 0.15, 0.10]
const FLOOR_AUDIT = [0.05, 0.08, 0.10]
const LOG_IQR_SCALE = 0.5
const THETA_AUDIT = 0.6
const SYSTEMIC_AUDIT = 0.01
const THINNING_AUDIT = 0.4
const CAPACITY_AUDIT = 0.4
const Z75 = 0.6744897501960817

const LOSS_AUDIT = [
    ((1 - SHARE_AUDIT[m])^(1 / (1 - SIGMA_AUDIT[m])) - 1) *
    DURATION_AUDIT[m] for m in eachindex(W_AUDIT)
]

normal_cdf_audit(z) = 0.5 * (1 + erf(z / sqrt(2)))
normal_quantile_audit(p) = sqrt(2) * erfinv(2p - 1)
logistic_cdf_audit(z) = z >= 0 ? 1 / (1 + exp(-z)) : exp(z) / (1 + exp(z))

function premium_cdf_audit(g, m, family)
    g <= 0 && return 0.0
    log_ratio = log(g / MEDIAN_AUDIT[m])
    if family == :lognormal
        return normal_cdf_audit(log_ratio / LOG_IQR_SCALE)
    elseif family == :loglogistic
        scale = Z75 * LOG_IQR_SCALE / log(3)
        return logistic_cdf_audit(log_ratio / scale)
    elseif family == :weibull
        target_ratio = exp(2Z75 * LOG_IQR_SCALE)
        shape = log(log(4) / log(4 / 3)) / log(target_ratio)
        scale = MEDIAN_AUDIT[m] / log(2)^(1 / shape)
        return 1 - exp(-(g / scale)^shape)
    elseif family == :sieve
        probabilities = range(0.01, 0.99, length = 99)
        bandwidth = 0.035
        total = 0.0
        for p in probabilities
            center = log(MEDIAN_AUDIT[m]) +
                LOG_IQR_SCALE * normal_quantile_audit(p)
            total += logistic_cdf_audit((log(g) - center) / bandwidth)
        end
        return total / length(probabilities)
    end
    throw(ArgumentError("unknown premium family: $family"))
end

hazard_audit(fm, aggregate, delta) =
    delta * (1 - THETA_AUDIT * (1 - fm)) + SYSTEMIC_AUDIT * aggregate

function threshold_audit(fm, aggregate, m, delta)
    hazard_audit(fm, aggregate, delta) * LOSS_AUDIT[m] *
    (1 + THINNING_AUDIT * fm) / (1 - CAPACITY_AUDIT * fm)
end

best_response_audit(fm, aggregate, m, delta, family) =
    FLOOR_AUDIT[m] + (1 - FLOOR_AUDIT[m]) * premium_cdf_audit(
        threshold_audit(fm, aggregate, m, delta), m, family)

function solve_other_sectors_audit(fc, delta, family)
    states = [fc, 0.1, 0.1]
    for _ in 1:20_000
        aggregate = sum(W_AUDIT .* states)
        candidate = copy(states)
        for m in 2:3
            candidate[m] = best_response_audit(
                states[m], aggregate, m, delta, family)
        end
        maximum(abs.(candidate[2:3] .- states[2:3])) < 1e-13 &&
            return sum(W_AUDIT .* candidate)
        states[2:3] .= 0.5 .* (states[2:3] .+ candidate[2:3])
    end
    error("other-sector fixed point failed to converge")
end

function roots_audit(delta, family; grid_step = 0.002)
    residual(fc) = fc - best_response_audit(
        fc, solve_other_sectors_audit(fc, delta, family), 1, delta, family)
    grid = collect(0.0:grid_step:1.0)
    values = residual.(grid)
    roots = Float64[]
    for i in 1:length(grid)-1
        values[i] == 0 && push!(roots, grid[i])
        values[i] * values[i + 1] >= 0 && continue
        left, right = grid[i], grid[i + 1]
        left_value = values[i]
        for _ in 1:70
            midpoint = (left + right) / 2
            midpoint_value = residual(midpoint)
            if left_value * midpoint_value <= 0
                right = midpoint
            else
                left = midpoint
                left_value = midpoint_value
            end
        end
        push!(roots, (left + right) / 2)
    end
    abs(values[end]) < 1e-11 && push!(roots, 1.0)
    roots
end

has_fold_audit(delta, family) = length(roots_audit(delta, family)) >= 3

function refine_boundary_audit(left, right, family, left_has_fold)
    for _ in 1:18
        midpoint = (left + right) / 2
        if has_fold_audit(midpoint, family) == left_has_fold
            left = midpoint
        else
            right = midpoint
        end
    end
    (left + right) / 2
end

function fold_band_audit(family)
    grid = collect(0.02:0.002:0.30)
    indicators = has_fold_audit.(grid, Ref(family))
    indices = findall(indicators)
    isempty(indices) && return (NaN, NaN)
    first_index, last_index = first(indices), last(indices)
    lower = first_index == 1 ? grid[1] : refine_boundary_audit(
        grid[first_index - 1], grid[first_index], family, false)
    upper = last_index == length(grid) ? grid[end] : refine_boundary_audit(
        grid[last_index], grid[last_index + 1], family, true)
    (lower, upper)
end

function write_distribution_outputs(results)
    labels = Dict(
        :lognormal => "Lognormal",
        :loglogistic => "Log-logistic",
        :weibull => "Weibull",
        :sieve => "Smoothed quantile sieve",
    )
    open(joinpath(OUTDIR_AUDIT, "premium_distribution_table.tex"), "w") do io
        println(io, "\\begin{tabular}{lcc}")
        println(io, "\\toprule")
        println(io, "Premium cdf & Lower fold & Upper fold \\\\")
        println(io, "\\midrule")
        for family in (:lognormal, :loglogistic, :weibull, :sieve)
            lower, upper = results[family]
            lower_text = isnan(lower) ? "No fold" : string(round(100lower, digits = 2), "\\%")
            upper_text = isnan(upper) ? "No fold" : string(round(100upper, digits = 2), "\\%")
            println(io, labels[family], " & ", lower_text, " & ", upper_text, " \\\\")
        end
        println(io, "\\bottomrule")
        println(io, "\\end{tabular}")
    end
end

function main_distribution_audit()
    mkpath(OUTDIR_AUDIT)
    results = Dict{Symbol,Tuple{Float64,Float64}}()
    for family in (:lognormal, :loglogistic, :weibull, :sieve)
        results[family] = fold_band_audit(family)
        println(family, " fold band = ", results[family])
    end
    write_distribution_outputs(results)
    results
end

if abspath(PROGRAM_FILE) == @__FILE__
    main_distribution_audit()
end
