# Degenerate-case audit for the five-paper v4 revision

The table audits theorem statements, fixed-point arguments, dynamic boundaries, and quantitative classifications. `COVERED` means the stated proof or numerical audit treats the case. `EXCLUDED` means an explicit hypothesis places the case outside the result.

| Paper | Degenerate case | Disposition | Location and resolution |
|---|---|---|---|
| Topic 1 | Government indifference and discontinuous debt policies | COVERED | Proposition `prop:existence` convexifies ties with mixed policies on finite grids and proves existence by Kakutani. |
| Topic 1 | Discount factor at zero or one | EXCLUDED | Proposition `prop:existence` states (0<\beta<1). |
| Topic 1 | Consumption at or below zero | COVERED | Proposition `prop:existence` extends utility below a positive floor. The original economy follows when the computed choices stay above that floor and residuals vanish. |
| Topic 1 | Debt at the boundary of the feasible grid | COVERED | Lemma `lem:bmono` proves repayment value decreases in inherited debt and the default set is an upper interval. |
| Topic 1 | Failure of income-monotone default | EXCLUDED | Propositions `prop:history`, `prop:returns`, and `prop:fragility` invoke Assumption `ass:monotone` in their statements. The computation appendix audits the assumption across baseline grids and recalibration vectors. |
| Topic 1 | Rational-belief endpoint (\theta=0) | COVERED | Corollary `cor:zero` and Proposition `prop:longzero` establish the exact short-debt and long-debt history zeros. |
| Topic 1 | Zero bond price or certain repayment | EXCLUDED | Proposition `prop:returns` states the return result for positive-price bonds and assigns strict signs only under the interior-risk condition of `prop:history`. |
| Topic 1 | Zero or unlimited rational intermediary capacity | COVERED | Appendix `app:intermediaries` takes both limits and shows continuous attenuation to full diagnostic pricing or rational pricing. |
| Topic 2 | Vanishing denominator (\kappa-\ell_1) | EXCLUDED | Proposition `prop:multiplier` assumes (\ell_1<\kappa). Proposition `prop:hetero` uses the corresponding strict heterogeneous inequality. |
| Topic 2 | Reserve choices at zero or one | COVERED | Proposition `prop:global` works on the constrained unit interval. Appendix `app:corners` proves that projection weakly lowers the local slope. |
| Topic 2 | Unit-circle roots or a singular stable eigenvector block | EXCLUDED | Proposition `prop:heterodynamics` requires exactly (n) stable roots and nonsingular (X). |
| Topic 2 | Forgiveness probability at zero or one | COVERED | Section `sec:reputation` sets (\alpha\in[0,1]), and Proposition `prop:reputation` evaluates the closed-form threshold at both endpoints. |
| Topic 2 | Aggregate contraction modulus equal to one | EXCLUDED | Proposition `prop:global` imposes a strict upper bound below one. |
| Topic 2 | Failure of global contraction | COVERED | The proposition limits its uniqueness claim to the strict region. The numerical routine enumerates all fixed points for every alternative closure. |
| Topic 2 | Zero exposure or zero accessibility loss | COVERED | The parameter appendix and `revision_tests.jl` recover a zero direct response as (z\omega p\phi\chi\) tends to zero. |
| Topic 3 | Capacity denominator (1-\chi F_m) at zero | EXCLUDED | Proposition `prop:complementarity` states (1-\chi F_m>0). |
| Topic 3 | All strategic feedback channels equal zero | COVERED | Proposition `prop:complementarity` shows that the threshold becomes state independent and equilibrium is unique. |
| Topic 3 | Singular multisector multiplier | EXCLUDED | Proposition `prop:multiplier` requires spectral radius (\varrho(J)<1), which makes (I-J) invertible. |
| Topic 3 | Tangency without curvature or transversality | EXCLUDED | Proposition `prop:tipping` states (R_{FF}\neq0) and (R_{F\delta}\neq0) together with the root and tangency equations. |
| Topic 3 | Atoms or a flat density at the switching threshold | EXCLUDED | Proposition `prop:complementarity` requires a positive density (h_m(\hat g_m)>0). |
| Topic 3 | Shock duration exactly at the basin threshold | COVERED | Proposition `prop:hysteresis` assigns the high branch for (T^{sp}\geq\bar T) and the low branch for (T^{sp}<\bar T). |
| Topic 3 | Terminal hazard exactly at a fold | EXCLUDED | Proposition `prop:hysteresis` places the terminal hazard in the open fold interval. |
| Topic 3 | Alternative premium tails and grid refinement | COVERED | `premium_distribution_audit.jl` matches lognormal, log-logistic, Weibull, and sieve inputs. `revision_tests.jl` checks all roots and fold residuals. |
| Topic 5 | Payoff hurdle at zero or one | EXCLUDED | Assumption `ass:exit` states (0<\bar p_k<1). |
| Topic 5 | Exit payoff varies with the crisis state | COVERED | Assumption `ass:exit` allows both actions to depend on survival and imposes the relative-exposure inequality used by Lemma `lem:asif`. |
| Topic 5 | No distrust, (\delta_k=0) | COVERED | Lemma `lem:asif` and Proposition `prop:premium` reduce exactly to the Bayesian cutoff. |
| Topic 5 | Composition at a simplex endpoint | COVERED | Proposition `prop:unique` applies to every composition. Proposition `prop:base` gives the corresponding one-sided composition derivative at an endpoint. |
| Topic 5 | Fixed-point slope equal to one | EXCLUDED | Proposition `prop:unique` imposes the strict precision bound (\alpha/\sqrt\beta<\sqrt{2\pi}). |
| Topic 5 | Vanishing public precision | COVERED | Proposition `prop:directional` derives the no-information anchor (\theta^*_{\infty}=\sum_k\mu_k(1-\bar p_k)). |
| Topic 5 | Ambiguity and Bayesian bias yield the same choices | COVERED | Proposition `prop:equivalence` proves equality of choices, run mass, thresholds, and model-implied spreads. |
| Topic 7 | Default probability at zero or one | COVERED | Lemma `lem:pricing` states (0<\mathcal R\leq1). Exact pricing maps the endpoints into finite compensation on the stated interval. |
| Topic 7 | Pricing contraction gain equal to one | EXCLUDED | Lemma `lem:pricing` imposes a strict gain below one. The sensitivity code classifies the crossing as a separate pricing boundary. |
| Topic 7 | Cognitive-state faces (n=0), (a=1), and (a=n) | COVERED | Proposition `prop:invariant` checks each face and allows the equality case (\gamma_n=\gamma_a). |
| Topic 7 | Acceptance probability at zero or one | COVERED | Proposition `prop:invariant` states (0\leq q\leq1). |
| Topic 7 | Zero belief abandonment in the reproduction number | EXCLUDED | The definition of (R_0), Proposition `prop:zone`, and Proposition `prop:policy` state (\gamma_n>0). |
| Topic 7 | Zero belief shift, (\Delta=0) | EXCLUDED | Theorem `prop:hump` states (\Delta>0). The excluded endpoint has the trivial gap (G\equiv0). |
| Topic 7 | Reproduction number exactly one | COVERED | Proposition `prop:zone` defines the susceptible set with the weak inequality (R_0\geq1). |
| Topic 7 | Flat equilibrium log derivative (Q_z=0) | EXCLUDED | Proposition `prop:eqhump` uses the strict condition (Q_z<0). |
| Topic 7 | Zero derivative at the drift root | EXCLUDED | Proposition `prop:cliff` states (D_\theta>0). |
| Topic 7 | Zero seed, default absorption, and finite-horizon classification | COVERED | `revision_tests.jl` checks the zero-seed path, invariant faces, absorbing default, 240 versus 360 months, and 8 versus 32 RK4 substeps. |

Open obligations: none.
