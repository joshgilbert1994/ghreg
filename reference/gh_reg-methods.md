# Methods for gh_reg fits

[`summary()`](https://rdrr.io/r/base/summary.html) gives the posterior
summary of each parameter as a tibble: `estimate` and `std.error` are
the posterior mean and standard deviation, `ci.lower` and `ci.upper` are
equal-tailed credible interval limits, and `rhat`, `ess_bulk`, and
`ess_tail` are convergence diagnostics. The same tibble, at the 95%
level, is stored in `fit$summary`.

## Usage

``` r
# S3 method for class 'gh_reg'
print(x, ...)

# S3 method for class 'gh_reg'
summary(object, ci.level = 0.95, diagnostics = TRUE, ...)

# S3 method for class 'gh_reg'
coef(object, ...)

# S3 method for class 'gh_reg'
nobs(object, ...)

# S3 method for class 'gh_reg'
as_draws(x, ...)

# S3 method for class 'gh_reg'
as_draws_array(x, ...)

# S3 method for class 'gh_reg'
as_draws_df(x, ...)
```

## Arguments

- x, object:

  A
  [`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
  fit.

- ...:

  Passed to the tibble print method by
  [`print()`](https://rdrr.io/r/base/print.html); unused otherwise.

- ci.level:

  Probability mass of the credible interval.

- diagnostics:

  Include the convergence diagnostics?

## Value

[`summary()`](https://rdrr.io/r/base/summary.html) returns a tibble with
one row per parameter; [`coef()`](https://rdrr.io/r/stats/coef.html)
returns posterior means; [`nobs()`](https://rdrr.io/r/stats/nobs.html)
returns the number of effect-size pairs;
[`as_draws()`](https://mc-stan.org/posterior/reference/draws.html),
[`as_draws_array()`](https://mc-stan.org/posterior/reference/draws_array.html),
and
[`as_draws_df()`](https://mc-stan.org/posterior/reference/draws_df.html)
return the draws.

## Examples

``` r
# \donttest{
fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6,
              chains = 2, iter_sampling = 2000)
#> Compiling the Stan model (once per machine; about a minute)...
summary(fit)
#> # A tibble: 7 × 8
#>   term      estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <chr>        <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1 beta        0.460     0.0907  0.275     0.633   1.00    1475.    2323.
#> 2 alpha      -0.0407    0.0431 -0.124     0.0440  1.00    1509.    2477.
#> 3 mu          0.443     0.0262  0.391     0.495   1.00    3674.    2576.
#> 4 study_sd1   0.129     0.0304  0.0671    0.188   1.00    2135.    1100.
#> 5 study_sd2   0.0587    0.0212  0.00903   0.0965  1.00    1068.     362.
#> 6 es_sd1      0.162     0.0259  0.111     0.213   1.00    1951.    2092.
#> 7 es_sd2      0.0376    0.0235  0.00187   0.0870  1.00    1526.    1114.
summary(fit, ci.level = 0.9, diagnostics = FALSE)
#> # A tibble: 7 × 5
#>   term      estimate std.error ci.lower ci.upper
#>   <chr>        <dbl>     <dbl>    <dbl>    <dbl>
#> 1 beta        0.460     0.0907  0.308     0.606 
#> 2 alpha      -0.0407    0.0431 -0.112     0.0307
#> 3 mu          0.443     0.0262  0.401     0.487 
#> 4 study_sd1   0.129     0.0304  0.0790    0.177 
#> 5 study_sd2   0.0587    0.0212  0.0184    0.0902
#> 6 es_sd1      0.162     0.0259  0.120     0.205 
#> 7 es_sd2      0.0376    0.0235  0.00365   0.0781
coef(fit)
#>        beta       alpha          mu   study_sd1   study_sd2      es_sd1 
#>  0.46006611 -0.04074860  0.44327315  0.12903693  0.05871951  0.16177541 
#>      es_sd2 
#>  0.03756482 
# }
```
