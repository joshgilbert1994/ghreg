#' Methods for gh_reg fits
#'
#' `summary()` gives the posterior summary of each parameter as a tibble:
#' `estimate` and `std.error` are the posterior mean and standard deviation,
#' `ci.lower` and `ci.upper` are equal-tailed credible interval limits, and
#' `rhat`, `ess_bulk`, and `ess_tail` are convergence diagnostics. The same
#' tibble, at the 95% level, is stored in `fit$summary`.
#'
#' @param x,object A [gh_reg()] fit.
#' @param ci.level Probability mass of the credible interval.
#' @param diagnostics Include the convergence diagnostics?
#' @param ... Passed to the tibble print method by `print()`; unused otherwise.
#' @return `summary()` returns a tibble with one row per parameter; `coef()`
#'   returns posterior means; `nobs()` returns the number of effect-size pairs;
#'   `as_draws()`, `as_draws_array()`, and `as_draws_df()` return the draws.
#' @examples
#' \donttest{
#' fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6)
#' summary(fit)
#' summary(fit, ci.level = 0.9, diagnostics = FALSE)
#' coef(fit)
#' }
#' @name gh_reg-methods
NULL

#' @rdname gh_reg-methods
#' @export
print.gh_reg <- function(x, ...) {
  cat("Gilbert-Himmelsbach persistence meta-regression\n")
  cat(sprintf("%d-level model: %d pairs of effect sizes%s\n", x$levels, x$n_pairs,
              if (x$levels == 3) sprintf(" in %d studies", x$n_studies) else ""))
  r <- unique(x$rho)
  cat("Sampling correlation (rho): ",
      if (length(r) == 1) format(r, digits = 3)
      else sprintf("varies, %s to %s (mean %s)", format(min(r), digits = 2),
                   format(max(r), digits = 2), format(mean(x$rho), digits = 2)),
      "\n", sep = "")
  cat(sprintf("Backend: %s, %d chains x %d draws; %d divergent transitions\n\n",
              x$backend, posterior::nchains(x$draws), posterior::niterations(x$draws),
              x$divergences))
  print(x$summary, ...)
  invisible(x)
}

#' @rdname gh_reg-methods
#' @export
summary.gh_reg <- function(object, ci.level = 0.95, diagnostics = TRUE, ...) {
  s <- .summarise(object$draws, ci.level = ci.level)
  if (!diagnostics) s <- s[c("term", "estimate", "std.error", "ci.lower", "ci.upper")]
  s
}

#' @rdname gh_reg-methods
#' @export
coef.gh_reg <- function(object, ...) {
  stats::setNames(object$summary$estimate, object$summary$term)
}

#' @rdname gh_reg-methods
#' @export
nobs.gh_reg <- function(object, ...) object$n_pairs

#' @rdname gh_reg-methods
#' @importFrom posterior as_draws
#' @method as_draws gh_reg
#' @export
as_draws.gh_reg <- function(x, ...) x$draws

#' @rdname gh_reg-methods
#' @importFrom posterior as_draws_array
#' @method as_draws_array gh_reg
#' @export
as_draws_array.gh_reg <- function(x, ...) x$draws

#' @rdname gh_reg-methods
#' @importFrom posterior as_draws_df
#' @method as_draws_df gh_reg
#' @export
as_draws_df.gh_reg <- function(x, ...) posterior::as_draws_df(x$draws)

#' @export
posterior::as_draws

#' @export
posterior::as_draws_array

#' @export
posterior::as_draws_df
