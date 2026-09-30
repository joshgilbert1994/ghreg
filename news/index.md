# Changelog

## ghreg 0.2.1

- In the two-level model (`study = NULL`, or one pair per study), the
  SDs are now reported as the between-study SDs `study_sd1` and
  `study_sd2`, as in a standard random-effects meta-analysis (the
  paper’s tau_1 and tau_2), instead of `es_sd1` and `es_sd2`. The
  estimates are unchanged; `es_sd1` and `es_sd2` now appear only in the
  three-level model.
- [`gh_simulate()`](https://joshgilbert1994.github.io/ghreg/reference/gh_simulate.md)
  now puts its default heterogeneity at the study level
  (`study_sd1 = 0.25`, `es_sd1 = 0`), matching how a two-level fit
  reports it. With the default one pair per study, the simulated data
  are identical to before.
- The model-fitting examples now run on the website and with
  [`example()`](https://rdrr.io/r/utils/example.html), but not in
  `R CMD check`, so they use the default settings and the website no
  longer shows `\donttest` markers.

## ghreg 0.2.0

- The variance components have clearer names, in the output of
  [`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
  and
  [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md),
  in `gh_sensitivity(parameters = )`, and as arguments of
  [`gh_simulate()`](https://joshgilbert1994.github.io/ghreg/reference/gh_simulate.md):
  `sd_u1` and `sd_u2` are now `study_sd1` and `study_sd2`, and `tau1`
  and `tau2` are now `es_sd1` and `es_sd2`. The estimates are unchanged.
  The documentation now says explicitly that the SDs ending in 2 are
  residual SDs of the true follow-up effects given the true endline
  effects.
- [`plot()`](https://rdrr.io/r/graphics/plot.default.html) on a
  [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md)
  result now draws with ggplot2 and returns a ggplot object, so it can
  be customized with `+`. Its `main` argument is now `title`. The
  vignette’s figures also use ggplot2.
- Equations on the package website’s help pages now render (they showed
  as raw LaTeX).
- The low effective-sample-size warning now uses a threshold of 100 per
  chain (400 with the default 4 chains) and names the parameters
  involved.

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
