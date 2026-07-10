# Edge case audit

## Payoffs

The as-if result requires survival to weakly improve both rollover and exit payoffs. Rollover must have strictly greater crisis exposure than exit. The implied hurdle must lie strictly between zero and one. `rollover_hurdle` rejects violations.

## Information

At zero distrust, the model is the Bayesian benchmark. At zero public precision, distrust has no effect and the threshold converges to the composition-weighted payoff anchor. The test suite verifies this limit numerically. The contraction condition is sufficient and uniform in creditor payoffs, composition, and distrust radii.

## Heterogeneity

Creditor types may have distinct payoff hurdles and distrust radii. Composition raises the threshold only when the incoming type has the higher run probability at the margin. The common-payoff calculation is a quantitative scenario, not a restriction of the theorem.

## Identification

Max-min ambiguity and Bayesian pessimistic bias beliefs are observationally equivalent for choices, thresholds, crisis probabilities, and model prices. Spreads cannot identify the preference interpretation. Revision histories and forecast microdata must be measured before market outcomes enter the analysis.

## Welfare

The precision theorem is conditional on the announcement. Ex ante welfare also depends on the induced announcement distribution and the cost of producing information. The paper does not infer an unconditional welfare ranking from the conditional comparative static.
