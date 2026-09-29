# ghreg: Persistence Meta-Regression Adjusted for Correlated Sampling Error

Meta-analyses of intervention effects often measure persistence by
regressing follow-up effect sizes on endline effect sizes. Because both
effect sizes come from the same participants and outcomes, their
sampling errors are correlated, and the naive slope is usually too
large. ghreg fits the Bayesian meta-regression of Gilbert and
Himmelsbach (2026), which models both sampling errors and their
correlation, and supports the sensitivity analysis the paper recommends
when that correlation is unknown.

## Main functions

- [`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
  fits the model for a given sampling correlation.

- [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md)
  refits it over a range of sampling correlations.

- [`gh_simulate()`](https://joshgilbert1994.github.io/ghreg/reference/gh_simulate.md)
  simulates meta-analytic data from the model.

- [`gh_prior()`](https://joshgilbert1994.github.io/ghreg/reference/gh_prior.md)
  sets the priors.

## References

Gilbert, J. B., & Himmelsbach, Z. (2026). *Why fadeout is (probably)
worse than we think: Adjusting for correlated sampling error in
meta-analyses of behavioral interventions* (EdWorkingPaper No. 26-1394).
Annenberg Institute at Brown University.
[doi:10.26300/87r9-qm15](https://doi.org/10.26300/87r9-qm15)

## See also

Useful links:

- <https://github.com/joshgilbert1994/ghreg>

- <https://joshgilbert1994.github.io/ghreg/>

- Report bugs at <https://github.com/joshgilbert1994/ghreg/issues>

## Author

**Maintainer**: Joshua B. Gilbert <joshua_gilbert@gse.harvard.edu>

Authors:

- Joshua B. Gilbert <joshua_gilbert@gse.harvard.edu>
