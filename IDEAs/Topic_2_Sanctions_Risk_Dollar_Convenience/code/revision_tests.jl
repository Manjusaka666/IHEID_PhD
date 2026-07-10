using Test

include("solve_model.jl")

@testset "local sanctions model" begin
    cb = calib(M0)
    @test isapprox(cb.m, 1 / (1 - cb.l1 / cb.kap); atol = 1e-14)
    @test isapprox(ss(0.0, cb).N, N0; atol = 1e-12)
    @test sanctions_wedge(1.0, PSING; chi = 2.0) ==
        2 * sanctions_wedge(1.0, PSING; chi = 1.0)
    @test privilege(N0, cb; zeta = 0.25) ==
        0.5 * privilege(N0, cb; zeta = 0.5)

    response = heterogeneous_local_response(
        [1.0, 2.0], [1.0, 0.5], [1.0, 0.0], [2.0, 1.0], 0.2)
    @test response.direct == -1.0
    @test response.multiplier > 1.0
    @test response.total < response.direct
end

@testset "bounded global scenario" begin
    gc = global_calib(M0)
    @test isapprox(global_convenience(N0, gc), CY0; atol = 1e-13)
    @test isapprox(global_convenience_slope(N0, gc), calib(M0).l1; atol = 1e-13)
    @test isapprox(global_marginal_cost_slope(N0, gc), kappa(); atol = 1e-13)
    @test 0 < global_convenience(0.0, gc) < global_convenience(1.0, gc)
    ngrid = range(0.0, 1.0; length = 10_001)
    contraction_bound = maximum(
        global_convenience_slope(n, gc) /
        global_marginal_cost_slope(0.0, gc) for n in ngrid)
    @test contraction_bound < 1.0
    @test global_marginal_cost_slope(0.0, gc) > 0
    gc_flat = global_calib(1.0)
    @test global_convenience(0.0, gc_flat) == CY0
    @test global_convenience_slope(N0, gc_flat) == 0.0

    baseline = global_ss(0.0, gc)
    shocked = global_ss(sanctions_wedge(1.0, 0.25), gc)
    @test isapprox(baseline.N, N0; atol = 1e-10)
    @test 0 <= shocked.aE <= shocked.aA <= 1
    @test shocked.N < baseline.N

    low_pass = gamma_threshold(0.10, gc; zeta = 0.25, chi = 1.0)
    high_pass = gamma_threshold(0.10, gc; zeta = 1.0, chi = 1.0)
    high_liquidity = gamma_threshold(0.10, gc; zeta = 0.25, chi = 4.0)
    @test high_pass > low_pass > 0
    @test high_liquidity > low_pass
end
