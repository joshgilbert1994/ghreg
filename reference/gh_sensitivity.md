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

  Parameters to report: any of `"beta"`, `"alpha"`, `"mu"`, `"es_sd1"`,
  `"es_sd2"`, and, for the three-level model, `"study_sd1"` and
  `"study_sd2"`. Every fit estimates all parameters; this only chooses
  which rows are kept. Unknown names are an error.

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
# \donttest{
sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
                       rho = seq(0, 0.9, by = 0.3), chains = 2,
                       iter_sampling = 2000)
sens
#> # A tibble: 4 × 10
#>     rho term  estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <dbl> <chr>    <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1   0   beta     0.678    0.0821  0.528      0.850 1.00     1874.    1840.
#> 2   0.3 beta     0.611    0.0845  0.449      0.787 1.00     1546.    1747.
#> 3   0.6 beta     0.457    0.0910  0.273      0.628 1.00     1399.    1852.
#> 4   0.9 beta     0.208    0.0961  0.00924    0.387 1.000    1597.    2003.
#> # ℹ 1 more variable: divergences <int>
plot(sens)

# }
```
