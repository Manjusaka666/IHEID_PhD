# Revision Notes: Narrative Contagion at the Sovereign Default Boundary

Response to referee_comments.md Section 7 (topic-specific) and cross-draft
Sections 6 and 7. Revised July 2026. New quantitative claims are computed by
`code/chi_sens.jl` (which reproduces every published baseline magnitude,
Monte Carlo objects bit-identical under the same seed, before computing
anything new) and enter the text through `output/chi_numbers.tex`.

## Two-primitive honesty (referee's central question)

- The abstract and introduction no longer claim that "one primitive does all
  the work" or that "both facts follow from one primitive rather than from
  two assumptions." The pricing hump is presented as a theorem from the
  threshold-default primitive. The contagion half is presented as resting on
  Assumption 1 (decision-relevant adoption), named behavioral at every
  appearance, with the mispricing-based rival kept in play.
- New epistemic reading guide at the top of Section 2: pricing results are
  theorems, contagion and policy results are theorems conditional on
  Assumption 1, all magnitudes are scenario arithmetic with no estimated
  epidemic parameters yet.
- The adoption rule's rival (perceived mispricing) was already flagged and
  already generated the capped-economy test (P4, post-OMT text volume). Kept
  and sharpened as one of the two decisive tests.

## Spread-cap result conditional (referee Section 7)

- Partial credibility is now computed, not gestured at. If activation is
  believed with probability c, price relevance in capped states scales by
  1 - c and so does the reproduction number: sterilization requires
  c >= 1 - 1/R0, which at the calibrated zone peak (R0 = 4) means the
  facility must be believed with probability three quarters. Stated in the
  policy section with the failure mode (doubted peg leaves the epidemic
  alive, wedge scaled by surviving relevance).

## Calibration (referee 6.2, 6.3, 6.7)

- **chi from gross-financing-need arithmetic (the referee's computable
  demand).** chi is now derived as an identity: capacity is in annual
  resources, so the drag per unit spread equals the GFN ratio. IMF-range GFN
  of 10 to 30 percent of output gives the band, 20 percent the baseline.
  `code/chi_sens.jl` re-runs the headline experiments at both ends with
  identical shocks:
  - peak wedge 0.7 to 6.9 percentage points (baseline 5.2)
  - annual cap-delay cost 4 to 41 points (baseline 17)
  - peak price relevance 124 to 1457 bp per 10 pp prevalence (baseline 229)
  - zone nonempty, wedge hump-shaped, cap dominant at both ends.
- **Finding worth the referee's attention:** at crisis-level GFN (chi = 0.30)
  the maximal pricing loop gain reaches 0.96 against the multiplicity bound
  of one. The paper now states, in the quant section and the Calvo appendix,
  that thirty-percent financing needs put the pricing equilibrium at the
  edge of the Calvo region, where narrative effects and equilibrium
  selection stop being separable: a computed scope statement.
- Calibration table rebuilt with a Category column (fixed / estimated /
  internal / scenario). The epidemic block (xi, gamma, R0, n0) is scenario
  throughout and labeled as pending Design 4.
- New Appendix E calibration audit: ten rows with location, units, source,
  range examined, effect, plus the three places the mechanism disappears
  (amplification below the zone threshold, chi = 0 kills the cliff, loop
  gain crossing one kills attribution).

## Model vs. data definition of a narrative (referee Section 7)

- New paragraph in Section 6.1: the model's n is the wealth share of
  investors pricing under the story, text delivers the coverage share, the
  protocol maintains rather than proves that coverage tracks the
  wealth-weighted object, and the survey-validation layer is the check on
  that maintained link, with downstream designs inheriting any failure.

## Econometrics (referee 6.4, 6.8, 6.9)

- **Decisive tests named with kill statements:** failure of the boundary
  interaction (delta_h zero excluding the calibrated peak, or safe
  sovereigns pricing like zone sovereigns) kills the boundary structure and
  returns the paper to the everything-explaining residual; narrative volume
  surviving a credible cap kills Assumption 1 in favor of its rival and the
  sterilization result with it. Remaining tests calibrate rather than kill.
- **Validation moments never used in calibration:** the De Grauwe-Ji
  fundamentals-unexplained spread components (several hundred bp at the 2011
  peak) sit inside the model's outbreak range with no parameter fit to them;
  the 2010-2012 chronology is reserved for validating, not fitting, the
  Design 4 surveillance model.
- **Data feasibility table:** eight sources with coverage, frequency,
  access, observed-vs-proxied, status. Prevalence is flagged as proxied by
  coverage. Platform text named as the weak link (restricted and
  incompletely archived), newswires the licensed backbone.

## Language (referee 6.10)

- 65 prose semicolons to 0, 0 em dashes. Triads restructured (story-content
  examples cut from three to two, reproduction/recovery/outbreak trimmed,
  takedowns list trimmed, priced/spread/kill recast, prevalence/spreads/
  fundamentals recast). "Calibrated to" became "In scenarios anchored to."
  Footnote brought to the standard template.

## Not done, stated honestly in the paper

- The entire empirical half (classified story archive, prevalence and
  reproduction series, estimated (xi, chi, A, gamma)): the paper's declared
  program, with the measurement protocol its most detailed part.
- Phase-diagram-style exhibits already cover the mechanism's nonlinearity
  (fig_zone spans amplification, fig_crisis spans initial fundamentals, and
  the new chi band spans the feedback); no additional figure added.

## Verification

- `latexmk -pdf` clean: 23 pages, 0 errors, 0 undefined references or
  citations, 1 residual overfull box of 0.6pt (invisible).
- Style greps: 0 em dashes, 0 prose semicolons, 0 AI-vocabulary hits.
- chi_sens.jl reproduces GainMax 0.64, RelPeakTen 229, zone [0.002, 0.070],
  WedgePeak 5.2, PCapEarly/Late 46.3/63.4, DelayCost 17, ZoneDefMonth 42
  before computing the band.
