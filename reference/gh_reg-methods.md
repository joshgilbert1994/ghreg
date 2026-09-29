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
#> Error in rstan::stan_model(model_code = code, model_name = "gh_reg"): Boost not found; call install.packages('BH')
summary(fit)
#> Error: object 'fit' not found
summary(fit, ci.level = 0.9, diagnostics = FALSE)
#> Error: object 'fit' not found
coef(fit)
#> Error: object 'fit' not found
# }
```
