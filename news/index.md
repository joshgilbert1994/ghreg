# Changelog

## ghreg 0.1.0

- First release:
  [`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md),
  [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md),
  [`gh_prior()`](https://joshgilbert1994.github.io/ghreg/reference/gh_prior.md),
  [`gh_simulate()`](https://joshgilbert1994.github.io/ghreg/reference/gh_simulate.md),
  and the `persist_sim` data set.
- Fits, [`summary()`](https://rdrr.io/r/base/summary.html), and
  [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md)
  return tibbles with broom-style column names (`estimate`, `std.error`,
  `ci.lower`, `ci.upper`).
