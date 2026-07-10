# Replication

Run all commands from `code` with Julia 1.12 or later.

```sh
julia --project=. -t auto revision_tests.jl
julia --project=. -t auto solve_model.jl
julia --project=. survey_mapping_mc.jl
julia --project=. -t auto solve_long_bonds_ce.jl
julia --project=. -t auto estimate_long_ce.jl
```

`solve_model.jl` produces the one-period quantitative results. `survey_mapping_mc.jl` produces the fixed-event forecast mapping. `solve_long_bonds_ce.jl` produces the long-duration benchmark using continuous temporary shocks and exact threshold probabilities. `estimate_long_ce.jl` runs the simulated-moment calibration with common random numbers. Every generated table macro and machine-readable result is written to `output`.

Compile the manuscript from the paper directory.

```sh
latexmk -pdf -interaction=nonstopmode -halt-on-error Diagnostic_Sovereign_Risk_Paper.tex
```
