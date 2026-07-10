# Information-block sensitivity for the ambiguity rollover model.
#
# The information block is a scenario grid. This script verifies the
# uniqueness condition ALP/sqrt(BET) < sqrt(2*pi) and reports how the model
# outputs move across the grid.
#
# Shared primitives are imported from solve_model.jl. Its main guard prevents
# the baseline output routine from running on import.
#
# WHAT IS HELD FIXED ACROSS THE GRID. solve_model.jl treats the public-signal
# LEVELS as the state: YCALM = 1.10 and YSTRESS = 0.95 are fixed constants, and
# so are MU0 = 0.40 and DELF = 0.08. It never recalibrates y to hit a target
# calm spread. We follow that structure exactly: across the (sigx, sigy) grid we
# hold y, mu, and delF fixed and let alp = 1/sigy^2, bet = 1/sigx^2 move. A
# consequence, reported below via \SCalmLo/\SCalmHi, is that the calm spread
# itself moves with precision through the threshold and crisis probability.
#
# Run:  julia --project=. info_sens.jl    Output: ../output/info_numbers.tex

using Printf
include("solve_model.jl")

const UNIQ_BOUND = sqrt(2.0 * pi)

# ------------------------------------------------ premium at one precision cell
# Distrust premium (bp) = ambiguity spread (delF = DELF) minus Bayesian spread
# (delF = 0), at a given public-signal level y and precision pair (alp, bet),
# holding mu = MU0. This is exactly the object solve_model.jl calls premium_bp,
# generalized to arbitrary (alp, bet).
function premium_bp(y; alp = ALP, bet = BET, mu = MU0)
    tA = tstar(mu, y; delF = DELF, alp = alp, bet = bet)
    tB = tstar(mu, y; delF = 0.0,  alp = alp, bet = bet)
    PA = crisisP(tA, y; alp = alp)
    PB = crisisP(tB, y; alp = alp)
    spread_bp(PA) - spread_bp(PB)
end

# calm-state spread (bp) with ambiguity at a cell (the calm anchor)
function scalm_bp(; alp = ALP, bet = BET, mu = MU0)
    tA = tstar(mu, YCALM; delF = DELF, alp = alp, bet = bet)
    spread_bp(crisisP(tA, YCALM; alp = alp))
end

ratio(sigx, sigy) = (1.0 / sigy^2) / sqrt(1.0 / sigx^2)   # = ALP/sqrt(BET) = sigx/sigy^2

# =============================================================== 1. BASELINE
# Reproduce the published headline and assert against the rounded macros.
base_ratio  = ALP / sqrt(BET)
base_bound  = UNIQ_BOUND
base_premC  = premium_bp(YCALM)
base_premS  = premium_bp(YSTRESS)
base_scalm  = scalm_bp()

println("BASELINE SCENARIO reproduction:")
@printf("  alp/sqrt(bet) = %.4f  (rounds to %.2f, published 1.35)\n", base_ratio, round(base_ratio, digits = 2))
@printf("  uniq bound    = %.4f  (rounds to %.2f, published 2.51)\n", base_bound, round(base_bound, digits = 2))
@printf("  calm premium  = %.3f bp (rounds to %d, published 18)\n", base_premC, round(Int, base_premC))
@printf("  stress premium= %.3f bp (rounds to %d, published 98)\n", base_premS, round(Int, base_premS))
@printf("  calm spread   = %.3f bp (rounds to %d, published 79)\n", base_scalm, round(Int, base_scalm))

@assert round(base_ratio, digits = 2) == 1.35   "ratio mismatch"
@assert round(base_bound, digits = 2) == 2.51    "bound mismatch"
@assert round(Int, base_premC) == 18             "calm premium mismatch"
@assert round(Int, base_premS) == 98             "stress premium mismatch"
@assert round(Int, base_scalm) == 79             "calm spread mismatch"
println("  all baseline asserts PASSED\n")

# =============================================================== 2. GRID SWEEP
# Information-precision grid. Precision spans well over a factor of 2 in each
# dimension: sigx in {0.10,0.15,0.20,0.30} -> bet in [11.1, 100] (x9);
# sigy in {0.25, 1/3, 0.50} -> alp in [4, 16] (x4). Baseline (0.15, 1/3) sits
# in the interior. delF, mu, and the public-signal levels y are held fixed.
sigx_grid = [0.10, 0.15, 0.20, 0.30]
sigy_grid = [0.25, 1.0 / 3.0, 0.50]

struct Cell
    sigx::Float64
    sigy::Float64
    ratio::Float64
    unique::Bool
    premC::Float64
    premS::Float64
    scalm::Float64
end

cells = Cell[]
println("GRID SWEEP (mu = $(MU0), delF = $(DELF), y_calm = $(YCALM), y_stress = $(YSTRESS)):")
@printf("  %-6s %-8s %-8s %-8s %-10s %-10s %-8s\n",
        "sigx", "sigy", "ratio", "unique?", "premCalm", "premStress", "SCalm")
for sx in sigx_grid, sy in sigy_grid
    alp = 1.0 / sy^2
    bet = 1.0 / sx^2
    r = alp / sqrt(bet)
    uniq = r < UNIQ_BOUND
    pc = premium_bp(YCALM;   alp = alp, bet = bet)
    ps = premium_bp(YSTRESS; alp = alp, bet = bet)
    sc = scalm_bp(alp = alp, bet = bet)
    push!(cells, Cell(sx, sy, r, uniq, pc, ps, sc))
    @printf("  %-6.2f %-8.4f %-8.2f %-8s %-10.1f %-10.1f %-8.1f\n",
            sx, sy, r, uniq ? "yes" : "NO", pc, ps, sc)
end
println()

# ratio range over the WHOLE grid (unique or not)
all_ratios = [c.ratio for c in cells]
ratio_lo = minimum(all_ratios)
ratio_hi = maximum(all_ratios)
cells_nonunique = count(c -> !c.unique, cells)

# premium / spread bands over the UNIQUE cells only (the model is only valid,
# i.e. single-equilibrium, where uniqueness holds; reporting premia in the
# selection region would be meaningless).
uniq_cells = filter(c -> c.unique, cells)
premC_lo = minimum(c.premC for c in uniq_cells)
premC_hi = maximum(c.premC for c in uniq_cells)
premS_lo = minimum(c.premS for c in uniq_cells)
premS_hi = maximum(c.premS for c in uniq_cells)
scalm_lo = minimum(c.scalm for c in uniq_cells)
scalm_hi = maximum(c.scalm for c in uniq_cells)
# stress-to-calm premium ratio (state-dependence of distrust pricing), unique cells
premratios = [c.premS / c.premC for c in uniq_cells]
premratio_lo = minimum(premratios)
premratio_hi = maximum(premratios)

# =============================================================== 3. FRONTIER
# Uniqueness frontier at sigy = 0.25: the private-noise level sigx at which
# ALP/sqrt(BET) = sqrt(2*pi) exactly. The ratio sigx/sigy^2 increases in sigx,
# so uniqueness holds for sigx below this value and selection appears above it;
# i.e. private noise can rise TO this value before selection appears. One-line
# bisection on f(sigx) = ratio(sigx, 0.25) - sqrt(2*pi).
function sigx_frontier(sy; lo = 0.01, hi = 2.0)
    f(sx) = ratio(sx, sy) - UNIQ_BOUND
    for _ in 1:200
        mid = 0.5 * (lo + hi)
        (f(mid) < 0.0) ? (lo = mid) : (hi = mid)
    end
    0.5 * (lo + hi)
end
sigx_front = sigx_frontier(0.25)
# closed-form check: sigx = sqrt(2pi) * sigy^2
@assert isapprox(sigx_front, UNIQ_BOUND * 0.25^2; atol = 1e-4) "frontier bisection off"

# For the transparency-side statement: minimum sigy at baseline sigx = 0.15
# below which selection appears (public noise can fall to this value).
function sigy_frontier(sx; lo = 0.01, hi = 2.0)
    # ratio decreases in sigy, so find sigy where ratio = bound
    f(sy) = ratio(sx, sy) - UNIQ_BOUND
    # f is decreasing in sy; want root
    for _ in 1:200
        mid = 0.5 * (lo + hi)
        (f(mid) > 0.0) ? (lo = mid) : (hi = mid)
    end
    0.5 * (lo + hi)
end
sigy_front = sigy_frontier(SIGX)

println("FRONTIER:")
@printf("  at sigy = 0.25, contraction frontier at sigx >= %.4f (private noise ceiling)\n", sigx_front)
@printf("  at sigx = 0.15, contraction frontier at sigy <= %.4f (public noise floor)\n", sigy_front)
@printf("  cells violating uniqueness: %d of %d\n\n", cells_nonunique, length(cells))

println("BANDS (over unique cells):")
@printf("  ratio grid:      [%.2f, %.2f]  (whole grid)\n", ratio_lo, ratio_hi)
@printf("  calm premium:    [%d, %d] bp\n", round(Int, premC_lo), round(Int, premC_hi))
@printf("  stress premium:  [%d, %d] bp\n", round(Int, premS_lo), round(Int, premS_hi))
@printf("  calm spread:     [%d, %d] bp\n", round(Int, scalm_lo), round(Int, scalm_hi))
@printf("  stress/calm prem ratio: [%.1f, %.1f]\n\n", premratio_lo, premratio_hi)

# =============================================================== 4. WRITE TEX
open(joinpath(OUTDIR, "info_numbers.tex"), "w") do io
    println(io, "% Information-block sensitivity macros (generated by code/info_sens.jl).")
    println(io, "% Grid: sigx in {0.10,0.15,0.20,0.30} x sigy in {0.25,1/3,0.50}, mu=0.40, delF=0.08.")
    println(io, "% y-levels (YCALM=1.10, YSTRESS=0.95), mu, and delF held fixed; alp,bet vary.")
    println(io, "% Premium/spread bands are over the UNIQUE cells only (alp/sqrt(bet) < sqrt(2pi)).")
    @printf(io, "\\newcommand{\\RatioGridLo}{%.2f}\n", ratio_lo)
    @printf(io, "\\newcommand{\\RatioGridHi}{%.2f}\n", ratio_hi)
    @printf(io, "\\newcommand{\\CellsNonUnique}{%d}\n", cells_nonunique)
    @printf(io, "\\newcommand{\\PremCalmLo}{%d}\n", round(Int, premC_lo))
    @printf(io, "\\newcommand{\\PremCalmHi}{%d}\n", round(Int, premC_hi))
    @printf(io, "\\newcommand{\\PremStressLo}{%d}\n", round(Int, premS_lo))
    @printf(io, "\\newcommand{\\PremStressHi}{%d}\n", round(Int, premS_hi))
    @printf(io, "\\newcommand{\\SCalmLo}{%d}\n", round(Int, scalm_lo))
    @printf(io, "\\newcommand{\\SCalmHi}{%d}\n", round(Int, scalm_hi))
    @printf(io, "\\newcommand{\\SigXFrontier}{%.3f}\n", sigx_front)
    @printf(io, "\\newcommand{\\PremRatioLo}{%.1f}\n", premratio_lo)
    @printf(io, "\\newcommand{\\PremRatioHi}{%.1f}\n", premratio_hi)
end
println("wrote ../output/info_numbers.tex")
