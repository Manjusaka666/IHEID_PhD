using Test

include("solve_model.jl")

@testset "payoff hurdles" begin
    safe_exit = rollover_hurdle(1.04, 0.60, 0.92, 0.92)
    state_exit = rollover_hurdle(1.04, 0.60, 0.94, 0.88)
    @test isapprox(safe_exit, pbar(1.04, 0.60, 0.08); atol = 1e-14)
    @test 0 < state_exit < 1
    @test_throws ArgumentError rollover_hurdle(1.04, 0.60, 1.00, 0.50)
end

@testset "as-if bias equivalence" begin
    pb = pbar(R, REC, KAP)
    theta = 0.9
    x = 0.95
    delta = 0.08
    posterior_ambiguous =
        (ALP * (YSTRESS - delta) + BET * x) / (ALP + BET)
    posterior_pessimistic =
        (ALP * (YSTRESS - delta) + BET * x) / (ALP + BET)
    @test posterior_ambiguous == posterior_pessimistic
    @test isapprox(tstar_types([1.0], YSTRESS; dels = [delta], pbs = [pb]),
                   tstar_types([1.0], YSTRESS - delta; dels = [0.0], pbs = [pb]);
                   atol = 1e-13)
    @test theta < 1
end

@testset "heterogeneous creditor types" begin
    pbs = [rollover_hurdle(1.03, 0.65, 0.93, 0.91),
           rollover_hurdle(1.05, 0.50, 0.91, 0.88)]
    threshold = tstar_types([0.6, 0.4], YSTRESS; dels = [0.0, 0.08], pbs = pbs)
    @test 0 < threshold < 1
    @test threshold > tstar_types([0.6, 0.4], YSTRESS; dels = [0.0, 0.0], pbs = pbs)
    @test ALP / sqrt(BET) < sqrt(2pi)
end

@testset "baseline directions" begin
    for y in (YCALM, YSTRESS)
        ambiguous = tstar(MU0, y)
        bayesian = tstar(MU0, y; delF = 0.0)
        @test ambiguous > bayesian
        @test slope_at(ambiguous, MU0, y) < 1
    end
    @test tstar(MU0 + 0.01, YSTRESS) > tstar(MU0, YSTRESS)
    @test tstar(MU0, YSTRESS; delF = DELF + 0.01) > tstar(MU0, YSTRESS)
end

@testset "precision theorem and no-information anchor" begin
    pb = pbar(R, REC, KAP)
    anchor = 1 - pb
    for y in (0.80, 1.10)
        almost_uninformative = tstar(MU0, y; alp = 1e-10)
        @test isapprox(almost_uninformative, anchor; atol = 2e-6)
    end

    t = tstar(MU0, YSTRESS)
    s = ALP / sqrt(BET)
    z = nquant(pb)
    g = (ALP * (t - YSTRESS) - z * sqrt(ALP + BET)) / sqrt(BET)
    phi_s = npdf(g)
    phi_f = npdf(g + s * DELF)
    ydagger = t - z / (2 * sqrt(ALP + BET)) +
        (MU0 * phi_f * DELF) / ((1 - MU0) * phi_s + MU0 * phi_f)
    eps = 1e-5
    derivative = (tstar(MU0, YSTRESS; alp = ALP * (1 + eps)) -
        tstar(MU0, YSTRESS; alp = ALP * (1 - eps))) / (2 * ALP * eps)
    @test sign(derivative) == sign(ydagger - YSTRESS)
end

@testset "coordination multiplier distribution" begin
    multipliers = Float64[]
    for y in 0.80:0.05:1.20, mu in (0.2, 0.4, 0.6, 0.8),
            delta in (0.04, 0.08, 0.12)
        threshold = tstar(mu, y; delF = delta)
        slope = slope_at(threshold, mu, y; delF = delta)
        @test 0 <= slope < 1
        push!(multipliers, 1 / (1 - slope))
    end
    @test minimum(multipliers) >= 1
    @test maximum(multipliers) > minimum(multipliers)
end
