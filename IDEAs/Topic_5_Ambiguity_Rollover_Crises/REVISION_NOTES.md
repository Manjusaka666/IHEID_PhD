# Revision Notes: Ambiguity, Investor Composition, and Sovereign Rollover Crises

Response to referee_comments.md Section 5 and cross-draft Sections 6 and 7.
Revised July 2026.

## Referee Section 5.2 (derivation)

- **One-sided worst case formalized.** The safe-exit property that drives the
  as-if lemma is now a numbered Assumption (Model-free exit: the run payoff
  1 - kappa does not depend on the unknown bias), with a discussion of what
  fails without it (a second minimization for the runner, a correction term in
  the as-if subtraction) and of the case where the results survive
  state-contingent exit prices (rollover payoff more worst-case-exposed than
  the exit payoff).
- **Uniqueness condition audited.** The inequality alpha/sqrt(beta) < sqrt(2pi)
  was already formal. New discussion after the proposition: the calibration
  sits at 1.35 against the bound 2.51 (official precision could nearly double
  before selection appears), the condition is estimable from dispersion and
  revision data rather than maintained, and the model fails gracefully at the
  boundary because the multiplier itself diverges and announces the approach.
- **Two-type aggregation justified.** New sentence at the top of Section 3:
  every proposition holds for any finite type set (the fixed point is written
  with sums over k), two types is a measurement choice mapped to the
  Arslanalp-Tsuda categories, and the appendix extension covers
  many-class payoff heterogeneity through type-specific hurdles.
- **Epistemic reading guide** added at the top of Section 2 (referee 6.1):
  Propositions 1 to 4 are exact theorems within the Gaussian one-shot game,
  quantitative magnitudes are scenario arithmetic, dynamic statements are
  conditional on the static chaining.

## Referee Section 5.3 (calibration)

- **Category column** added to the calibration table (fixed / estimated /
  internal / scenario): payoff block estimated (Cruces-Trebesch anchoring
  already present), information block scenario pending dispersion data,
  distrust radius the declared unknown of the paper.
- **Calibration audit (referee 6.2).** New Appendix E table: each parameter's
  location, units, source, range examined (tied to the figures that span it),
  and effect, plus the two places the mechanism disappears (delta = 0 gives
  the Bayesian game and kills P1/P4/P5/P6; crossing the uniqueness bound
  replaces comparative statics with selection).
- mu already defined on maturing debt with maturity weighting (referee Q on
  Arslanalp-Tsuda mapping): unchanged, verified present.
- **Information-block sensitivity computed (referee: verify uniqueness under
  a range of precisions, band the scenario numbers).** New `code/info_sens.jl`
  (reproduces the published baseline exactly, ratio 1.35, bound 2.51, premia
  18/98 bp, calm spread 79 bp, before computing anything) sweeps a 12-cell
  precision grid, sigx 0.10-0.30, sigy 0.25-0.50. Results now in the text
  via `output/info_numbers.tex`: ratio 0.40 to 4.80 across the grid, 3 of 12
  cells cross the uniqueness bound (sharp-public noisy-private corner),
  frontier at sigx = 0.157 for the sharpest public signal and 0.279 at
  baseline. Direction of state dependence robust (stress premium exceeds
  calm in every unique cell); strength scenario-dependent (ratio 1.3 where
  the public signal is very noisy). Honest addendum stated in the paper: the
  grid holds signal levels fixed, so the calm anchor itself is a scenario,
  swinging 0 to 865 bp, and Design 4's dispersion data are what would
  replace it with an estimate. Audit-table row for (sigx, sigy) updated with
  the grid range and effects.

## Referee Section 5.4 (econometrics)

- **Decisive tests** (P4 precision-vs-credibility sign switch, P5
  distrust-vs-disagreement opposite signs in distress) were already named.
  Added a quantified rejection criterion for the calibrated block (Design-1
  interactions zero with confidence excluding 98 bp at Greek-scale distrust
  kills the composition channel).
- **Out-of-sample validation (referee 6.8).** New paragraph: the Greek
  sequence (spreads repricing on revision announcements while fundamentals
  moved smoothly) and the Cady (2004) data-standard result are validation
  observations that entered no calibration.
- **Data feasibility (referee 6.9).** New Table 4: seven sources with
  coverage, frequency, access, observed-vs-proxied, status. Names auction
  microdata (Design 3) as the binding data investment, spreads and surveys as
  the licensed items.
- Doom loop: appendix already derives the explosive-loop condition with the
  coordination multiplier explicit. New scope boundary in the introduction:
  domestic banks enter only as stable holders, and the sovereign-bank nexus
  is declared outside the model as the third boundary on the claims.

## Referee Sections 6.5, 6.6, 6.10 (policy, scope, language)

- Abstract: "Calibrated to" became "In scenarios anchored to". Opening triad
  restructured. Policy hierarchy in the conclusion kept, its four-fold
  anaphora ("has a natural scale; ...loading; ...census; ...laboratory")
  broken into varied sentences.
- Language pass: prose semicolons 65 to 0, 0 em dashes, triads restructured
  (fundamentals/information/holders, banks/lenders/institutions,
  analysts/budgets/markets, buffers/surplus/resources, documents/
  announcements/reviews, analysis/flows/knowledge, standards/audit/record),
  "the robust object" reworded. No AI-vocabulary hits ("leverage" retained
  once as the financial noun).

## Not done, stated honestly in the paper

- All estimates (Designs 1 to 4 pending; the structural inversion is the
  paper's declared path to measuring delta).
- The fully dynamic staggered-maturity run (He-Xiong extension mapped, not
  solved).
- The sovereign-bank nexus (scope boundary).
- Endogenous promised yield R (appendix notes reported magnitudes are
  conservative in omitting it).

## Verification

- `latexmk -pdf` clean: 23 pages, 0 errors, 0 undefined references or
  citations, 4 residual overfull boxes under 2pt.
- Style greps: 0 em dashes, 0 prose semicolons, 0 AI-vocabulary hits.
