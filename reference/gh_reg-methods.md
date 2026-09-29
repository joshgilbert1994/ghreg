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
              chains = 2)
#> Compiling the Stan model (once per machine; about a minute)...
summary(fit)
#> # A tibble: 7 × 8
#>   term  estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <chr>    <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1 beta    0.459     0.0884  0.279     0.631   1.00     828.    1130.
#> 2 alpha  -0.0405    0.0417 -0.122     0.0415  1.00     832.    1251.
#> 3 mu      0.443     0.0267  0.390     0.496   1.00    1737.    1241.
#> 4 sd_u1   0.129     0.0308  0.0671    0.189   1.00    1082.     436.
#> 5 sd_u2   0.0597    0.0209  0.0139    0.0989  1.00     917.     608.
#> 6 tau1    0.162     0.0256  0.111     0.212   1.00    1004.     988.
#> 7 tau2    0.0378    0.0234  0.00202   0.0873  1.00    1038.     661.
summary(fit, ci.level = 0.9, diagnostics = FALSE)
#> # A tibble: 7 × 5
#>   term  estimate std.error ci.lower ci.upper
#>   <chr>    <dbl>     <dbl>    <dbl>    <dbl>
#> 1 beta    0.459     0.0884  0.312     0.603 
#> 2 alpha  -0.0405    0.0417 -0.110     0.0295
#> 3 mu      0.443     0.0267  0.400     0.488 
#> 4 sd_u1   0.129     0.0308  0.0789    0.178 
#> 5 sd_u2   0.0597    0.0209  0.0219    0.0914
#> 6 tau1    0.162     0.0256  0.119     0.204 
#> 7 tau2    0.0378    0.0234  0.00410   0.0791
coef(fit)
#>        beta       alpha          mu       sd_u1       sd_u2        tau1 
#>  0.45925798 -0.04052779  0.44348418  0.12884894  0.05967261  0.16182152 
#>        tau2 
#>  0.03782099 
# }
```
