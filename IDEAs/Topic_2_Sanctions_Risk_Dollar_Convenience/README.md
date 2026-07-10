# Sanctions Risk and Dollar Convenience

The paper separates a local linear reserve-demand model from a matched nonlinear global scenario. Public aggregate COFER data anchor the reserve share. Country analysis uses TIC holdings scaled by total official reserves and treats custodial attribution explicitly.

## Reproduction

Run from `code/`:

```sh
julia --project=. revision_tests.jl
julia --project=. solve_model.jl
julia --project=. breakeven_sens.jl
Rscript make_figures.R
cd ..
latexmk -pdf Sanctions_Risk_Dollar_Convenience_Paper.tex
```

The Julia scripts write `output/results.json` and `output/breakeven_numbers.tex`. The R script writes the figure files and `output/quant_numbers.tex`. The manuscript imports both macro files.

## Parameter status

Observed or externally estimated inputs are separated from model-implied values and scenario inputs in Table 1. The geopolitical value, target breadth, crisis-liquidity multiplier, exposed reserve share, issuer capture rate, and network multiplier are reported as scenarios unless estimated in a future implementation of the empirical design.
