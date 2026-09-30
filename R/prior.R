#' Priors for gh_reg()
#'
#' The defaults are the priors in Gilbert and Himmelsbach (2026): standard
#' normal priors on `mu`, `alpha`, and `beta`, and half-Cauchy(0, 0.5) priors on
#' all standard deviations.
#'
#' @param mu,alpha,beta Normal priors, each given as `c(mean, sd)`.
#' @param sd_scale Scale of the half-Cauchy prior on all four SDs: `study_sd1`,
#'   `study_sd2`, `es_sd1`, and `es_sd2`.
#' @return An object of class `gh_prior`, to pass to [gh_reg()].
#' @examples
#' gh_prior()
#' # a prior centered on half of effects persisting
#' gh_prior(beta = c(0.5, 0.25))
#' @export
gh_prior <- function(mu = c(0, 1), alpha = c(0, 1), beta = c(0, 1), sd_scale = 0.5) {
  chk <- function(x, what) {
    if (!is.numeric(x) || length(x) != 2 || anyNA(x) || x[2] <= 0)
      stop("`", what, "` must be c(mean, sd) with sd > 0.", call. = FALSE)
    as.numeric(x)
  }
  if (!is.numeric(sd_scale) || length(sd_scale) != 1 || is.na(sd_scale) || sd_scale <= 0)
    stop("`sd_scale` must be a positive number.", call. = FALSE)
  structure(list(p_mu = chk(mu, "mu"), p_alpha = chk(alpha, "alpha"),
                 p_beta = chk(beta, "beta"), sd_scale = as.numeric(sd_scale)),
            class = "gh_prior")
}

#' @export
print.gh_prior <- function(x, ...) {
  cat("Priors for gh_reg():\n")
  cat(sprintf("  %-5s ~ normal(%g, %g)\n", c("mu", "alpha", "beta"),
              c(x$p_mu[1], x$p_alpha[1], x$p_beta[1]),
              c(x$p_mu[2], x$p_alpha[2], x$p_beta[2])), sep = "")
  cat(sprintf("  study_sd1, study_sd2, es_sd1, es_sd2 ~ half-Cauchy(0, %g)\n",
              x$sd_scale))
  invisible(x)
}
