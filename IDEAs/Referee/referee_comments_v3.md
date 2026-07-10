# Referee Memorandum on the Five First Drafts

## Scope of this report

I treat these papers as **first drafts under active development**, not as completed submissions. The relevant question is therefore not whether every empirical result has already been produced, but whether each project has a coherent economic mechanism, mathematically defensible claims, a credible quantitative route, and an empirical design that can actually be implemented.

I impose the following data-availability rule throughout:

> A proposed dataset is admissible only if it is publicly downloadable or obtainable through a normal university or commercial subscription. I exclude confidential central-bank microdata, undisclosed country-level COFER data, proprietary platform firehoses that cannot be licensed, restricted firm-to-firm customs records, and internal auction or portfolio data available only through personal institutional access.

Commercially licensed products such as Consensus Economics, Bloomberg, Refinitiv, Factiva, LexisNexis, and J.P. Morgan EMBI are treated as obtainable, but they should always be identified as licensed rather than public.

No assessment below implies an ordering among the five projects.

---

# I. Diagnostic Expectations and Sovereign Default

The draft embeds diagnostic expectations in a standard sovereign-default environment. The central result is that recent income news becomes an additional pricing state: conditional on current debt and output, debt is priced differently depending on whether the economy arrived after good or bad news. The paper then derives predictable bond returns, history-dependent default regions, and belief-dependent welfare effects of debt ceilings. 

## 1. Core contribution and economic interpretation

The paper has a clear economic object:

[
\nu_t=x_t-x_{t-1},
]

which measures recent news, and a clear belief distortion:

[
\widehat{x}*{t+1}\mid x_t,x*{t-1}
\sim
N!\left(
\rho x_t+\theta\rho(x_t-x_{t-1}),
\sigma_\varepsilon^2
\right).
]

This is an effective way to connect behavioral expectation formation to sovereign default. The main contribution should be stated narrowly:

> Forecast-measured overreaction changes the location of the sovereign default boundary and produces history-dependent sovereign bond pricing, even in a unique recursive equilibrium without sunspots.

That statement is both defensible and sufficiently distinctive. The paper should avoid presenting the general fact that diagnostic expectations generate boom-bust credit dynamics as its main novelty. Diagnostic expectations have already been shown to generate realistic credit cycles, low subsequent bond returns, and fragility following good times in a fully developed corporate-credit model. ([AEA Publications][1]) The sovereign-default option, the externally estimated belief parameter, and the fiscal-policy result are the genuinely paper-specific contributions.

The policy result is intellectually interesting but must be framed carefully. When only lenders are diagnostic, the sovereign benefits from selling overpriced claims; when the government is also diagnostic, a debt rule may protect it from its own extrapolation. This is a statement about **sovereign welfare under the true probability measure**, not necessarily global welfare. Foreign-lender losses, international spillovers, and political-economy costs of default are outside the baseline welfare criterion.

## 2. Mathematical model and proofs

### 2.1 Diagnostic density

The Gaussian diagnostic-tilt lemma is clean. Because the true and reference distributions have equal variance, exponential tilting by their likelihood ratio shifts the conditional mean without changing the variance. The proof should remain in the main mathematical appendix, but it would be helpful to display the completed-square calculation explicitly. This is the foundational step from which the one-dimensional news state follows.

The draft should also explain that the one-state expansion is special to:

1. Gaussian innovations;
2. equal conditional variances;
3. a first-order Markov income process;
4. the selected diagnostic reference distribution.

Under stochastic volatility, nonlinear income dynamics, or permanent-transitory components, the belief state will generally have more than one dimension. This does not invalidate the current model, but it clarifies the source of its tractability.

### 2.2 Equilibrium existence

The current statement that existence follows because the price operator maps a compact set into itself is not sufficient. A self-map of a compact set need not possess a fixed point without continuity or an appropriate correspondence argument.

There are two acceptable routes.

**Finite-grid numerical route.** Define a finite-state, finite-action economy, introduce a deterministic tie-breaking rule, and establish continuity or upper hemicontinuity of the induced price correspondence. Then apply Brouwer or Kakutani. This is sufficient for the computational model.

**Analytical route.** Work with compact debt and income spaces, continuous utility and kernels, and a mixed default/issuance correspondence. Establish existence of value functions and an equilibrium price correspondence. This is considerably harder and not essential for a first draft.

The practical recommendation is to make a modest claim:

> “On the finite grids used in the quantitative implementation, an equilibrium fixed point exists under the stated tie-breaking and continuity conditions. The numerical algorithm converges to the reported fixed point from multiple initial price schedules.”

The paper should report convergence from at least three initial conditions: risk-free prices, zero prices, and the rational-equilibrium price schedule.

### 2.3 Monotone default

The key propositions rely on the maintained condition that default is nonincreasing in income. The draft already acknowledges this and verifies it numerically. That is acceptable at the current stage, provided the language is precise:

* debt monotonicity is proven;
* income monotonicity is assumed and numerically verified;
* price, return, and default-region results are conditional on income monotonicity.

The paper should not suggest that numerical verification over the calibration establishes a general theorem.

A useful improvement would be to derive sufficient conditions for income monotonicity in a simplified version, for example:

* i.i.d. income;
* proportional default costs;
* one-period debt;
* CRRA or log utility;
* monotone price schedules.

Even a restricted theorem would explain why the numerical regularity is economically natural.

### 2.4 Strict price monotonicity

The price result follows from first-order stochastic dominance of diagnostic beliefs and a monotone repayment set. Strictness requires that the repayment indicator differ on a set of positive diagnostic probability. The proposition should explicitly state:

[
0<
\Pr_\theta[d(b',x',x)=1\mid x,h]
<1.
]

Otherwise, in risk-free and certain-default regions, the price is locally invariant to news even when (\theta>0).

### 2.5 Forecast-revision mapping

The exact mapping

[
\beta_{CG}
==========

-\frac{\theta(1+\theta)}
{(1+\theta)^2+\theta^2\rho^2}
]

is valuable, but its domain must be stated precisely. It depends on:

* a fixed target date;
* the one-step or specifically derived forecast horizon;
* no unmodelled forecaster heterogeneity;
* the assumed information timing;
* the AR(1) law;
* the same (\theta) across forecast dates.

The empirical forecasts are fixed-event annual forecasts converted into fixed-horizon forecasts. The paper should therefore derive the horizon-specific and temporal-aggregation mapping in the main text or a prominent appendix. It should not estimate (\theta) by mechanically applying the quarterly one-step expression to annual growth forecasts.

A Monte Carlo validation is necessary: simulate the exact monthly survey structure, apply the empirical transformation, estimate the forecast-error regression, and verify that inversion recovers the input (\theta).

### 2.6 Long-duration debt

The current quantitative difficulty—reasonable default frequencies accompanied by severely compressed spreads after recalibration—is a consequence of the one-period-debt structure. The long-duration extension should become part of the main quantitative model rather than remain only an appendix.

A standard recursion can take the form

[
q(b',x,h)
=========

\frac{1}{1+r^*}
\widehat{\mathbb E}_{\theta}
\left[
(1-d')
\left(
\delta +(1-\delta)
\left[
z+q(b'',x',x)
\right]
\right)
\right],
]

where (\delta) is the maturity rate and (z) the coupon. This adds dilution and capital-gain channels and allows the paper to confront duration-specific returns.

The theoretical one-period results can remain the analytical core. The long-duration model should be identified as the quantitative implementation.

## 3. Calibration and quantitative discipline

The fixed-parameter comparative static is informative but should not be interpreted as a fit. At (\theta=0.5), the draft reports a spread standard deviation of 57.8 percent and a default frequency of 11.6 per century; at (\theta=1), spread volatility becomes extreme. After recalibration, default frequency and debt service improve but the median spread collapses. 

The correct structure is a two-stage quantitative exercise.

### Stage A: mechanism experiment

Hold the original rational-expectations calibration fixed and vary (\theta). Label all outputs as controlled mechanism comparisons. The purpose is to show how beliefs move equilibrium objects.

### Stage B: internally consistent estimation

Estimate or calibrate the long-duration model with (\theta) fixed by forecast data. The remaining parameters should target at least:

[
\begin{aligned}
&\text{default frequency},\
&\text{mean and median spread},\
&\text{spread volatility},\
&\text{mean debt or debt service},\
&\operatorname{corr}(s_t,y_t),\
&\operatorname{corr}(s_t,\Delta y_t),\
&\text{bond-return predictability},\
&\text{average maturity}.
\end{aligned}
]

The objective function and weighting matrix should be reported. The paper should provide:

* model and data moments side by side;
* estimated parameter uncertainty;
* overidentifying moments not used in estimation;
* joint—not merely one-at-a-time—sensitivity analysis.

The belief parameter must not be selected to fit sovereign spreads if the paper claims that forecasts identify it externally.

## 4. Empirical design

### 4.1 Forecast data

Consensus Economics is feasible. Its products contain individual as well as consensus forecasts across a large set of countries and are available through publications, Excel files, data platforms, or an API. ([Consensus Economics][2])

The paper should secure the license and audit the following before retaining the current design:

1. stable anonymous forecaster identifiers;
2. individual forecasts rather than only mean, high, and low forecasts;
3. respondent entry and exit;
4. forecast target definitions;
5. historical publication dates;
6. availability of the relevant emerging-market countries.

The publicly downloadable Philadelphia Fed and ECB Surveys of Professional Forecasters can be used to validate the coding and inversion method. Both provide anonymised individual forecast microdata. ([Federal Reserve Bank of Philadelphia][3]) These public datasets do not replace emerging-market forecasts, but they provide a transparent replication benchmark.

### 4.2 Measurement of forecast errors

The dependent variable should use first-release or real-time realizations wherever possible. Latest-revised GDP introduces an avoidable discrepancy between the information available to forecasters and the econometrician’s final data.

Measurement error is particularly important because the same forecast can enter the revision and forecast-error terms with opposite signs. Lagged revisions are not automatically valid instruments: persistent news or persistent forecaster types may correlate them with subsequent forecast errors.

A more credible design is:

[
FE_{ij,t+h}
===========

\alpha_{ij}
+\tau_{i,t}
+\beta,Rev_{ij,t}
+\Gamma'Z_{i,t}
+u_{ij,t+h},
]

with:

* forecaster-country fixed effects;
* country-target-date fixed effects;
* leave-one-out common revision controls;
* explicit treatment of overlapping horizons;
* standard errors clustered by country and target date.

Scheduled macroeconomic releases can be used to isolate externally timed information shocks. Revisions immediately following a release should be separated from revisions made without an observable public-information event.

### 4.3 Sovereign-spread test

The “rational zero” should be described as a zero restriction of the benchmark model, not of every rational sovereign-pricing model. In reality, lagged growth may proxy for political risk, fiscal news, commodity shocks, reserves, maturity structure, or permanent-income news.

The preferred specification should therefore be:

[
s_{it}
======

\alpha_i+\tau_t+
g_i(b_{it},y_{it},X_{it})
+
\beta_1 Rev_{it}
+
\beta_2\widehat\theta_i Rev_{it}
+\varepsilon_{it},
]

where (g_i(\cdot)) is estimated flexibly with splines, bins, or cross-fitted machine-learning controls. (X_{it}) should include observable state variables unavailable in the simple model but relevant empirically.

The cleaner test is an announcement-window design:

[
\Delta s_{i,t}^{,\text{window}}
===============================

\beta_1 Surprise_{it}
+
\beta_2 Surprise_{it}\times PriorNews_{it}
+
\varepsilon_{it}.
]

Diagnostic beliefs predict that the response to the same current surprise depends on the preceding direction of news. This is closer to the theoretical mechanism and less exposed to slow-moving omitted variables.

### 4.4 Bond returns

The return-predictability proposition is economically stronger than a spread-level regression. It should receive equal empirical weight.

Using J.P. Morgan EMBI total-return data through Bloomberg or Refinitiv, estimate:

[
RX_{i,t\rightarrow t+h}
=======================

\alpha_i+\tau_t+
\beta,Rev_{it}
+\Gamma'X_{it}
+\varepsilon_{i,t+h}.
]

Under the theory, positive news and optimistic revisions should predict lower subsequent excess returns. This test directly distinguishes belief overreaction from a rational model in which high spreads simply compensate investors for risk.

## 5. Fully obtainable data architecture

| Object                                | Dataset                                                                                          | Access                              |
| ------------------------------------- | ------------------------------------------------------------------------------------------------ | ----------------------------------- |
| Individual emerging-market forecasts  | Consensus Economics                                                                              | Standard commercial licence         |
| Public replication forecast microdata | Philadelphia Fed SPF; ECB SPF                                                                    | Public downloadable                 |
| Sovereign spreads and total returns   | J.P. Morgan EMBI through Bloomberg/Refinitiv                                                     | Standard commercial licence         |
| Public debt and debt composition      | World Bank QPSD/IDS; IMF WEO                                                                     | Public downloadable                 |
| Real-time macro releases              | National statistical-office archives; IMF WEO historical forecasts for robustness                | Public, manually assembled          |
| Default and restructuring events      | Sovereign default databases used in the literature, cross-checked against official announcements | Published/licensed depending source |

The World Bank QPSD and IDS databases provide downloadable debt stocks, flows, debt service, and public-sector debt components. ([DataBank][4])

## 6. Concrete revisions

1. Separate unconditional theorems from results conditional on income-monotone default.
2. Replace the current abbreviated existence statement with a finite-grid fixed-point argument and numerical convergence tests.
3. Move the long-duration model into the principal quantitative section.
4. Re-estimate the model jointly rather than recalibrating only ((\beta,\phi)).
5. Derive and simulate the exact survey-horizon mapping from (\beta_{CG}) to (\theta).
6. State the rational-zero result as a benchmark-model restriction.
7. Add sovereign bond excess-return evidence.
8. Distinguish sovereign welfare, lender welfare, and global welfare in the fiscal-rule analysis.
9. Report estimation and simulation uncertainty around all headline crisis hazards.

**Assessment confidence:** high on the mathematical and calibration diagnosis; moderately high on the feasible empirical route because the final country coverage depends on the licensed Consensus Economics files.

---

# II. Sanctions Risk and Dollar Convenience

The draft models sanctions exposure as an expected haircut on the liquidity value of dollar reserves. Countries choose dollar holdings in the presence of network-dependent convenience benefits, adjustment costs generate slow portfolio reallocation, and the hegemon faces a rule-versus-discretion problem. 

## 1. Core contribution and economic interpretation

The sanctions wedge,

[
\widehat\pi=\omega \bar s p\phi,
]

is an analytically convenient object. It translates geopolitical risk into the same units as a convenience yield. The aggregation result,

[
N=
\frac{\bar r+\ell_0-\mu\widehat\pi}
{\kappa-\ell_1},
\qquad
m=\frac{1}{1-\ell_1/\kappa},
]

provides an intelligible decomposition between the direct demand response and network amplification.

The contribution must be positioned carefully because the anticipation of financial sanctions reducing dollar convenience and dollar holdings is already established in the literature and has appeared in the *Economic Journal*. ([NBER][5]) The distinct contribution here should be:

> The interaction between sanctions policy rules and the endogenous reserve-currency network, including the distinction between local portfolio responses and aggregate network effects.

The paper should not claim novelty for the sanctions wedge itself.

## 2. Mathematical model

### 2.1 Heterogeneous reserve demand

The cross-sectional cancellation result,

[
a_A-a_E=\frac{\widehat\pi}{\kappa},
]

depends on a common (\kappa), a common network benefit, and binary exposure. With heterogeneous portfolio costs,

[
a_i
===

\frac{\bar r+\ell_i(N)-z_i\widehat\pi_i}{\kappa_i},
]

the network term need not cancel from group comparisons. This matters empirically because trade invoicing, external debt currency, exchange-rate regime, and intervention needs generate substantial cross-country heterogeneity.

The baseline can remain homogeneous for closed-form results, but the paper should add a random-coefficient extension:

[
\kappa_i=\exp(X_i'\beta_\kappa+\eta_i),
\qquad
\ell_i(N)=\lambda_i\ell(N).
]

The corresponding estimand is then an average direct semi-elasticity, not exactly (1/\kappa).

### 2.2 State dependence of sanctions losses

A central bank loses access to reserves precisely in states in which reserve liquidity is unusually valuable. The expected wedge should therefore be more than an actuarially fair expected loss.

A tractable extension is:

[
\widehat\pi_i
=============

\omega p_i\bar s\phi
\frac{u_i'(L_i^{\text{crisis}})}
{u_i'(L_i^{\text{normal}})}.
]

The ratio can be represented by a crisis-liquidity multiplier. This would distinguish a small expected asset loss from a potentially large loss of insurance services. It also gives the empirical analysis a reason to interact sanctions exposure with reserve adequacy, external debt, and import cover.

### 2.3 Local versus global approximation

The linear convenience function is defensible around the current reserve equilibrium. It is not defensible for a counterfactual moving the dollar share from approximately 59 percent to 23.6 percent without additional functional-form evidence.

The paper should explicitly divide the analysis:

* **local theorem and local calibration:** small sanctions reassessment around the observed equilibrium;
* **global scenario:** nonlinear convenience and portfolio costs, used for routine weaponisation.

A bounded specification such as

[
\ell(N)
=======

\ell_{\min}
+
\frac{\ell_{\max}-\ell_{\min}}
{1+\exp[-a(N-\bar N)]}
]

would permit global counterfactuals without treating a first-order approximation as valid near corners.

### 2.4 Time inconsistency

The maximal-discretion result (s_D=1) is driven by the assumption that a realised sanction does not change beliefs about the future rule at the moment of choice. This assumption is in tension with the paper’s motivating idea that each use of sanctions teaches reserve managers something about the rule.

The result should be presented as:

> a no-reputation or fixed-belief discretion benchmark.

It is not a general theorem that discretion necessarily generates maximal sanctions.

The repeated-game section should be integrated more tightly into the main model. A better dynamic formulation would have a public reputation state (r_t):

[
r_{t+1}
=======

\mathcal B(r_t,s_t,\text{crisis characteristics}),
]

where reserve managers update beliefs about future policy. The hegemon’s dynamic problem becomes

[
V(r,N)
======

\max_s
\left{
G(s)+\Omega(N)
+\beta_H
V(r',N')
\right}.
]

A simpler first-draft alternative is to retain the trigger strategy but describe (s_D=1) only as the punishment equilibrium. The Ramsey-versus-trigger comparison then becomes the central commitment result.

### 2.5 Issuer privilege

The expression

[
\Omega(N)=\ell(N)NW
]

implicitly assumes that the issuer captures the entire convenience yield on official dollar reserves. In practice, some convenience benefits accrue to private dollar intermediaries, market makers, and users of the payment system.

Introduce a pass-through parameter:

[
\Omega(N)=\zeta_H,\ell(N)NW,
\qquad 0\leq \zeta_H\leq1.
]

The policy threshold should be reported across a documented range of (\zeta_H). Without this adjustment, dollar-value welfare numbers appear more precise than the underlying economic mapping supports.

## 3. Calibration

The baseline calculations are useful as scenario arithmetic. They should not be presented as estimates because the decisive parameters—target breadth (p), geopolitical stakes (\gamma), exposed mass (\mu), multiplier (m), and adjustment cost—are not jointly estimated.

The quantitative section should distinguish four classes:

1. **directly observed:** aggregate dollar reserve share, world reserves, documented freezes;
2. **externally estimated:** convenience-yield measures and portfolio adjustment persistence;
3. **internally estimated:** direct reserve-demand elasticity and network slope;
4. **scenario parameters:** geopolitical stakes and future sanctions breadth.

The break-even breadth is better reported as a function:

[
p^*
===

p^*(\gamma,\phi,\mu,m,\zeta_H),
]

rather than as a headline point estimate of 2.9 percent. The paper can show contour plots and threshold tables. This is more informative and more honest.

Geopolitical utility (\gamma) cannot be credibly estimated from military expenditures or fiscal aid alone. It should remain a scenario parameter. The paper should invert the model:

> For each empirically estimated portfolio response, what geopolitical benefit would justify the observed sanctions policy?

That is a policy threshold, not a claim to have measured geopolitical welfare.

## 4. Data feasibility and necessary redesign

### 4.1 Country-level COFER must be removed

Country-level currency composition reported to the IMF is strictly confidential. Access is restricted even within the IMF, and only aggregate COFER series are published. ([IMF Data][6])

Therefore, no empirical design may require country-level COFER data.

The aggregate COFER series remains usable for global dynamics and is publicly available quarterly. ([IMF Data][7])

### 4.2 Feasible country-level outcomes

The primary country-level outcome should be:

[
\frac{\text{country }i\text{ holdings of U.S. Treasury securities}}
{\text{country }i\text{ total official reserves}}.
]

The numerator can be constructed from U.S. Treasury TIC holdings and transactions; the denominator can come from IMF reserve data or national sources. TIC is public and contains country-level files, including downloadable country transaction series. ([U.S. Department of the Treasury][8])

However, TIC is primarily custody based and cannot perfectly attribute holdings to ultimate beneficial owners. The Treasury explicitly warns about this limitation. ([U.S. Department of the Treasury][9]) The empirical design must therefore:

* exclude or separately treat major custodial centres;
* report results with and without Belgium, Luxembourg, Ireland, the Caribbean centres, and other custody hubs;
* avoid interpreting TIC holdings as exact reserve-currency shares;
* use disclosed national reserve reports as validation only.

Publicly disclosed currency compositions from individual central-bank reports may be assembled, but this will be a selected sample. Selection must be reported rather than ignored.

### 4.3 Sanctions and alignment data

The following inputs are obtainable:

| Object                              | Dataset                                                | Access              |
| ----------------------------------- | ------------------------------------------------------ | ------------------- |
| Aggregate currency composition      | IMF COFER                                              | Public aggregate    |
| Country Treasury holdings and flows | U.S. Treasury TIC                                      | Public              |
| Total reserves                      | IMF data; national central banks                       | Public              |
| Sanction events and types           | Global Sanctions Data Base, Release 4                  | Public upon request |
| Official post-2023 measures         | OFAC, EU, UK official sanctions lists                  | Public              |
| Geopolitical alignment              | UN voting and ideal-point datasets                     | Public              |
| U.S. Treasury and corporate yields  | FRED/Treasury; Bloomberg/Refinitiv for richer measures | Public or licensed  |

GSDB Release 4 covers global sanctions through 2023 and is obtainable from the project. ([globalsanctionsdatabase.com][10]) UN voting records and ideal-point data are publicly downloadable. ([Dataverse][11])

### 4.4 Main portfolio design

The main design should be a country-month or country-quarter panel:

[
\Delta
\left(
\frac{UST_{it}}{Reserves_{it}}
\right)
=======

\alpha_i+\tau_t+
\beta
\left(
Post_t\times Exposure_i
\right)
+
\Gamma'X_{it}
+\varepsilon_{it}.
]

Exposure should be predetermined using:

* pre-2022 geopolitical alignment;
* historical sanctions incidence;
* reserve adequacy;
* external debt currency;
* trade invoicing where obtainable.

Directly sanctioned countries must be separated from non-target countries. For directly sanctioned countries, observed holdings may decline mechanically because assets are frozen or reclassified. The anticipation channel is best studied among non-target countries whose perceived risk changes but whose assets are not confiscated.

A continuous exposure design is preferable to a binary aligned/exposed classification.

### 4.5 Aggregate network multiplier

A single aggregate COFER time series cannot separately identify the network multiplier from:

* exchange-rate valuation;
* relative reserve-asset returns;
* reserve accumulation;
* gold purchases;
* monetary policy;
* Treasury supply;
* global risk aversion.

The paper should estimate bounds rather than claim precise identification from one event.

A feasible strategy is to combine:

1. valuation-adjusted aggregate COFER;
2. multiple sanctions episodes;
3. country-level TIC portfolio responses;
4. convenience-yield measures;
5. externally timed reserve-demand shocks.

The aligned-country response is potentially informative: countries with little direct sanctions exposure may nevertheless reduce Treasury holdings when the network’s value declines. But this result is not unique to network effects because common portfolio and monetary shocks can produce the same movement. It must be supported by differential exposure to network-dependent uses of the dollar, such as dollar invoicing or dollar liabilities.

### 4.6 Convenience-yield design

The baseline Treasury–AAA spread is easy to construct but is not a pure reserve convenience yield. The paper should use several measures:

* Treasury versus high-grade corporate spreads;
* Treasury versus agency spreads;
* currency-hedged safe-asset differentials;
* cross-currency basis measures from licensed financial data.

The predicted effect is small relative to daily variation. Estimation should therefore focus on:

* low-frequency regime changes;
* distributed lags;
* dollar-relative-to-euro or dollar-relative-to-yen measures;
* external instruments for reserve demand.

## 5. Policy interpretation

The paper should distinguish three statements:

1. an individual freeze can be geopolitically worthwhile despite a small network cost;
2. repeated broad use reduces the dollar network;
3. a discretionary government may overuse sanctions relative to a rule.

The first two are robust qualitative implications. The third requires a particular belief and reputation structure.

The “sanctions Laffer curve” terminology is intuitive, but the object is not tax revenue. “Weaponisation frontier” or “sanctions-use frontier” would be more precise.

## 6. Concrete revisions

1. Remove all reliance on country-level COFER.
2. Make TIC/reserves the main country-level outcome and disclose its custody limitations.
3. Separate local comparative statics from global routine-use counterfactuals.
4. Introduce heterogeneous portfolio costs and network dependence.
5. Add crisis-state liquidity value to the sanctions wedge.
6. Recast maximal discretion as a fixed-belief benchmark.
7. Incorporate reputation or belief updating into the dynamic policy problem.
8. Add an issuer pass-through parameter to the privilege calculation.
9. Treat geopolitical stakes as a scenario parameter and report threshold functions.
10. Estimate or bound the network multiplier using several moments, not a single aggregate trend.

**Assessment confidence:** high regarding the mathematical and data-feasibility issues; high regarding the impossibility of using country-level COFER under normal research access.

---

# III. Endogenous Trade Fragmentation

The draft develops a model in which firm sourcing decisions are strategically complementary. Firms that leave cross-bloc supply relationships reduce the amount of trade that deters escalation, thin trade infrastructure, and expand friendly production capacity. These channels can produce amplification, multiple equilibria, folds, hysteresis, and a state-dependent policy wedge. 

## 1. Core contribution and economic interpretation

The most valuable mechanism is not fragmentation in general. It is the feedback:

[
\text{friend-shoring}
\rightarrow
\text{less remaining cross-bloc surplus}
\rightarrow
\text{weaker deterrence}
\rightarrow
\text{higher disruption risk}
\rightarrow
\text{more friend-shoring}.
]

The decomposition of the threshold derivative into deterrence erosion, route thinning, and capacity scale is analytically useful because the channels imply different empirical moments and different policies.

The novelty claim must be revised. Recent work already embeds diplomatic escalation in quantitative trade models and shows that de-risking can reduce the opportunity cost of conflict and raise escalation risk. ([cepii.fr][12])

The distinct contribution should therefore be:

> Decentralised firm sourcing converts the trade–conflict relation into a private externality, potentially creating sector-level folds, hysteresis, and a policy wedge that changes sign across equilibrium branches.

That is sufficiently different from an aggregate bilateral trade-and-war model.

## 2. Mathematical model

### 2.1 Escalation probability

Under a general distribution (F_B) of political benefits, the escalation probability should be written as

[
\pi_m(F_m,F)
============

\delta_m
\left[
1-
F_B
\left(
C_m(F_m,F)
\right)
\right],
]

where (C_m) is the trade surplus destroyed by escalation.

Then

[
\frac{\partial \pi_m}{\partial F_m}
===================================

\delta_m f_B(C_m)
\left(
-\frac{\partial C_m}{\partial F_m}
\right)>0
]

when remaining trade raises the cost of escalation. This shows that strategic complementarity does not depend on a uniform distribution. The linear expression can then be identified as a convenient calibration case.

### 2.2 Fold theorem

The condition

[
\max_F T_m'(F)>1
]

is not sufficient by itself to establish a three-equilibrium region or a fold bifurcation. A monotone map can have slope above one without crossing the 45-degree line three times.

Define

[
G(F,\delta)=T(F,\delta)-F.
]

A fold at ((F^*,\delta^*)) requires:

[
G(F^*,\delta^*)=0,
]

[
G_F(F^*,\delta^*)=0,
]

[
G_{FF}(F^*,\delta^*)\neq0,
]

[
G_\delta(F^*,\delta^*)\neq0.
]

The paper should state the saddle-node theorem under these nondegeneracy conditions. To obtain an interval with three equilibria, additional global conditions must ensure that the map crosses the diagonal on both sides of the unstable fixed point.

Similarly, the statement that fixed points are generically finite, odd in number, and alternate in stability requires a transversality or genericity argument. It is not true for every continuous increasing map.

### 2.3 Multisector multiplier

The quantitative model has multiple sectors coupled through aggregate fragmentation. The correct local multiplier is therefore a matrix:

[
d\mathbf F
==========

\left(I-J_T\right)^{-1}
T_z,dz,
]

where (J_T) is the Jacobian of sectoral best responses.

Local stability requires

[
\rho(J_T)<1,
]

where (\rho(\cdot)) is the spectral radius. The scalar expression

[
M_m=\frac{1}{1-\Phi_m'}
]

is exact only in a one-sector or conditionally decoupled case.

The full draft should report:

* the largest eigenvalue of the calibrated Jacobian;
* sector-specific direct responses;
* cross-sector spillovers;
* the contribution of the systemic term (\eta_a).

Approach to a system-wide fold should be diagnosed by the leading eigenvalue approaching one.

### 2.4 Hysteresis and expectations

The transition law

[
F_{m,t+1}
=========

(1-\rho)F_{m,t}
+
\rho T_m(F_{m,t},F_t,\delta_t)
]

is a partial-adjustment or adaptive-dynamics selection rule. It generates basin dependence, but it does not establish that fully forward-looking firms must select the same path.

The draft should distinguish:

* **static multiplicity:** several sourcing equilibria at the same fundamentals;
* **dynamic hysteresis under partial adjustment:** the state crosses the unstable fixed point;
* **expectational selection:** firms coordinate on a high or low branch based on future beliefs;
* **physical irreversibility:** sunk supplier investments or relationship capital.

The current result is valid under the chosen partial-adjustment process. It should not be described as independent of the dynamic selection mechanism.

A useful robustness exercise would solve a forward-looking discrete-choice problem with switching costs:

[
V_i^C(F_t,\delta_t)
\quad\text{and}\quad
V_i^S(F_t,\delta_t),
]

and determine whether the same basin structure remains under rational expectations.

### 2.5 Welfare and policy

The Pigouvian wedge is economically interesting, but the sign result depends on the planner’s objective. The baseline counts:

* sourcing premia;
* expected disruption losses;
* the deterrence externality;
* the capacity externality.

It does not fully include:

* wartime security value;
* asymmetric dependence;
* technology transfer;
* strategic leakage;
* bargaining leverage;
* foreign welfare;
* terms-of-trade changes;
* fiscal costs of subsidies and stockpiles.

The paper should present the policy result as a threshold condition. Let (v_m) denote the social value of independence. Then the maintenance subsidy is positive when

[
\tau_m^{\text{deterrence}}
+
\tau_m^{\text{thinning}}

>

\tau_m^{\text{capacity}}
+
v_m.
]

This is more defensible than a universal statement that friend-shoring subsidies have the wrong sign.

The state-dependent sign reversal remains valuable: the same policy may be inappropriate on the low-fragmentation branch and appropriate after the deterrence value of remaining trade has largely disappeared.

## 3. Calibration

The headline distance to the fold depends on several uncertain parameters:

[
\theta,\quad \xi,\quad \chi,\quad
H_m,\quad \lambda_m^0,\quad \delta_m.
]

Because the fold is a nonlinear object, one-at-a-time sensitivity analysis is inadequate. The paper should propagate joint parameter uncertainty.

The relevant output is not only a point such as “66 percent of the distance has been consumed,” but:

[
\Pr!\left(
\delta_{\text{current}}
\geq \delta^*_{\text{fold}}
\mid \widehat\Theta
\right),
]

or, in a non-Bayesian implementation, a confidence region for (\delta^*_{\text{fold}}).

At the first-draft stage, the current values may remain as scenarios, but every table and figure should identify them as such.

The loss formula

[
\lambda_m^0=
\left[
(1-s_m)^{1/(1-\sigma_m)}-1
\right]D_m
]

is transparent but strong. It assumes that the relevant input share disappears, that the CES aggregator applies at the stated level, and that no emergency substitution occurs during the disruption. Empirical estimates of short-run substitution should be used, not long-run trade elasticities.

## 4. Fully feasible data architecture

The draft can be executed without confidential firm-level customs data, but the unit of observation must be changed from a literal firm–supplier link to an importer–exporter–HS6 relationship.

### 4.1 Public core data

| Object                                    | Dataset                       | Access              |
| ----------------------------------------- | ----------------------------- | ------------------- |
| Bilateral HS6 trade values and quantities | CEPII BACI                    | Public downloadable |
| Input-output shares                       | OECD ICIO/TiVA                | Public downloadable |
| Import dependency and concentration       | CEPII GeoDep                  | Public downloadable |
| Applied tariffs                           | CEPII MAcMap-HS6              | Public downloadable |
| Sanction cases                            | GSDB Release 4                | Public upon request |
| UN alignment                              | UN voting/ideal points        | Public              |
| Maritime disruptions                      | IMF PortWatch                 | Public downloadable |
| Aggregate conflict or dispute events      | Public MID/UCDP-type datasets | Public              |
| Trade price indices and unit values       | CEPII TradePrices/BACI        | Public              |

BACI provides annual bilateral data for approximately 200 countries at the HS6 level. ([cepii.fr][13]) OECD ICIO provides harmonised international input-output flows. ([OECD][14]) CEPII GeoDep already provides public measures of product-level import dependence, concentration, substitutability, and persistent dependency. ([cepii.fr][15]) PortWatch is an open IMF platform with downloadable maritime-disruption data. ([PortWatch][16])

### 4.2 Direct switching design

Define a cross-bloc relationship at the importer–exporter–HS6 level:

[
Link_{ijpt}
===========

\mathbf 1{Trade_{ijpt}>\underline v}.
]

Exit and re-entry hazards can then be measured without firm identifiers. The empirical language must reflect that these are product-country sourcing relationships, not firm–supplier links.

A triple-difference design is feasible:

[
TradeShare_{ijpt}
=================

\alpha_{ijp}
+\alpha_{ipt}
+\alpha_{jpt}
+
\beta,
Post_t
\times GeoDistance_{ij}
\times Criticality_{ip}
+\varepsilon_{ijpt}.
]

Criticality must be constructed using pre-event information only. The 2018 tariff episode can be used as a comparison, but it is not a perfect placebo because tariffs themselves can induce supply-chain investment and persistence.

### 4.3 Premium distribution

Unit values are noisy measures of sourcing premia because they combine quality, product mix, markups, and transportation costs.

A more defensible measure is the within-importer-product difference between incumbent cross-bloc and alternative aligned suppliers:

[
g_{ijpt}
========

## \log UV^{aligned}_{ipt}

\log UV^{cross}_{ijpt},
]

with:

* importer-product-year fixed effects;
* exporter-product fixed effects;
* trimming of small quantities;
* separate treatment of quality ladders;
* robustness using CEPII trade-price indices.

The distribution (H_m) can then be estimated from these relative cost gaps rather than imposed as lognormal without evidence.

### 4.4 Capacity-scale effect

Estimate whether alternative-supplier prices fall with cumulative reallocation:

[
\log UV^{aligned}_{jpt}
=======================

\alpha_{jp}+\tau_t+
\chi
\log CapacityDemand_{jpt}
+\varepsilon_{jpt}.
]

A shift-share instrument can use demand shifts from third-country importers:

[
Z_{jpt}
=======

\sum_{k\neq i}
w_{kjp,0},
GeoShock_{kt}.
]

This is feasible with BACI, though the exclusion restriction must be defended carefully because global product shocks may affect prices directly.

### 4.5 Route-thinning effect

The route-thinning parameter should not be inferred only from unit values. A feasible design can use PortWatch and trade relationships around identifiable maritime disruptions:

[
RecoveryTime_{ijpt}
===================

\alpha_{ip}+\alpha_j+
\beta_1 CorridorThickness_{ijpt-1}
+\Gamma'X_{ijpt}
+\varepsilon_{ijpt}.
]

Corridor thickness may be measured by:

* active exporter count;
* pre-disruption shipment value;
* alternative-route capacity;
* number of supplier countries.

This provides a direct empirical analogue of the loss-duration channel.

### 4.6 Deterrence channel

GSDB contains sanctions cases but generally not a complete product-level sequence of every geopolitical dispute and its escalation. The deterrence equation should therefore be estimated at the dyad-year level:

[
Pr(Escalation_{ij,t}=1
\mid Dispute_{ij,t}=1)
======================

\Lambda
\left(
\alpha_{ij}+\tau_t
+\beta,PredictedTradeExposure_{ij,t-1}
+\Gamma'X_{ij,t-1}
\right).
]

Trade exposure is endogenous to political relations. Use gravity-predicted trade or historical trade determinants rather than contemporaneous realised trade. The model assumes dispute arrival is exogenous; empirically, conditioning on observed disputes helps align the estimation with that assumption.

Sector-specific deterrence parameters should not be claimed unless a sufficiently rich product-level export-control dataset is actually assembled from public official lists.

## 5. Empirical identification

The 2022 event combines invasion, sanctions, export controls, commodity shocks, freight shocks, industrial policy, and monetary tightening. A single post-2022 coefficient cannot identify the model.

The empirical section should use several layers:

1. broad post-2022 descriptive reallocation;
2. relationship exit and re-entry;
3. independently estimated deterrence;
4. capacity-price response;
5. disruption-recovery evidence;
6. structural estimation of the fixed-point map.

The paper’s major structural claim—distance to the fold—should be estimated only after the component parameters have been disciplined separately.

## 6. Concrete revisions

1. Replace the current fold condition with the standard saddle-node nondegeneracy conditions.
2. Derive the multisector Jacobian multiplier and spectral-radius stability condition.
3. Separate adaptive-dynamics hysteresis from forward-looking equilibrium selection.
4. Restate the policy result as a threshold condition incorporating the value of independence.
5. Treat all current fold distances as scenario calculations pending estimation.
6. Use importer–exporter–HS6 relationships rather than unobservable firm links.
7. Estimate (H_m), (\chi), (\xi), and the deterrence relation using separate public-data moments.
8. Use joint parameter uncertainty for fold probabilities.
9. Reposition the paper relative to the recent trade–escalation literature.
10. Preserve the sectoral focus: aggregate trade is not the appropriate unit for identifying a fold.

**Assessment confidence:** high on the theorem corrections and literature positioning; moderately high on the empirical plan because sector-level escalation measurement remains the most difficult observable.

---

# IV. Ambiguity, Investor Composition, and Sovereign Rollover Crises

The draft introduces heterogeneous ambiguity about official-signal bias into a sovereign rollover global game. Ambiguity acts as a pessimistic signal shift, investor composition changes the crisis threshold, and precision and credibility have different effects on rollover stability. 

## 1. Core contribution and interpretation

The central analytical result,

[
x_k^*
=====

x_B^*(\theta^*)
+
\frac{\alpha}{\beta}\delta_k,
]

is clear and economically interpretable. Distrust matters more when investors rely heavily on the public signal relative to their private information.

The contribution should be framed as:

> Investor composition determines how losses of official credibility are amplified through the unique rollover threshold.

That is stronger than presenting ambiguity alone as the novelty. Multiple-prior global games and debt-rollover applications already exist, including recent work distinguishing ambiguous information from merely noisy information. ([IDEAS/RePEc][17])

The paper-specific elements are:

* heterogeneous ambiguity across holder types;
* investor composition as a state;
* the precision-versus-credibility distinction;
* empirical interaction restrictions.

## 2. Mathematical model

### 2.1 Model-free exit assumption

The as-if pessimism theorem relies on the runner receiving a payoff independent of the unknown official-signal bias. This is a strong but transparent assumption.

The paper should add a robustness result in which both rollover and exit payoffs depend on fundamentals:

[
U^R(\theta,b),
\qquad
U^X(\theta,b).
]

The worst-case distortion then depends on relative exposure:

[
\frac{\partial U^R}{\partial b}
-------------------------------

\frac{\partial U^X}{\partial b}.
]

If rollover is more negatively exposed to official overstatement than exit, ambiguity still raises the run cutoff, but the loading need not be exactly (\alpha\delta/\beta).

This extension would show that the baseline theorem is a limiting clean case rather than a knife-edge artefact.

### 2.2 Ambiguity versus pessimism

Under the baseline assumptions, a multiple-prior creditor behaves exactly like a Bayesian creditor who observes (y-\delta_k). Consequently, market behaviour alone cannot distinguish:

* max-min ambiguity;
* a pessimistic prior;
* distrust of official statistics;
* a biased subjective signal.

The paper should acknowledge this observational equivalence. Its empirical interpretation is therefore “distrust-equivalent pessimism,” unless separate evidence identifies ambiguity attitudes.

The multiple-prior interpretation remains valuable because it generates a disciplined response to uncertainty about bias, but the empirical section should not claim to measure ambiguity preferences directly from spreads.

### 2.3 Uniqueness

The uniqueness condition

[
\frac{\alpha}{\sqrt{\beta}}
<
\sqrt{2\pi}
]

is correctly independent of (\delta_k) because ambiguity translates the arguments of the normal cdfs without changing the maximum possible slope.

The proof should distinguish:

* uniqueness of the fixed point in threshold strategies;
* uniqueness among monotone strategies;
* possible non-monotone equilibria, if relevant.

The paper should also report the local slope

[
\Phi'
=====

\frac{\alpha}{\sqrt{\beta}}
\sum_k
\mu_k
\phi!\left(
g+\frac{\alpha}{\sqrt{\beta}}\delta_k
\right),
]

rather than only its upper bound. This is the coordination multiplier’s actual empirical target.

### 2.4 Composition comparative statics

The positive effect of fragile-holder share on the crisis threshold is robust when the fragile type has a larger run propensity. The cross-derivative with respect to (\mu) and (\delta), however, is not globally positive; the draft already conditions it on the relevant side of the density.

The headline language should preserve that qualification. “Distrust and fragile composition reinforce each other in the empirically relevant marginal-creditor region” is accurate. “They always reinforce” is not.

### 2.5 Precision

The result that more public precision can destabilise after bad news is a comparative static holding the realised public signal (y) fixed. It should not be interpreted as an ex ante result that less accurate official statistics are socially desirable.

The paper should add an ex ante calculation:

[
\mathbb E_y
\left[
Loss(\theta^*(y,\alpha,\delta))
\right].
]

This would distinguish:

* ex post threshold effects conditional on a bad announcement;
* ex ante welfare effects of improving information quality;
* credibility improvements that reduce (\delta).

The policy conclusion should be “credibility is unconditionally stabilising within the model, while the ex post effect of precision depends on the content of the signal,” not “governments should avoid precision in distress.”

### 2.6 Holder types

Domestic banks and official holders should not all be assigned zero run margins. Domestic banks may have regulatory incentives to hold debt, but they also face mark-to-market losses, liquidity needs, and sovereign-bank feedback.

The heterogeneous-payoff extension currently in the appendix should be moved closer to the baseline:

[
\bar p_k
========

\frac{R_k-(1-\kappa_k)}
{R_k-\underline R_k}.
]

Types should differ in both:

* payoff/run sensitivity (\bar p_k);
* distrust (\delta_k).

This is necessary because observed investor categories will combine these two dimensions.

## 3. Calibration

The payoff block is reasonably anchored, but the information block remains scenario based. The current 18bp and 98bp ambiguity premia should therefore be labelled calibrated scenarios, not estimated magnitudes. 

The calibration should be reorganised around observable moments:

* recovery rates and haircuts;
* market yields and exit discounts;
* forecast dispersion;
* response of private forecasts to official releases;
* revisions in fiscal data;
* holder composition;
* spread response around credibility events.

The information precisions ((\alpha,\beta)) can be estimated using individual forecast data. For example, in an individual forecast panel:

[
Forecast_{j,t}
==============

w_P PublicSignal_t
+
w_X PrivateComponent_{j,t},
]

with

[
\frac{w_P}{w_X}
===============

\frac{\alpha}{\beta}.
]

The ECB SPF provides downloadable individual microdata and is therefore a particularly useful public source for the euro-area implementation. ([European Central Bank][18])

The radius (\delta) should not be fitted solely to spreads. It can be disciplined by the distribution of real-time fiscal revisions and then validated using spreads.

## 4. Fully obtainable data plan

### 4.1 Investor composition

The original Arslanalp–Tsuda dataset is publicly associated with the paper and contains quarterly investor-base estimates for 24 emerging markets through the original sample period. ([IMF][19]) It is suitable for historical analysis but should not be presented as a complete current post-2022 panel unless an updated public file is actually secured.

For the euro area, the ECB Data Portal provides public government-debt statistics with creditor-sector breakdowns. ([ECB Data Portal][20]) This supports a feasible euro-area panel with:

* central-bank holdings;
* domestic financial institutions;
* nonresident holdings;
* other sectoral holders.

The exact classification must be matched to the model; “fragile” cannot simply be equated with “foreign.”

### 4.2 Fiscal revision histories

The IMF now provides a historical WEO forecast archive, including past projections across vintages. ([IMF Data][21]) This allows construction of:

[
Revision_{i,t}^{(h)}
====================

## Forecast_{i,t}^{(h)}

Forecast_{i,t-1}^{(h)}.
]

For EU countries, Eurostat government deficit and debt releases and revision notes are public and dated. ([European Commission][22])

A distrust proxy can be based on:

* cumulative absolute revisions;
* unusually one-sided revisions;
* formal statistical-integrity events;
* differences between preliminary and final fiscal data.

Routine forecast revisions and documented credibility failures should be treated separately.

### 4.3 Transparency and credibility reforms

IMF SDDS and SDDS Plus subscription dates are public. ([DSBB][23]) Annual observance reports also document timeliness and compliance. These data can support event studies, although adoption is endogenous.

Useful distinctions are:

* **precision/timeliness reforms:** more frequent publication, shorter release lags;
* **credibility reforms:** independent fiscal councils, audit reforms, documented statistical-governance changes;
* **negative credibility shocks:** large undisclosed revisions or official integrity investigations.

The paper should avoid using a single index for all three.

### 4.4 Spreads and auction outcomes

For a euro-area panel, public ECB yield data can be used. For emerging markets, EMBI or Bloomberg sovereign yields are obtainable through normal institutional subscriptions.

Auction microdata are unevenly available across national debt-management offices. The project should not rely on confidential bidder identities or internal bid-level files.

A feasible auction component is a set of public country case studies using published:

* bid-to-cover ratios;
* accepted amounts;
* cut-off yields;
* maturity;
* auction dates.

These can be manually collected from national debt-management agencies. They should supplement, not determine, the main panel.

### 4.5 Data table

| Object                           | Feasible source                                            | Access                        |
| -------------------------------- | ---------------------------------------------------------- | ----------------------------- |
| Euro-area holder composition     | ECB Data Portal creditor-sector government-debt statistics | Public                        |
| Historical EM holder composition | Arslanalp–Tsuda original dataset                           | Public                        |
| Fiscal forecast revisions        | IMF WEO historical forecasts                               | Public                        |
| EU fiscal revisions              | Eurostat releases and revision notes                       | Public                        |
| SDDS adoption and observance     | IMF DSBB                                                   | Public                        |
| Individual forecast microdata    | ECB SPF; Consensus Economics for broader countries         | Public or licensed            |
| Sovereign yields                 | ECB public data; EMBI/Bloomberg for broader sample         | Public or licensed            |
| Auction aggregates               | National debt-management offices                           | Public but manually assembled |

No internal Eurosystem purchase data, confidential auction bids, or private holder-level portfolios are required.

## 5. Econometric design

### 5.1 Core interaction panel

The main test should be:

[
\Delta s_{it}
=============

\alpha_i+\tau_t+
\beta_1D_{it}\mu_{it}
+
\beta_2D_{it}\mu_{it}Stress_{it}
+
\Gamma'X_{it}
+\varepsilon_{it}.
]

Here:

* (D_{it}) is a predetermined revision-based credibility measure;
* (\mu_{it}) is holder composition;
* (Stress_{it}) is constructed from lagged debt service, liquid buffers, maturity structure, and primary-balance forecasts.

The level effects of (D) and (\mu) should also be included. The model predicts interaction effects but does not imply they can be omitted.

Composition is endogenous to spreads. Possible instruments available through normal data access include:

* index inclusion and rebalancing;
* rating-threshold eligibility changes;
* central-bank purchase eligibility rules;
* predetermined maturity runoff interacting with announced reinvestment policy.

The paper should implement only instruments whose data are actually acquired and whose institutional rule is verifiable.

### 5.2 Credibility versus precision events

The distinction is promising but requires event classification before examining spread outcomes.

Each event should be coded along separate dimensions:

[
Event_e
=======

(Credibility_e,\ Precision_e,\ News_e).
]

Then estimate:

[
\Delta s_{i,e}
==============

\beta_C Credibility_e
+
\beta_P Precision_e
+
\beta_N News_e
+
\beta_{PS}Precision_e\times Stress_{i,e-1}
+\varepsilon_{i,e}.
]

An IMF review or fiscal-council adoption may affect both credibility and expected fiscal policy. The paper should not assume that institutional events are pure information shocks.

### 5.3 Structural inversion

An implied (\widehat\delta_{it}) from spreads can be useful, but it must be treated as a model-based residual. It should be computed only after controlling for:

* expected default losses;
* liquidity;
* global risk;
* maturity;
* currency;
* political risk.

Validation must be out of sample:

* does (\widehat\delta) rise around documented credibility failures?
* does it decline following sustained accurate reporting?
* does it forecast disagreement or auction outcomes not used in the inversion?

Without such validation, (\widehat\delta) simply renames unexplained spreads.

## 6. Policy analysis

The QT experiment should remain a model counterfactual unless a clean composition shock is identified. Central-bank runoff changes more than holder composition: duration supply, liquidity, monetary policy expectations, and bank balance sheets may all move.

CACs and official backstops can remain structural counterfactuals. The paper should be explicit that:

* recovery improvements alter payoff thresholds;
* backstops may reduce worst-case losses only if activation is sufficiently credible;
* discretionary backstops can themselves be ambiguous.

## 7. Concrete revisions

1. State the observational equivalence between ambiguity and pessimistic signal bias.
2. Generalise the model-free-exit theorem to partially state-dependent exit payoffs.
3. Move heterogeneous payoff thresholds into the main model.
4. Add ex ante welfare analysis of precision.
5. Estimate (\alpha/\beta) from public or licensed individual forecast data.
6. Construct (\delta) from real-time revision histories before using spreads.
7. Use public ECB holder-sector data for the current euro-area panel.
8. Use the historical Arslanalp–Tsuda data only for the period actually covered.
9. Make public auction aggregates an optional validation exercise, not a required global dataset.
10. Validate any structurally inverted distrust index out of sample.

**Assessment confidence:** high on the theoretical qualifications and data plan; moderate on causal identification of holder-composition effects because portfolio composition remains intrinsically endogenous.

---

# V. Narrative Contagion at the Sovereign Default Boundary

The paper combines a sovereign default-probability curve, a narrative prevalence process, and a spread-to-fundamentals feedback. The primitive pricing effect is hump-shaped near the default boundary, while a behavioural adoption rule makes narrative contagion inherit that state dependence. 

## 1. Core contribution and positioning

The paper’s strongest idea is:

> A fixed pessimistic belief distortion has little value for a safe sovereign or an already-condemned sovereign, but substantial price relevance near the default boundary.

This follows from

[
G(z)
====

\Phi(z+\Delta)-\Phi(z),
]

the probability mass lying between the uninfluenced and narrative-shifted default thresholds.

The novelty must be located relative to the existing narrative-macro literature. Flynn and Sastry already model narratives as contagious beliefs that can go viral and create persistent macroeconomic effects in a unique equilibrium. ([NBER][24]) The new object here is not epidemic narrative dynamics by itself, but:

* default-boundary state dependence;
* sovereign spread pricing;
* debt-service feedback;
* policy interventions that alter narrative relevance.

## 2. Mathematical model

### 2.1 Within-period spread equilibrium

The contraction condition

[
\frac{(1-R)\chi}
{\sigma\sqrt{2\pi}}
<1
]

is sufficient for a unique spread fixed point. This is a clean result.

The draft should distinguish the annual probability model from the monthly transition model more carefully. Currently, monthly fundamentals evolve while annual default probability is inserted into a monthly spread-feedback process. The annual-to-monthly mapping of ((\rho,\sigma,\chi)) should be made explicit and tested numerically.

### 2.2 Primitive pricing hump versus equilibrium hump

The primitive belief gap

[
G(z)=\Phi(z+\Delta)-\Phi(z)
]

is log-concave and single-peaked, with maximum at (z=-\Delta/2).

The equilibrium price impact is

[
\frac{\partial s^*}{\partial n}
===============================

(1-R)G(z^*)M(\theta,n),
]

where (M) is the doom-loop multiplier.

A bounded positive multiplier does not, by itself, guarantee that the product of (G) and (M) remains single-peaked. The current result is therefore partly theoretical and partly a calibrated regularity.

The paper should split the proposition:

**Theorem.** The primitive direct pricing effect is single-peaked.

**Sufficient-condition proposition.** The equilibrium price effect remains single-peaked when the loop gain and narrative shift satisfy stated derivative restrictions.

**Calibration result.** Those restrictions hold over the reported parameter region.

This avoids calling a numerical regularity a theorem from one primitive.

### 2.3 Contagion assumption

The contagion result follows from:

[
\beta(\theta,n)
===============

\bar mA,h!\left(
\frac{\partial s^*}{\partial n}
\right).
]

This is the most important assumption in the paper. It should receive a more explicit microfoundation.

One possible foundation is costly attention or strategy adoption. An investor adopts and transmits the narrative if the expected trading or decision value exceeds an idiosyncratic cost (c_i):

[
c_i
\leq
\lambda
\left|
\frac{\partial s^*}{\partial n}
\right|.
]

If (c_i\sim H_c), then

[
h(v)=H_c(\lambda |v|).
]

This does not make belief adoption fully rational, but it translates the reduced-form contagion function into an observable distribution of attention or communication costs.

The paper should continue to treat decision-relevant adoption and perceived-mispricing adoption as competing hypotheses.

### 2.4 Discrete versus continuous epidemic dynamics

The discrete equation

[
n_{t+1}-n_t
===========

\beta n_t(1-n_t)-\gamma n_t
]

requires parameter restrictions to keep (n_t\in[0,1]). A continuous-time formulation is analytically cleaner:

[
\dot n_t
========

\beta(\theta_t,n_t)n_t(1-n_t)
-\gamma n_t.
]

The monthly simulation can remain a discretisation of this system. This would make the reproduction-number and outbreak-delay expressions exact rather than approximate discrete-time analogues.

### 2.5 Moving-cliff result

The increase of the instantaneous zero-drift boundary with narrative prevalence follows from the increase of (s^*(\theta,n)) in (n). But a zero-drift locus is not automatically a global basin boundary.

To prove that seeded and unseeded paths converge to different outcomes, the paper needs:

* existence and uniqueness of the zero-drift crossing;
* sign conditions on either side;
* invariance of the default basin;
* interaction with the hump-shaped contagion rate;
* control of the fact that contagion may weaken again when fundamentals become extremely poor.

The current statement should therefore be divided:

* monotonicity of the instantaneous drift boundary: analytical;
* existence of a critical seeded-default interval: conditional on global phase-diagram assumptions;
* month-42 default example: calibrated simulation.

A phase portrait of ((\theta,n)) with nullclines and vector fields would substantially improve the paper.

### 2.6 Debt-service feedback

Setting (\chi) equal to gross financing needs overstates pass-through when:

* debt has long fixed-rate maturity;
* only part of the stock is refinanced;
* official loans are insulated from market spreads;
* cash buffers absorb temporary stress;
* primary balances adjust;
* coupons and principal have different timing.

A better mapping is:

[
\chi_{it}
=========

RefinancingShare_{it}
\times
MarketRatePassThrough_{it}
\times
FiscalCapacityConversion_{it}.
]

All three factors can be calibrated from public debt and fiscal data. The model can retain a scalar (\chi), but its empirical construction must reflect actual debt cash flows.

### 2.7 Spread cap

A perfectly credible cap sets the marginal price response to narrative prevalence to zero only for the capped instrument. Narratives may continue to affect:

* CDS spreads;
* longer maturities;
* auction quantities;
* capital flight;
* bank funding;
* political outcomes.

The theoretical cap result is valid within the model, but the policy interpretation should be “sterilises the modelled sovereign-spread channel,” not “eliminates the narrative.”

OMT also changed tail-risk insurance and the expected policy regime, not merely communication. ECB research finds that OMT announcements reduced Italian and Spanish two-year yields by about two percentage points. ([European Central Bank][25]) The event is useful, but it cannot be treated as a pure test of narrative deletion.

## 3. Calibration

The current epidemic parameters are scenario inputs:

[
R_0^{\max}=4,\qquad
\xi=0.03,\qquad
n_0=0.02,\qquad
\gamma=0.30.
]

Consequently, the 229bp price effect, 5.2 percentage-point default wedge, and 17 percentage-point annual delay cost are scenario outputs. That is acceptable for a first draft, provided the wording is explicit.

The quantitative section should eventually estimate:

* narrative decay (\gamma) from episode half-lives;
* diffusion rate from cross-outlet propagation;
* narrative bite (\xi) from belief or forecast responses;
* text-to-latent-prevalence loading;
* spread-feedback parameter (\chi) from debt cash-flow exposure;
* initial seed from the observed onset of a narrative episode.

The model should report uncertainty bands for the susceptible and critical regions.

## 4. Measurement: feasible data only

The draft should remove all dependence on unavailable platform-level diffusion data and literal wealth-weighted investor prevalence.

### 4.1 Text corpus

The main corpus can use GDELT 2.1. GDELT is fully open and provides downloadable global media data and BigQuery access. ([GDELT Project][26])

For historical depth and article-level validation, Factiva or LexisNexis can be used through standard institutional licences. Factiva covers a large multilingual global news archive and is a commercially obtainable product. ([dowjones.com][27])

The empirical design should not require:

* private messaging data;
* restricted social-platform archives;
* investor chat logs;
* wealth-weighted social networks;
* confidential news-consumption data.

### 4.2 Measurement equation

Text prevalence should not be equated directly with investor wealth prevalence. Introduce a measurement equation:

[
TextIndex_{it}
==============

a_i+\lambda_i n_{it}+e_{it}.
]

The latent narrative state can be estimated in a state-space framework jointly with the model’s transition:

[
n_{i,t+1}
=========

\mathcal T(n_{it},\theta_{it})+\eta_{it}.
]

Alternatively, the empirical section can remain reduced form and interpret the text index only as a proxy for (n). In that case, quantitative conversion into “ten percentage points of investor prevalence” should not be attempted.

### 4.3 Narrative classification

Narratives should be defined as structured claims containing:

1. an economic state;
2. a causal explanation;
3. an implied future outcome;
4. an action or policy implication.

This prevents the classifier from confusing a topic such as “debt” with a narrative such as “the government is concealing deficits and will restructure.”

A feasible pipeline is:

* dictionary-based high-recall screening;
* multilingual LLM classification;
* manually labelled gold-standard sample;
* blinded double coding;
* inter-rater reliability;
* frozen prompt and model version;
* country- and language-specific validation;
* out-of-sample performance reporting.

No inaccessible data are needed.

### 4.4 Diffusion and reproduction

GDELT timestamps and source identifiers can measure cross-outlet propagation:

* first appearance;
* number of new outlets adopting the narrative;
* geographic and language spread;
* decay after the peak;
* repeat mentions.

This is not person-to-person investor transmission. The paper should call it **media diffusion** and estimate how it maps into the latent investor narrative state.

### 4.5 Fiscal releases and prices

Eurostat publishes dated release calendars for government deficit and debt data. ([European Commission][28]) National statistical offices and the IMF publish additional scheduled releases.

A feasible data set combines:

| Object                             | Source                                        | Access   |
| ---------------------------------- | --------------------------------------------- | -------- |
| Global media diffusion             | GDELT                                         | Public   |
| Historical full-text validation    | Factiva/LexisNexis                            | Licensed |
| Fiscal-release dates and values    | Eurostat, national statistics, IMF            | Public   |
| Consensus surprises                | Consensus Economics                           | Licensed |
| Euro-area sovereign yields         | ECB Data Portal                               | Public   |
| Emerging-market spreads            | EMBI/Bloomberg/Refinitiv                      | Licensed |
| Public debt and maturity variables | World Bank QPSD/IDS; ECB government-debt data | Public   |
| Maritime or trade controls         | Not required for this paper                   | —        |

## 5. Econometric design

### 5.1 Boundary interaction

The main reduced-form specification should be:

[
\Delta s_{i,t+h}
================

\alpha_i+\tau_t+
\beta_h N_{it}
+
\delta_h
N_{it}\times B_{i,t-1}
+
\Gamma_h'X_{i,t-1}
+u_{i,t+h},
]

where:

* (N_{it}) is the text narrative index;
* (B_{i,t-1}) is a predetermined boundary-proximity statistic;
* (X) includes fiscal and global factors.

The theory predicts a hump, not simply a positive interaction. Therefore estimate narrative effects across bins of (B) or with a flexible function:

[
\Delta s_{it}
=============

f(B_{i,t-1})N_{it}
+\cdots.
]

The strongest empirical result would be that (f(B)) is small in both tails and peaks in the middle.

### 5.2 Measuring boundary proximity

Boundary proximity should not be estimated using contemporaneous spreads, because that mechanically creates a narrative-by-spread interaction.

A better measure is the lagged local sensitivity of spreads to scheduled fundamental surprises:

[
B_{it}
======

\widehat{
\frac{\partial s_{it}}
{\partial FundamentalSurprise_{it}}
}.
]

It can be estimated using rolling or pooled announcement-window regressions. Debt service, reserves, maturity structure, and primary-balance forecasts can provide an alternative model-based measure.

### 5.3 Scheduled-release design

For each scheduled fiscal release:

[
Takeup_{i,e}
============

\alpha_i+\tau_e+
\pi_1 Surprise_{i,e}
+
\pi_2 Surprise_{i,e}\times B_{i,e-1}
+\varepsilon_{i,e}.
]

Then:

[
\Delta s_{i,e}
==============

\beta_1 Surprise_{i,e}
+
\beta_2 ResidualTakeup_{i,e}
+
\beta_3 ResidualTakeup_{i,e}\times B_{i,e-1}
+u_{i,e}.
]

Residual take-up is not perfectly exogenous, but controlling for the released surprise and pre-event state is substantially better than treating all narrative coverage as an independent shock.

### 5.4 Imported narratives

Foreign narrative diffusion can provide additional variation:

[
N_{it}^{foreign}
================

\sum_{j\neq i}
MediaOverlap_{ij,0}N_{jt}.
]

The exclusion restriction is difficult because common investors, banks, language, and trade can transmit fundamentals. The design must control for those channels and should be described as supportive rather than definitive causal evidence.

### 5.5 OMT event

The OMT episode can test whether narrative volume falls after a credible policy backstop. The relevant outcomes are:

* default and redenomination narrative counts;
* diffusion speed;
* sovereign yields;
* CDS where licensed data are available;
* differences between countries more and less exposed to redenomination narratives.

This is an interrupted event study, not a clean randomised policy experiment.

### 5.6 Lead-lag analysis

The prediction that narratives lead prices near the boundary but prices lead narratives outside it is interesting. A panel local projection or panel VAR can test it, but identification should not be inferred from Granger timing alone.

The result should be described as a dynamic fingerprint consistent with the mechanism.

## 6. Policy analysis

Deletion, transparency, and caps operate through different model objects:

* deletion reduces (n_t);
* transparency increases (\gamma) or lowers (\xi);
* a cap reduces (\partial s/\partial n) and the spread-feedback channel.

This decomposition is worth preserving.

The numerical policy claims should, however, be conditional:

* the deletion delay formula assumes the economy remains supercritical;
* transparency can affect both abandonment and fundamentals;
* a cap is effective only if credible and fiscally sustainable;
* cap conditionality may itself change beliefs;
* delayed intervention costs are calibration dependent.

## 7. Concrete revisions

1. Separate the direct pricing-hump theorem from the equilibrium-hump calibration result.
2. Provide formal sufficient conditions for the equilibrium impact to remain single-peaked.
3. Microfound narrative adoption through attention or decision-value costs.
4. Use continuous-time epidemic dynamics or state parameter restrictions explicitly.
5. Distinguish the zero-drift locus from the global basin boundary.
6. Add a phase diagram for ((\theta,n)).
7. Replace (\chi=\text{GFN}) with a debt-cash-flow pass-through measure.
8. Introduce a measurement equation between text coverage and latent prevalence.
9. Eliminate all reliance on inaccessible platform or investor-network data.
10. Use GDELT as the public core corpus and Factiva/LexisNexis only as licensed validation.
11. Describe OMT as a compound policy intervention, not a pure narrative experiment.
12. Report quantitative results as scenario arithmetic until epidemic parameters are estimated.

**Assessment confidence:** high on the mathematical distinctions and data feasibility; moderate on causal identification because narrative coverage and sovereign stress are jointly endogenous by construction.

---

# Cross-draft standards that should be applied uniformly

These standards do not imply any ordering or common empirical model. They are basic requirements for all five drafts.

## 1. Parameter audit

Every parameter table should contain:

| Field                    | Required content                                                   |
| ------------------------ | ------------------------------------------------------------------ |
| Symbol                   | Exact model notation                                               |
| Economic interpretation  | One sentence                                                       |
| Unit                     | Quarterly, annual, probability, basis points, share, etc.          |
| Source category          | Direct observation, external estimate, internal estimate, scenario |
| Data source              | Specific dataset or paper                                          |
| Estimation mapping       | Equation or moment                                                 |
| Sampling uncertainty     | Standard error or reported range                                   |
| Quantitative sensitivity | Effect on principal results                                        |

A parameter should not be labelled “calibrated from the literature” unless the literature provides a numerical estimate that maps transparently into the model.

## 2. Data-access audit

Each empirical section should include:

* dataset name;
* public versus licensed status;
* coverage;
* frequency;
* unit of observation;
* acquisition date;
* known measurement limitations;
* fallback if a commercial licence is unavailable.

The following should not appear as required inputs:

* country-level COFER;
* confidential central-bank reserve portfolios;
* undisclosed Eurosystem security-level holdings;
* restricted bidder identities;
* unlicensed platform archives;
* proprietary firm–supplier customs links;
* private investor communications.

## 3. Epistemic classification of results

Each result should be explicitly classified as one of:

* theorem under stated assumptions;
* conditional proposition;
* numerical property of the calibrated model;
* scenario calculation;
* empirical estimate;
* model-implied counterfactual.

This is particularly important for exact-looking thresholds, fold distances, crisis probabilities, and welfare values.

## 4. Joint uncertainty

Nonlinear quantities should be accompanied by joint uncertainty:

* default hazards;
* break-even sanctions breadth;
* distance to a trade fold;
* ambiguity premia;
* narrative critical zones;
* welfare sign thresholds.

One-at-a-time parameter changes are useful diagnostics but are not substitutes for joint uncertainty propagation.

## 5. Model rejection and external validation

Every quantitative model should report moments not used in estimation. Examples include:

* sovereign excess-return predictability;
* aligned-country portfolio responses;
* sectoral re-entry hazards;
* announcement-induced disagreement;
* narrative diffusion decay.

A model that matches only its calibration targets has not yet been empirically disciplined.

## 6. Policy language

Policy conclusions should be written as conditional statements tied to measurable inequalities. Examples:

[
\text{debt ceiling beneficial}
\iff
\text{government belief distortion exceeds the lost mispricing rent},
]

[
\text{sanctions restraint desirable}
\iff
\text{network cost exceeds geopolitical gain},
]

[
\text{maintenance subsidy positive}
\iff
\text{deterrence and thinning externalities exceed capacity and independence benefits},
]

[
\text{credibility reform especially valuable}
\iff
\mu\delta\frac{\alpha}{\beta}
\text{ is high},
]

[
\text{narrative intervention material}
\iff
R_0(\theta)>1
\text{ and the sovereign lies near the default boundary}.
]

This formulation preserves the papers’ policy relevance without making claims stronger than the models and data can support.

[1]: https://pubs.aeaweb.org/doi/abs/10.1257/aer.20211820?utm_source=chatgpt.com "Real Credit Cycles - Andrei Shleifer"
[2]: https://www.consensuseconomics.com/?utm_source=chatgpt.com "Consensus Economics - Economic Forecasts and Indicators"
[3]: https://www.philadelphiafed.org/surveys-and-data/real-time-data-research/individual-forecasts?utm_source=chatgpt.com "Individual Forecasts: Survey of Professional Forecasters"
[4]: https://databank.worldbank.org/source/quarterly-public-sector-debt?utm_source=chatgpt.com "Quarterly Public Sector Debt - DataBank - World Bank"
[5]: https://www.nber.org/system/files/working_papers/w31024/w31024.pdf?utm_source=chatgpt.com "Javier Bianchi César Sosa-Padilla Working Paper 31024"
[6]: https://data.imf.org/en/news/october%201%202025%20cofer?utm_source=chatgpt.com "Currency Composition of Official Foreign Exchange Reserves"
[7]: https://data.imf.org/en/datasets/IMF.STA%3ACOFER?utm_source=chatgpt.com "COFER - IMF Data - International Monetary Fund"
[8]: https://home.treasury.gov/data/treasury-international-capital-tic-system?utm_source=chatgpt.com "Treasury International Capital (TIC) System | U.S. ..."
[9]: https://home.treasury.gov/news/press-releases/sb0448?utm_source=chatgpt.com "Treasury International Capital Data for February"
[10]: https://www.globalsanctionsdatabase.com/?utm_source=chatgpt.com "Global Sanctions Data Base (GSDB)"
[11]: https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi%3A10.7910%2FDVN%2FLEJUQZ&utm_source=chatgpt.com "United Nations General Assembly Ideal Points"
[12]: https://www.cepii.fr/PDF_PUB/wp/2025/wp2025-23.pdf?utm_source=chatgpt.com "The Fragmentation Paradox: De-risking Trade and Global ..."
[13]: https://www.cepii.fr/DATA_DOWNLOAD/baci/doc/baci_webpage.html?utm_source=chatgpt.com "The CEPII-BACI dataset"
[14]: https://www.oecd.org/en/data/datasets/inter-country-input-output-tables.html?utm_source=chatgpt.com "Inter-Country Input-Output tables"
[15]: https://www.cepii.fr/cepii/en/bdd_modele/bdd_modele_item.asp?id=41&utm_source=chatgpt.com "CEPII - GeoDep"
[16]: https://portwatch.imf.org/?utm_source=chatgpt.com "PortWatch"
[17]: https://ideas.repec.org/a/eee/gamebe/v149y2025icp65-81.html?utm_source=chatgpt.com "Strategic ambiguity in global games"
[18]: https://www.ecb.europa.eu/stats/ecb_surveys/survey_of_professional_forecasters/html/all_data.en.html?utm_source=chatgpt.com "Download all data of the survey of professional forecasters"
[19]: https://www.imf.org/-/media/websites/imf/imported-full-text-pdf/external/pubs/ft/wp/2014/_wp1439.pdf?utm_source=chatgpt.com "Tracking Global Demand for Emerging Market Sovereign ..."
[20]: https://data.ecb.europa.eu/?utm_source=chatgpt.com "ECB Data Portal: Homepage"
[21]: https://data.imf.org/en/datasets/IMF.RES%3AWEO?utm_source=chatgpt.com "WEO - IMF Data - International Monetary Fund"
[22]: https://ec.europa.eu/eurostat/web/government-finance-statistics/publications?utm_source=chatgpt.com "Publications - Government finance statistics and EDP statistics"
[23]: https://dsbb.imf.org/sdds/subscription-date?utm_source=chatgpt.com "IMF - Subscription Information (DSBB)"
[24]: https://www.nber.org/system/files/working_papers/w32602/w32602.pdf?utm_source=chatgpt.com "The Macroeconomics of Narratives Joel P. Flynn Karthik ..."
[25]: https://www.ecb.europa.eu/pub/pdf/scpwps/ecbwp1707.pdf?utm_source=chatgpt.com "The financial and macroeconomic effects of OMT ..."
[26]: https://www.gdeltproject.org/data.html?utm_source=chatgpt.com "Data: Querying, Analyzing and Downloading"
[27]: https://www.dowjones.com/business-intelligence/factiva/?utm_source=chatgpt.com "Dow Jones Factiva - News, Data & Media Monitoring ..."
[28]: https://ec.europa.eu/eurostat/news/release-calendar?utm_source=chatgpt.com "Release calendar - Eurostat - European Commission"
