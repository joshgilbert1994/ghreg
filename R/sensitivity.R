#' Sensitivity of conditional persistence to the sampling correlation
#'
#' Refits [gh_reg()] over a grid of sampling correlations `rho`, the approach
#' recommended by Gilbert and Himmelsbach (2026) when the correlation of the
#' outcome across time is unknown. The Stan model is compiled once and reused.
#'
#' @param ... Arguments to [gh_reg()], other than `rho`.
#' @param rho Values of the sampling correlation to try. Each value is applied
#'   to every pair of effect sizes.
#' @param parameters Parameters to report: any of `"beta"`, `"alpha"`, `"mu"`,
#'   `"tau1"`, `"tau2"`, and, for the three-level model, `"sd_u1"` and
#'   `"sd_u2"`. Every fit estimates all parameters; this only chooses which
#'   rows are kept. Unknown names are an error.
#' @param ci.level Probability mass of the credible intervals.
#' @return A tibble of class `gh_sensitivity`, with one row per value of `rho`
#'   and parameter. The columns are `rho`, the columns of
#'   `summary(fit)` (see [summary.gh_reg()]), and the number of
#'   divergent transitions. Plot it with [plot.gh_sensitivity()].
#' @examples
#' \donttest{
#' sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
#'                        rho = seq(0, 0.9, by = 0.3), chains = 2)
#' sens
#' plot(sens)
#' }
#' @export
gh_sensitivity <- function(..., rho = seq(0, 0.9, by = 0.1), parameters = "beta",
                           ci.level = 0.95) {
  if (!is.numeric(rho) || !length(rho)) stop("`rho` must be a numeric vector.", call. = FALSE)
  # catch typos before fitting anything
  if (!is.character(parameters) || !length(parameters) || anyNA(parameters))
    stop("`parameters` must be a character vector of parameter names.", call. = FALSE)
  .check_names(parameters, .gh_parameters, "Unknown `parameters`")
  out <- lapply(rho, function(rr) {
    f <- gh_reg(..., rho = !!rr)
    # sd_u1 and sd_u2 exist only in the three-level model
    .check_names(parameters, f$summary$term,
                 sprintf("Not in this %d-level model", f$levels))
    s <- .summarise(f$draws, ci.level = ci.level)
    s <- s[s$term %in% parameters, ]
    s <- tibble::add_column(s, rho = rr, .before = 1)
    s$divergences <- f$divergences
    s
  })
  out <- do.call(rbind, out)
  class(out) <- c("gh_sensitivity", class(out))
  out
}

#' Plot a sensitivity analysis
#'
#' Plots the posterior mean and interval of a parameter against the assumed
#' sampling correlation `rho`.
#'
#' @param x Output of [gh_sensitivity()].
#' @param parameter Parameter to plot.
#' @param ref Optional reference values to mark with dashed horizontal lines,
#'   such as the naive meta-regression slope. Names, if given, label the lines.
#' @param xlab,ylab,main Axis labels and title.
#' @param ... Further arguments to [graphics::plot()].
#' @return `x`, invisibly.
#' @export
plot.gh_sensitivity <- function(x, parameter = "beta", ref = NULL,
                                xlab = expression("Sampling correlation " * rho),
                                ylab = NULL, main = NULL, ...) {
  if (!is.character(parameter) || length(parameter) != 1)
    stop("`parameter` must be a single parameter name.", call. = FALSE)
  .check_names(parameter, unique(x$term), "Not in this sensitivity analysis")
  d <- x[x$term == parameter, ]
  lo <- d$ci.lower; hi <- d$ci.upper
  if (is.null(ylab))
    ylab <- if (parameter == "beta") "Conditional persistence" else parameter
  graphics::plot(d$rho, d$estimate, ylim = range(lo, hi, ref), pch = 19,
                 xlab = xlab, ylab = ylab, main = main, las = 1, ...)
  graphics::arrows(d$rho, lo, d$rho, hi, length = 0, lwd = 1.5)
  if (!is.null(ref)) {
    graphics::abline(h = ref, lty = 2, col = "grey40")
    if (!is.null(names(ref)))
      graphics::text(max(d$rho), ref, names(ref), pos = 3, cex = 0.8, col = "grey30")
  }
  invisible(x)
}

.gh_parameters <- c("beta", "alpha", "mu", "sd_u1", "sd_u2", "tau1", "tau2")

.check_names <- function(x, valid, what) {
  bad <- setdiff(x, valid)
  if (length(bad))
    stop(what, ": ", paste0("\"", bad, "\"", collapse = ", "), ".\n",
         "Choose from ", paste0("\"", valid, "\"", collapse = ", "), ".",
         call. = FALSE)
  invisible(x)
}
