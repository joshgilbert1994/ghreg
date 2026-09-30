# Simulate a persistence meta-analysis

Simulates effect sizes the way the simulations in Gilbert and
Himmelsbach (2026) do: draw true endline and follow-up effects from the
persistence model, then, for each pair, simulate a two-arm randomized
trial whose outcomes are correlated `rho` across time, and estimate both
effects by a difference in means. The sampling errors of the two
estimates are therefore correlated by (approximately) `rho`.

## Usage

``` r
gh_simulate(
  n_studies = 50,
  pairs_per_study = 1,
  n = 100,
  rho = 0.5,
  mu = 0.5,
  alpha = 0,
  beta = 0.5,
  es_sd1 = 0,
  es_sd2 = 0,
  study_sd1 = 0.25,
  study_sd2 = 0
)
```

## Arguments

- n_studies:

  Number of studies.

- pairs_per_study:

  Pairs of effect sizes per study: one number, or one per study.

- n:

  Participants per trial: one number, or one per pair.

- rho:

  Correlation of the outcome across time (the test-retest reliability):
  one number, or one per pair.

- mu:

  Mean true endline effect.

- alpha:

  Mean true follow-up effect when the true endline effect is 0.

- beta:

  Conditional persistence: the slope of the true follow-up effect on the
  true endline effect.

- es_sd1:

  SD of the true endline effects across effect-size pairs within a
  study.

- es_sd2:

  Residual SD of the true follow-up effects across effect-size pairs
  within a study, given the true endline effects.

- study_sd1:

  Between-study SD of the true endline effects.

- study_sd2:

  Between-study residual SD of the true follow-up effects, given the
  true endline effects.

## Value

A data frame with one row per pair: `study`, `es_id`, `n`, `rho`, the
estimates `es1`, `se1`, `es2`, `se2`, and the true effects `theta1` and
`theta2`.

## Details

Outcomes have unit variance within arm, so the effect sizes are on a
standardized scale. Participants are split evenly between arms.

The true effects follow the model in
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md):
\$\$\theta\_{1jk} = \mu + u\_{1k} + \epsilon\_{1jk}\$\$
\$\$\theta\_{2jk} = \alpha + \beta \theta\_{1jk} + u\_{2k} +
\epsilon\_{2jk}\$\$ with study effects \\u\_{1k} \sim N(0,
\sigma\_{S1}^2)\\ and \\u\_{2k} \sim N(0, \sigma\_{S2}^2)\\ shared by
every pair in study \\k\\, and pair-level deviations \\\epsilon\_{1jk}
\sim N(0, \sigma\_{E1}^2)\\ and \\\epsilon\_{2jk} \sim N(0,
\sigma\_{E2}^2)\\. The arguments `study_sd1`, `study_sd2`, `es_sd1`, and
`es_sd2` set \\\sigma\_{S1}\\, \\\sigma\_{S2}\\, \\\sigma\_{E1}\\, and
\\\sigma\_{E2}\\, and have the same names as in the output of
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md).

By default each study contributes one pair, so the data follow the
two-level model, and the heterogeneity is set at the study level
(`study_sd1 = 0.25`, `es_sd1 = 0`). That matches
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md),
which reports a two-level model's SDs as `study_sd1` and `study_sd2`:
with one pair per study, only the total SD at each time is identified,
so a two-level fit estimates \\\sqrt{\sigma\_{S1}^2 + \sigma\_{E1}^2}\\
whichever level you put the variation in. To simulate data for the
three-level model, give studies several pairs (`pairs_per_study` above

1.  and set the pair-level SDs `es_sd1` or `es_sd2` above 0.

Each pair is simulated as its own trial, so sampling errors are
independent across pairs, including pairs from the same study. In real
meta-analyses, several effect sizes from one study often share
participants, so their sampling errors are correlated; neither
`gh_simulate()` nor
[`gh_reg()`](https://joshgilbert1994.github.io/ghreg/reference/gh_reg.md)
models that.

## Examples

``` r
set.seed(1)
d <- gh_simulate(n_studies = 100, n = 100, rho = 0.7)
head(d)
#>   study es_id   n rho       es1       se1        es2       se2    theta1
#> 1     1     1 100 0.7 0.2716376 0.2138972 0.13942871 0.2096923 0.3433865
#> 2     2     2 100 0.7 0.7206355 0.2240437 0.33806940 0.2017344 0.5459108
#> 3     3     3 100 0.7 0.3315374 0.2174811 0.15356801 0.2117522 0.2910928
#> 4     4     4 100 0.7 1.0310525 0.2009144 0.53809463 0.2126681 0.8988202
#> 5     5     5 100 0.7 0.6116389 0.2034935 0.25324465 0.1951599 0.5823769
#> 6     6     6 100 0.7 0.1522272 0.2121770 0.00430808 0.2165604 0.2948829
#>      theta2
#> 1 0.1716933
#> 2 0.2729554
#> 3 0.1455464
#> 4 0.4494101
#> 5 0.2911885
#> 6 0.1474415
# the naive meta-regression slope is inflated (true beta = 0.5)
coef(lm(es2 ~ es1, d))
#> (Intercept)         es1 
#> -0.06306031  0.61356804 

# three-level data: 40 studies with 3 pairs each and study-level variation
d3 <- gh_simulate(n_studies = 40, pairs_per_study = 3, rho = 0.7,
                  es_sd1 = 0.15, study_sd1 = 0.2, study_sd2 = 0.05)
table(table(d3$study))
#> 
#>  3 
#> 40 
```
