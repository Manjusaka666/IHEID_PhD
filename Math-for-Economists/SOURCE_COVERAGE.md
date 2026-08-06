# Source Coverage Map

Two directions are recorded. Section 1 runs forward: every slide of every deck,
mapped to the chapter file that carries it. Section 2 runs backward: every
chapter file, mapped to the sources it rests on. Section 3 records the material
that comes only from the supplementary reference volume, and Section 4 the
places where sources disagreed and how the disagreement was resolved.

Slide numbers are those printed on the slides. Chapter files are in
`Lectures/`; the two appendices referred to are in `appendix.tex`.

---

## 1. Forward map: slides to chapters

### 1.1 `Gerzensee_Real_Analysis_2026_04.pdf` — 77 slides

| Slides | Topic | Chapter file | What the notes add beyond the slide |
|---|---|---|---|
| 1–4 | Title, outline | — | Used to fix the ordering of Chapters 3–6 |
| 5–7 | Inner product | `lec_3.tex` | Axioms stated for a general real vector space; the induced norm; the polarisation identity |
| 8–11 | Riesz representation in $\mathbb{R}^n$ | `lec_3.tex` | Full proof; uniqueness; the Hilbert-space version is proved separately in `lec_11.tex` |
| 12–15 | Matrix representation | `lec_2.tex` | Basis dependence made explicit; change of basis; the correspondence between linear maps and matrices |
| 16–22 | Norms; Cauchy–Schwarz | `lec_3.tex` | Cauchy–Schwarz proved with the equality case; $\ell^p$ norms; equivalence of norms in finite dimension |
| 23–25 | Distance | `lec_3.tex` | Metric axioms; the discrete metric; metrics not induced by norms |
| 26 | Open balls | `lec_3.tex`, `lec_4.tex` | Balls in the discrete metric as the standard counterexample |
| 27–28 | Bounded sets | `lec_4.tex` | Boundedness versus total boundedness; the distinction is what makes Heine–Borel finite-dimensional |
| 29–40 | Open and closed sets, with exercises and solutions | `lec_4.tex` | Arbitrary unions and finite intersections; closure, interior, boundary; the sequential characterisation of closedness |
| 41–48 | Sequences; bounded sequences | `lec_4.tex` | Bolzano–Weierstrass; subsequences; sequential compactness and its equivalence with compactness in metric spaces |
| 49–57 | Limits; continuous functions | `lec_5.tex` | $\varepsilon$–$\delta$, sequential and preimage characterisations proved equivalent; uniform continuity; Heine–Cantor |
| 58–62 | Completeness of a metric space | `lec_6.tex` | Completeness of $\mathbb{R}^n$; $\mathcal{B}(X,\mathbb{R})$ with the sup norm; completeness is not a topological property |
| 63–72 | Contraction mapping theorem | `lec_6.tex` | Full proof with the a priori and a posteriori error bounds; the invariant-set corollary; failure when the modulus is not uniform |
| 73–76 | Blackwell's condition | `lec_6.tex`, `lec_15.tex` | Proved as a sufficient condition; applied to the Bellman operator |
| 77 | Banach and Hilbert spaces | `lec_3.tex`, `lec_11.tex` | Definitions carried into the projection theorem and the value-function space |

### 1.2 `Gerzensee_Calculus_2026_03.pdf` — 98 slides

| Slides | Topic | Chapter file | What the notes add |
|---|---|---|---|
| 1–3 | Title, outline, firm's problem | `lec_7.tex` | The firm's problem opens the chapter as motivation |
| 4–8 | Derivatives; first-order conditions; concavity | `lec_7.tex` | Fermat's theorem; sufficiency under concavity separated from necessity |
| 9–20 | Properties of derivatives | `lec_7.tex` | Product, quotient and chain rules proved; mean value theorem; monotonicity and convexity criteria |
| 21 | Price-taking firm | `lec_7.tex` | Second-order condition made explicit |
| 22–25 | Price-setting firm | `lec_7.tex` | Lerner index derived; the elasticity condition $\eta<-1$ |
| 26–27, 41–42 | Risk premium | `lec_7.tex` | Arrow–Pratt coefficient derived from a second-order expansion with the remainder controlled |
| 28–36 | Taylor expansion | `lec_7.tex` | Lagrange and Peano forms; the remainder stated with its hypotheses |
| 37–40 | Applications of $\log$ | `lec_7.tex` | Growth accounting, growth rates, the Fisher equation, log-linearisation, each with the approximation error named |
| 43 | Unconstrained optimisation | `lec_8.tex` | Motivating problem for the chapter |
| 44–49 | Partial derivatives | `lec_8.tex` | Gradient as a column vector; the Cobb–Douglas example; homogeneity of degree zero |
| 50–51 | Differentiation | `lec_8.tex` | Total derivative distinguished from partials; the standard counterexample where partials exist and the function is discontinuous |
| 52–53 | First-order conditions | `lec_8.tex` | Interior optimum; second-order conditions via the Hessian |
| 54 | Representative firm | `lec_8.tex` | Factor-price equations; the capital–labour ratio; factor shares |
| 55–60, 63–64 | OLS by calculus | `lec_8.tex`, `lec_11.tex` | Normal equations from the first-order conditions; then the same estimator as a projection |
| 61–62 | Projection theorem | `lec_11.tex` | Orthogonal decomposition; the projection matrix; Gram–Schmidt; Frisch–Waugh–Lovell |
| 65–68 | Integration | `lec_10.tex` | Darboux construction; criteria for integrability |
| 69–78 | Integration by parts | `lec_10.tex` | Hypotheses stated; the $\int\log x$ example |
| 79–84 | Substitution | `lec_10.tex` | Proof via the fundamental theorem; the mnemonic justified |
| 85–93 | Normal distribution | `lec_10.tex`, `lec_14.tex`, App. C | The Gaussian integral computed; the density normalised; the multivariate law in the appendix |
| 94–98 | Leibniz's rule | `lec_10.tex` | Differentiation under the integral sign with variable limits, hypotheses stated in full |

### 1.3 `Gerzensee_Optimization_2026_05.pdf` — 44 slides

| Slides | Topic | Chapter file | What the notes add |
|---|---|---|---|
| 1–2 | Title, outline | — | — |
| 3–4 | Formulation of the programming problem | `lec_12.tex` | Sign convention fixed and its consequence for the multiplier's sign recorded |
| 5–9 | Binding constraints | `lec_12.tex` | Why one identifies binding constraints first; the case distinction made explicit |
| 10–18 | The five formulations; Lagrangian; complementary slackness; saddle point | `lec_9.tex`, `lec_12.tex` | Each implication proved separately; the diagram of implications turned into a chain of propositions; the concavity hypotheses isolated |
| 19–20 | Kuhn–Tucker theorem | `lec_12.tex` | Proved from Farkas–Minkowski; Slater's condition stated as an assumption; a counterexample where the constraint qualification fails |
| 21–32 | Consumer-choice illustration | `lec_12.tex` | Cobb–Douglas demand derived; the multiplier computed two ways; the envelope theorem stated and proved with its differentiability hypothesis |
| 33–35 | `fmincon`, `sqp`, `scipy.optimize.minimize` | `lec_12.tex` | The sign convention of the solvers reconciled with the text's |
| 36 | Consumer-choice example | `lec_12.tex` | Numerical values matched against the closed form |
| 37–40 | Intertemporal utility maximisation | `lec_12.tex` | Euler equation derived; the two-period problem solved |
| 41–44 | Nash bargaining | `lec_12.tex` | Solution derived; the tangency condition interpreted |

### 1.4 `Gerzensee_Probability_2026_04.pdf` — 32 slides

| Slides | Topic | Chapter file | What the notes add |
|---|---|---|---|
| 1–2 | Title, outline | — | — |
| 3–14 | Bayes' law | `lec_14.tex` | $\sigma$-algebra and probability measure defined first; the law of total probability; the odds form; the three worked examples verified numerically |
| 15 | Random variables | `lec_14.tex` | Measurability stated; the discrete case separated from the general one |
| 16 | Expectations | `lec_14.tex` | Definition, linearity, monotonicity, change of variables; Jensen's inequality with its equality case |
| 17 | Conditional expectations | `lec_14.tex` | Conditioning on an event and on a random variable distinguished |
| 18–19 | Law of iterated expectations | `lec_14.tex` | Proved; the taking-out-what-is-known property proved separately |
| 20–21 | Conditional expectation as the best predictor | `lec_14.tex` | Stated as an $L^2$ projection, connecting to `lec_11.tex`; the variance decomposition derived |
| 22–32 | Normal–normal updating | `lec_14.tex`, App. C | Conjugate updating proved; the precision form; the many-observation case; the Gaussian conditional law in the appendix |

### 1.5 `Gerzensee_Dynamic_Programming_2026_02.pdf` — 63 slides

| Slides | Topic | Chapter file | What the notes add |
|---|---|---|---|
| 1, 3 | Title, outline | — | — |
| 2, 4–8 | The dynamic optimisation problem | `lec_15.tex` | Sequential problem stated with its standing assumptions; stationarity discussed |
| 9–11 | Bellman's principle of optimality | `lec_15.tex` | Proved, with the transversality caveat stated |
| 12–18 | Solving a Bellman equation | `lec_6.tex`, `lec_15.tex` | The Bellman operator shown to be a contraction; the a priori and a posteriori error bounds; the inflation factor $\beta/(1-\beta)$ |
| 19–25, 30 | Cake-eating problem | `lec_15.tex` | Solved by guess and verify; why it falls outside the bounded-return assumptions |
| 26–29 | Remarks on the MATLAB codes | `lec_15.tex` | Grid choice, the $\log 0$ truncation, and the discretisation error that the contraction bound does not control |
| 31–35 | Closed-form solution | `lec_15.tex` | Constants derived, including $\sum_t t\beta^t=\beta/(1-\beta)^2$ |
| 36–41 | Ramsey growth model | `lec_15.tex`, `lec_16.tex` | Euler equation and modified golden rule in discrete time; the continuous-time counterpart and its phase diagram |
| 42–62 | Lucas asset-pricing model | `lec_15.tex` | The consumer's problem, equilibrium constraints, the pricing functional equation, the stochastic discount factor, the contraction proof for the pricing operator, the log closed form, and the numerical caveats |
| 63 | References | — | Reconciled against the bibliography |

### 1.6 `Gerzensee_Logistics_2026_04.pdf` — 11 slides

Contains no mathematics. Slides 2–4 state the course objectives, the topic list
and the rationale for the topic selection; these fix the volume's scope and the
statement in the Preface that the chapters are ordered by logical dependence
rather than by the order of the four-day course. Slides 5–9 concern materials and
software; slides 10–11 the surrounding PhD curriculum.

---

## 2. Backward map: chapters to sources

| Chapter file | Slides | Supplementary reference volume | External references cited |
|---|---|---|---|
| `lec_1.tex` — Sets, Relations, Logic, and the Real Number System | none directly; presupposed by every deck | Ch. 1, Sec. 1.1–1.7, 1.10–1.11 (pp. 1–56) | Corbae–Stinchcombe–Zeman, Le Gall (2022), Ok, Rudin |
| `lec_2.tex` — Vector Spaces, Linear Maps, and Matrices | Real Analysis 12–15 | Ch. 4 (pp. 135–156), Ch. 5 (pp. 157–184), Sec. 10.7 (pp. 363–365) | Axler, Ljungqvist–Sargent, Meyer (2000) |
| `lec_3.tex` — Inner Products, Norms, and Metric Spaces | Real Analysis 5–11, 16–26, 77 | Sec. 7.1 (pp. 201–214), Def. 7.12–7.13 (p. 293) | LeRoy–Werner |
| `lec_4.tex` — Topology of Metric Spaces | Real Analysis 26–48 | Sec. 7.2–7.3 (pp. 214–238), Sec. 8.1 (pp. 261–270) | Aliprantis–Border, Rudin |
| `lec_5.tex` — Continuity, Semicontinuity, and the Weierstrass Theorem | Real Analysis 49–57 | Sec. 7.4.2 (pp. 239–252), Sec. 7.5 (pp. 254–256), Sec. 8.1 (pp. 261–270), Sec. 8.3 (pp. 271–278) | Rudin |
| `lec_6.tex` — Completeness, Contractions, and Fixed Points | Real Analysis 58–76; DP 12–18 | Sec. 8.4 (pp. 278–294), incl. Prop. 8.20–8.21 | Lucas (1978), Stokey–Lucas–Prescott |
| `lec_7.tex` — Differential Calculus in One Variable | Calculus 3–42 | Ch. 3, Sec. 11.2, 11.3, 11.7 | none; slides and reference volume only |
| `lec_8.tex` — Differential Calculus in Several Variables | Calculus 43–54 | Ch. 11 (Def. 11.1, Prop. 11.3–11.6, Thm 11.1–11.7) | Rudin |
| `lec_9.tex` — Convexity and Separation | Calculus 7–8, 52; Optimization 10–18 | Ch. 6, Ch. 10 (Thm 10.1–10.3, 10.9), Sec. 7.6, 9.1, 10.6.2, 11.3 | Aliprantis–Border, Boyd–Vandenberghe (§3.3 p. 90), Rockafellar (§23, §25) |
| `lec_10.tex` — Integration | Calculus 65–98 | Ch. 3 (integration), Sec. 3.6 (Leibniz) | Le Gall (2022), Rudin |
| `lec_11.tex` — Projection, Orthogonality, and Least Squares | Calculus 55–64 | Ch. 9 (Thm 9.1–9.4, Sec. 9.4–9.5) | none; slides and reference volume only |
| `lec_12.tex` — Constrained Optimisation | Optimization 3–44 | Ch. 12 (pp. 423–464), Sec. 13.4.1 (pp. 479–484), Thm 10.9 | Boyd–Vandenberghe, Mangasarian, Milgrom–Segal, Nash (1950) |
| `lec_13.tex` — Correspondences, the Maximum Theorem and Fixed Points | none | Ch. 13 (pp. 465–484), Sec. 8.2 (pp. 270–271) | Aliprantis–Border, Ok, Rockafellar |
| `lec_14.tex` — Probability and Conditional Expectation | Probability 3–32; Calculus 85–93 | Sec. 2.1–2.5 (pp. 57–82), Sec. 9.6 (pp. 323–332) | Brockwell–Davis, Gelman et al., Grossman–Stiglitz, Kyle, Le Gall (2022), O'Hara |
| `lec_15.tex` — Discrete-Time Dynamic Programming | DP 2–62 | Ch. 15 (Sec. 15.1.1–15.1.4, 15.2) | Bellman, Benveniste–Scheinkman, Rockafellar, Stokey–Lucas–Prescott |
| `lec_16.tex` — Continuous-Time Dynamic Optimisation | none | Ch. 16 (pp. 563–575), Prop. 7.30 (p. 288) | Amann–Escher II, Cesari (1983), Halkin (1974), Kamien–Schwartz, Pontryagin et al. (1962), Seierstad–Sydsæter (1987) |
| `appendix.tex` A — The Implicit Function Theorem | Calculus 65 | Thm 11.7 (p. 419) | — |
| `appendix.tex` B — Matrix Differentiation | Calculus 49 | Ch. 3, 11 | Axler |
| `appendix.tex` C — The Multivariate Normal Distribution | Probability 22–32; Calculus 85–93 | Sec. 2.5 | Ash–Doléans-Dade |

---

## 3. Material with no slide counterpart

Three bodies of material are in the volume because the slides' own economic
applications presuppose them, not because a slide states them.

**Chapter 13 — correspondences and fixed points.** Optimization slide 21 and
Dynamic Programming slides 12–24 both assume that a parametrised maximum exists
and varies continuously with the parameter. The slides do not prove it. The
supplementary reference volume, Ch. 13 and Sec. 8.2, supplies hemicontinuity,
Berge's maximum theorem, Brouwer and Kakutani; the chapter proves them and then
uses them for Nash equilibrium and Walrasian existence.

**Chapter 16 — continuous-time dynamic optimisation.** Dynamic Programming
slides 36–41 present the Ramsey model in discrete time. The supplementary
reference volume, Ch. 16, gives the continuous-time treatment: the
Euler–Lagrange equation, the maximum principle, the Hamilton–Jacobi–Bellman
equation, and the Keynes–Ramsey rule. The chapter also checks that the
continuous-time solutions are the short-period limits of the discrete ones.

**Appendix A — the proof of the implicit function theorem.** Calculus slide 65
advertises the theorem as an application of the contraction mapping theorem
without carrying out the construction. The appendix carries it out.

---

## 4. Conflicts between sources and how they were resolved

**Constraint sign convention.** The Optimization slides write constraints as
$g_j(x)\ge0$; most of the optimisation literature, including
Boyd–Vandenberghe, writes $g_j(x)\le0$. The slides' orientation is kept
throughout, because it makes the multiplier non-negative at a maximum without a
case distinction, and the opposite convention is recorded in the Notation and
Conventions chapter and again in Chapter 12 where the numerical solvers, which
use the opposite sign, are discussed.

**Supremum versus maximum in the Bellman equation.** Chapter 6 introduces the
Bellman operator with a supremum, because the contraction argument needs no
more. Chapter 15 replaces it with a maximum. The replacement is a theorem, not a
convention, and Chapter 15 says so explicitly and points back to Chapter 6.

**Hemicontinuity versus semicontinuity.** Both hyphenated and unhyphenated
spellings occur in the literature. The volume uses "hemicontinuous" and
"semicontinuous" throughout, following Aliprantis–Border and
Stokey–Lucas–Prescott, the two texts cited most often for this material.

**Saddle-path stability.** Chapter 2 states the Blanchard–Kahn condition for
discrete-time linear systems; Chapter 16 needs its continuous-time form. Rather
than restating it, Chapter 16 derives the eigenvalue count directly and records
the correspondence — "outside the unit circle" becomes "positive real part".

**British and American spelling.** The slides are written in American spelling
("optimization"). The notes use British spelling throughout, including in
chapter titles. Source titles quoted in the bibliography keep the spelling of the
original.

---

## 5. Material added beyond the slides and the reference volume

Each item below is present because a statement elsewhere in the volume needs it,
not for its own sake. The dependency is named in each case.

| Location | Added material | Why it is here |
|---|---|---|
| §2.6 | Singular value decomposition, Moore–Penrose pseudoinverse, operator norm, condition number, $\kappa(A^{\transp}A)=\kappa(A)^2$ | Ch. 11 forms $X^{\transp}X$ and inverts it; the accompanying regression programs do the same. Without the conditioning result the numerical remark in Ch. 11 and the collinearity discussion have no content. |
| §2.7 | Non-negative matrices, Perron–Frobenius (stated; parts (i)–(iii) cited to Meyer Ch. 8), stochastic-matrix and Hawkins–Simon corollaries (proved) | Ch. 6 §6.5 solves the Leontief system, Ch. 14 and Ch. 15 use stationary distributions of finite Markov chains, and §15.7 needs $(I-\beta P_h)^{-1}\ge0$. |
| §6.3.2 | Equicontinuity, Arzelà–Ascoli (proved), uniformly Lipschitz corollary | Ch. 16's existence remark needs compactness in $\mathcal{C}([t_0,t_1],\R^n)$; Ch. 5's infinite-dimensional Weierstrass failure is the same phenomenon. |
| §9.6 | Subgradients, existence at interior points, optimality condition, subdifferential versus gradient, Fenchel conjugate, Fenchel–Young, biconjugate, profit function as conjugate and Hotelling's lemma | Ch. 13 §13.5 asserts that concavity gives a non-empty superdifferential and that differentiability is a singleton subdifferential; that assertion was previously unsupported. |
| §13.5 | Danskin's theorem with proof, and the reading of a kink as disagreement among maximisers | The same section previously named Danskin's theorem without stating it. |
| §14.7 | Modes of convergence and their hierarchy (proved), monotone/Fatou/dominated convergence (stated, Le Gall Thm 2.4 p. 21, Thm 2.8 p. 25, Thm 2.11 p. 30), weak and strong LLN, CLT, asymptotic normality of least squares, martingales, optional stopping | The chapter's inequalities section already derived convergence in probability of sample means; the conditional-expectation construction in §14.4 uses dominated convergence; §9.7 and §15.8 are martingale statements in disguise. |
| §15.4 | Weighted-norm contraction theorem (proved) | Assumption 15.4.1(iii) fails for log and CRRA returns; the remark on unbounded returns previously only pointed at the literature. |
| §15.4.1 | Policy iteration: algorithm, monotone improvement, geometric bound, finite termination | The accompanying programs all use value function iteration; the comparison is what makes their iteration counts interpretable. |
| §16.3 | Existence of an optimal control: the Arzelà–Ascoli compactness argument, the chattering counterexample, the Filippov–Cesari convexity condition | The chapter states only necessary conditions; without this the reader has no statement about when an optimum exists. |
| §9.7 | Proper/closed/convex terminology, Fenchel–Moreau (stated, Rockafellar Thm. 12.2), the $-\sqrt{x}$ example showing $f^{\ast\ast}=f$ without a subgradient | §9.6's biconjugate proposition proves one direction only; the profit-function application needs the exact scope of $c^{\ast\ast}=c$. |
| §14.7 | Continuous mapping, Slutsky and the delta method, with Slutsky and the delta method proved and the continuous mapping theorem cited to Corbae–Stinchcombe–Zeman Thm. 9.4.3 p. 562 | The asymptotic normality of OLS previously joined an almost sure limit to a distributional limit without a theorem licensing it. |
| §15.2 | Remark distinguishing $\mathcal{B}(X,\R)$, $\mathcal{C}_b(X)$ and the bounded measurable functions as domains for the Bellman operator | The chapter had used $\mathcal{B}$ for two different spaces and cited the wrong completeness theorem. |
| §15.4.1 | Measurable-selection remark: what Berge does and does not supply, with the measurable maximum theorem cited to Aliprantis–Border Thm. 18.19 | Policy improvement asks for a selection from an argmax correspondence; Berge gives upper hemicontinuity, not a selector. |
| §15.6 | Lemma verifying Assumption 15.1.1 for the growth model on an invariant compact state space, and the remark on utility unbounded at zero consumption with the consumption-floor construction | Proposition 15.6.1 invoked Theorem 15.4.2, whose hypotheses the Ramsey problem does not satisfy as posed. |
| Figures | `svd-ellipse.tex`, `semicontinuity.tex`, `hemicontinuity.tex`, `separation.tex`, `subgradient.tex`, `vfi-error.tex`, `pi-vs-vi.tex`, `cake-paths.tex`, `ramsey-phase.tex` | The first five illustrate definitions that are hard to read from the formula alone. `vfi-error.tex` plots measured output of `DP_cake_eating.m` against its closed form under two encodings of the infeasible cells; `pi-vs-vi.tex` plots the two dynamic-programming algorithms on a randomly generated 40-state problem and is the numerical content of Theorem 15.3.3(ii); `ramsey-phase.tex` carries the computed global stable manifold of Remark 16.6.2 rather than a sketch of it. Coordinates for those three were computed in MATLAB R2025b; `cake-paths.tex` and the two loci of `ramsey-phase.tex` are closed forms evaluated by `pgfplots` itself. Every figure is drawn with `tikz`/`pgfplots` inside the document, so all nine carry the volume's own fonts and line weights rather than an imported raster. |

---

## 6. Programs: what was executed and what was observed

Every claim in the text about an accompanying program was obtained by running a
copy of it; the originals in `Supplementary/codes/` were not modified.

| Program | Environment | Observed output |
|---|---|---|
| `regression.m` | MATLAB R2025b | `rng(0)`; $\hat\beta=(0.955343, 2.940044)$ from both the normal equations and `regress` |
| `regression_Python.py` | Python 3 + NumPy | `np.random.seed(1)`; $\hat\beta=(1.023019, 3.021874)$ from both routes |
| `regression_Octave.m` | MATLAB R2025b, on a line-by-line syntax translation | `rng(0)`; $\hat\beta=(0.955343, 2.940044)$, identical to `regression.m`. Its second `fprintf` is labelled `regress` but prints `beta_hat`, not `beta_hat_2`; the two agree to $1.6\times10^{-15}$ |
| `consumer_choice_fmincon.m` | MATLAB R2025b | $x^\ast=(0.700,0.300)$, objective $0.54288$, multiplier $0.54288$ |
| `consumer_choice_python.py` | Python 3 + SciPy | $x^\ast=(0.700,0.300)$, objective $0.54285$, multiplier $0.54295$ |
| `two_periods_consumption_fmincon.m` | MATLAB R2025b | $c^\ast=(0.526,0.497)$, objective $-1.27044$, multiplier $1.90000$ |
| `two_periods_consumption_python.py` | Python 3 + SciPy | same allocation, objective $-1.27044$, multiplier $1.90002$ |
| `Nash_bargaining_fmincon.m` | MATLAB R2025b | $u^\ast=(0.7071,0.7071)$; source solves the **circular** frontier $u_1^2+u_2^2\le1$, not a linear one |
| `Nash_bargaining_python.py` | Python 3 + SciPy | $u^\ast=(0.7071,0.7071)$, multiplier $0.50000$ |
| `DP_cake_eating.m` | MATLAB R2025b | converged in 279 iterations, 1.041850 s |
| `DP_cake_eating_CRRA.m` | MATLAB R2025b | converged in 199 iterations |
| `DP_cake_eating_plot_iterations.m` | MATLAB R2025b | 0.112116 s |
| `deterministic_Ramsey_growth.m` | MATLAB R2025b | converged in 211 iterations |
| `Lucas_Tree_DP.m` | MATLAB R2025b | converged in 180 iterations |
| `consumer_choice_sqp_Octave.m` | MATLAB R2025b, translation | $x^\ast=(0.700000,0.300000)$, utility $0.542881$, budget multiplier $0.542881$, both bound multipliers $0$; matches the closed form $\alpha^\alpha(1-\alpha)^{1-\alpha}=0.542881$ |
| `two_periods_consumption_sqp_Octave.m` | MATLAB R2025b, translation | $c^\ast=(0.526316,0.497368)$, lifetime utility $-1.270436$, multiplier $1.900000$; matches $c_1=1/(1+\beta)$, $\lambda=1+\beta$ |
| `Nash_bargaining_sqp_Octave.m` | MATLAB R2025b, translation | $u^\ast=(0.707107,0.707107)$, product $0.500000$, multiplier $0.500000$; the frontier in the source is the circle $u_1^2+u_2^2\le1$ |
| `Lucas_Tree_DP_Octave.m` | MATLAB R2025b, translation | converged in 180 iterations, 0.0939 s; $\max\lvert p-\beta y/(1-\beta)\rvert=0.004896$, relative $0.0103\%$ |
| independent replication of `DP_cake_eating.m` | Python 3 + NumPy | 255 iterations; value error 12.06 at $w=0.001$, $\le0.33$ on $w\ge0.1$; policy error $\le0.00122$ above the first node; reported consumption $-0.999$ at the first node |
| repaired `DP_cake_eating.m` ($-\infty$ on infeasible cells plus the analytic value at the lowest node) | MATLAB R2025b | 51 iterations; consumption $0$ at the lowest node; value error $\le0.0238$ on $w\ge0.1$ and $0.00236$ at $w=1$; policy error $\le5.75\times10^{-4}$, one grid spacing. Observed error ratio $\exp(-0.162519)=\beta$ to five decimals |

**The Octave variants.** No Octave interpreter is installed on this machine, and
none is available to install here. Each Octave source was instead translated
into MATLAB syntax line by line — `pkg load statistics` deleted, `endfunction`
→ `end`, `rng("default")` → `rng('default')`, and `sqp(x0,phi,[],h,lb,ub)` →
`fmincon` with the `sqp` algorithm and the constraint $h(x)\ge0$ written as
$-h(x)\le0$ — and run in MATLAB R2025b. Nothing else was altered and the
originals were not touched. The translations are recorded above as
translations, not as runs of the Octave sources: the numbers verify what the
sources compute, not the behaviour of Octave's own `sqp` implementation.

**Where the code lives.** Everything run for the figures and for the numbers
quoted about the programs is kept in `Figures/matlab/`, beside the figures it
produces, so that each plotted curve can be regenerated:

| Script | What it produces |
|---|---|
| `vfi_error_data.m` | `vfi-error.dat`, the four series of `Figures/vfi-error.tex`, and every number quoted in Remark 15.6.3: iteration counts 279 and 51, the errors under each encoding, the measured contraction ratio, and the demonstration that $-\infty$ alone drives all 2000 nodes to $-\infty$ |
| `pi_vs_vi_data.m` | `pi-vs-vi.dat`, the three series of `Figures/pi-vs-vi.tex`, together with the checks that the policy iterates dominate the value iterates at every step and that the value iterates stay under the envelope $\beta^m\lVert W_0-V\rVert_\infty$ |
| `ramsey_saddle_data.m` | `ramsey-saddle.dat`, the stable arm of `Figures/ramsey-phase.tex`, with the steady state, the Jacobian, $\lambda_s=-0.181458$, $\lambda_u=0.231458$, the eigenvector slope, and the checks that the computed arm is invariant under the flow and sits on the correct side of the $\dot k=0$ locus |
| `octave_variants_check.m` | The MATLAB translations of the five Octave sources, in one file, with the closed-form comparison for each |

The tables inside `vfi-error.tex`, `pi-vs-vi.tex` and `ramsey-phase.tex` are the
`.dat` files verbatim; the header of each figure names its generator.
