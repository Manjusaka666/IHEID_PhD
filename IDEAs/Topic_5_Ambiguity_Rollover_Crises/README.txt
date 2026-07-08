Ambiguity and Sovereign Rollover Crises

Files in this folder are fully independent of the other proposal folders:
- Ambiguity_Rollover_Crises.tex: standalone LaTeX source with its own preamble and body
- Ambiguity_Rollover_Crises.bib: topic-specific bibliography only
- Ambiguity_Rollover_Crises.pdf: compiled PDF

To compile from this folder:
latexmk -pdf Ambiguity_Rollover_Crises.tex

--------------------------------------------------------------------
First-draft PAPER (July 2026), built from this proposal:
- Ambiguity_Rollover_Crises_Paper.tex / .bib / .pdf  (21 pp.)
- code/solve_model.jl  : Julia solver (global rollover game with multiple-priors
                         creditors; fragility frontier, transparency sign map,
                         distrust-vs-noise, QT and CAC experiments);
                         writes output/results.json
- code/make_figures.R  : figures (output/fig_*.pdf) and output/quant_numbers.tex
- output/              : results, figures, number macros

Reproduce end to end (from code/):
  julia --project=. solve_model.jl
  Rscript make_figures.R
  cd .. && latexmk -pdf Ambiguity_Rollover_Crises_Paper.tex
(biblatex uses the bibtex backend; the TeX Live biber binary is broken
on this machine.)
