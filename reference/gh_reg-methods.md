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
fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6,
              seed = 1)
#> Compiling the Stan model (once per machine; about a minute)...
summary(fit)
#> # A tibble: 7 × 8
#>   term      estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <chr>        <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1 beta        0.454     0.0914  0.273     0.625   1.00    1392.    2426.
#> 2 alpha      -0.0381    0.0437 -0.123     0.0474  1.00    1415.    2444.
#> 3 mu          0.444     0.0265  0.392     0.497   1.00    3265.    2605.
#> 4 study_sd1   0.131     0.0280  0.0734    0.186   1.00    2759.    1748.
#> 5 study_sd2   0.0587    0.0210  0.0125    0.0963  1.00    1314.     782.
#> 6 es_sd1      0.161     0.0253  0.112     0.210   1.00    2403.    2031.
#> 7 es_sd2      0.0373    0.0232  0.00208   0.0849  1.00    1303.    1194.
summary(fit, ci.level = 0.9, diagnostics = FALSE)
#> # A tibble: 7 × 5
#>   term      estimate std.error ci.lower ci.upper
#>   <chr>        <dbl>     <dbl>    <dbl>    <dbl>
#> 1 beta        0.454     0.0914  0.300     0.604 
#> 2 alpha      -0.0381    0.0437 -0.111     0.0343
#> 3 mu          0.444     0.0265  0.401     0.488 
#> 4 study_sd1   0.131     0.0280  0.0835    0.176 
#> 5 study_sd2   0.0587    0.0210  0.0212    0.0908
#> 6 es_sd1      0.161     0.0253  0.119     0.203 
#> 7 es_sd2      0.0373    0.0232  0.00434   0.0779
coef(fit)
#>        beta       alpha          mu   study_sd1   study_sd2      es_sd1 
#>  0.45357769 -0.03807829  0.44407135  0.13054858  0.05866494  0.16103195 
#>      es_sd2 
#>  0.03734233 
```
