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

  the `CmdStanMCMC` or `stanfit` object, which keeps the Stan program's
  names (`es_sd1` and `es_sd2` in the two-level model)

- `levels`:

  2 or 3

- `n_pairs`, `n_studies`:

  sample sizes

- `rho`:

  the sampling correlations used, one per pair

- `divergences`, `max_treedepth`:

  sampler diagnostics

The parameters are

- `beta`:

  conditional persistence

- `alpha`:

  mean true follow-up effect when the true endline effect is 0

- `mu`:

  mean true endline effect

- `study_sd1`:

  between-study SD of the true endline effects

- `study_sd2`:

  between-study residual SD of the true follow-up effects, given the
  true endline effects

- `es_sd1`:

  SD of the true endline effects across effect-size pairs within a study
  (three-level model only)

- `es_sd2`:

  residual SD of the true follow-up effects across effect-size pairs
  within a study, given the true endline effects (three-level model
  only)

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
`rho`, and \\u\_{1k} \sim N(0, \sigma\_{S1}^2)\\, \\u\_{2k} \sim N(0,
\sigma\_{S2}^2)\\, \\\epsilon\_{1jk} \sim N(0, \sigma\_{E1}^2)\\, and
\\\epsilon\_{2jk} \sim N(0, \sigma\_{E2}^2)\\. The same `beta` links the
true effects within and between studies.

The four standard deviations \\\sigma\_{S1}\\, \\\sigma\_{S2}\\,
\\\sigma\_{E1}\\, and \\\sigma\_{E2}\\ are reported as `study_sd1`,
`study_sd2`, `es_sd1`, and `es_sd2`: S (study) is the between-study
level and E (effect size) the level of effect-size pairs within studies.
The "1" SDs describe the true endline effects. The "2" SDs are
*residual*: they describe the true follow-up effects after conditioning
on the true endline effects, so the total SD of the true follow-up
effects is at least as large (larger whenever `beta` is not 0).

With `study = NULL`, or when every study contributes one pair, the model
has a single level of heterogeneity: the two-level model in the paper,
which treats each pair as its own study. Only the total variance across
pairs is identified, so the output reports it as the between-study SDs
`study_sd1` and `study_sd2` (the paper's \\\tau_1\\ and \\\tau_2\\), and
there are no `es_sd1` or `es_sd2`. If studies do contribute several
pairs, pass `study` to fit the three-level model.

The study effects \\u\_{1k}\\ and \\u\_{2k}\\ capture clustering of the
*true* effects within studies. The sampling errors of different pairs
are assumed independent, even within a study. When a study reports
several effect sizes from the same participants, their sampling errors
are likely correlated as well, which the model does not account for.

The latent \\\theta\\, \\\epsilon\\, and \\u\\ are integrated out
analytically, so Stan samples only the hyperparameters. The posterior is
the same as that of the latent-variable program in the paper's appendix,
but sampling is faster and free of the funnel geometry that causes
divergent transitions when sampling error is large relative to the
heterogeneity.

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
fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6,
              seed = 1)
fit
#> Gilbert-Himmelsbach persistence meta-regression
#> 3-level model: 174 pairs of effect sizes in 60 studies
#> Sampling correlation (rho): 0.6
#> Backend: rstan, 4 chains x 1000 draws; 0 divergent transitions
#> 
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
coef(fit)
#>        beta       alpha          mu   study_sd1   study_sd2      es_sd1 
#>  0.45357769 -0.03807829  0.44407135  0.13054858  0.05866494  0.16103195 
#>      es_sd2 
#>  0.03734233 

# study-specific sampling correlations
gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = rho, seed = 1)
#> Gilbert-Himmelsbach persistence meta-regression
#> 3-level model: 174 pairs of effect sizes in 60 studies
#> Sampling correlation (rho): varies, 0.23 to 0.94 (mean 0.67)
#> Backend: rstan, 4 chains x 1000 draws; 0 divergent transitions
#> 
#> # A tibble: 7 × 8
#>   term      estimate std.error ci.lower ci.upper  rhat ess_bulk ess_tail
#>   <chr>        <dbl>     <dbl>    <dbl>    <dbl> <dbl>    <dbl>    <dbl>
#> 1 beta        0.337     0.0911  0.161     0.517  1.00     1583.    2097.
#> 2 alpha       0.0124    0.0431 -0.0711    0.0947 1.000    1599.    1996.
#> 3 mu          0.443     0.0269  0.389     0.497  1.00     3379.    2515.
#> 4 study_sd1   0.139     0.0275  0.0835    0.193  1.00     2560.    1763.
#> 5 study_sd2   0.0618    0.0212  0.0141    0.100  1.00     2046.     884.
#> 6 es_sd1      0.162     0.0242  0.117     0.212  1.00     2354.    2240.
#> 7 es_sd2      0.0592    0.0238  0.00818   0.102  1.00     1487.     809.
```
