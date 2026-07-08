# Revision Notes: Sanctions Risk and Dollar Convenience

Response to referee_comments.md Section 2 and cross-draft Sections 6 and 7.
Revised July 2026. New quantitative claims are computed by
`code/breakeven_sens.jl` and enter the text through macros in
`output/breakeven_numbers.tex`.

## Referee Section 2.2 (derivation) and Questions 1, 2, 8

- **Q1/Q2 (linear convenience: microfound or admit approximation).** Chose the
  honest option. New reading-guide paragraph at the top of Section 2: all
  propositions are exact within the linear-quadratic structure, linearity is a
  first-order approximation around the observed equilibrium, and the paper now
  states at each point which conclusions need only the sign of the slope
  (direction of the multiplier, micro-macro gap, existence of the bias) and
  which need the functional form (all magnitudes, the routine-use corner).
  The environment section explains why linear (exactness plus the fact that
  measurement delivers a slope, not a curvature) and flags that the routine-use
  scenario moves far from the approximation point. Abstract and scope paragraph
  updated to match.
- **Q8 (time inconsistency too timing-dependent).** The belief structure behind
  the discretion result is now a numbered Assumption (Markov beliefs), with an
  explicit warning that it is not innocent. The repeated game moved from a
  deferred appendix remark into the body as new Section 4.3 with a formal
  Proposition (Reputation): the trigger equilibrium sustains the Ramsey rule
  iff beta_H/(1-beta_H) >= gamma/(omega gamma - 2 l1 omega^2 c^2 W). Computed:
  the threshold binds at a 5.0 percent annual discount rate against the 4
  percent baseline, so a doctrine is self-enforcing with a one-point margin.
  At routine breadth the interior concavity condition fails outright, so
  reputation cannot be relied on exactly where it is most needed. Proof added
  to Appendix A. The self-weakening point (erosion destroys the collateral) is
  retained and now quantified.

## Referee Section 2.3 (calibration) and Questions 3, 7, 9

- **Calibration table** rebuilt with a Category column (estimated / internal /
  fixed / scenario) and scenario ranges in braces. mu = 0.5 re-anchored to an
  observable (countries outside the 2022 coalition hold roughly half of world
  reserves, China about a quarter) and varied 0.3 to 0.7. p and omega labeled
  scenario. New identification statement in Section 2: only the product
  omega*sbar*p*phi enters demand, so the wedge is the identified object and
  the decomposition is bookkeeping until the hegemon's problem.
- **Q9 (break-even breadth as scenario band).** New computation
  (breakeven_sens.jl): break-even p* one-way in each unidentified parameter
  and over the full 81-cell grid. Baseline 2.9 percent. One-way: 0.7 to 12.3
  percent in gamma (the dominant input, and the one no design identifies),
  5.6 to 1.4 in m, 5.8 to 1.9 in phi, 4.8 to 2.1 in mu. Full grid 0.2 to 45.2
  percent. Reported in a new paragraph in Section 5.3, in the abstract, and in
  the intro. The robust claim is restated as the shape (the crossing exists
  and sits at single-digit breadth for all but the largest stakes), not the
  point.
- **Calibration audit (referee 6.2).** New Appendix E table: every parameter
  with location, units, source or moment, range examined, and effect, plus the
  three places the mechanism disappears (l1 = 0, mu*p*phi = 0, gamma large).

## Referee Section 2.4 (econometrics) and Question 10

- **Q10 (power).** Already flagged in the draft (Design 2 power problem).
  The revision makes the portfolio cross-section, the aligned-country
  fingerprint (P5), and gold the centerpiece: new paragraph after the
  predictions table names the two decisive tests (P3, P5) and adds explicit
  quantified rejection criteria, including how each of the two failures would
  kill a different part of the theory.
- **Validation moments (referee 6.8).** New paragraph: post-2022 gold record
  and the reversal-free COFER drift are validation observations never used in
  calibration (which uses only the yield level, the share level, and the
  half-life).
- **Data feasibility (referee 6.9).** New Table 5: seven sources with
  coverage, frequency, access, observed-vs-proxied, status. States that the
  binding constraint is attribution (COFER anonymity), not access.

## Referee Sections 6.5, 6.6, 6.10 (policy, scope, language)

- "Ruinous to make routine" replaced by quantified conditional language
  ("in every scenario computed here, a losing trade"). "Calibrated to the
  2022 freeze" became "in scenarios anchored to". Conclusion triple-question
  structure broken up.
- Scope paragraph extended: no microfoundation of the network term, linear
  approximation caveat, no target response, gamma reduced form.
- Language pass: all prose semicolons removed (36 sites to 0; remaining ";"
  are \; math macros), 0 em dashes, rhetorical triads restructured
  (currencies/rails/custodial, gold/currencies/store-of-value,
  markets/gold/rails, designs/signs/magnitudes, the three-question
  conclusion), no AI vocabulary.

## Not done, stated honestly in the paper

- Designs 1 and 2 estimates (pending data assembly; designs, signs,
  magnitudes, and rejection criteria pre-stated).
- Microfoundation of l(N) (declared a local approximation instead).
- Full reputational analysis at routine breadth (interior formula fails at
  the corner; stated in Proposition and proof).
- Endogenous outside asset, target response (extensions appendix).

## Verification

- `latexmk -pdf` clean: 24 pages, 0 errors, 0 undefined references or
  citations, 0 overfull boxes.
- Style greps: 0 em dashes, 0 prose semicolons, 0 AI-vocabulary hits.
- Recalibration rule (referee 6.3) checked computationally: with the
  sanctions wedge at its pre-2022 value of zero, the full model's steady
  state reproduces the targeted moments exactly (dollar share 0.59,
  convenience yield 73.0 bp), so introducing the mechanism does not disturb
  the calibrated baseline. The kappa-robustness experiment in
  code/solve_model.jl (line ~188) already re-solves the outside spread so
  perturbed calibrations still match (N0, CY0) before the shock is applied.
