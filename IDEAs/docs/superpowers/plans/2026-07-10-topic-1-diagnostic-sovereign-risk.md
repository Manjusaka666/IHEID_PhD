# Topic 1 Diagnostic Sovereign Risk Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct the equilibrium claims, implement the survey transformation and long-duration quantitative model, align welfare and calibration claims with code, and revise the paper to answer every Topic 1 item in referee v3.

**Architecture:** Preserve the one-period model as the analytical core. Add three focused computational modules: deterministic fixed-point diagnostics, monthly survey-transformation Monte Carlo, and a Chatterjee-Eyigungor long-duration solver. The manuscript reports analytical results only where proved and reads all new numbers from generated TeX macros.

**Tech Stack:** Julia 1.x with the existing project, R with jsonlite, LaTeX with biblatex and latexmk.

## Global Constraints

- The manuscript source is `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`.
- The scripts must run from `Topic_1_Diagnostic_Sovereign_Risk/code/`.
- Model-generated manuscript numbers must enter through generated TeX macros.
- No em dashes, prose semicolons, rhetorical triads, AI stock phrases, promotional language, or draft meta-commentary may remain in paper prose.
- Licensed data may be described but not claimed as analysed.

---

### Task 1: Fixed-point diagnostics and finite-grid equilibrium statement

**Files:**
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/code/solve_model.jl`
- Create: `Topic_1_Diagnostic_Sovereign_Risk/code/revision_tests.jl`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`

**Interfaces:**
- Consumes: `solve(theta; q0, return_diagnostics)` and the existing `Solution` object.
- Produces: `fixed_point_residual(sol)`, convergence results from `:riskfree`, `:zero`, and `:rational` initial schedules, plus manuscript macros for residuals and schedule differences.

- [ ] Add tests that require transition rows to sum to one, prices to remain in `[0,1/R]`, the Bellman and price residuals to be below `1e-7`, and the three initial schedules to converge to arrays within `1e-6`.
- [ ] Run `julia --project=. -t auto revision_tests.jl` and verify failure because the diagnostic interfaces do not exist.
- [ ] Extend `solve` with a typed initialization argument and retain the existing default:

```julia
function solve(theta::Float64; bceil::Float64 = Inf, tol::Float64 = 5e-8,
               maxit::Int = 2000, damp::Float64 = 0.5,
               q0::Union{Symbol,Array{Float64,3}} = :riskfree)
```

- [ ] Implement `fixed_point_residual` by one undamped Bellman-price update evaluated at the returned arrays.
- [ ] Generate convergence diagnostics in `results.json` without changing baseline moments.
- [ ] Replace the invalid compact-self-map paragraph with a finite-state mixed-policy Kakutani proposition. Verify nonempty compact convex strategy sets, continuity of finite discounted MDP values in prices, upper hemicontinuity and convexity of mixed best responses, and continuity of zero-profit pricing. State that the computed deterministic fixed point is selected numerically and is not a uniqueness theorem.

### Task 2: Complete proof and edge-case audit

**Files:**
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`
- Create: `Topic_1_Diagnostic_Sovereign_Risk/EDGE_CASE_AUDIT.md`

**Interfaces:**
- Consumes: all numbered results in the manuscript.
- Produces: complete proofs and a case table whose rows are COVERED or EXCLUDED.

- [ ] Rewrite the Gaussian tilt proof with the full completed square and normalizing constant.
- [ ] Repair the debt-monotonicity proof by invoking compactness and attainment at the maximizing issuance choice before claiming strictness.
- [ ] State the positive-probability strictness condition in Proposition 1 and distinguish risk-free and certain-default regions.
- [ ] Correct Corollary 1 so the converse is local to an interior-risk cell rather than an unconditional global equivalence.
- [ ] Expand the return proof by differentiating the ratio with the true repayment probability fixed at fixed `(b',x)`.
- [ ] Add the edge-case table for `theta=0`, zero or unit repayment probability, zero debt, debt-grid endpoints, income-grid endpoints, infeasible repayment, policy ties, and nonunique deterministic fixed points.

### Task 3: Survey-horizon transformation and Monte Carlo inversion

**Files:**
- Create: `Topic_1_Diagnostic_Sovereign_Risk/code/survey_mapping_mc.jl`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`
- Create: `Topic_1_Diagnostic_Sovereign_Risk/output/survey_mapping_numbers.tex`

**Interfaces:**
- Produces: `survey_beta(theta, rho_q; nmonths, seed)`, `invert_survey_beta(beta, rho_q)`, `survey_mapping.json`, and TeX macros for the transformed coefficient and recovery error.

- [ ] Add tests for exact recovery at `theta` in `{0.0,0.25,0.5,1.0}` to tolerance `0.02` and for monotonicity of the simulated mapping.
- [ ] Simulate a monthly AR(1) whose quarterly persistence is `rho_q`, construct annual-average growth targets, form current-year and next-year diagnostic fixed-event forecasts, apply the month-weighted twelve-month conversion, and estimate the same regression used by the empirical design.
- [ ] Invert with a monotone bisection on the simulated mapping instead of applying the one-step formula mechanically.
- [ ] Revise the measurement section so equation (CG mapping) is identified as the fixed-target benchmark and the survey transformation is the mapping used for annual Consensus data.
- [ ] Add the Philadelphia Fed SPF as a public code-validation dataset and state its identifier caveat.

### Task 4: Long-duration quantitative implementation

**Files:**
- Create: `Topic_1_Diagnostic_Sovereign_Risk/code/solve_long_bonds.jl`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/code/make_figures.R`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`
- Create: `Topic_1_Diagnostic_Sovereign_Risk/output/long_bond_numbers.tex`

**Interfaces:**
- Produces: a long-bond `LongSolution`, `solve_long(theta; maturity, coupon, q0)`, `simulate_long`, `results_long.json`, and generated macros.

- [ ] Add tests for the risk-free price identity

```julia
qbar = (maturity + (1 - maturity) * coupon) / (maturity + rstar)
```

and for the one-period limit `maturity=1`, zero-profit residuals, probability bounds, and convergence from three price schedules.
- [ ] Implement the government budget

```julia
c = y - (maturity + (1 - maturity) * coupon) * b +
    q[bp, ix, ih] * (bp - (1 - maturity) * b)
```

and the lender recursion with next-period resale value evaluated at the successor policy.
- [ ] Use `maturity=0.05` and `coupon=0.03`, which Chatterjee and Eyigungor map to a five-year median maturity and a 12 percent annual coupon for Argentina.
- [ ] Report model and literature moments side by side, reserving return predictability and boom-reversal hazards as validation moments.
- [ ] Move long-duration debt into the main quantitative section. Remove the appendix conjecture and every statement that the implementation is future work.

### Task 5: Recalibrated welfare and welfare accounting

**Files:**
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/code/solve_gov.jl`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/code/make_figures.R`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`

**Interfaces:**
- Produces: baseline and recalibrated two-by-two welfare arrays, sovereign welfare, lender expected profit under the true measure, and their sum under the model's resource accounting.

- [ ] Parameterize `solve_general` and `eval_true` with `beta` and `phi` while preserving their old defaults.
- [ ] Recompute the two-by-two at `(beta,phi)=(0.969,0.910)` and generate separate macros.
- [ ] State the sovereign criterion in the proposition and report lender losses separately. Do not call the sovereign ranking a global-welfare result.
- [ ] Remove policy recommendations not supported by a measurable welfare inequality.

### Task 6: Prose, bibliography, and reproducibility pass

**Files:**
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.tex`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/Diagnostic_Sovereign_Risk_Paper.bib`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/README.txt`
- Modify: `Topic_1_Diagnostic_Sovereign_Risk/REVISION_NOTES.md`

- [ ] Rewrite the abstract and introduction around the narrow contribution identified by referee v3.
- [ ] Replace the spread-level rational-zero design with a benchmark-model restriction and add the announcement-window and EMBI excess-return designs.
- [ ] Correct data-access descriptions for Consensus, EMBI, QPSD, WEO vintages, Philadelphia Fed SPF, and ECB SPF.
- [ ] Run every Julia script, the R script, and `latexmk -pdf -interaction=nonstopmode -halt-on-error Diagnostic_Sovereign_Risk_Paper.tex` from the paper directory.
- [ ] Run reference, citation, macro, parameter, and style lint. Accept no undefined reference, stale generated file, em dash, prose semicolon, banned AI vocabulary, or unresolved edge-case row.

## Plan Self-Review

The plan covers every Topic 1 item in referee v3: finite-grid existence, income monotonicity status, strict price monotonicity, survey transformation, long-duration debt, calibration discipline, public validation data, benchmark-zero language, return evidence, and welfare accounting. The plan contains no implementation placeholders. New interfaces are local to Topic 1 and do not alter other papers.
