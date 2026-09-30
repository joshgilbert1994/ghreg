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
#'   `"study_sd1"`, `"study_sd2"`, and, for the three-level model, `"es_sd1"`
#'   and `"es_sd2"`. Every fit estimates all parameters; this only chooses
#'   which rows are kept. Unknown names are an error.
#' @param ci.level Probability mass of the credible intervals.
#' @return A tibble of class `gh_sensitivity`, with one row per value of `rho`
#'   and parameter. The columns are `rho`, the columns of
#'   `summary(fit)` (see [summary.gh_reg()]), and the number of
#'   divergent transitions. Plot it with [plot.gh_sensitivity()].
#' @examplesIf interactive() || identical(Sys.getenv("IN_PKGDOWN"), "true")
#' sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
#'                        rho = seq(0, 0.9, by = 0.3), seed = 1)
#' sens
#' plot(sens)
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
    # es_sd1 and es_sd2 exist only in the three-level model
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
#' Plots the posterior mean and credible interval of a parameter against the
#' assumed sampling correlation `rho`, with ggplot2.
#'
#' @param x Output of [gh_sensitivity()].
#' @param parameter Parameter to plot.
#' @param ref Optional reference values to mark with dashed horizontal lines,
#'   such as the naive meta-regression slope. Names, if given, label the lines.
#' @param xlab,ylab,title Axis labels and title.
#' @param ... Unused.
#' @return A ggplot object, which you can modify further with `+`.
#' @examplesIf interactive() || identical(Sys.getenv("IN_PKGDOWN"), "true")
#' sens <- gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
#'                        rho = seq(0, 0.9, by = 0.3), seed = 1)
#' plot(sens, ref = c(Naive = 0.535))
#' plot(sens) + ggplot2::theme_minimal()
#' @export
plot.gh_sensitivity <- function(x, parameter = "beta", ref = NULL,
                                xlab = expression("Sampling correlation " * rho),
                                ylab = NULL, title = NULL, ...) {
  if (!is.character(parameter) || length(parameter) != 1)
    stop("`parameter` must be a single parameter name.", call. = FALSE)
  .check_names(parameter, unique(x$term), "Not in this sensitivity analysis")
  d <- as.data.frame(x[x$term == parameter, ])
  if (is.null(ylab))
    ylab <- if (parameter == "beta") "Conditional persistence" else parameter
  p <- ggplot2::ggplot(d, ggplot2::aes(x = .data$rho, y = .data$estimate))
  if (!is.null(ref)) {
    p <- p + ggplot2::geom_hline(yintercept = ref, linetype = "dashed",
                                 colour = "grey45")
    if (!is.null(names(ref)))
      p <- p + ggplot2::annotate("text", x = max(d$rho), y = ref,
                                 label = names(ref), hjust = 1, vjust = -0.5,
                                 size = 3.2, colour = "grey30")
  }
  p +
    ggplot2::geom_errorbar(ggplot2::aes(ymin = .data$ci.lower,
                                        ymax = .data$ci.upper), width = 0) +
    ggplot2::geom_point(size = 2.2) +
    ggplot2::labs(x = xlab, y = ylab, title = title) +
    ggplot2::theme_bw()
}

.gh_parameters <- c("beta", "alpha", "mu", "study_sd1", "study_sd2", "es_sd1",
                    "es_sd2")

.check_names <- function(x, valid, what) {
  bad <- setdiff(x, valid)
  if (length(bad))
    stop(what, ": ", paste0("\"", bad, "\"", collapse = ", "), ".\n",
         "Choose from ", paste0("\"", valid, "\"", collapse = ", "), ".",
         call. = FALSE)
  invisible(x)
}
