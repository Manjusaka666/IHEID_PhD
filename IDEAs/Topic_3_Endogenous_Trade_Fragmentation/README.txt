Endogenous Trade Fragmentation

Files in this folder are fully independent of the other proposal folders:
- Endogenous_Trade_Fragmentation.tex: standalone LaTeX source with its own preamble and body
- Endogenous_Trade_Fragmentation.bib: topic-specific bibliography only
- Endogenous_Trade_Fragmentation.pdf: compiled PDF

To compile from this folder:
latexmk -pdf Endogenous_Trade_Fragmentation.tex

--------------------------------------------------------------------
First-draft PAPER (July 2026), built from this proposal:
- Endogenous_Trade_Fragmentation_Paper.tex / .bib / .pdf  (25 pp.)
- code/solve_model.jl  : Julia solver (threshold economy with three feedback
                         channels: deterrence erosion, route thinning, capacity
                         scale; folds, hysteresis, planner wedge, policies);
                         writes output/results.json
- code/make_figures.R  : figures (output/fig_*.pdf), output/quant_numbers.tex,
                         output/sens_table.tex
- output/              : results, figures, number macros

Reproduce end to end (from code/):
  julia --project=. solve_model.jl
  Rscript make_figures.R
  cd .. && latexmk -pdf Endogenous_Trade_Fragmentation_Paper.tex
(biblatex uses the bibtex backend; the TeX Live biber binary is broken
on this machine.)
