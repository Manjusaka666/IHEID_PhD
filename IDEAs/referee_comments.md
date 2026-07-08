# Referee-Style Comments on Five Top-Econ PhD Drafts

**Prepared as a research-review memorandum.**  
**Scope:** mathematical derivation, model discipline, calibration, econometric design, and frontier contribution.  
**Important instruction applied throughout:** every calibration parameter must be supported by external peer-reviewed estimates, official data, or transparent estimation from real data. No headline quantitative result should rely on unsupported parameter guesses.

---

## Executive Summary

The five drafts are serious first drafts with substantial intellectual ambition. They are considerably stronger than ordinary topic sketches: each has a clear mechanism, a mathematical structure, a proposed calibration, and an empirical agenda. However, all five still have first-draft weaknesses that would be heavily scrutinized by top economics referees.

The common problem is not a lack of ideas. The common problem is that several propositions are stated more sharply than the assumptions justify, several calibrations are illustrative rather than externally disciplined, and several empirical designs promise more identification than the available data are likely to deliver. The papers should be revised toward a stricter standard: each central claim must be either proved analytically, estimated from real data, or explicitly labeled as a calibrated scenario.

Across all drafts, the calibration standard must be upgraded. Parameters must not be chosen because they are “reasonable,” because they make the mechanism visible, or because they reproduce a qualitative narrative. Every parameter should be placed in one of four categories:

| Parameter category | Required treatment |
|---|---|
| Externally fixed | Taken from peer-reviewed literature or official data, with source, sample, frequency, and units reported. |
| Directly estimated | Estimated from raw data in the paper, with standard errors and robustness checks. |
| Internally calibrated | Chosen to match clearly stated moments; those moments cannot later be used as validation. |
| Scenario parameter | Not identified; used only for transparent sensitivity and not described as a calibrated structural parameter. |

A top referee will not accept a calibration table in which the most important parameters are based on judgment. The papers must show that their mechanisms are quantitatively relevant under parameter values supported by real data and external literature.

---

# 1. Diagnostic Expectations and Sovereign Default

## 1.1 Core Contribution

The paper embeds diagnostic expectations into a standard sovereign default model. In the workhorse Eaton–Gersovitz/Arellano environment, default risk and spreads depend on current debt and current income. The draft changes the belief-formation process of creditors so that recent income news becomes an additional state variable. The central innovation is that two countries with the same debt and same current output may face different bond prices if they arrived at that state through different recent news histories.

The strongest theoretical object in the draft is the Gaussian diagnostic-tilt result. If the true log-income process is

\[
x_{t+1}=\rho x_t+\varepsilon_{t+1}, \qquad \varepsilon_{t+1}\sim N(0,\sigma_\varepsilon^2),
\]

and diagnostic creditors use

\[
\hat p_\theta(x'\mid x,h) \propto p(x'\mid x)\left[\frac{p(x'\mid x)}{p(x'\mid h)}\right]^\theta,
\]

then the diagnostic distribution remains Gaussian with unchanged variance and shifted mean:

\[
\hat x'\mid x,h \sim N\big(\rho x+\theta \rho(x-h),\sigma_\varepsilon^2\big).
\]

This is mathematically clean and gives the paper a tractable behavioral state variable, \(\nu=x-h\). The result is well aligned with the diagnostic-expectations literature, where agents overweight future states whose likelihood rises after incoming data.

## 1.2 Mathematical Derivation: Strengths and Weaknesses

The main theoretical weakness is that several propositions rely on a monotone-default assumption rather than proving monotonicity in the expanded state space. In the rational Arellano benchmark, default is more likely at low output and high debt. But in the diagnostic model, bond prices depend on the history variable \(h\), and this modifies both borrowing incentives and continuation values.

The paper claims:

1. bond prices are increasing in good recent news;
2. expected creditor returns are predictably low after good news;
3. default regions are history dependent;
4. boom reversals can generate sharp increases in default hazard.

The first two claims are plausible conditional on monotone default. The third and fourth claims are stronger because the government’s debt choice responds endogenously to the diagnostic price schedule. If good-news pricing encourages more borrowing, the state may move endogenously toward a fragile debt region. That is an important mechanism, but it also means monotonicity cannot simply be assumed.

The paper should separate three kinds of results:

- **belief-kernel results**, which can be proved exactly;
- **pricing comparative statics conditional on monotone default**, which require explicit assumptions;
- **equilibrium default-region and borrowing results**, which may be numerical rather than analytical.

At a minimum, the draft should provide a proposition of the following form: under compact debt grids, concavity of utility, a bounded default-cost function, and a monotone price schedule, the computed equilibrium preserves monotone default in \((b,x)\). If such a theorem cannot be proven, the paper should present systematic numerical verification across grid sizes, calibrations, and alternative default-cost functions.

## 1.3 Calibration Concerns

The draft currently takes the Arellano Argentina calibration and varies only the diagnostic parameter \(\theta\). That is acceptable as a first comparative-static exercise, but not as a final quantitative calibration.

The paper reports very large changes in spread volatility and default frequency when \(\theta\) is introduced. That result is informative, but it also shows that the rest of the parameter vector cannot remain fixed. Once the belief distortion changes equilibrium default incentives and spreads, the discount factor, default cost, re-entry probability, and possibly debt maturity should be recalibrated or re-estimated.

The calibration must not treat \(\theta\) as an informal behavioral knob. The draft’s idea of mapping \(\theta\) from forecast-error-on-revision regressions is exactly the right discipline, but the mapping must be implemented using actual forecast data relevant to emerging markets. If the empirical forecast data are annual, fixed-event, monthly-vintage forecasts, the theoretical mapping from a one-period quarterly AR(1) model is not automatically valid. Horizon conversion, overlapping forecast windows, and individual-versus-consensus aggregation must be handled explicitly.

Required external or real-data support:

| Parameter/object | Required source or estimation basis |
|---|---|
| Income process \((\rho,\sigma_\varepsilon)\) | Real GDP data for the target country/sample; transparent detrending and frequency conversion. |
| Risk-free rate | Observable U.S. or global short rate over the calibration sample. |
| Default frequency | Historical sovereign default/restructuring databases. |
| Recovery/haircut assumptions | Sovereign restructuring datasets or published estimates. |
| Re-entry probability | Historical market-access duration after default. |
| Default output cost | Published sovereign default calibrations or estimated to match external default/output moments. |
| Diagnostic parameter \(\theta\) | Individual-level forecast-error-on-revision regressions, preferably for emerging-market output forecasts. |
| Spread moments | EMBI, CDS, or comparable sovereign spread data, with sample and filtering rules reported. |

No parameter should be retained from a benchmark model simply because it is standard if the new belief mechanism materially changes equilibrium outcomes.

## 1.4 Econometric Design Concerns

The empirical design is conceptually strong because it gives a sharp rational null: conditional on debt and current output, recent news should not independently price sovereign debt under the rational benchmark. The diagnostic model predicts that recent positive news compresses spreads beyond what fundamentals justify.

However, the design must overcome several threats:

1. **Forecast revisions are not exogenous.** They may capture political news, fiscal news, commodity-price news, global risk, or changes in measurement quality.
2. **Consensus forecasts may underreact even if individual forecasters overreact.** The paper’s behavioral parameter should be estimated from individual forecasts if the theory is about individual diagnostic beliefs.
3. **Linear controls are insufficient.** The paper itself notes that linear regressions can produce misleading news coefficients because of nonlinear spread schedules. Nonparametric or high-dimensional controls for debt and output are necessary.
4. **Spread data are influenced by global risk appetite.** VIX, U.S. rates, dollar funding conditions, commodity prices, and risk-on/risk-off episodes must be controlled carefully.
5. **Country-time measurement of debt and output may be poor.** If the empirical design uses annual debt and quarterly or monthly spreads, timing mismatch may induce bias.

## 1.5 Questions for Revision

1. Can the monotone-default assumption be proved in the diagnostic model, or only verified numerically?
2. Does the history variable \(h\) affect only pricing, or can it reverse borrowing and default monotonicity through endogenous leverage?
3. How sensitive are the model’s main boom-reversal hazards to grid density, income discretization, and debt-grid bounds?
4. Does the model still fit mean spreads, spread volatility, debt-to-output, default frequency, and output-spread cyclicality after recalibrating non-belief parameters?
5. Is \(\theta\) estimated from individual professional forecasts rather than consensus forecasts?
6. Does the forecast-revision mapping account for fixed-event forecasts, overlapping horizons, and time aggregation?
7. Can the spread-on-news coefficient survive nonparametric conditioning on debt, output, ratings, fiscal news, commodity prices, and global risk?
8. Are the main quantitative results robust to longer-maturity debt rather than one-period bonds?
9. Can the model generate realistic debt levels without producing excessive default frequency once diagnostic beliefs are introduced?

---

# 2. Sanctions Risk and Dollar Convenience

## 2.1 Core Contribution

The paper models financial sanctions risk as a state-contingent haircut on the liquidity value of dollar reserves. Reserve holders choose dollar shares by balancing the dollar’s convenience yield against diversification costs and expected sanctions losses. The dollar network matters because the convenience yield increases with aggregate dollar use.

The paper’s cleanest result is that cross-sectional comparisons identify only the direct sanctions wedge. If reserve demand is

\[
a_i=\frac{\bar r+\ell(N)-z_i\hat\pi}{\kappa},
\]

then the difference between aligned and exposed countries is

\[
a_A-a_E=\frac{\hat\pi}{\kappa},
\]

while the aggregate response is amplified by

\[
m=\frac{1}{1-\ell_1/\kappa}.
\]

This is a useful “micro is not macro” result. Cross-sectional designs can estimate the direct demand elasticity but cannot identify the network multiplier unless aggregate convenience-yield or reserve-share movements are also used.

## 2.2 Mathematical Derivation: Strengths and Weaknesses

The static model is transparent, but perhaps too transparent. The linear convenience function \(\ell(N)=\ell_0+\ell_1N\) and quadratic reserve objective produce closed-form results, but they also make the key multiplier mechanical. A top referee will ask whether the network multiplier is a substantive economic result or a direct consequence of the assumed linear externality.

The paper needs either:

1. a microfoundation of the convenience yield from payment networks, invoicing complementarities, collateral liquidity, and safe-asset demand; or
2. a clear statement that the linear-quadratic model is a local approximation around the observed reserve equilibrium.

The time-inconsistency result is interesting but currently too dependent on timing. The draft argues that under discretion, the hegemon sanctions at full intensity because reserve portfolios are predetermined. But if each sanctioning action immediately changes beliefs about the future rule, then the ex post marginal cost is not literally zero. A repeated-game or reputation model should be moved closer to the core argument.

## 2.3 Calibration Concerns

The calibration is the most vulnerable part of this paper. Global reserve shares can be anchored to IMF COFER data, but country-level currency composition is often missing or incomplete. The network multiplier, sanction probability, crisis arrival rate, target probability, exposed mass, and geopolitical benefit are difficult to identify separately.

The paper should not report a precise break-even breadth such as “2.9 percent” unless the parameters entering that threshold are externally disciplined. If the threshold is sensitive to \(p\), \(\mu\), \(\phi\), \(\ell_1\), or \(\gamma\), it should be reported as a scenario result rather than a calibrated conclusion.

Required external or real-data support:

| Parameter/object | Required source or estimation basis |
|---|---|
| Global dollar reserve share | IMF COFER or equivalent official reserve data. |
| Country-level dollar shares | Direct country disclosures where available; otherwise clearly labeled estimates. |
| Convenience yield | Published estimates of Treasury convenience yield, cross-currency basis, or safe-asset premia. |
| Network slope \(\ell_1\) | Estimated from aggregate reserve shares and convenience-yield variation; not assumed. |
| Sanctions frequency \(\omega\) | Historical sanctions-event databases. |
| Freeze severity \(\phi\) | Documented asset-freeze episodes, such as central-bank reserve freezes. |
| Target probability \(p\) | Historical incidence of sanctions conditional on geopolitical crises; not chosen by judgment. |
| Exposed mass \(\mu\) | Reserve-weighted geopolitical alignment measures from observable country classifications. |
| Geopolitical benefit \(\gamma\) | Must be treated as a scenario parameter unless independently estimated. |

The model can be valuable as policy arithmetic, but only if the paper is honest about which parameters are estimated and which are scenario inputs.

## 2.4 Econometric Design Concerns

The proposed designs face severe data limitations.

First, country-level reserve currency composition is often unavailable. IMF COFER is excellent for global aggregates, but not sufficient for many country-level exposure tests. Second, TIC data suffer from custodial bias: reserves held through financial centers may not reveal beneficial ownership. Third, convenience-yield measures are noisy and affected by monetary policy, regulatory demand, global risk appetite, safe-asset scarcity, and dollar funding conditions.

The predicted convenience-yield effect of a single sanctions reassessment appears small relative to the volatility of safe-asset spreads. The paper should therefore not rely on a single-event time-series test. It should combine cross-country portfolio evidence, gold-reserve accumulation, official reserve disclosures, and aggregate convenience-yield evidence.

## 2.5 Questions for Revision

1. What real data identify the network slope \(\ell_1\)?
2. Is the network multiplier estimated, calibrated to a moment, or assumed?
3. How are \(\omega\), \(p\), \(\phi\), and \(\mu\) separately identified?
4. Can the model distinguish sanctions-driven reserve diversification from valuation effects, interest-rate changes, reserve adequacy motives, and nontraditional reserve-currency diversification?
5. What evidence supports the claim that reserve holders price future sanctions risk after a central-bank freeze?
6. Does the model match the observed gradual movement in global reserve shares without overstating de-dollarization?
7. Is the break-even breadth robust across credible parameter ranges?
8. How does the time-inconsistency result change if current sanctions immediately update beliefs about future sanctions policy?
9. Are geopolitical benefits estimated or purely scenario-based?
10. Can the empirical design detect a convenience-yield change of the magnitude predicted by the model?

---

# 3. Endogenous Trade Fragmentation

## 3.1 Core Contribution

The paper studies trade fragmentation as an endogenous equilibrium process. Firms choose whether to keep a cheap cross-bloc supplier or switch to a politically safe supplier. The key mechanism is that remaining cross-bloc trade deters escalation. When firms friend-shore, they shrink the trade surplus that acts as a hostage, thereby increasing the disruption hazard faced by firms that remain exposed.

The threshold for switching is

\[
\hat g_m(F_m,F)=\frac{\pi_m(F_m,F)\lambda_m^0(1+\xi F_m)}{1-\chi F_m}.
\]

This combines three feedback channels:

1. deterrence erosion: friend-shoring reduces the trade hostage;
2. route thinning: fewer users make logistics, insurance, and backup routes thinner;
3. capacity scale: more friend-shoring expands safe-supplier capacity and lowers switching costs.

This is an ambitious and potentially important mechanism. It connects firm-level sourcing decisions to geopolitical escalation risk rather than treating geopolitical risk as exogenous.

## 3.2 Mathematical Derivation: Strengths and Weaknesses

The strategic-complementarity result is plausible if the hazard, disruption loss, and switching premium have the assumed monotonicities. The fixed-point multiplier

\[
M_m=\frac{1}{1-\Phi_m'}
\]

is a standard and useful way to summarize amplification near a stable equilibrium.

However, the strongest claims—fold bifurcation, hysteresis, sectoral tipping, and the sign flip of optimal policy—are not generic without additional restrictions. They depend on the shape of the switching-cost distribution \(H_m\), the magnitude of deterrence erosion, the strength of scale economies, and the thinning elasticity. The paper must be precise about what is analytically general and what is a calibrated possibility.

The policy result is especially delicate. The paper argues that below the fold, private friend-shoring is socially excessive because firms ignore the deterrence externality. This is a valid mechanism. But if governments value strategic autonomy beyond firms’ private disruption losses, then friend-shoring may be socially valuable even below the fold. The model introduces such a value \(v\), but the main policy language still sounds stronger than the model supports.

## 3.3 Calibration Concerns

This draft has a heavy calibration burden. The fold location and the policy sign depend on parameters that are hard to measure:

- deterrence elasticity;
- route-thinning elasticity;
- friendly-capacity scale elasticity;
- switching-cost distribution;
- disruption duration;
- input substitutability;
- sectoral input cost shares;
- dispute-arrival hazard.

These cannot be chosen by judgment. They must be estimated or externally sourced.

Required external or real-data support:

| Parameter/object | Required source or estimation basis |
|---|---|
| Product-level trade flows | BACI, customs data, or equivalent product-country bilateral data. |
| Input-output exposure | OECD ICIO, WIOD, national IO tables, or firm-level supply-chain data. |
| Substitution elasticities | Published trade or production elasticity estimates by sector/product. |
| Disruption duration | Evidence from natural disasters, pandemic disruptions, export controls, or firm supply-chain studies. |
| Switching-cost premium distribution \(H_m\) | Unit-value gaps, firm sourcing data, procurement records, or observed supplier-switching costs. |
| Deterrence parameter | Estimated from escalation probability versus remaining trade exposure, with credible instruments. |
| Capacity-scale elasticity \(\chi\) | Estimated from cost compression after cumulative reallocation to safe suppliers. |
| Route-thinning elasticity \(\xi\) | Estimated from disruption duration, freight cost, insurance cost, or logistics-market thickness. |
| Dispute hazard | Historical export-control, embargo, sanctions, or geopolitical-dispute data. |
| Strategic-autonomy value \(v\) | Scenario parameter unless independently measured. |

The draft should avoid presenting a sector as “two-thirds of the way to tipping” unless every parameter used to compute that distance is empirically disciplined.

## 3.4 Econometric Design Concerns

The empirical program is feasible only if narrowed and disciplined. A global HS-6 analysis is useful for descriptive patterns, but it is unlikely to identify the structural feedback parameters cleanly. A more credible empirical implementation would focus on a small number of critical sectors with high-quality product-level and firm-level data.

Key threats:

1. Sectors with high strategic importance are both more likely to be targeted and more likely to fragment.
2. Unit values are contaminated by quality changes, product mix, tariffs, and logistics costs.
3. Reallocation after 2022 may reflect tariffs, pandemic supply-chain lessons, subsidies, and China-specific costs, not only geopolitical disruption risk.
4. Escalation probability is endogenous to trade exposure and strategic salience.
5. Re-entry hysteresis may reflect sunk costs rather than equilibrium multiplicity.

The paper needs empirical moments that distinguish deterrence erosion from ordinary supply-chain adjustment.

## 3.5 Questions for Revision

1. Which results are true for all admissible parameter values, and which require the calibrated parameterization?
2. Can the fold bifurcation be characterized analytically with explicit sufficient conditions?
3. Is the hysteresis result due to equilibrium multiplicity or to implicit switching frictions?
4. What real evidence supports the deterrence channel at the sector level?
5. How is the route-thinning parameter \(\xi\) measured?
6. How is the capacity-scale parameter \(\chi\) measured?
7. Are unit-value gaps valid measures of switching premia?
8. How large must strategic-autonomy value \(v\) be to overturn the maintenance-subsidy result?
9. Can the model predict observable early-warning indicators of tipping?
10. Does the empirical design identify equilibrium amplification or only direct switching responses?
11. Are the central results robust to alternative substitution elasticities and input-output shares from external datasets?

---

# 4. Ambiguity, Investor Composition, and Sovereign Rollover Crises

## 4.1 Core Contribution

The paper combines global-game rollover crises with multiple-priors ambiguity about official information. Creditors distrust the official signal because they are unsure about its bias. A creditor with ambiguity radius \(\delta_k\) behaves as if the official signal were shifted downward:

\[
y \mapsto y-\delta_k.
\]

The resulting cutoff premium is

\[
x_k^*-x_B^*=\frac{\alpha}{\beta}\delta_k.
\]

This is a strong and interpretable result. Distrust matters most when official information is precise relative to private information, because creditors must lean more heavily on the official signal. The model also claims that ambiguity shifts run cutoffs without changing the uniqueness condition of the global game. That is a valuable theoretical distinction: fragility moves smoothly with distrust and investor composition rather than appearing as an equilibrium-selection problem.

## 4.2 Mathematical Derivation: Strengths and Weaknesses

The as-if-pessimism result is clean, provided the worst-case prior is indeed one-sided in the rollover decision. The uniqueness result is also plausible because ambiguity shifts signal intercepts rather than slopes. However, the paper must state the uniqueness condition carefully and verify that it holds under empirically estimated signal precisions, not merely under assumed values.

The two-type investor-base structure is useful but too coarse. Stable holders are assumed not to have a meaningful run margin, while fragile holders are price-sensitive and distrustful. In reality, domestic banks, foreign nonbanks, foreign official holders, pension funds, hedge funds, and central banks differ along several dimensions: liquidity demand, regulation, collateral constraints, accounting rules, domestic political exposure, and risk-bearing capacity. The model should either justify the aggregation or extend the composition block to multiple investor classes.

The distinction between credibility and precision is one of the best ideas in the paper. Precision can destabilize when news is bad, while credibility always stabilizes by reducing \(\delta\). This is a sharp theoretical contribution. But empirically, fiscal transparency events often combine news revelation and credibility improvement. The paper must distinguish the content of information from the credibility of the information source.

## 4.3 Calibration Concerns

The calibration should be built from observable components. The payoff block is easier to discipline than the information block.

Required external or real-data support:

| Parameter/object | Required source or estimation basis |
|---|---|
| Recovery/haircut | Sovereign restructuring datasets. |
| Rollover yield | Market yields for relevant sovereign debt. |
| Fire-sale exit cost | Auction tails, bid-ask spreads, crisis liquidity discounts, or secondary-market stress episodes. |
| Investor composition \(\mu\) | Investor-base datasets, debt-management-office data, custodial holdings, or security-level holdings. |
| Maturity-relevant fragile share | Investor composition by residual maturity, not only total debt holdings. |
| Official signal precision | Real-time fiscal forecast errors, data revisions, or official projection errors. |
| Private signal precision | Forecast dispersion, analyst coverage, market-implied information, or auction microdata. |
| Ambiguity radius \(\delta\) | Fiscal revision histories, audit scandals, data-standard adoption, statistical credibility events, or structural estimation validated out of sample. |
| Stress state | Observable spread, debt-service, fiscal-balance, or market-access thresholds. |

The ambiguity radius \(\delta\) is the most important and difficult parameter. It cannot be selected to match spreads and then used to explain spreads. If inferred structurally, it must be validated using credibility events not used in the estimation.

## 4.4 Econometric Design Concerns

The proposed interaction design is promising:

\[
\Delta s_{it}=\alpha_i+\tau_t+\beta_1D_{it}\mu_{it}+\beta_2D_{it}\mu_{it}Stress_{it}+\cdots.
\]

The theory predicts that distrust matters more when fragile investors hold more debt and when the sovereign is near stress. That interaction is empirically meaningful.

Still, identification is difficult:

1. Investor composition is endogenous. Fragile investors may enter high-yield markets or exit before crises.
2. Fiscal revision history proxies not only distrust but also fiscal weakness and institutional quality.
3. Stress interactions can mechanically arise from nonlinear spread dynamics.
4. Domestic banks may be stable rollover holders but unstable through the sovereign-bank doom loop.
5. Secondary-market spreads may not directly measure rollover pressure; auction data would be more convincing.

The strongest empirical evidence would come from auction microdata, maturity-specific investor-base data, and identifiable credibility events.

## 4.5 Questions for Revision

1. What observable variable maps into \(\delta\)?
2. How does the model distinguish distrust from risk, volatility, forecast disagreement, and bad fundamentals?
3. Can \(\mu\) be measured for the maturing debt stock, rather than total outstanding debt?
4. How endogenous is investor composition to expected crisis risk?
5. Are domestic banks truly stable holders once sovereign-bank feedback is considered?
6. How are public and private signal precisions estimated?
7. Does the uniqueness condition hold using empirically estimated precision ratios?
8. Can auction outcomes validate the run-margin mechanism?
9. Does the implied ambiguity premium match observed spreads out of sample?
10. How persistent is \(\delta\), and what data discipline its law of motion?

---

# 5. Narrative Contagion at the Sovereign Default Boundary

## 5.1 Core Contribution

The paper imposes a useful boundary on narrative economics. A pessimistic sovereign-default narrative matters only when the default-probability curve is steep. If default probability is

\[
p(\theta,s)=\Phi(z(\theta,s)),
\]

and infected investors perceive fundamentals as worse by \(\xi\), then the narrative’s pricing effect is governed by

\[
\Phi(z+\Delta)-\Phi(z).
\]

This object is hump-shaped: it is small for very safe sovereigns, small for already-condemned sovereigns, and large near the default boundary. That is a valuable discipline because it prevents the narrative mechanism from explaining everything.

The paper then links the pricing hump to epidemic diffusion: narratives spread when they are useful for pricing. This produces a susceptible zone, a febrile zone, and a critical zone in which the narrative-spread-fundamentals loop can tip the sovereign into default.

## 5.2 Mathematical Derivation: Strengths and Weaknesses

The pricing hump follows from the S-curve of default probability. That part is solid. The contagion hump, however, depends on a behavioral assumption: investors adopt and transmit narratives in proportion to price relevance. This is plausible, but it is not derived from optimizing communication, social learning, media incentives, or investor attention.

The paper must not claim that “one primitive does all the work” unless the adoption rule is also derived. At present, one primitive generates the pricing hump, while an additional behavioral assumption maps price relevance into contagion.

The spread-cap result is also conditional on this adoption rule. If a credible cap makes the narrative irrelevant for prices, the model predicts that the epidemic dies. But if investors transmit narratives because they believe the cap is politically fragile, fiscally costly, or mispriced, narrative volume may persist even when spreads are capped. The paper should treat this as a testable implication rather than a general theorem.

## 5.3 Calibration Concerns

This is the draft with the most difficult calibration problem. Recovery rates and default losses can be externally disciplined, but narrative parameters require original measurement.

Required external or real-data support:

| Parameter/object | Required source or estimation basis |
|---|---|
| Recovery/haircut | Sovereign restructuring datasets. |
| Fundamentals process | Fiscal capacity, debt-service capacity, or sovereign-risk state variables estimated from real data. |
| Spread feedback \(\chi\) | Debt-service arithmetic using gross financing needs, maturity structure, and refinancing rates. |
| Narrative bite \(\xi\) | Estimated from investor surveys, forecast revisions, event studies, or structural text-spread moments. |
| Narrative prevalence \(n_t\) | Wealth-weighted investor exposure to the narrative, not raw article counts. |
| Abandonment rate \(\gamma\) | Estimated from observed decay of narrative prevalence after corrections or news resolution. |
| Reproduction number \(R_0\) | Estimated from diffusion patterns across outlets, investors, platforms, or text networks. |
| Seed size | Observed initial reach of narrative shocks. |
| Amplification parameter | Estimated from media/platform diffusion data, not assumed. |
| Boundary proximity | Estimated local sensitivity of spreads to fundamentals news. |

The model should not report quantitative claims such as “ten percentage points of prevalence move spreads by hundreds of basis points” unless prevalence is empirically measured in economically meaningful units.

## 5.4 Econometric Design Concerns

The empirical design should focus on the state-dependence prediction. The theory does not merely say that narratives move spreads. It says narratives move spreads only near the default boundary.

Therefore, the central regression should interact narrative prevalence with a boundary-proximity statistic:

\[
\Delta s_{i,t+h}=\alpha_i+\tau_t+\beta_h \hat n_{it}+\delta_h \hat n_{it}B_{i,t-1}+\Gamma_hX_{i,t-1}+u_{i,t+h}.
\]

The coefficient \(\beta_h\) should be small away from the boundary; \(\delta_h\) should be positive if the model is correct.

Main threats:

1. Text volume responds endogenously to spreads and fundamentals.
2. Narrative classifiers may confuse bad-fundamentals news with pessimistic narratives.
3. Imported narratives may proxy common creditor exposure or regional fundamentals.
4. Platform or media diffusion shocks may not be exogenous to investor attention.
5. The mapping from media text to investor wealth-weighted beliefs is weak.

The paper needs pre-specified narrative categories, validated text classification, hand-labeled samples, and placebo tests in safe countries where narratives should be loud in text but silent in prices.

## 5.5 Questions for Revision

1. What exactly is a narrative: a text topic, a belief distortion, an investor state, or a pricing signal?
2. How is text prevalence mapped into wealth-weighted investor prevalence?
3. How is the narrative bite \(\xi\) estimated?
4. What data identify \(\gamma\) and \(R_0\)?
5. Does narrative prevalence lead spreads only near the default boundary?
6. Can the model separate narrative contagion from bad-fundamentals news coverage?
7. Are imported narratives valid instruments, or do they reflect common creditors and regional fundamentals?
8. Does narrative volume collapse after credible spread caps, as the relevance-adoption mechanism predicts?
9. What happens if adoption is driven by perceived mispricing rather than price relevance?
10. Are policy results robust to partial cap credibility?

---

# 6. Cross-Draft Issues That Must Be Fixed

This section applies to all five drafts. These are not stylistic comments; they are structural issues that would matter for a top-field or top-five economics submission.

## 6.1 Separate Theorems, Conditional Results, and Calibrated Facts

The drafts often state numerical or locally valid results with the language of general propositions. This must be corrected. Every result should be classified as one of the following:

1. **Analytical theorem:** true under explicitly stated assumptions and proven formally.
2. **Conditional comparative static:** true only if regularity conditions such as monotonicity, interiority, uniqueness, or stability hold.
3. **Numerical property:** true in the computed equilibrium for a specific parameterization.
4. **Scenario result:** true under an assumed parameter configuration that is not empirically identified.

Examples:

- In the diagnostic sovereign-default paper, history-dependent prices follow from diagnostic beliefs and monotone default, but default-region expansion requires equilibrium monotonicity.
- In the sanctions paper, the cross-sectional cancellation is analytical, but the break-even breadth is a calibrated scenario unless all parameters are externally disciplined.
- In the trade-fragmentation paper, strategic complementarity may be general, but fold bifurcation and hysteresis require parameter restrictions.
- In the ambiguity paper, as-if pessimism is analytical, but the spread premium is calibrated.
- In the narrative paper, the pricing hump is analytical, but the contagion zone depends on an adoption assumption and calibrated epidemic parameters.

## 6.2 Calibration Must Be Evidence-Based, Not Mechanism-Based

All five drafts need stricter calibration discipline. The current calibration style is too often illustrative: parameters are selected to show that the mechanism can be quantitatively large. That is not enough.

A proper calibration table must include:

1. parameter name;
2. equation location;
3. value;
4. unit and frequency;
5. source or estimation method;
6. sample period;
7. target moment if internally calibrated;
8. whether the target moment is later used for validation;
9. sensitivity range;
10. effect of varying the parameter on headline results.

A parameter that determines a headline result must be externally supported or estimated. If it cannot be supported, the headline result must be downgraded to a scenario.

## 6.3 Recalibration Is Required When a New Mechanism Changes Equilibrium Moments

A recurring problem is that drafts add a new mechanism to a benchmark model while keeping all benchmark parameters fixed. This is useful for comparative statics, but not for final quantitative claims.

If a new mechanism changes default frequency, spread volatility, debt levels, reserve shares, network size, or trade shares, the full parameter vector must be recalibrated or estimated. Otherwise, the exercise answers only: “What happens if we add this mechanism to someone else’s calibration?” It does not answer whether the model fits the data.

This applies especially to:

- diagnostic expectations in sovereign default;
- sanctions risk in reserve demand;
- endogenous feedback in trade fragmentation;
- ambiguity in rollover crises;
- narrative contagion in sovereign spreads.

## 6.4 Empirical Designs Must Be Narrower and More Falsifiable

The drafts currently propose broad empirical designs. Broad designs are useful for proposal writing but often weak in actual identification. Each paper should identify one or two decisive empirical tests that could genuinely reject the theory.

Examples:

- Diagnostic expectations: conditional spread response to forecast revisions, using individual forecast data and nonparametric controls.
- Sanctions risk: exposed-country reserve diversification after financial sanctions, plus aligned-country movement as the network fingerprint.
- Trade fragmentation: sector-level evidence that remaining trade lowers escalation probability and that switching exhibits structural amplification.
- Ambiguity: interaction of fiscal credibility shocks with maturity-specific fragile investor shares, validated in auction outcomes.
- Narrative contagion: narrative prevalence should price spreads only near the estimated default boundary and should not price safe countries.

The empirical sections should not list many weak tests. They should focus on a small set of tests that map directly to the model’s distinctive restrictions.

## 6.5 Policy Conclusions Must Be Conditional on Welfare Assumptions

The policy conclusions are often sharper than the welfare models justify. This is dangerous.

Examples:

- Debt ceilings may lower welfare when only markets overreact, but this depends on the government being rational and able to exploit mispricing.
- Sanctions restraint may be optimal under a Ramsey rule, but the result depends on the value of geopolitical objectives and the network elasticity.
- Friend-shoring subsidies may have the wrong sign only if deterrence externalities dominate strategic-autonomy benefits.
- Transparency may stabilize ambiguity-driven rollover crises, but precision can destabilize under bad news.
- Spread caps may kill narrative contagion only if adoption depends on price relevance.

The papers should state policy results as conditional propositions, not universal policy prescriptions.

## 6.6 Model Scope Must Be Explicit

Each paper should state what it does not model.

- The diagnostic paper does not fully model political economy of sovereign borrowing.
- The sanctions paper does not model the target country’s strategic response in detail.
- The trade-fragmentation paper does not fully model national-security autonomy values.
- The ambiguity paper does not fully model sovereign-bank feedback or endogenous investor entry and exit.
- The narrative paper does not fully model media supply or political information production.

A good top-level paper can abstract from these issues, but it must make clear which conclusions depend on the abstraction.

## 6.7 Sensitivity Analysis Must Be Global, Not Token

The drafts often report baseline results and limited sensitivity. That is insufficient because several mechanisms are nonlinear. Sensitivity should be global and structured.

Required sensitivity outputs:

1. one-way sensitivity for every major parameter;
2. two-way sensitivity for interacting parameters;
3. robustness to alternative calibrations from external literature;
4. robustness to alternative functional forms;
5. robustness to grid size and numerical method;
6. reporting of regions where the mechanism disappears.

For nonlinear mechanisms such as tipping, hysteresis, multiplier blow-up, or narrative outbreaks, sensitivity should be shown as phase diagrams rather than only tables.

## 6.8 The Papers Need Clear Validation Moments Not Used in Calibration

Every quantitative model should distinguish calibration targets from validation moments. A model cannot claim success because it matches the moments it was designed to match.

Each draft should reserve at least two external validation moments:

- Diagnostic expectations: return predictability and forecast-revision coefficients not used in calibration.
- Sanctions risk: aligned-country reserve movement or convenience-yield response not used to set the multiplier.
- Trade fragmentation: re-entry asymmetry or escalation response not used to calibrate switching.
- Ambiguity: auction pressure or credibility-event responses not used to estimate \(\delta\).
- Narrative contagion: safe-country placebo outbreaks or post-cap text-volume collapse not used to estimate diffusion.

## 6.9 Data Availability Must Be Audited Before Claims Are Finalized

Several empirical designs require proprietary or incomplete data. Before writing strong empirical promises, each paper should include a data feasibility audit:

1. exact dataset name;
2. coverage period;
3. country and sector coverage;
4. frequency;
5. access restrictions;
6. missing-data structure;
7. whether the variable is directly observed or proxied;
8. whether the data can be legally shared in replication files.

This matters especially for:

- Consensus Economics individual forecasts;
- EMBI spreads;
- country-level reserve currency composition;
- TIC beneficial ownership;
- firm-level supplier switching;
- auction microdata;
- licensed news and platform text.

## 6.10 Writing Must Become More Referee-Proof

The drafts are rhetorically strong, but top referees will punish overstatement. The revision should reduce language such as:

- “the model proves”; 
- “the policy implication is”; 
- “the weapon is ruinous”; 
- “friend-shoring has the wrong sign”; 
- “the story kills”; 
- “the effect is exact”; 
- “the multiplier cannot be seen.”

These phrases are acceptable only when the statement is literally true under stated assumptions. Otherwise, use conditional language:

- “under the maintained monotonicity condition”;
- “in the calibrated baseline”;
- “if the estimated network elasticity lies in this range”;
- “conditional on adoption being price-relevance based”;
- “in the absence of an independent strategic-autonomy motive.”

The goal is not to make the papers less ambitious. The goal is to make the ambition defensible.

---

# 7. Minimum Revision Checklist

Each draft should include the following before being presented as a serious top-econ PhD proposal:

1. **Formal assumption list.** Every theorem must state all assumptions explicitly.
2. **Proof classification.** Identify which results are analytical, conditional, numerical, or scenario-based.
3. **Calibration audit.** Every parameter must have a source, target, or estimation method.
4. **External-parameter support.** All headline parameters must be supported by external literature or real data.
5. **Recalibrated benchmark.** If the new mechanism changes equilibrium moments, recalibrate the model.
6. **Validation moments.** Reserve moments not used in calibration for external validation.
7. **Empirical falsification.** State what empirical result would reject the model.
8. **Data feasibility table.** Confirm availability, access, frequency, and replication feasibility.
9. **Sensitivity maps.** Show where the mechanism survives and where it disappears.
10. **Policy conditions.** State welfare assumptions and parameter thresholds behind policy conclusions.

---

# 8. Reference and Data Anchor Notes

The following external sources are useful anchors for revising the drafts. They should not be treated as exhaustive references; they are listed to emphasize that calibration and empirical discipline must come from real sources.

1. Arellano, C. (2008). “Default Risk and Income Fluctuations in Emerging Economies.” *American Economic Review*. Source: https://www.aeaweb.org/articles?id=10.1257/aer.98.3.690
2. Bordalo, P., Gennaioli, N., and Shleifer, A. (2018). “Diagnostic Expectations and Credit Cycles.” *Journal of Finance*. Source: https://www.nber.org/papers/w22266 and https://onlinelibrary.wiley.com/doi/10.1111/jofi.12586
3. Bianchi, J., and Sosa-Padilla, C. (2025). “International Sanctions and Dollar Dominance.” *Economic Journal*. Source: https://ideas.repec.org/a/oup/econjl/v135y2025i672p2567-2577..html
4. Bianchi, J., and Sosa-Padilla, C. (2024). “On Wars, Sanctions, and Sovereign Default.” *Journal of Monetary Economics*. Source: https://www.sciencedirect.com/science/article/abs/pii/S0304393223001265
5. IMF COFER. “Currency Composition of Official Foreign Exchange Reserves.” Source: https://data.imf.org/en/datasets/IMF.STA:COFER
6. Gopinath, G., and Stein, J. C. (2021). “Banking, Trade, and the Making of a Dominant Currency.” *Quarterly Journal of Economics*. Source: https://ideas.repec.org/a/oup/qjecon/v136y2021i2p783-830..html
7. Martin, P., Mayer, T., and Thoenig, M. (2008). “Make Trade Not War?” *Review of Economic Studies*. Source: https://academic.oup.com/restud/article-abstract/75/3/865/1555305
8. CEPII BACI trade database. Source: https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37
9. Arslanalp, S., and Tsuda, T. (2014). “Tracking Global Demand for Emerging Market Sovereign Debt.” IMF Working Paper. Source: https://www.imf.org/-/media/websites/imf/imported-full-text-pdf/external/pubs/ft/wp/2014/_wp1439.pdf
10. Cruces, J. J., and Trebesch, C. (2013). “Sovereign Defaults: The Price of Haircuts.” *American Economic Journal: Macroeconomics*. Source: https://www.aeaweb.org/articles?id=10.1257/mac.5.3.85
11. Morris, S., and Shin, H. S. (2004). “Coordination Risk and the Price of Debt.” *European Economic Review*. Source: https://economics.mit.edu/sites/default/files/publications/paper_38_coordination_risk.pdf
12. Hellwig, C. (2002). “Public Information, Private Information, and the Multiplicity of Equilibria in Coordination Games.” *Journal of Economic Theory*. Source: https://econpapers.repec.org/RePEc:eee:jetheo:v:107:y:2002:i:2:p:191-222
13. Shiller, R. J. (2017). “Narrative Economics.” *American Economic Review*. Source: https://www.aeaweb.org/articles?id=10.1257/aer.107.4.967
14. Kermack, W. O., and McKendrick, A. G. (1927). “A Contribution to the Mathematical Theory of Epidemics.” *Proceedings of the Royal Society A*. Source: https://royalsocietypublishing.org/rspa/article/115/772/700/2165/A-contribution-to-the-mathematical-theory-of

---

# 9. Bottom Line

The five drafts are promising but not yet referee-proof. Their main shared weakness is that they are written as if elegant mechanisms are already disciplined quantitative theories. The next revision must impose a stricter hierarchy:

1. prove what can be proved;
2. estimate what can be estimated;
3. externally source what can be externally sourced;
4. clearly label the rest as scenarios.

Only after this discipline is imposed can the papers credibly claim top-economics research quality.
