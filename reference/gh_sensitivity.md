# Sensitivity of conditional persistence to the sampling correlation

Refits
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
over a grid of sampling correlations `rho`, the approach recommended by
Gilbert and Himmelsbach (2026) when the correlation of the outcome
across time is unknown. The Stan model is compiled once and reused.

## Usage

``` r
gh_sensitivity(
  ...,
  rho = seq(0, 0.9, by = 0.1),
  parameters = "beta",
  ci.level = 0.95
)
```

## Arguments

- ...:

  Arguments to
  [`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md),
  other than `rho`.

- rho:

  Values of the sampling correlation to try. Each value is applied to
  every pair of effect sizes.

- parameters:

  Parameters to report: any of `"beta"`, `"alpha"`, `"mu"`,
  `"study_sd1"`, `"study_sd2"`, and, for the three-level model,
  `"es_sd1"` and `"es_sd2"`. Every fit estimates all parameters; this
  only chooses which rows are kept. Unknown names are an error.

- ci.level:

  Probability mass of the credible intervals.

## Value

A tibble of class `gh_sensitivity`, with one row per value of `rho` and
parameter. The columns are `rho`, the columns of `summary(fit)` (see
[`summary.gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg-methods.md)),
and the number of divergent transitions. Plot it with
[`plot.gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/plot.gh_sensitivity.md).

## Examples

``` r
sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
                       rho = seq(0, 0.9, by = 0.3), seed = 1)
sens
#> # A tibble: 4 × 10
#>     rho term  estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <dbl> <chr>    <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1   0   beta     0.677    0.0859  0.519      0.861  1.00    1893.    2147.
#> 2   0.3 beta     0.612    0.0828  0.446      0.778  1.00    1778.    2134.
#> 3   0.6 beta     0.454    0.0914  0.273      0.625  1.00    1392.    2426.
#> 4   0.9 beta     0.207    0.100  -0.00259    0.394  1.00    1363.    1557.
#> # ℹ 1 more variable: divergences <int>
plot(sens)
```
