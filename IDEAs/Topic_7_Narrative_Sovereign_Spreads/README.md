# Replication guide

The equilibrium and simulation code is in Julia. Figures and TeX macros are produced in R. Recovery is the only externally anchored numerical input. The remaining non-implied values are scenario inputs.

From the `code` directory, run:

```sh
julia --project=. revision_tests.jl
julia --project=. chi_sens.jl
Rscript make_figures.R
```

`revision_tests.jl` imports the main solver, which regenerates `output/results.json`, and then verifies exact annual aggregation, the continuous prevalence flow, analytical price derivatives, the contraction margin, and the equilibrium-hump condition. `chi_sens.jl` writes `output/chi_numbers.tex`. The R script writes `output/quant_numbers.tex` and all paper figures, including the phase portrait.

The public empirical core uses GDELT media data. Licensed full text is reserved for historical validation. Text coverage is linked to latent investor prevalence through the measurement equation in the paper and is never treated as a wealth share without estimation.
