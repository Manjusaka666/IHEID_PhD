# Five-Paper Referee v3 Revision Design

## Objective

Revise the five paper drafts in Topic 1, Topic 2, Topic 3, Topic 5, and Topic 7 to a common JPE or AER standard for economic argument and quantitative discipline, with Econometrica-level care for theorem statements and proofs.

The revision must close every issue in `Referee/referee_comments_v3.md` that can be resolved with the analytical models, the existing replication packages, public data, normally licensed data descriptions, and verifiable parameters from the literature. No draft may report an unavailable estimate as if it had been produced.

## Source of Truth

Each paper's `*_Paper.tex` file is the manuscript source of truth. The corresponding Julia solver is the source of model-generated numerical results. The R script is the source of figures and generated TeX macros. The `output/` directory contains derived artifacts and must never be edited by hand when a generating script exists.

The standalone proposal files without `_Paper` in their names remain outside the revision unless a paper explicitly inputs them. Bibliographies are paper-specific.

## Work Order

The papers will be completed in this order:

1. `Topic_1_Diagnostic_Sovereign_Risk`
2. `Topic_2_Sanctions_Risk_Dollar_Convenience`
3. `Topic_3_Endogenous_Trade_Fragmentation`
4. `Topic_5_Ambiguity_Rollover_Crises`
5. `Topic_7_Narrative_Sovereign_Spreads`

Each paper reaches its acceptance criteria before work begins on the next paper.

## Per-Paper Revision Cycle

### 1. Claim and dependency audit

Read the full manuscript, solver, figure script, generated macros, results file, and bibliography. Map every numbered result to its assumptions and appendix proof. Classify every quantitative statement as a theorem, conditional proposition, calibrated numerical property, scenario, estimate, or counterfactual.

### 2. Mathematical audit

Re-derive every lemma, proposition, corollary, first-order condition, fixed-point condition, comparative static, and welfare expression. Named theorems may be invoked only after their hypotheses are checked for the specific objects in the paper.

Every result receives an edge-case table covering parameter endpoints, corners, ties, nonattainment, multiplicity, zero-probability regions, and limiting cases. An open row must be resolved by a proof, a condition in the theorem statement, or removal of the claim.

### 3. Quantitative and source audit

Match every parameter in the manuscript to the value used by code. Record its unit, frequency, source category, source, mapping equation or target, uncertainty or range, and effect on headline results.

Sources must be original research papers, official datasets, or authoritative data documentation. The revision may use public data and descriptions of normally licensed sources. It may not fabricate proprietary estimates or imply that unacquired licensed microdata were analysed.

### 4. Code revision and reproduction

Make the smallest solver changes needed to implement the corrected model. Preserve the existing Julia and R structure unless a mathematical correction requires a local redesign. Add assertions for analytical identities, fixed-point residuals, probability bounds, monotonicity conditions, convergence, and baseline reproduction.

Regenerate JSON results, TeX number macros, sensitivity tables, and figures from code. The manuscript must consume generated numbers rather than duplicate them manually.

### 5. Manuscript revision

Rewrite the abstract, introduction, model, results, policy interpretation, conclusion, and appendices around the corrected claims. Put the question and answer first. Keep one idea per paragraph. Define notation at first use. Give an economic interpretation around each key equation.

No paper prose may contain em dashes, prose semicolons, hidden rhetorical triads, AI stock phrases, promotional adjectives, throat-clearing, stacked hedges, or meta-commentary about drafting. Policy claims must state the inequality or measurable condition that supports them.

### 6. Verification

Run the Julia project from the paper's `code/` directory, run every supplementary Julia script used by the manuscript, run the R figure script, and compile the paper from its own directory with a final single `latexmk` process.

Check for solver errors, failed assertions, unresolved citations or references, undefined controls, overfull boxes that affect readability, stale generated files, banned prose patterns, parameter mismatches, and manuscript numbers absent from generated macros.

## Paper-Specific Mathematical Deliverables

### Topic 1

Replace the abbreviated equilibrium-existence claim with a valid finite-grid statement and convergence evidence. Add strictness conditions to history-dependent pricing. Derive the survey-horizon mapping and validate it by Monte Carlo. Move long-duration debt into the quantitative implementation or remove claims that require it. Separate sovereign, lender, and global welfare.

### Topic 2

Remove all reliance on country-level COFER. Add heterogeneous reserve demand, crisis-state liquidity valuation, nonlinear global counterfactuals, issuer pass-through, and an explicit reputation state or a precisely delimited trigger benchmark. Replace a point break-even breadth with a sourced threshold surface.

### Topic 3

Replace the slope-only fold claim with saddle-node nondegeneracy conditions and global crossing conditions. Derive the multisector Jacobian multiplier and spectral-radius stability test. Separate partial-adjustment hysteresis from forward-looking equilibrium selection. State the welfare result as a threshold including the value of strategic independence.

### Topic 5

Generalize model-free exit to state-dependent exit payoffs. State the observational equivalence between ambiguity and pessimism. Distinguish threshold-strategy uniqueness from broader equilibrium uniqueness. Add ex ante precision welfare and heterogeneous type-specific payoff thresholds.

### Topic 7

Separate the primitive pricing-hump theorem from the equilibrium-hump result. Supply derivative conditions for the latter. Microfound adoption with attention costs. Use continuous-time prevalence dynamics or an invariant discrete map. Distinguish a zero-drift locus from a global basin boundary and construct debt-service pass-through from refinancing exposure.

## Acceptance Criteria

A paper is complete only when all of the following hold:

- Every v3 mathematical comment is either implemented or made inapplicable by a corrected claim.
- Every numbered result has a complete proof or an explicit, correctly scoped numerical status.
- Every proof has a written edge-case disposition table with no unresolved open row.
- Every reported calibration value matches code and has a verifiable source or a scenario label.
- Every generated result is reproducible from the checked-in Julia and R scripts.
- The final PDF compiles without undefined references or citations.
- The style lint reports no em dashes, prose semicolons, banned AI vocabulary, or rhetorical triads in manuscript prose.
- The paper contains no claim of estimation based on data that were not actually acquired and analysed.

## Cross-Paper Final Audit

After Topic 7 passes, compare the five manuscripts for consistent epistemic labels, data-access language, parameter-table fields, proof terminology, and policy-condition formatting. Re-run all replication pipelines and all five LaTeX builds in sequence. A final single-process build in each paper directory determines the reported compilation status.
