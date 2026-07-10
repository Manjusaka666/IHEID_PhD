using Test

include("solve_model.jl")
include("survey_mapping_mc.jl")
include("solve_long_bonds.jl")
include("solve_long_bonds_ce.jl")

@testset "diagnostic sovereign revision checks" begin
    x, P, Pd = build_kernels(0.5)
    @test maximum(abs.(sum(P, dims = 2) .- 1.0)) < 1e-12
    @test maximum(abs.(sum(Pd, dims = 3) .- 1.0)) < 1e-12

    rational = solve(0.0; q0 = :riskfree)
    from_riskfree = solve(0.5; q0 = :riskfree)
    from_zero = solve(0.5; q0 = :zero)
    from_rational = solve(0.5; q0 = rational.q)

    for sol in (rational, from_riskfree, from_zero, from_rational)
        residual = fixed_point_residual(sol)
        @test residual["bellman"] < 1e-7
        @test residual["price"] < 1e-7
        @test minimum(sol.q) >= -1e-12
        @test maximum(sol.q) <= 1.0 / (1.0 + RSTAR) + 1e-12
        @test minimum_repayment_consumption(sol) > CMIN
    end

    @test maximum(abs.(from_riskfree.q .- from_zero.q)) < 1e-6
    @test maximum(abs.(from_riskfree.q .- from_rational.q)) < 1e-6
    @test from_riskfree.d == from_zero.d == from_rational.d
end

@testset "long-duration sovereign debt" begin
    @test isdefined(Main, :solve_long_ce)
    @test isdefined(Main, :solve_long_ce_path)
    @test isdefined(Main, :LONG_D0)
    @test isdefined(Main, :LONG_D1)
    @test isdefined(Main, :LONG_REENTRY)
    @test LONG_SIGMA_M == 0.003
    @test isdefined(Main, :build_long_kernels)
    @test isdefined(Main, :long_expected_payoff_continuous_fast)
    @test isdefined(Main, :long_repayment_choice)
    @test isdefined(Main, :long_choice_at_m_range)
    bcheck = collect(range(0.0, 0.35, length = 20))
    ycheck = exp.(tauchen_grid())
    qcheck = fill(long_riskfree_price(0.05, 0.03), 20, NY, NY)
    Wcheck = zeros(20, NY)
    Wcheck[:, 11] .= range(-0.05, 0.05, length = 20)
    Vdcheck = fill(-25.0, NY)
    payment_check = 0.05 + 0.95 * 0.03
    for ib in (1, 10, 20)
        reference = long_expected_payoff_continuous_reference(
            ib, 11, 11, bcheck, ycheck, qcheck, Wcheck, Vdcheck,
            payment_check, 0.05, 0.03, 0.969, 0.003)
        fast = long_expected_payoff_continuous_fast(
            ib, 11, 11, bcheck, ycheck, qcheck, Wcheck, Vdcheck,
            payment_check, 0.05, 0.03, 0.969, 0.003)
        @test isapprox(fast, reference; atol = 1e-13)
    end
    delta = 0.05
    coupon = 0.03
    qbar = long_riskfree_price(delta, coupon)
    @test abs(qbar - (delta + (1 - delta) * coupon) / (delta + LONG_RSTAR)) < 1e-14
    mcheck, pcheck = transitory_grid(LONG_NM, LONG_SIGMA_M)
    @test isapprox(sum(pcheck), 1.0; atol = 1e-14)
    @test maximum(abs.(mcheck)) < LONG_TRUNCATION * LONG_SIGMA_M
    @test abs(dot(mcheck, pcheck)) < 1e-14

    one_period = solve(0.5)
    limit = solve_long(0.5; maturity = 1.0, coupon = coupon,
                       beta = BETA, phi = PHI, nb = NB, bmax = BMAX,
                       nm = 1, sigma_m = 0.0, calibration = :short,
                       reentry = LAM, rstar = RSTAR, damp = 0.5,
                       maxit = 10_000, tol = 1e-6)
    @test maximum(abs.(one_period.q .- limit.q)) < 1e-6
    @test one_period.d == dropdims(limit.d, dims = 4)

    xce, Pce, Pdce = build_long_kernels(0.5)
    @test maximum(abs.(sum(Pce, dims = 2) .- 1.0)) < 1e-12
    @test maximum(abs.(sum(Pdce, dims = 3) .- 1.0)) < 1e-12
    @test long_riskfree_price(1.0, coupon, RSTAR) == 1 / (1 + RSTAR)

    bce = collect(range(0.0, 1.5, length = 12))
    yce = exp.(xce)
    qce = fill(long_riskfree_price(delta, coupon), 12, NY, NY)
    lossce = max.(0.0, LONG_D0 .* yce .+ LONG_D1 .* yce .^ 2)
    Xce = [ce_autarky_flow(yce[ix] - lossce[ix], LONG_SIGMA_M) /
           (1 - LONG_BETA) for ix in 1:NY]
    Zce = repeat(reshape(Xce, 1, NY), 12, 1)
    Dce = similar(Xce)
    Vce = zeros(12, NY, NY)
    payoffce = similar(Vce)
    Znce = similar(Zce)
    Xnce = similar(Xce)
    qnce = similar(qce)
    loce = -LONG_TRUNCATION * LONG_SIGMA_M
    hice = LONG_TRUNCATION * LONG_SIGMA_M
    paymentce = delta + (1 - delta) * coupon
    wholece = ce_gauss_value(1, loce, hice, 1, 11, 11, bce, yce, qce,
                              Zce, Xce, paymentce, delta, LONG_BETA,
                              LONG_SIGMA_M)
    adaptivece = ce_adaptive_value(
        1, loce, hice, wholece, 1, 11, 11, bce, yce, qce, Zce, Xce,
        paymentce, delta, LONG_BETA, LONG_SIGMA_M, 1)
    fixedce = ce_gauss20_value(
        1, loce, hice, 1, 11, 11, bce, yce, qce, Zce, Xce,
        paymentce, delta, LONG_BETA, LONG_SIGMA_M)
    @test isapprox(fixedce, adaptivece; atol = 1e-10, rtol = 1e-11)
    ce_operator!(Vce, payoffce, Znce, Xnce, Dce, qnce, Zce, Xce, qce,
                 xce, Pce, Pdce, bce, LONG_BETA, LONG_D0, LONG_D1,
                 LONG_REENTRY, LONG_RSTAR, delta, coupon, LONG_SIGMA_M)
    @test all(isfinite, Vce)
    @test all(isfinite, qnce)
    @test minimum(qnce) >= -1e-12
    @test maximum(qnce) <= long_riskfree_price(delta, coupon) + 1e-12
    seedce = LongCESolution(
        xce, Pce, Pdce, yce, bce, Zce, Xce, Dce, qce, Vce, payoffce,
        0.5, LONG_BETA, LONG_D0, LONG_D1, LONG_REENTRY, LONG_RSTAR,
        delta, coupon, LONG_SIGMA_M, 0)
    finece = prolongate_long_ce(seedce, 25, 1.5)
    @test size(finece.Z) == (25, NY)
    @test size(finece.q) == (25, NY, NY)
    @test finece.Z[1, :] == seedce.Z[1, :]
    @test finece.Z[end, :] == seedce.Z[end, :]

end

@testset "monthly survey transformation" begin
    betas = [survey_beta(theta; nmonths = 120_000, seed = 20260710) for theta in (0.0, 0.25, 0.5, 1.0)]
    @test abs(betas[1]) < 0.02
    @test all(diff(betas) .< 0.0)
    for (theta, beta) in zip((0.0, 0.25, 0.5, 1.0), betas)
        recovered = invert_survey_beta(beta; nmonths = 120_000, seed = 20260710)
        @test abs(recovered - theta) < 0.02
    end
end
