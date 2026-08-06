# Source Manifest

Every file in the three source areas, recorded once. "Read in detail" means the
file's mathematical content was extracted and worked through, not merely listed.
Page and slide counts are those reported by `pdfinfo`; slide numbers cited in the
notes are the numbers printed on the slides themselves.

Source areas:

- `Gerzensee/Math Camp/Slides/` — 6 files
- `Gerzensee/Math Camp/Supplementary/` — 37 files
- `PhD Math/` — 12 files

Nothing in any source area was modified.

---

## 1. Gerzensee Math Camp — Slides

| Path | Type | Title / author | Slides | Main mathematical topics | Economic applications | Relevance | Chapter | Read in detail | Used |
|---|---|---|---|---|---|---|---|---|---|
| `Slides/Gerzensee_Real_Analysis_2026_04.pdf` | PDF slides | "Real Analysis", Satoshi Fukuda, 4–5 Aug 2026 | 77 | Inner product (5–7); Riesz representation in $\mathbb{R}^n$ (8–11); matrix representation (12–15); norms and Cauchy–Schwarz (16–22); distance (23–25); open balls (26); bounded sets (27–28); open and closed sets (29–40); sequences (41–48); limits and continuous functions (49–57); completeness (58–62); contraction mapping theorem (63–72); Blackwell's condition (73–76); Banach and Hilbert spaces (77) | Existence of consumer demand; the Bellman operator as a contraction | Primary | 2, 3, 4, 5, 6 | Yes | Yes |
| `Slides/Gerzensee_Calculus_2026_03.pdf` | PDF slides | "Calculus through Economic Applications", Satoshi Fukuda, 3–4 Aug 2026 | 98 | Derivatives and their properties (4–20); first-order conditions (5–8, 52–53); Taylor expansion (28–36); logarithmic approximations (37–40); partial derivatives (44–49); total differentiation (50–51); OLS by calculus (55–60, 63–64); projection theorem (61–62); definite and indefinite integration (65–68); integration by parts (69–78); substitution (79–84); the Gaussian integral (85–93); Leibniz's rule (94–98) | Price-taking and price-setting firm, Lerner index; Arrow–Pratt risk premium (26–27, 41–42); growth accounting, growth rates, Fisher equation, log-linearisation; representative firm's factor shares (54); least squares | Primary | 7, 8, 10, 11 | Yes | Yes |
| `Slides/Gerzensee_Optimization_2026_05.pdf` | PDF slides | "Introduction to Static Optimization", Satoshi Fukuda, 4 Aug 2026 | 44 | Formulation of the programming problem (3–4); binding constraints (5–9); the five equivalent formulations, Lagrangian, complementary slackness, saddle point (10–18); Kuhn–Tucker theorem (19–20); numerical solvers (33–35) | Cobb–Douglas consumer choice worked in full with the multiplier computed two ways and the envelope calculation (21–32, 36); intertemporal utility maximisation (37–40); Nash bargaining (41–44) | Primary | 9, 12 | Yes | Yes |
| `Slides/Gerzensee_Dynamic_Programming_2026_02.pdf` | PDF slides | "Dynamic Programming", Satoshi Fukuda, 6 Aug 2026 | 63 | The dynamic optimisation problem (2, 4–8); Bellman's principle of optimality (9–11); solving a Bellman equation and value function iteration (12–18); closed-form solution by guess and verify (31–35) | Cake-eating problem (19–25, 30) with its numerical implementation (26–29); Ramsey growth model (36–41); Lucas asset-pricing model — consumer's problem, equilibrium constraints, the pricing functional equation, numerical computation (42–62) | Primary | 6, 15 | Yes | Yes |
| `Slides/Gerzensee_Probability_2026_04.pdf` | PDF slides | "Probability Theory", Satoshi Fukuda, 3 Aug 2026 | 32 | Bayes' law and the odds form (3–14); random variables (15); expectations (16); conditional expectations (17); law of iterated expectations (18–19); conditional expectation as the best predictor (20–21); normal–normal updating (22–32) | Medical testing, airport carousel and polling examples; inference from a signal; precision-weighted updating | Primary | 14 | Yes | Yes |
| `Slides/Gerzensee_Logistics_2026_04.pdf` | PDF slides | "Mathematics Review Course: Course Information", Satoshi Fukuda, 2026 | 11 | None. Course objectives (2), topic list (3), motivation for the topic selection (4), materials (5), expectations (6), MATLAB/Octave resources (7–9), first-year PhD coursework map (10) | None | Scope-setting only | Preface, How to Use These Notes | Yes | Yes — for the statement of scope, the ordering rationale and the course's stated goals. It contributes no mathematics because it contains none. |

## 2. Gerzensee Math Camp — Supplementary

| Path | Type | Title / author | Pages | Main content | Relevance | Chapter | Read in detail | Used |
|---|---|---|---|---|---|---|---|---|
| `Supplementary/Math_Reference_Lecture_Notes_Gerzensee_2026.pdf` | PDF | "Lecture Notes on Mathematics for Economics", Satoshi Fukuda, version of 9 July 2026 | 768 | The full reference volume behind the slides: Ch. 1–2 (sets, relations, logic, the reals), Ch. 3 (mappings and partial derivatives), Ch. 5–7 (metric and normed spaces, topology, completeness, contraction), Ch. 6 and 10 (convexity, separation, Farkas–Minkowski), Ch. 8 (Brouwer), Ch. 9 (projection, Riesz in Hilbert space), Ch. 11 (differentiation in $\mathbb{R}^n$, implicit function theorem), Ch. 12 (Kuhn–Tucker), Ch. 13 (correspondences, Berge's maximum theorem, Kakutani), Ch. 15 (dynamic programming), Ch. 16 (continuous-time dynamic optimisation), Sec. 2.1–2.5 and 9.6 (probability) | Primary. It is the only source for Chapters 13 and 16, which have no slide counterpart | All | Yes — full text extracted; the chapters listed were worked through line by line, and page images were inspected wherever the text layer rendered formulas unreliably | Yes |
| `Supplementary/codes/DP_cake_eating.m` | MATLAB | Deterministic cake-eating, log utility | — | Value function iteration on a 2000-node grid over $[0.001,1]$, $\beta=0.85$, compared against the closed form $h(w)=(1-\beta)w$ | Numerical counterpart to Ch. 15 | 15 | Yes | Yes |
| `Supplementary/codes/DP_cake_eating_CRRA.m` | MATLAB | Cake-eating with CRRA utility | — | Same algorithm with CRRA preferences | Ch. 15 | 15 | Yes | Yes |
| `Supplementary/codes/DP_cake_eating_plot_iterations.m` | MATLAB | Cake-eating, successive iterates | — | Displays $W_m \to V$ | Illustrates the contraction error bound | 15 | Yes | Yes |
| `Supplementary/codes/deterministic_Ramsey_growth.m` | MATLAB | Deterministic Ramsey growth | — | Computes $k^\ast=(\alpha A/(\beta^{-1}-(1-\delta)))^{1/(1-\alpha)}$, then 1000 nodes on $[0.25k^\ast,1.75k^\ast]$; infeasible pairs penalised | Ch. 15, and the compactness argument of the unbounded-returns remark | 15 | Yes | Yes |
| `Supplementary/codes/Lucas_Tree_DP.m` | MATLAB | Lucas tree | — | Iterates the pricing operator with spline interpolation and a 500-draw Monte Carlo integral; grid spans four stationary standard deviations; validated against $\beta y/(1-\beta)$ for $\gamma=1$ | Ch. 15 | 15 | Yes | Yes |
| `Supplementary/codes/Lucas_Tree_DP_Octave.m` | Octave | Lucas tree, Octave port | — | Same algorithm | Ch. 15 | 15 | Yes | Yes |
| `Supplementary/codes/consumer_choice_fmincon.m` | MATLAB | Cobb–Douglas consumer choice | — | $\alpha=0.7$, $p_1=p_2=1$, $m=1$; returns the multiplier alongside the solution | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/consumer_choice_sqp_Octave.m` | Octave | Same problem, `sqp` | — | Sequential quadratic programming | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/consumer_choice_python.py` | Python | Same problem, `scipy.optimize.minimize` | — | Same problem | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/two_periods_consumption_fmincon.m` | MATLAB | Two-period consumption | — | $\beta=0.9$, $R=1.05$, log utility; the Euler equation | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/two_periods_consumption_sqp_Octave.m` | Octave | Same problem | — | Same problem | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/two_periods_consumption_python.py` | Python | Same problem | — | Same problem | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/Nash_bargaining_fmincon.m` | MATLAB | Nash bargaining | — | $\max x_1x_2$ subject to $x_1^2+x_2^2\le1$ | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/Nash_bargaining_sqp_Octave.m` | Octave | Same problem | — | Same problem | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/Nash_bargaining_python.py` | Python | Same problem | — | Same problem | Ch. 12 | 12 | Yes | Yes |
| `Supplementary/codes/regression.m` | MATLAB | Least squares | — | Simulated regression with a fixed seed | Ch. 11 | 11 | Yes | Yes |
| `Supplementary/codes/regression_Octave.m` | Octave | Same | — | Same | Ch. 11 | 11 | Yes | Yes |
| `Supplementary/codes/regression_Python.py` | Python | Same | — | Same | Ch. 11 | 11 | Yes | Yes |
| `Supplementary/codes_pdf/*.pdf` (18 files) | PDF | Typeset printouts of the 18 programs above | — | Identical content to the `.m` and `.py` sources | Duplicate | — | Confirmed to be printouts of the corresponding sources | Not used separately. The executable sources in `codes/` were read instead; citing the printout as well as the source would double-count a single artefact. |

## 3. `PhD Math` — reference texts

Each was opened, its table of contents read, and the sections bearing on this
volume's material examined. "Used" means the text is cited in the notes at a
specific chapter, section or page.

| Path | Pages | Title / author | Sections examined | Relevance | Chapter | Used |
|---|---|---|---|---|---|---|
| `Rudin-Principles of Mathematical Analysis.pdf` | 388 | Rudin, *Principles of Mathematical Analysis*, 3rd ed. | Ch. 1–4, 6, 9; Thm 9.28 | High. Standard reference for the real-analysis spine | 1, 4, 5, 8, 10 | Yes |
| `Amann-Analysis I.pdf` | 436 | Amann and Escher, *Analysis I* | Ch. I–II | Moderate. Foundations, order, the reals | 1 | Yes — cited collectively in the Preface as the analysis reference |
| `Amann-Analysis II.pdf` | 409 | Amann and Escher, *Analysis II* | Ch. VI–VII | Moderate. Differentiation and integration in several variables | 8, 10 | Yes — as above |
| `Amann-Analysis III.pdf` | 477 | Amann and Escher, *Analysis III* | Ch. IX–X | Moderate. Measure and integration | 10 | Yes — as above |
| `Axler-Linear Algebra Done Right.pdf` | 404 | Axler, *Linear Algebra Done Right*, 4th ed. | Ch. 5–7 | High. Eigenvalues, spectral theorem, inner product spaces | 2, App. B | Yes |
| `Boyd-Convex Optimization.pdf` | 732 | Boyd and Vandenberghe, *Convex Optimization* | Sec. 2.5 (p. 46), 3.4 (p. 95), 5.4 (p. 237), 5.5 (p. 241), 5.6 (p. 249) | High. Separation, quasiconvexity, saddle points, optimality conditions, sensitivity | 9, 12 | Yes. Text layer present and readable; §2.5 p. 46, §3.4 p. 95, §5.4 p. 237, §5.5 p. 241 and §5.6 p. 249 confirmed against the table of contents and the running heads by `pdftotext -layout` |
| `An Introduction to Mathematical Analysis for Economic Theory.pdf` | 696 | Corbae, Stinchcombe and Zeman, *An Introduction to Mathematical Analysis for Economic Theory* | Ch. 1–2 | High. Preference relations and their representation | 1 | Yes |
| `Sargent-Recursive Macroeconomic Theory.pdf` | 1477 | Ljungqvist and Sargent, *Recursive Macroeconomic Theory*, 4th ed. | Ch. 3 | High. Recursive methods, the Ramsey and Lucas models | 2, 15 | Yes |
| `Le Gall-Measure Theory, Probability, and Stochastic Processes.pdf` | 409 | Le Gall, *Measure Theory, Probability, and Stochastic Processes* | Ch. 1–5 | High. $\sigma$-algebras, measures, integration, conditional expectation | 1, 10, 14 | Yes |
| `Gelman-Bayesian Data Analysis.pdf` | 656 | Gelman et al., *Bayesian Data Analysis*, 3rd ed. | Sec. 2.5 (pp. 39–42), 3.5 (p. 70) | High. Conjugate normal updating in precision form; the multivariate case | 14 | Yes |
| `Brockwell-Introduction to Time Series and Forecasting.pdf` | 428 | Brockwell and Davis, *Introduction to Time Series and Forecasting* | Ch. 9, Sec. 9.4 (p. 270) | Moderate. The Kalman recursions, of which the Riccati recursion in Ch. 14 is the scalar case | 14 | Yes |
| `Le Gall-Brownian Motion, Martingales, and Stochastic Calculus.pdf` | 282 | Le Gall, *Brownian Motion, Martingales, and Stochastic Calculus* | Table of contents; Ch. 1–2 skimmed | Low for this volume | — | Not used beyond a Preface pointer. No slide topic and no economic application in the course requires continuous-time stochastic processes: Chapter 16 is deterministic optimal control, and the only continuous-time object in the volume is the Hamilton–Jacobi–Bellman equation of a deterministic problem. Introducing stochastic calculus would be mathematics unrelated to the course spine. |

---

## Summary

- Slides: 6 of 6 checked, 6 of 6 used. All 325 slides accounted for in
  `SOURCE_COVERAGE.md`.
- Supplementary: 37 of 37 checked. The reference volume and all 18 program
  sources are used; the 18 PDF printouts are duplicates of those sources.
- `PhD Math`: 12 of 12 checked and classified; 11 cited in the notes, 1
  (Le Gall, *Brownian Motion*) deliberately not, for the reason recorded above.
