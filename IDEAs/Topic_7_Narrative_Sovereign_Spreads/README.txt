Narrative Sovereign Spreads

Files in this folder are fully independent of the other proposal folders:
- Narrative_Sovereign_Spreads.tex: standalone LaTeX source with its own preamble and body
- Narrative_Sovereign_Spreads.bib: topic-specific bibliography only
- Narrative_Sovereign_Spreads.pdf: compiled PDF

To compile from this folder:
latexmk -pdf Narrative_Sovereign_Spreads.tex

--------------------------------------------------------------------
First-draft PAPER (July 2026), built from this proposal:
- Narrative_Sovereign_Spreads_Paper.tex / .bib / .pdf  (21 pp.)
- code/solve_model.jl  : Julia solver (sovereign pricing block with doom-loop
                         fixed point; SIR narrative block with decision-relevant
                         adoption; hump, susceptible zone, outbreak paths,
                         Monte Carlo crisis wedge, policy timing);
                         writes output/results.json
- code/make_figures.R  : figures (output/fig_*.pdf) and output/quant_numbers.tex
- output/              : results, figures, number macros

Reproduce end to end (from code/):
  julia --project=. solve_model.jl
  Rscript make_figures.R
  cd .. && latexmk -pdf Narrative_Sovereign_Spreads_Paper.tex
(biblatex uses the bibtex backend; the TeX Live biber binary is broken
on this machine.)
