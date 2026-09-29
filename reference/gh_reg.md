# Persistence meta-regression adjusted for correlated sampling error

Fits the Gilbert and Himmelsbach (2026) meta-regression of follow-up
effect sizes on endline effect sizes, accounting for the sampling error
in both and for the correlation between them. The slope `beta` is the
*conditional persistence* of effects: 1 means effects fully persist, 0
means they fully fade out.

## Usage

``` r
gh_reg(
  data,
  es1,
  se1,
  es2,
  se2,
  study = NULL,
  rho,
  prior = gh_prior(),
  backend = gh_backend(),
  chains = 4,
  cores = chains,
  iter_warmup = 1000,
  iter_sampling = 1000,
  seed = NULL,
  refresh = 0,
  ...
)
```

## Arguments

- data:

  A data frame with one row per pair of effect sizes, or `NULL` to take
  the variables from the calling environment.

- es1, se1:

  Endline effect sizes and their standard errors.

- es2, se2:

  Follow-up effect sizes and their standard errors.

- study:

  Optional study identifier, for data with more than one pair of effect
  sizes per study.

- rho:

  The correlation between the sampling errors of `es1` and `es2`: a
  single number, or a vector or column with one value per pair, each in
  (-1, 1).

- prior:

  Priors, from
  [`gh_prior()`](https://joshgilbert1994.github.io/ghreg/reference/gh_prior.md).

- backend:

  `"cmdstanr"` or `"rstan"`; see
  [`gh_backend()`](https://joshgilbert1994.github.io/ghreg/reference/gh_backend.md).

- chains:

  Number of Markov chains.

- cores:

  Number of chains to run in parallel.

- iter_warmup, iter_sampling:

  Warmup and sampling iterations per chain.

- seed:

  Random seed for Stan.

- refresh:

  How often Stan reports progress; 0 is silent.

- ...:

  Further arguments to `$sample()` (cmdstanr) or
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html),
  such as `adapt_delta` (cmdstanr) or
  `control = list(adapt_delta = .99)` (rstan).

## Value

An object of class `gh_reg` with elements

- `summary`:

  posterior summary of the parameters, a tibble with columns `term`,
  `estimate`, `std.error`, `ci.lower`, `ci.upper`, `rhat`, `ess_bulk`,
  and `ess_tail`; see
  [`summary.gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg-methods.md)

- `draws`:

  posterior draws, a
  [`posterior::draws_array`](https://mc-stan.org/posterior/reference/draws_array.html)

- `fit`:

  the `CmdStanMCMC` or `stanfit` object

- `levels`:

  2 or 3

- `n_pairs`, `n_studies`:

  sample sizes

- `rho`:

  the sampling correlations used, one per pair

- `divergences`, `max_treedepth`:

  sampler diagnostics

The parameters are `beta` (conditional persistence), `alpha` (mean true
follow-up effect when the true endline effect is 0), `mu` (mean true
endline effect), `sd_u1` and `sd_u2` (study-level SDs; three-level model
only), and `tau1` and `tau2` (effect-size-level SDs).

## Details

`es1`, `se1`, `es2`, `se2`, `study`, and `rho` are evaluated in `data`,
so they can be bare column names, expressions such as `sqrt(var1)`, or
column names as strings.

## Model

For effect-size pair \\j\\ in study \\k\\, with observed endline and
follow-up effect sizes \\\delta\_{1jk}\\ and \\\delta\_{2jk}\\,
\$\$\theta\_{1jk} = \mu + u\_{1k} + \epsilon\_{1jk}\$\$
\$\$\theta\_{2jk} = \alpha + \beta \theta\_{1jk} + u\_{2k} +
\epsilon\_{2jk}\$\$ \$\$(\delta\_{1jk}, \delta\_{2jk}) \sim
N\left((\theta\_{1jk}, \theta\_{2jk}), \Sigma\_{jk}\right),\$\$ where
\\\Sigma\_{jk}\\ has variances `se1^2` and `se2^2` and correlation
`rho`, and \\u\_{1k} \sim N(0, sd\_{u1}^2)\\, \\u\_{2k} \sim N(0,
sd\_{u2}^2)\\, \\\epsilon\_{1jk} \sim N(0, \tau_1^2)\\, and
\\\epsilon\_{2jk} \sim N(0, \tau_2^2)\\. The same `beta` links the true
effects within and between studies.

With `study = NULL`, or when every study contributes one pair, the study
level is dropped (only \\sd\_{u}^2 + \tau^2\\ would be identified) and
the model is the two-level model in the paper.

The study effects \\u\_{1k}\\ and \\u\_{2k}\\ capture clustering of the
*true* effects within studies. The sampling errors of different pairs
are assumed independent, even within a study. When a study reports
several effect sizes from the same participants, their sampling errors
are likely correlated as well, which the model does not account for.

The latent \\\theta\\, \\\epsilon\\, and \\u\\ are integrated out
analytically, so Stan samples only the hyperparameters. The posterior is
the same as that of the latent-variable program in the paper's appendix,
but sampling is faster and free of the funnel geometry that causes
divergent transitions when sampling error is large relative to
\\\tau_1\\.

## The sampling correlation `rho`

For a difference in means with a constant treatment effect, the
correlation between the endline and follow-up effect sizes equals the
correlation of the outcome across time (its test-retest reliability). It
is rarely reported, so the paper treats it as a sensitivity parameter:
fit the model over a grid of values with
[`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md).
`rho` can also be a column of study-specific values.

## References

Gilbert, J. B., & Himmelsbach, Z. (2026). *Why fadeout is (probably)
worse than we think: Adjusting for correlated sampling error in
meta-analyses of behavioral interventions* (EdWorkingPaper No. 26-1394).
Annenberg Institute at Brown University.
[doi:10.26300/87r9-qm15](https://doi.org/10.26300/87r9-qm15)

## See also

[`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md)
to vary `rho`,
[`gh_prior()`](https://joshgilbert1994.github.io/ghreg/reference/gh_prior.md),
[`gh_simulate()`](https://joshgilbert1994.github.io/ghreg/reference/gh_simulate.md).

## Examples

``` r
# \donttest{
# 2 chains keeps the examples within CRAN's limit of 2 cores; the default
# is 4 chains run in parallel
fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6,
              chains = 2)
#> Compiling the Stan model (once per machine; about a minute)...
#> Error in rstan::stan_model(model_code = code, model_name = "gh_reg"): Boost not found; call install.packages('BH')
fit
#> Error: object 'fit' not found
coef(fit)
#> Error: object 'fit' not found

# study-specific sampling correlations
gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = rho, chains = 2)
#> Compiling the Stan model (once per machine; about a minute)...
#> Error in rstan::stan_model(model_code = code, model_name = "gh_reg"): Boost not found; call install.packages('BH')
# }
```
