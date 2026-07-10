# Endogenous Trade Fragmentation

The quantitative model contains three sectors coupled through aggregate fragmentation. Local comparative statics use the full Jacobian and report the spectral radius, direct sector responses, and cross-sector spillovers. Fold locations are refined by solving the equilibrium and tangency equations jointly.

## Reproduction

Run from `code/`:

```sh
julia --project=. revision_tests.jl
julia --project=. solve_model.jl
julia --project=. dispersion_sens.jl
julia --project=. phase_diagram.jl
Rscript make_figures.R
Rscript make_phase_fig.R
cd ..
latexmk -pdf Endogenous_Trade_Fragmentation_Paper.tex
```

The main solver writes `output/results.json`. The R scripts generate manuscript macros and figures. Scenario inputs are labeled as scenarios in the calibration table.

## Data architecture

The public empirical unit is an importer-exporter-HS6 relationship. BACI supplies trade values and quantities. OECD ICIO and CEPII GeoDep supply criticality inputs. MAcMap-HS6 supplies tariffs. IMF PortWatch supplies disruption events. GSDB release 4 and a public dispute chronology supply the escalation sample.
