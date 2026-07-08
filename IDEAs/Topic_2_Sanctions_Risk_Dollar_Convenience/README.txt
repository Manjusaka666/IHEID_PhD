Sanctions Risk and Dollar Convenience

Files in this folder are fully independent of the other proposal folders:
- Sanctions_Risk_Dollar_Convenience.tex: standalone LaTeX source with its own preamble and body
- Sanctions_Risk_Dollar_Convenience.bib: topic-specific bibliography only
- Sanctions_Risk_Dollar_Convenience.pdf: compiled PDF

To compile from this folder:
latexmk -pdf Sanctions_Risk_Dollar_Convenience.tex

--------------------------------------------------------------------
First-draft PAPER (July 2026), built from this proposal:
- Sanctions_Risk_Dollar_Convenience_Paper.tex / .bib / .pdf  (21 pp.)
- code/solve_model.jl  : Julia solver (closed-form LQ reserve-network model,
                         Ramsey vs discretion, Laffer curve, counterfactuals);
                         writes output/results.json
- code/make_figures.R  : figures (output/fig_*.pdf) and output/quant_numbers.tex
- output/              : results, figures, number macros

Reproduce end to end (from code/):
  julia --project=. solve_model.jl
  Rscript make_figures.R
  cd .. && latexmk -pdf Sanctions_Risk_Dollar_Convenience_Paper.tex
(biblatex uses the bibtex backend; the TeX Live biber binary is broken
on this machine.)
