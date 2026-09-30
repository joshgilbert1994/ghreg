# Plot a sensitivity analysis

Plots the posterior mean and credible interval of a parameter against
the assumed sampling correlation `rho`, with ggplot2.

## Usage

``` r
# S3 method for class 'gh_sensitivity'
plot(
  x,
  parameter = "beta",
  ref = NULL,
  xlab = expression("Sampling correlation " * rho),
  ylab = NULL,
  title = NULL,
  ...
)
```

## Arguments

- x:

  Output of
  [`gh_sensitivity()`](https://joshgilbert1994.github.io/ghreg/reference/gh_sensitivity.md).

- parameter:

  Parameter to plot.

- ref:

  Optional reference values to mark with dashed horizontal lines, such
  as the naive meta-regression slope. Names, if given, label the lines.

- xlab, ylab, title:

  Axis labels and title.

- ...:

  Unused.

## Value

A ggplot object, which you can modify further with `+`.

## Examples

``` r
# \donttest{
sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
                       rho = seq(0, 0.9, by = 0.3), chains = 2,
                       iter_sampling = 2000)
plot(sens, ref = c(Naive = 0.535))

plot(sens) + ggplot2::theme_minimal()

# }
```
