# Revision Notes: Endogenous Trade Fragmentation

Response to referee_comments.md Section 3 and cross-draft Sections 6 and 7.
Revised July 2026. New quantitative claims are computed by
`code/dispersion_sens.jl` (which reproduces the published baseline fold band
before being trusted) and enter the text through macros in
`output/dispersion_numbers.tex`.

## Referee Section 3.2 (derivation): stratify the results

- **New epistemic ledger** at the top of Section 2: the threshold lemma, the
  complementarity decomposition, the multiplier formula, the micro-macro
  corollary, and the ordering and hysteresis propositions are analytical, with
  the last three explicitly conditional (fold and trap exist only where the
  sector map's slope exceeds one somewhere, a condition no theorem guarantees
  and the calibration must establish). Fold existence labeled a calibrated
  possibility. Uniform-distribution linearity of the hazard flagged (exact
  linearity special, monotonicity general for log-concave benefits, as the
  appendix lemma already showed).
- **Multiplicity vs heterogeneity (the referee's artifact question).** New
  computed paragraph in Section 3.2: at the calibrated premium dispersion of
  0.5 log points the fold band is [11.4, 13.1] percent. Dispersion 0.3 and 0.4
  widen the band, and dispersion 0.7 removes the fold entirely. Multiplicity
  survives smooth heterogeneity up to 40 percent more dispersion than
  calibrated, and not beyond, which upgrades the dispersion from nuisance to
  load-bearing parameter and is stated as the reason Design 4 estimates it.

## Referee Section 3.3 (calibration)

- **Calibration table** rebuilt with a Category column (estimated / internal /
  scenario) and scenario ranges in braces. Long citations moved to notes.
- **Distance-to-tipping as a band (referee 6.3, 6.7).** The "consumed two
  thirds of the distance" headline is now flanked, in the abstract, intro,
  Section 6.2, and conclusion, by its computed range across the (theta, chi)
  sensitivity grid: 47 to 105 percent, with the honest addendum that in the
  most fragile grid cell (theta 0.4, chi 0.6) the fold already sits below the
  post-2022 hazard, so on that calibration the sector is past its tipping
  point.
- **Calibration audit (referee 6.2).** New Appendix E table: every parameter
  group with location, units, source, range examined, effect, plus the stated
  places the mechanism disappears (all feedbacks zero; fold conditions from
  the sensitivity table; dispersion ceiling; chi = 0 kills the wedge flip).
- **Phase diagram (referee 6.7).** New `code/phase_diagram.jl` (reproduces
  the published baseline fold band before computing) classifies 165 cells of
  the (theta, chi) plane at calibrated dispersion; `code/make_phase_fig.R`
  draws `output/fig_phase.pdf`, now Figure 7 next to the sensitivity table,
  with macros via `output/phase_numbers.tex`. Content: the fold region is a
  northeast wedge with the two feedbacks substituting along its boundary
  (fold at chi >= 0.15 when theta = 0.6, no capacity channel needed at
  theta >= 0.65); 48 cells monotone, 117 with a fold, 16 past the fold, all
  in the neighborhood of the fragile (0.4, 0.6) corner of the coarser
  published table, whose classification the finer grid reproduces exactly.
  New honest observation in the paper: at theta <= 0.35 the plane passes
  from monotone directly to past-fold with no warning band.

## Referee Section 3.4 (econometrics)

- **Decisive tests** were already ranked (P4 deterrence engine, P3 hysteresis
  signature). Added explicit quantified rejection criteria: no response of
  escalation probabilities to coverage with confidence excluding theta = 0.4
  kills the deterrence externality and the maintenance-subsidy result, and
  exit symmetry matching the tariff benchmark rejects the fold structure
  outright, each failure killing a named part of the theory.
- **Validation moments (referee 6.8).** New paragraph: the sectoral
  concentration of post-2022 reallocation and its aggregate smallness are
  facts the model requires, documented by Gopinath et al., and never used in
  calibration.
- **Data feasibility (referee 6.9).** New Table 4: seven sources with
  coverage, frequency, access, observed-vs-proxied, status. Unit values named
  as the weak link, with the design response (within-product changes, episode
  identification).

## Referee Sections 6.5, 6.6, 6.10 (policy, scope, language)

- Abstract: results triad split into two sentences, policy claim
  conditionalized ("at this calibration, friend-shoring subsidies have the
  wrong sign"), scenario band added to the two-thirds claim.
- "The paper sits at the junction of three literatures" replaced ("draws on
  three literatures").
- Language pass: prose semicolons 85 to 0 (three remaining ";" are
  function-argument notation in displayed math, e.g. T(F; delta)), 0 em
  dashes, rhetorical triads restructured (supplier qualities, severance
  instruments, hostage chain, routes/insurance/inventories, no-friction list,
  facts list, multiplier/folds/traps), 0 AI-vocabulary hits.

## Not done, stated honestly in the paper

- All estimates of Designs 1 to 4 (public-data designs, signs, magnitudes,
  rejection criteria pre-stated; the bottom line once Design 4 runs is a
  standard error on the distance to the fold).
- Forward-looking firm dynamics (adaptive benchmark bounded in Appendix C,
  full treatment flagged as the next paper).
- Downstream input-output propagation of losses (conservatively omitted,
  flagged in the microfoundations appendix).

## Verification

- `latexmk -pdf` clean: 27 pages, 0 errors, 0 undefined references or
  citations, 2 residual overfull boxes under 0.6pt (invisible).
- phase_diagram.jl asserts the baseline band and cross-checks the coarse
  hazard grid against the fine one (agreement within 0.0005).
- Style greps: 0 em dashes, 0 prose semicolons, 0 AI-vocabulary hits.
- dispersion_sens.jl asserts reproduction of the baseline fold band
  [0.114, 0.131] before computing anything new.
