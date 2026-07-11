using Test

include("solve_model.jl")

@testset "exact annual to monthly mapping" begin
    @test isapprox(RHOM^12, RHO; atol = 1e-14)
    innovation_variance = SIGM^2 * sum(RHOM^(2j) for j in 0:11)
    @test isapprox(innovation_variance, SIG^2; atol = 1e-14)
    feedback_sum = CHIM * sum(RHOM^j for j in 0:11)
    @test isapprox(feedback_sum, CHI; atol = 1e-14)
end

@testset "awareness and belief invariant region" begin
    for a in 0.0:0.1:1.0, n in 0.0:0.1:a
        next_a, next_n = awareness_belief_flow(a, n, 1.2)
        @test 0 <= next_n <= next_a <= 1
    end
    @test awareness_belief_drift(0.4, 0.0, 1.0)[2] == 0
    da_top, _ = awareness_belief_drift(1.0, 0.4, 1.0)
    @test da_top < 0
    da_equal, dn_equal = awareness_belief_drift(0.4, 0.4, 1.0)
    @test da_equal - dn_equal >= 0
    coarse = awareness_belief_flow(0.08, 0.02, 1.2; substeps = 8)
    fine = awareness_belief_flow(0.08, 0.02, 1.2; substeps = 32)
    @test maximum(abs.(collect(coarse) - collect(fine))) < 1e-6
end

@testset "pricing derivative and uniqueness" begin
    for (th, n) in ((0.02, 0.0), (0.06, 0.2), (0.15, 0.4))
        h = 1e-6
        numerical = (sstar(th, n + h) - sstar(th, n - h)) / (2h)
        @test isapprox(rel(th, n), numerical; rtol = 2e-5, atol = 1e-8)
    end
    for probability in (0.01, 0.10, 0.50)
        intensity = -log1p(-probability)
        exact = credit_spread(probability)
        @test exact > 0
        @test isapprox(exact, -log(
            REC + (1 - REC) * exp(-intensity)); atol = 1e-14)
    end
    @test GAINMAX < 1
    @test HUMP_MARGIN < 0
end

@testset "global phase audit" begin
    @test all(0 .<= paths["zone"]["n"] .<= 1)
    @test all(paths["zone"]["n"] .<= paths["zone"]["a"])
    @test length(phase["dtheta"]) == length(phase_theta)
    @test all(length(row) == length(phase_n) for row in phase["dn"])
    @test length(equilibrium_audit) >= 3
    @test count(equilibrium -> equilibrium.stable, equilibrium_audit) == 1
    @test any(equilibrium -> equilibrium.belief > 0 && !equilibrium.stable,
              equilibrium_audit)
    @test 0 < zone_seed_audit["horizon_240"] < N0SEED
    @test abs(zone_seed_audit["horizon_360"] -
              zone_seed_audit["horizon_240"]) < 1e-3
    @test abs(zone_seed_audit["substeps_32"] -
              zone_seed_audit["substeps_16"]) < 1e-5
    @test 0 < deterministic_default_month(
        SC["zone"], N0SEED; horizon = 360) <= 360
    @test all(paths["zone"]["th0"] .>= 0)
end
