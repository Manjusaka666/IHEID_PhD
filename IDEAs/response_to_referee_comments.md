# Reply to the Research-Review Memorandum on the Five Drafts

**R. E. Lucas — July 2026.**
**Reference:** `referee_comments.md`, sections 1–9.

The report proposes a hierarchy: prove what can be proved, estimate what can be estimated, source what can be sourced, and label the rest as scenarios. I accept the hierarchy without reservation; it is the standard the drafts were written toward, and where they fall short of it the fault is mine and the fix is specified below. But I will also insist on an accounting. A number of the report's "musts" are already in the papers, in some cases verbatim, and a response that conceded them silently would misstate where the work actually stands. So each section below keeps three ledgers: what the report asks for that the draft already contains, what I concede and will change, and where I decline and why.

One remark on provenance before the ledgers. Several passages of the report describe the proposals rather than the papers. The report says the diagnostic paper "should separate belief-kernel results, conditional comparative statics, and numerical equilibrium results"; the draft does exactly this (Lemma 1 is proved, Propositions 1–3 are stated under Assumption 1, and the borrowing response is reported in Section 4 as "a quantitative property, not a theorem"). The report says the measurement of the overreaction parameter "must be implemented using actual forecast data" with fixed-event conversion and individual-level forecasts; Section 5.2 and the data appendix specify precisely that design, including the fixed-event-to-fixed-horizon weighting, first-release outturns, the consensus-versus-individual distinction, and the measurement-error instruments, with the horizon-invariance of the mapping proved in the appendix. Where the report and the drafts already agree, I record the agreement and move on.

---

## 1. Diagnostic Expectations and Sovereign Default

### Already in the draft

Four of the report's demands are met in the current text and I list them so the revision effort goes where it is needed.

1. **Monotone default is stated as an assumption, not smuggled in.** Assumption 1 is explicit; the text explains that no monotonicity theorem exists in this literature even at θ = 0 with persistent income (Arellano's proof covers i.i.d. income only); and the computational appendix reports verification at every grid point: zero violations at θ ∈ {0, 0.5}, and 0.02 percent of (x, h) columns at θ = 1, flagged as a grid artifact.
2. **The result classification the report demands in §6.1 is the draft's architecture.** Exact results (Lemmas 1–2, Proposition 5), conditional results (Propositions 1–3, each carrying Assumption 1 in its statement), and numerical properties (issuance increasing in news) are labeled as such in the text.
3. **Individual forecasts, not consensus.** Section 5.1 states why consensus and individual coefficients differ in sign and why only the individual coefficient identifies θ. This is the report's item 4.2 point 2, already in the paper.
4. **Nonparametric conditioning.** The report warns that linear controls are insufficient. The draft goes further: Table 2 shows the rational economy produces a spurious −168 basis-point "news effect" under linear controls and the diagnostic economy gets the wrong sign, which is why the design in Section 7 uses cell fixed effects. The rational zero holds only within cells; the paper says so and builds the design around it.

### Conceded, with commitments

1. **Recalibration is the binding gap.** The default frequency at θ = 0.5 is 11.6 per century against 2–3 in Argentine data, because the non-belief parameters were calibrated to hit the frequency at θ = 0. The draft discloses this and defers the fix; the report is right that deferral is not good enough for headline claims. Commitment: re-estimate (β, φ) by simulated method of moments with θ fixed at its survey value, targeting default frequency, mean debt service, and spread level; report the recalibrated moments beside the fixed-parameter comparative statics; recompute the boom-reversal hazard (currently 12.6 versus 1.5 percent) and the fiscal-rule two-by-two on the recalibrated economy. The fixed-parameter table stays, relabeled as what it is: a comparative static in θ on a known benchmark.
2. **Half of Assumption 1 will become a theorem.** Monotonicity of default in debt is provable unconditionally: V^R is strictly decreasing in b at every candidate issuance while V^D does not involve b, so the default set is an interval in b. I will state and prove this, leaving only income-monotonicity, the genuinely circular half, as the maintained assumption with expanded numerical verification: grid-doubling (n_x = 31, n_b = 400), alternative default-cost functions, and the recalibrated parameter vector.
3. **Long-duration bonds.** The appendix sets up the Chatterjee–Eyigungor recursion and conjectures the interaction with dilution; the report's question 8 is fair. Commitment: compute it. The one-period results then become the short-maturity benchmark of a two-maturity paper rather than the paper.
4. **Data feasibility.** Consensus Economics individual panels and EMBI stripped spreads are proprietary. The draft marks every dependent estimate as pending; I will add the report's §6.9 audit table (dataset, coverage, access, replication rights) so no reader mistakes a design for a result.

### Declined

The report asks (question 1) whether monotone default "can be proved in the diagnostic model, or only verified numerically," and elsewhere implies that assuming it is a weakness peculiar to this draft. The rational benchmark has no such theorem either; the standard the literature meets, and the one this paper meets, is proof where available and exhaustive verification where not. With the debt-half proved and the income-half verified across grids, calibrations, and cost functions, I regard the treatment as complete. I also decline to drop the fixed-parameter exercise in favor of only the re-estimated model: holding the benchmark fixed is what isolates the mechanism, and the report's own taxonomy (comparative static versus calibrated fact) is exactly the labeling the two tables will carry.

---

## 2. Sanctions Risk and Dollar Convenience

### Already in the draft

1. **The cross-sectional cancellation is analytic and its econometric meaning is drawn.** Proposition 1, Corollary 1, and the division of labor in the empirical section (cross section for 1/κ, aggregates for ℓ₁) are the report's §2.1 restated.
2. **κ is not judgment.** With r̄ normalized to zero, the pre-2022 equilibrium condition κN₀ = ℓ(N₀) pins κ = 124 basis points from the same two documented numbers (73 basis points, 59 percent) that anchor the level.
3. **γ is declared reduced-form and reported as a menu.** The draft says "the stakes are the policymaker's input" and presents the Ramsey figure over γ ∈ [50, 800] billion rather than at a point. This is the report's demanded treatment of an unidentified parameter.
4. **The power problem is flagged in the paper's own words.** Design 2 states that the predicted 1.3 basis-point cumulative convenience-yield effect is small against the volatility of the spread series and that single-event tests are weak, and it responds with the differenced dollar-specific premium and regime-sized episodes. The report's §2.4 paragraph 3 makes the same point.

### Conceded, with commitments

1. **The break-even breadth is a scenario statistic and will be labeled and banded as one.** The 2.9 percent figure depends on (ω, φ, μ, m, γ), of which φ is event-anchored, μ is a classification, and m and γ are spanned rather than estimated. Commitment: report the break-even as a band across the announced spans of m and γ, state its comparative statics (falling in m, rising in γ), move the point estimate out of the abstract, and put the identification status in the table notes.
2. **Identification structure, stated as a result.** The report asks how ω, p, φ, μ are separately identified. On the demand side they are not, and should not pretend to be: portfolios depend only on the wedge π̂ = ω s̄ p φ, which is the object the cross section identifies (as π̂/κ). The components matter separately only in the hegemon's problem. Commitment: a remark stating exactly this, with the Laffer curve re-expressed in wedge units (basis points of π̂) as the primary axis and breadth p as a translated scenario axis.
3. **The linear convenience function becomes an explicit local approximation.** The report's alternative (i) — microfoundation — is what the cited literature supplies and this paper should not re-derive; its alternative (ii) is the right fix. Commitment: state the model as the linear-quadratic approximation of a general ℓ(N) around the observed equilibrium, with m = 1/(1 − ℓ′(N₀)/κ) defined by the local slope, and the corner analysis of the appendix bounding what the approximation can say globally.
4. **Reputation moves from the appendix toward the core.** The report's point that a sanction teaches reserve managers about the rule is the reputational margin; the appendix already contains the trigger-strategy condition and the result that the reputational collateral erodes along the discretionary path. Commitment: promote this to a titled section as the third benchmark, between commitment and discretion.

### Declined

The report says the time-inconsistency result is "too dependent on timing." Timing dependence is not a defect of the result; it is the result, as it was in Kydland and Prescott and Barro and Gordon: portfolios price the rule, the crisis decision takes portfolios as given, and under Markov beliefs the ex post cost of intensity is exactly zero. The reputational equilibrium in which beliefs respond to actions is the appropriate complication, and it will get its section; but discretion and commitment remain the benchmarks that bracket it, and I decline to let the clean version of the argument dissolve into the repeated game.

---

## 3. Endogenous Trade Fragmentation

### Already in the draft

1. **What is general and what is calibrated is stated.** Strategic complementarity is Proposition 1 with the decomposition into deterrence, thinning, and scale, and the exact condition under which it vanishes. The fold requires max Φ′ > 1 (Proposition 3), and the sensitivity table maps where it exists (θ ≥ 0.5 with χ ≥ 0.2 at the calibration) and where it disappears. The conclusion says in terms: "these are calibrated statements, not estimates."
2. **The strategic-autonomy objection has its own paragraph and its own threshold.** The value v enters the wedge as τ* − v, and the draft prices the condition: the vulnerability motive must exceed 6.4 percent of trade value per year at the post-2022 point before zero maintenance subsidy is right. The report's §3.2 concern is this paragraph.
3. **Criticality is arithmetic, not adjective.** λ⁰_m is derived from (σ_m, s_m, D_m) via the CES formula, each input sourced from published elasticities, input-output tables, and the disruption literature.
4. **The hysteresis-versus-sunk-costs confound is addressed in the design.** The model has no sunk cost of return by construction (Lemma 1 and the dynamics), and Design 2's discriminating comparison — geopolitical exits against tariff-episode exits, which the literature finds partially reversed — is built to separate equilibrium hysteresis from friction in the data.

### Conceded, with commitments

1. **Analytic sufficient conditions for the fold.** The report's question 2 deserves a proposition, not a table alone. With lognormal H_m the aggregate response is S-shaped and max Φ′ has a closed-form bound in terms of the density peak and the threshold slope at the flex point. Commitment: state the explicit inequality in (θ, ξ, χ, dispersion s) under which the fold exists, and its converse, so the sensitivity table becomes an illustration of a stated condition rather than a substitute for one.
2. **Conditional language on the two headline claims.** "Two thirds of the way to tipping" becomes "at the calibrated parameters, two thirds"; "friend-shoring subsidies have the wrong sign" carries its two conditions in the same sentence: below the fold, and absent an autonomy value exceeding τ*. The edge stays; the conditions ride with it.
3. **The empirical program narrows to two sectors.** The report is right that a global HS-6 sweep will not identify the feedback parameters. Commitment: the structural implementation (Designs 3 and 4) runs first on semiconductors and critical minerals, the two sectors where product-level data, documented export-control events, and firm-level sourcing evidence coexist; the HS-6 panel remains as descriptive context and the placebo bed.
4. **Priority of Design 4.** The fold's existence turns on χ, the paper says the unit-value compression estimate is the single most consequential moment, and every dataset it needs (BACI, ICIO, published elasticities) is public. It is therefore the first empirical work item in the whole program; see the schedule in Section 8.

### Declined

The report suggests hysteresis "may reflect sunk costs rather than equilibrium multiplicity." In the model it cannot: firms re-optimize freely at every reconsideration and the trap survives, which is the content of Proposition 4. In the data the confound is real, which is why Design 2 exists. I decline the implied rewrite of the theory; the empirical discrimination is already the design's stated purpose.

---

## 4. Ambiguity, Investor Composition, and Sovereign Rollover Crises

### Already in the draft

1. **The one-sidedness of the worst case is proved, not assumed.** Lemma 1 shows the run payoff is model-independent, so the minimization is one-shot and the circularity the report worries about does not arise; the uniqueness proposition then states the Hellwig–Morris–Shin condition and shows δ is absent from it, for every composition and every profile of radii.
2. **δ is not fitted to spreads.** The calibration disciplines δ = 0.08 by revision magnitudes of Greek size against liquid capacity of order one; Design 4's structural inversion is validated out of sample against credibility events, decay, and transparency indices it was not fitted to, which is the report's own prescription in §4.3.
3. **μ is defined on maturing debt.** The state variable is "the share of maturing debt held by" fragile creditors, with maturity weighting where debt-office data permit (data appendix). Report question 3 is the draft's definition.
4. **Distrust versus disagreement is the paper's own point.** Proposition 5 separates them with opposite predicted signs in distress, and P5 implements the separation. The report's question 2 ("how does the model distinguish distrust from risk, volatility, forecast disagreement") is answered by the paper's sharpest result.

### Conceded, with commitments

1. **The uniqueness bound must hold at estimated precisions.** The calibration sits at α/√β = 1.35 against a bound of 2.51, but the ratio is chosen, not measured. Commitment: estimate α from real-time official revision variance and β from forecaster dispersion, country by country; report the bound check across the panel; and where a country violates it, say so and characterize the regime honestly rather than assuming it away.
2. **From two types to K types.** The theory already holds for arbitrary profiles (μ_k, δ_k), so the two-type exposition is a choice, and the report is right that it is coarse for measurement. Commitment: the quantitative section moves to the six Arslanalp–Tsuda categories with type-specific radii and hurdles (the appendix's heterogeneous-payoffs extension), and the two-type model remains the expositional core.
3. **Domestic banks and the doom loop: a scope statement.** The report is right that holders who are stable on the rollover margin can be destabilizing through the bank-sovereign nexus. The appendix's feedback covers debt service, not bank balance sheets. Commitment: an explicit scope paragraph stating that "stable" means stable on the run margin only, that the bank channel biases the composition results against finding fragility in high-domestic-bank countries, and that the nexus is not modeled.
4. **Endogenous composition.** Commitment: Design 1 uses lagged composition and, as the quasi-experimental shifter, central-bank runoff schedules, which move μ mechanically and are set by monetary policy considerations plausibly excludable from country-specific rollover risk. That this shifter exists is, of course, the QT experiment's premise.

### Declined

Nothing of substance. This is the report's most accurate section, and its demands and the draft's designs largely coincide; the work is to execute them.

---

## 5. Narrative Contagion at the Sovereign Default Boundary

### Already in the draft

1. **The adoption rule is flagged as an assumption, with its rival named and a test that separates them.** Assumption 1 is labeled behavioral in the introduction and at its statement; the mispricing-based alternative is described; and the two are distinguished by exactly one observable, whether narrative volume collapses under a credible cap, which is P4 and a moment in Design 4. The report's demand that the cap result "be treated as a testable implication rather than a general theorem" describes the draft's own treatment.
2. **The theory carries its own placebo.** P2: outbreaks about safe sovereigns must be loud in text and silent in prices (the model's number is 2.3 basis points per ten points of prevalence at the safe point, against 229 at the peak). The report's §5.4 asks for precisely this design.
3. **Reverse causality is embraced, not evaded.** P6 predicts the lead-lag flip: text leads spreads inside the zone, spreads lead text outside. The identification claim rests on state-dependence, not exogeneity of text, as the draft states.
4. **Uniqueness is protected by construction.** The calibration sits inside the contraction region (maximal loop gain 0.64) so every narrative effect is attributable; the Calvo multiplicity frontier is mapped in the appendix.

### Conceded, with commitments

1. **"One primitive does all the work" overclaims, and the abstract will stop saying it.** One primitive (the S-curve) generates the pricing hump as a theorem; converting price relevance into contagion requires Assumption 1. The corrected sentence: one primitive and one stated behavioral assumption, separately testable, generate the zone. The report's §5.2 is right on this point and the introduction's own honesty makes the abstract's compression indefensible.
2. **Prevalence units.** The gap between reach-weighted text prevalence and wealth-weighted investor prevalence is the measurement's weakest link. Commitment: the survey-validation requirement (text prevalence must predict survey crash beliefs, not only prices) is promoted from protocol aspiration to a gate on the empirical program; and holdings-weighted robustness is added where custody data identify the holder population. Headline quantitative claims stated in prevalence units carry scenario labels until that gate is passed.
3. **Epidemic parameters are scenario values.** γ and R₀ are calibrated to news-cycle persistence and an amplification-era judgment; the estimation designs exist (generation-interval method, SMM in Design 4) but have not run. Commitment: the hazard-wedge numbers (5.2 percentage points at peak, 0.06 for safe sovereigns) are labeled scenario results in table notes and text until Design 4 replaces them.

### Declined

The report asks (question 9) what happens if adoption is driven by perceived mispricing rather than price relevance. The paper's answer stands: the two rules disagree only under a binding cap, the disagreement is the content of P4, and a single historical text archive (post-OMT) adjudicates. I decline to model both rules symmetrically in the body; the model takes a stand, states it, and specifies its falsification, which is what the report's own §6.4 asks papers to do.

---

## 6. The Cross-Draft Program (report §6–7)

The report's ten-item checklist is accepted in full. Item by item, with the papers' current status honestly marked:

1. **Formal assumption lists.** Largely present (every theorem in every paper states its conditions); will be audited paper by paper.
2. **Proof classification.** Each paper gains an appendix table classifying every numbered result as analytical, conditional, numerical, or scenario. Most of the classification exists in prose; the table makes it inspectable.
3. **Calibration audit.** The current tables carry value and source. They will be extended to the report's full format: equation location, units and frequency, sample, estimation method, target moment, whether that moment is reused for validation (it will not be), sensitivity range, and effect on headline results.
4. **External support for headline parameters.** The binding cases: (β, φ) in Paper 1 (SMM, committed above); m and p in Paper 2 (banded, scenario-labeled); ḡ_m, χ in Paper 3 (Design 4, first in the queue); (α, β) in Paper 5 (estimated from revisions and dispersion); (γ, R₀, ξ) in Paper 7 (scenario-labeled until Design 4 runs).
5. **Recalibrated benchmarks.** Paper 1 is the case where the mechanism moves the calibrated moments materially, and it gets the SMM treatment. Papers 2, 3, 5, 7 are calibrated arithmetic around observed equilibria rather than moment-matching exercises; their discipline is the audit and the labels, not re-estimation of someone else's fit.
6. **Validation moments, reserved.** Named now, and excluded from all estimation: Paper 1, return predictability (P3) and the cross-country θ–δ restriction (P4). Paper 2, aligned-country movement (P5) and the no-reversal shape. Paper 3, re-entry asymmetry against tariff exits (P3). Paper 5, auction outcomes (Design 3) and credibility events. Paper 7, the safe-country placebo (P2) and post-cap volume collapse (P4).
7. **Falsification.** Each paper already designates its decisive tests; the revision states them in one sentence each in the introductions.
8. **Data feasibility tables.** Added to every paper: dataset, coverage, frequency, access status, replication rights. The proprietary chokepoints are Consensus Economics individual panels and EMBI (Papers 1, 5), TIC beneficial-ownership limits (Paper 2), and licensed text (Paper 7). Papers 3's program is fully public-data, which is one reason it leads the empirical schedule.
9. **Global sensitivity.** Papers 3 and 7 have phase-diagram exhibits; Papers 1, 2, 5 will add one-way sensitivity for every parameter and two-way maps for the interacting pairs the report names, with the regions where mechanisms disappear shown, not mentioned.
10. **Policy conditions.** Every policy sentence gets its welfare assumption attached: the fiscal-rule signs conditional on whose beliefs are distorted (already the result's content); Ramsey restraint conditional on γ and the network elasticity; the maintenance subsidy conditional on v < τ*; transparency conditional on the news; the cap conditional on relevance-based adoption.

On the report's §6.10: I accept the rule as the report itself states it, that sharp language is acceptable when the statement is literally true under stated assumptions. The revisions attach the assumptions; they do not remove the sentences. "Cheap to fire once and ruinous to make routine" survives with "in the baseline arithmetic" standing next to it. A paper afraid of its own results is not more honest, only less useful.

---

## 7. Order of Work

The revision program, in the order the work will run:

1. **Uniform passes (all papers, first):** result-classification tables; calibration audits; scenario labels; conditional language on the flagged sentences; data feasibility tables; falsification sentences in the introductions.
2. **Paper 1:** the b-monotonicity proof; SMM re-estimation of (β, φ) at survey θ; grid-doubling; recalibrated headline tables; long-bond computation.
3. **Paper 3:** the fold sufficient-condition proposition; then Design 4 on public data (unit-value premia and their compression), the program's highest empirical value per unit of effort since it gates the tipping-distance claim and needs no data purchase.
4. **Paper 5:** K-type quantitative section; precision estimation and the uniqueness-bound check; scope paragraph on the bank nexus.
5. **Paper 2:** identification remark; wedge-unit Laffer curve with banded break-even; local-approximation statement; reputation section promoted.
6. **Paper 7:** abstract repair; scenario labels; the survey-validation gate written into the measurement protocol.
7. **Data acquisition (parallel, decision required):** Consensus Economics individual panel and EMBI access gate the estimation halves of Papers 1 and 5 and part of 2. This is a purchasing decision, not a modeling one, and it should be made once, for the whole program, since the same two purchases serve three papers.

---

## 8. Bottom Line

The report's standard is the right one and the drafts will meet it: proofs labeled as proofs, conditions carried in the statements that need them, calibrations audited line by line, scenarios called scenarios, and the two proprietary data purchases identified as the program's chokepoint. What I do not accept is the report's occasional suggestion that elegance and discipline trade off. The mechanisms in these papers survive the labeling; several of the report's demands were already the papers' own architecture; and the revisions above make the ambition inspectable rather than smaller.
