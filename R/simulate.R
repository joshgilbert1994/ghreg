#' Simulate a persistence meta-analysis
#'
#' Simulates effect sizes the way the simulations in Gilbert and Himmelsbach
#' (2026) do: draw true endline and follow-up effects from the persistence
#' model, then, for each pair, simulate a two-arm randomized trial whose
#' outcomes are correlated `rho` across time, and estimate both effects by a
#' difference in means. The sampling errors of the two estimates are therefore
#' correlated by (approximately) `rho`.
#'
#' Outcomes have unit variance within arm, so the effect sizes are on a
#' standardized scale. Participants are split evenly between arms.
#'
#' @param n_studies Number of studies.
#' @param pairs_per_study Pairs of effect sizes per study: one number, or one
#'   per study.
#' @param n Participants per trial: one number, or one per pair.
#' @param rho Correlation of the outcome across time (the test-retest
#'   reliability): one number, or one per pair.
#' @param mu,alpha,beta,tau1,tau2,sd_u1,sd_u2 Parameters of the persistence
#'   model; see [gh_reg()]. With `sd_u1 = sd_u2 = 0` studies are exchangeable.
#' @return A data frame with one row per pair: `study`, `es_id`, `n`, `rho`,
#'   the estimates `es1`, `se1`, `es2`, `se2`, and the true effects `theta1`
#'   and `theta2`.
#' @examples
#' set.seed(1)
#' d <- gh_simulate(n_studies = 100, n = 100, rho = 0.7)
#' head(d)
#' # the naive meta-regression slope is inflated (true beta = 0.5)
#' coef(lm(es2 ~ es1, d))
#' @export
gh_simulate <- function(n_studies = 50, pairs_per_study = 1, n = 100, rho = 0.5,
                        mu = 0.5, alpha = 0, beta = 0.5, tau1 = 0.25, tau2 = 0,
                        sd_u1 = 0, sd_u2 = 0) {
  pairs_per_study <- rep_len(pairs_per_study, n_studies)
  if (any(pairs_per_study < 1)) stop("`pairs_per_study` must be at least 1.", call. = FALSE)
  study <- rep(seq_len(n_studies), pairs_per_study)
  K <- length(study)
  if (!length(n) %in% c(1, K) || !length(rho) %in% c(1, K))
    stop("`n` and `rho` must be a single number or have one value per pair (",
         K, ").", call. = FALSE)
  n <- rep_len(n, K)
  rho <- rep_len(rho, K)
  if (any(n < 4)) stop("`n` must be at least 4.", call. = FALSE)
  if (any(abs(rho) >= 1)) stop("`rho` must be in (-1, 1).", call. = FALSE)

  u1 <- stats::rnorm(n_studies, 0, sd_u1)[study]
  u2 <- stats::rnorm(n_studies, 0, sd_u2)[study]
  theta1 <- mu + u1 + stats::rnorm(K, 0, tau1)
  theta2 <- alpha + beta * theta1 + u2 + stats::rnorm(K, 0, tau2)

  es <- t(vapply(seq_len(K), function(i)
    .sim_trial(n[i], theta1[i], theta2[i], rho[i]), numeric(4)))

  data.frame(study = study, es_id = seq_len(K), n = n, rho = rho,
             es1 = es[, 1], se1 = es[, 2], es2 = es[, 3], se2 = es[, 4],
             theta1 = theta1, theta2 = theta2)
}

# One trial: difference in means with its OLS standard error, at both times.
.sim_trial <- function(n, theta1, theta2, rho) {
  treat <- sample(rep_len(0:1, n))
  z1 <- stats::rnorm(n)
  z2 <- rho * z1 + sqrt(1 - rho^2) * stats::rnorm(n)
  est <- function(y) {
    m1 <- mean(y[treat == 1]); m0 <- mean(y[treat == 0])
    n1 <- sum(treat); n0 <- n - n1
    s2 <- (sum((y[treat == 1] - m1)^2) + sum((y[treat == 0] - m0)^2)) / (n - 2)
    c(m1 - m0, sqrt(s2 * (1 / n1 + 1 / n0)))
  }
  c(est(z1 + theta1 * treat), est(z2 + theta2 * treat))
}
