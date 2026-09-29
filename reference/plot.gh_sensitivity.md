# Plot a sensitivity analysis

Plots the posterior mean and interval of a parameter against the assumed
sampling correlation `rho`.

## Usage

``` r
# S3 method for class 'gh_sensitivity'
plot(
  x,
  parameter = "beta",
  ref = NULL,
  xlab = expression("Sampling correlation " * rho),
  ylab = NULL,
  main = NULL,
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

- xlab, ylab, main:

  Axis labels and title.

- ...:

  Further arguments to
  [`graphics::plot()`](https://rdrr.io/r/graphics/plot.default.html).

## Value

`x`, invisibly.
