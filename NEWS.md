# ghreg 0.2.0

* The variance components have clearer names, in the output of `gh_reg()` and `gh_sensitivity()`, in `gh_sensitivity(parameters = )`, and as arguments of `gh_simulate()`: `sd_u1` and `sd_u2` are now `study_sd1` and `study_sd2`, and `tau1` and `tau2` are now `es_sd1` and `es_sd2`. The estimates are unchanged. The documentation now says explicitly that the SDs ending in 2 are residual SDs of the true follow-up effects given the true endline effects.
* `plot()` on a `gh_sensitivity()` result now draws with ggplot2 and returns a ggplot object, so it can be customized with `+`. Its `main` argument is now `title`. The vignette's figures also use ggplot2.
* Equations on the package website's help pages now render (they showed as raw LaTeX).
* The low effective-sample-size warning now uses a threshold of 100 per chain (400 with the default 4 chains) and names the parameters involved.

# ghreg 0.1.0

* First release: `gh_reg()`, `gh_sensitivity()`, `gh_prior()`, `gh_simulate()`, and the `persist_sim` data set.
* Fits, `summary()`, and `gh_sensitivity()` return tibbles with broom-style column names (`estimate`, `std.error`, `ci.lower`, `ci.upper`).
