# Edge-case audit

- `p = 0`, `phi = 0`, `omega = 0`, or `chi = 0` eliminates the sanctions wedge.
- `ell_1 = 0` sets the network multiplier to one and removes the aligned-country response.
- `zeta_H = 0` eliminates captured privilege and the commitment motive in the issuer objective.
- `ell_1 >= kappa` invalidates the local contraction proof. It does not by itself prove multiplicity.
- Portfolio corners are solved with projection onto `[0,1]`.
- The global model uses bounded convenience and strictly convex portfolio cost.
- The reported global calibration satisfies the contraction bound over the unit interval.
- The fixed-belief result `s_D = 1` is not applied to environments in which current policy changes the public reputation state.
- Country-level COFER is never used. TIC country attribution is treated as custodial and is validated against disclosed central-bank reports.
- A missing sanctions-use crossing on `p in [0,1]` is reported as no feasible crossing, not as a numerical failure.
