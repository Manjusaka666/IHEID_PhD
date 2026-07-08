# Revision Notes: Diagnostic Expectations and Sovereign Default

Response to referee_comments.md Section 1 and cross-draft Sections 6 and 7.
Revised July 2026. All new quantitative claims are computed by `code/robustness.jl`
and enter the text through macros in `output/robust_numbers.tex`.

## Referee Section 1.2 (derivation) and Questions 1 to 3

- **Q1 (prove or verify monotone default).** Split the old two-part monotonicity
  assumption. The debt margin is now proved unconditionally as Lemma 3
  (default is monotone in debt, default set is an upper interval), with a
  three-line proof in Appendix A. Only the income margin remains an assumption
  (Assumption 1), which is exactly the margin the rational literature also
  cannot prove with persistent income. A new reading-guide paragraph at the top
  of Section 4 classifies every result as analytical, conditional, numerical,
  or scenario (referee 6.1).
- **Q2 (endogenous leverage reversing monotonicity).** Lemma 3 rules it out on
  the debt margin at any parameter vector. The borrowing response to news is
  explicitly labeled a numerical property, not a theorem.
- **Q3 (grid sensitivity of hazards).** New computation: grid-doubling
  (n_x = 31, n_b = 400) at theta in {0, 0.5, 1}. Zero monotonicity violations at
  theta in {0, 0.5}; hazard 12.0 vs 1.1 percent (baseline 12.6 vs 1.5); news
  coefficient -400 vs -462 bp; rational news coefficient stays 0. Alternative
  proportional default cost (psi in {0.02, 0.05}): zero violations. Reported in
  the rewritten computation appendix. The winsorized spread s.d. is flagged as
  the one grid-sensitive statistic.

## Referee Section 1.3 (calibration) and Questions 4, 9

- **Recalibration (referee 6.3, Q4).** New Section 6.5: grid search over
  (beta, phi) at theta = 0.5 (30 pairs), targeting 3 defaults per century and
  5.5 percent debt service. Interior optimum (0.969, 0.910) hits both targets
  (3.1 per century, 5.5 percent). News coefficient -84 bp, reversal hazard
  3.1 vs 0.3 percent at identical parameters. New finding reported: the
  rational economy at the recalibrated parameters defaults once per century,
  so the belief distortion accounts for roughly two thirds of defaults at the
  data-consistent calibration.
- **Q9 (realistic debt without excessive default).** Answered by the same
  exercise; the compressed spread level that results is flagged as the known
  one-period-bond failure, with long-duration SMM named as the fix.
- **Calibration audit (referee 6.2).** Table 1 now carries a category column
  (externally fixed / directly estimated / internally calibrated / scenario).
  New Table 7 (appendix) reports equation location, units, source and sample,
  range examined, and effect on headline results for every parameter, plus the
  region where the mechanism disappears (theta = 0 exactly; theta near 1
  pathological at fixed parameters). Validation moments (news coefficient,
  return predictability, reversal hazard) are stated as never used in
  calibration (referee 6.8).

## Referee Section 1.4 (econometrics) and Questions 5 to 8

- **Q5 (individual vs consensus).** Sharpened in Section 5.1: consensus
  aggregation can reverse the sign; individual data essential; theta = 0.5 is
  explicitly labeled a scenario value inside the published US range until the
  EM estimation runs.
- **Q6 (fixed-event, horizons, aggregation).** Horizon invariance of the CG
  mapping is proved in Appendix A (Prop. 5); fixed-event conversion and
  measurement-error IV strategy stated in Section 5.2 and Appendix D.
- **Q7 (nonparametric conditioning and confounds).** P1 now controls for
  commodity terms of trade and fiscal-forecast revisions in addition to cell
  fixed effects, time effects, ratings, and the forecast level. Annual-debt
  timing mismatch addressed in the data appendix (lagged debt for cells, BIS
  quarterly subsample).
- **Q8 (longer maturity).** Stated in the main text and conclusion that all
  quantitative results are one-period-bond results; long-bond recursion in
  Appendix E.2 with the dilution-optimism interaction stated as a conjecture.
- **Narrowing (referee 6.4).** Section 7 now ranks P1 and P4 as decisive, P2
  and P3 as supporting, and states the explicit rejection criteria.
- **Data feasibility (referee 6.9).** New Table 8: dataset, coverage,
  frequency, access, observed vs proxied, replication status for all seven
  sources.

## Referee Sections 6.5, 6.6, 6.10 (policy, scope, language)

- Policy result restated as a conditional proposition in Section 8 with its
  conditions italicized (one-period debt, benevolent government, computed
  equilibria at theta = 0.5); noted that the two-by-two was not recomputed at
  recalibrated parameters.
- New scope paragraph in the conclusion: no political economy, risk-neutral
  lenders, one-quarter debt.
- Language pass: removed "at the intersection of" (banned phrase), removed all
  prose semicolons (85 to 0; remaining `;` in the file are `\;` math-spacing
  macros), no em dashes, three-item rhetorical coordinations restructured, and
  overstatement trimmed ("What the calibration cannot overturn" and similar).

## Not done, stated honestly in the paper

- SMM with standard errors (coarse grid search instead, labeled as such).
- The EM forecast estimation of theta and all spread-panel estimates (pending
  licensed data; designs and rejection criteria pre-stated).
- Two-by-two welfare at recalibrated parameters.
- A primitive-conditions theorem for the income margin of monotone default
  (verified numerically across grids, cost functions, and 30+ parameter
  vectors instead).

## Verification

- `latexmk -pdf` clean: 31 pages, no errors, no undefined references or
  citations; 4 residual overfull boxes of 4 to 7 pt in wide audit tables.
- Style greps: 0 em dashes, 0 prose semicolons, 0 AI-vocabulary hits.
