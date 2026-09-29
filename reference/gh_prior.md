# Priors for gh_reg()

The defaults are the priors in Gilbert and Himmelsbach (2026): standard
normal priors on `mu`, `alpha`, and `beta`, and half-Cauchy(0, 0.5)
priors on all standard deviations.

## Usage

``` r
gh_prior(mu = c(0, 1), alpha = c(0, 1), beta = c(0, 1), sd_scale = 0.5)
```

## Arguments

- mu, alpha, beta:

  Normal priors, each given as `c(mean, sd)`.

- sd_scale:

  Scale of the half-Cauchy prior on `tau1`, `tau2`, `sd_u1`, and
  `sd_u2`.

## Value

An object of class `gh_prior`, to pass to
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md).

## Examples

``` r
gh_prior()
#> Priors for gh_reg():
#>   mu    ~ normal(0, 1)
#>   alpha ~ normal(0, 1)
#>   beta  ~ normal(0, 1)
#>   tau1, tau2, sd_u1, sd_u2 ~ half-Cauchy(0, 0.5)
# a prior centered on half of effects persisting
gh_prior(beta = c(0.5, 0.25))
#> Priors for gh_reg():
#>   mu    ~ normal(0, 1)
#>   alpha ~ normal(0, 1)
#>   beta  ~ normal(0.5, 0.25)
#>   tau1, tau2, sd_u1, sd_u2 ~ half-Cauchy(0, 0.5)
```
