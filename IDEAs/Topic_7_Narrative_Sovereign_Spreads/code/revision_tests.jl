using Test

include("solve_model.jl")

@testset "exact annual to monthly mapping" begin
    @test isapprox(RHOM^12, RHO; atol = 1e-14)
    innovation_variance = SIGM^2 * sum(RHOM^(2j) for j in 0:11)
    @test isapprox(innovation_variance, SIG^2; atol = 1e-14)
    feedback_sum = CHIM * sum(RHOM^j for j in 0:11)
    @test isapprox(feedback_sum, CHI; atol = 1e-14)
end

@testset "continuous prevalence flow" begin
    for n in 0.0:0.05:1.0
        next_n = prevalence_flow(n, 1.2, 0.3)
        @test 0 <= next_n <= 1
    end
    endemic = 1 - 0.3 / 1.2
    @test isapprox(prevalence_flow(endemic, 1.2, 0.3), endemic; atol = 1e-14)
    @test prevalence_flow(0.02, 1.2, 0.3) > 0.02
    @test prevalence_flow(0.02, 0.1, 0.3) < 0.02
end

@testset "pricing derivative and uniqueness" begin
    for (th, n) in ((0.02, 0.0), (0.06, 0.2), (0.15, 0.4))
        h = 1e-6
        numerical = (sstar(th, n + h) - sstar(th, n - h)) / (2h)
        @test isapprox(rel(th, n), numerical; rtol = 2e-5, atol = 1e-8)
    end
    @test GAINMAX < 1
    @test HUMP_MARGIN < 0
end

@testset "scenario outputs" begin
    @test all(0 .<= paths["zone"]["n"] .<= 1)
    @test length(phase["dtheta"]) == length(phase_theta)
    @test all(length(row) == length(phase_n) for row in phase["dn"])
    @test first(findall(paths["zone"]["th"] .< 0)) == 39
end
