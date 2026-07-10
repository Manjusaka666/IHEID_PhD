# Edge-Case Audit: Diagnostic Expectations and Sovereign Default

This table audits the statements in `Diagnostic_Sovereign_Risk_Paper.tex`. A row marked EXCLUDED names the hypothesis in the statement that removes the case. A row marked COVERED points to the proof or numerical check that handles it.

| Object | Degenerate case | Disposition | Location |
|---|---|---|---|
| Discount factor | `beta = 0` or `beta = 1` | EXCLUDED | Proposition `prop:existence` assumes `0 < beta < 1` |
| Consumption | A repayment action gives nonpositive consumption | COVERED | Proposition `prop:existence` uses a continuous tangent extension. `revision_tests.jl` verifies every chosen repayment action lies strictly above the floor |
| Policy | Repayment is infeasible at a state | COVERED | Default remains available. Proof of Lemma `lem:bmono` handles forced default separately |
| Policy | Two issuance choices tie | COVERED | Proposition `prop:existence` admits mixtures over all maximizing actions. The deterministic computation uses the first grid maximizer |
| Policy | Default and repayment tie | COVERED | The numerical rule repays at equality. The mixed existence result admits either action or a mixture |
| Equilibrium | Deterministic equilibrium is nonunique | COVERED | Proposition `prop:existence` proves mixed existence only. The computation reports convergence from three price schedules without claiming global uniqueness |
| Beliefs | `theta = 0` | COVERED | Lemma `lem:tilt`, Corollary `cor:zero`, and Proposition `prop:returns` recover the rational kernel and zero expected excess returns |
| Beliefs | `theta` approaches infinity | EXCLUDED | Quantitative claims use `theta` in `{0,0.5,1}` and identify `theta=1` as a stress calculation. No theorem requires a uniform bound as `theta` diverges |
| Beliefs | Conditional variances differ | EXCLUDED | Lemma `lem:tilt` states equal Gaussian conditional variances. The text identifies equal variance as the source of the one-dimensional mean shift |
| Beliefs | Income is non-Gaussian or not first-order Markov | EXCLUDED | Lemma `lem:tilt` and Proposition `prop:cg` state the Gaussian AR(1) law explicitly |
| Pricing | Repayment probability is one | COVERED | Proposition `prop:history` gives weak monotonicity. Strictness is not claimed outside interior-risk cells |
| Pricing | Repayment probability is zero | COVERED | The price is zero. Proposition `prop:returns` is stated only for positive-price bonds |
| Pricing | Repayment differs only on a null set | COVERED | Proposition `prop:history` requires a difference on a set with positive diagnostic probability for strictness |
| Default policy | Default is not monotone in income | EXCLUDED | Propositions `prop:history`, `prop:returns`, and `prop:fragility` state Assumption `ass:monotone`. The computation reports violations separately at `theta=1` |
| Debt | `b = 0` | COVERED | Lemma `lem:bmono` allows the lower endpoint and makes no strict default claim there |
| Debt | Upper debt-grid endpoint | COVERED | Compactness gives attainment. `revision_tests.jl` checks price and consumption bounds. The long-bond simulation records the fraction of policies at the upper endpoint |
| Income | Lower or upper grid endpoint | COVERED | Transition bins include Gaussian tail mass in the endpoint cells. Strict pricing requires only positive mass on both repayment regions |
| Returns | True repayment probability is zero | COVERED | A zero-price claim has no finite gross return and is outside Proposition `prop:returns` |
| Returns | Risk-free repayment | COVERED | True and diagnostic repayment probabilities both equal one, so expected excess return is zero |
| Forecast mapping | `theta = 0` | COVERED | Both the analytical and simulated mappings return a zero coefficient |
| Forecast mapping | Fixed-event targets roll across December | COVERED | `survey_mapping_mc.jl` constructs current-year and next-year targets by calendar month and changes the target year at the boundary |
| Forecast mapping | Overlapping forecast horizons | COVERED | The simulation preserves overlap. The population mapping uses one long simulated path, while empirical standard errors are clustered by country and target date |
| Long bond | Maturity rate equals one | COVERED | `revision_tests.jl` tests the one-period payoff and budget limit against the separate short-bond solver |
| Long bond | Maturity rate equals zero | EXCLUDED | The long-bond calibration states `0 < delta <= 1`. The baseline uses `delta=0.05` |
| Long bond | Zero market value | COVERED | Yield statistics omit zero-price observations and report their frequency. Pricing residuals remain defined |
| Long bond | Temporary shock reaches a truncation point | COVERED | The quadrature partitions every policy interval at all choice and default thresholds. Endpoint mass is handled by the truncated-normal cdf |
| Long bond | Fixed Gaussian integration is inaccurate within a policy interval | COVERED | `revision_tests.jl` compares twenty-node Gaussian integration with independently adaptive integration at selected states |
| Long bond | Deterministic iteration cycles on a finer debt grid | COVERED | The 100-node diagnostic iteration switches at near ties. The paper reports the converged 50-node deterministic equilibrium and relies on the mixed-policy existence theorem rather than claiming deterministic existence on every grid |
| Welfare | Foreign-lender losses omitted from sovereign welfare | COVERED | The policy section labels sovereign welfare and reports lender expected profit under the true measure separately |
| Welfare | Political costs or cross-country spillovers | EXCLUDED | The policy statement defines the model resource accounting and does not call it global welfare outside that accounting |
