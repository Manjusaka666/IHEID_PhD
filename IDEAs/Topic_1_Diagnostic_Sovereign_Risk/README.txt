Diagnostic Sovereign Risk

Files in this folder are fully independent of the other proposal folders:
- Diagnostic_Sovereign_Risk.tex: standalone LaTeX source with its own preamble and body
- Diagnostic_Sovereign_Risk.bib: topic-specific bibliography only
- Diagnostic_Sovereign_Risk.pdf: compiled PDF

To compile from this folder:
latexmk -pdf Diagnostic_Sovereign_Risk.tex

--------------------------------------------------------------------
First-draft PAPER (July 2026), built from this proposal:
- Diagnostic_Sovereign_Risk_Paper.tex / .bib / .pdf  (26 pp., self-contained)
- code/solve_model.jl  : Julia solver (Eaton-Gersovitz + diagnostic lenders);
                         writes output/results.json
- code/solve_gov.jl    : 2x2 government/lender beliefs + debt-ceiling welfare;
                         writes output/results_gov.json
- code/make_figures.R  : figures (output/fig_*.pdf) and output/quant_numbers.tex,
                         the macro file with every model-generated number in the text
- output/              : results, figures, number macros

Reproduce end to end (from code/):
  julia --project=. -t auto solve_model.jl
  julia --project=. -t auto solve_gov.jl
  Rscript make_figures.R
  cd .. && latexmk -pdf Diagnostic_Sovereign_Risk_Paper.tex
(biblatex uses the bibtex backend because the TeX Live biber binary is broken
on this machine.)
