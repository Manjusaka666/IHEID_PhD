using Test
using LinearAlgebra

include("solve_model.jl")

@testset "threshold and complementarity" begin
    state = steady(DELTA_POST, NOPOL; init = fill(0.02, 3))
    m = 1
    step = 1e-6
    partials = response_partials(state.Fm[m], state.F, m, DELTA_POST, NOPOL)
    own_fd = (
        fmap(state.Fm[m] + step, state.F, m, DELTA_POST, NOPOL) -
        fmap(state.Fm[m] - step, state.F, m, DELTA_POST, NOPOL)) / (2step)
    aggregate_fd = (
        fmap(state.Fm[m], state.F + step, m, DELTA_POST, NOPOL) -
        fmap(state.Fm[m], state.F - step, m, DELTA_POST, NOPOL)) / (2step)
    shock_fd = (
        fmap(state.Fm[m], state.F, m, DELTA_POST + step, NOPOL) -
        fmap(state.Fm[m], state.F, m, DELTA_POST - step, NOPOL)) / (2step)
    @test isapprox(partials.own, own_fd; rtol = 1e-7)
    @test isapprox(partials.aggregate, aggregate_fd; rtol = 1e-7)
    @test isapprox(partials.shock, shock_fd; rtol = 1e-7)
    @test partials.own > 0
    @test partials.aggregate > 0
end

@testset "multisector multiplier" begin
    state = steady(DELTA_POST, NOPOL; init = fill(0.02, 3))
    response = vector_multiplier(state.Fm, DELTA_POST, NOPOL)
    @test response.spectral_radius < 1
    @test all(response.total .> response.direct)
    @test all(response.cross_spillover .> 0)
    step = 1e-5
    shifted_up = steady(DELTA_POST + step, NOPOL; init = state.Fm)
    shifted_down = steady(DELTA_POST - step, NOPOL; init = state.Fm)
    finite_difference = (shifted_up.Fm - shifted_down.Fm) / (2step)
    @test isapprox(response.total, finite_difference; rtol = 1e-6, atol = 1e-14)
    @test maximum(abs.(response.J)) > 0
    @test isapprox((I - response.J) * response.total, response.direct; atol = 1e-12)
end

@testset "fixed points and policy signs" begin
    baseline = steady(DELTA_POST, NOPOL; init = fill(0.02, 3))
    @test maximum(abs.(baseline.Fm .-
        [fmap(baseline.Fm[m], baseline.F, m, DELTA_POST, NOPOL) for m in 1:3])) < 1e-12
    @test all(0 .<= baseline.Fm .<= 1)
    planner_state = planner(DELTA_POST, 1)
    corrective = pigou(DELTA_POST, 1, planner_state.F)
    @test corrective > 0
    @test lam0(1) > lam0(2) > lam0(3) > 0
    @test disruption_loss(1) == lam0(1)
    @test disruption_loss(1; inventory_years = 0.25,
                          emergency_substitution = 0.25) < lam0(1)
    @test disruption_loss(1; inventory_years = 0.5,
                          emergency_substitution = 0.5) <
        disruption_loss(1; inventory_years = 0.25,
                         emergency_substitution = 0.25)

    constant_path = fill(DELTA_POST, 30)
    initial_path = repeat(reshape(baseline.Fm, 1, :), 30, 1)
    forward = perfect_foresight(
        constant_path, NOPOL; init = baseline.Fm,
        initial_path = initial_path)
    @test forward.residual < 1e-9
    @test maximum(abs.(forward.Fm .- initial_path)) < 1e-8
    @test all(0 .<= forward.Fm .<= 1)
end

@testset "nondegenerate folds" begin
    lower = refine_fold(0.74, 0.114, NOPOL)
    upper = refine_fold(0.23, 0.131, NOPOL)
    for fold in (lower, upper)
        @test abs(fold.residual) < 1e-9
        @test abs(fold.slope_residual) < 1e-8
        @test abs(fold.curvature) > 1e-2
        @test abs(fold.transversality) > 1e-2
    end
    @test lower.delta < upper.delta
    @test lower.F > upper.F

    middle_hazard = (lower.delta + upper.delta) / 2
    audit = equilibrium_grid_audit(middle_hazard, NOPOL)
    @test all(audit.root_counts .== 3)
    @test audit.max_root_difference < 1e-7
end

include("premium_distribution_audit.jl")

@testset "premium distribution audit" begin
    for family in (:lognormal, :loglogistic, :weibull, :sieve)
        @test isapprox(premium_cdf_audit(MEDIAN_AUDIT[1], 1, family), 0.5;
                       atol = family == :sieve ? 2e-3 : 1e-12)
        @test premium_cdf_audit(0.01, 1, family) <
            premium_cdf_audit(0.20, 1, family) <
            premium_cdf_audit(1.00, 1, family)
    end
    baseline_roots = roots_audit(0.12, :lognormal)
    @test length(baseline_roots) == 3
    @test all(0 .<= baseline_roots .<= 1)
end
