# Choose a Stan backend

Returns the backend
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
uses by default: the `ghreg.backend` option if set, otherwise
`"cmdstanr"` when cmdstanr and CmdStan are installed, and `"rstan"`
otherwise.

## Usage

``` r
gh_backend()
```

## Value

`"cmdstanr"` or `"rstan"`.

## Examples

``` r
gh_backend()
#> [1] "rstan"
# options(ghreg.backend = "rstan")  # to always use rstan
```
