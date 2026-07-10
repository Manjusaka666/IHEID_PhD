# Replication guide

The paper uses Julia for the equilibrium calculations and R for figures and TeX macros. All non-implied numerical inputs except recovery are scenario values. Recovery is anchored to the sovereign haircut evidence cited in the paper.

From the `code` directory, run:

```sh
julia --project=. revision_tests.jl
julia --project=. solve_model.jl
julia --project=. info_sens.jl
Rscript make_figures.R
```

The Julia scripts write `output/results.json` and `output/info_numbers.tex`. The R script reads the JSON file and writes the figures and `output/quant_numbers.tex`. The paper source imports both generated TeX files.

The empirical sequence is separate from the scenario calculation. Revision histories discipline the bias radius. Individual forecast panels discipline signal variances. Current holder-sector accounts discipline investor composition. Spreads and auctions are outcomes used to test the mechanism.
