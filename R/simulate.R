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
#' The true effects follow the model in [gh_reg()]:
#' \deqn{\theta_{1jk} = \mu + u_{1k} + \epsilon_{1jk}}{theta1_jk = mu + u1_k + eps1_jk}
#' \deqn{\theta_{2jk} = \alpha + \beta \theta_{1jk} + u_{2k} + \epsilon_{2jk}}{theta2_jk = alpha + beta * theta1_jk + u2_k + eps2_jk}
#' with study effects \eqn{u_{1k} \sim N(0, sd_{u1}^2)}{u1_k ~ N(0, sd_u1^2)} and
#' \eqn{u_{2k} \sim N(0, sd_{u2}^2)}{u2_k ~ N(0, sd_u2^2)} shared by every pair in study \eqn{k}, and
#' pair-level deviations \eqn{\epsilon_{1jk} \sim N(0, \tau_1^2)}{eps1_jk ~ N(0, tau1^2)} and
#' \eqn{\epsilon_{2jk} \sim N(0, \tau_2^2)}{eps2_jk ~ N(0, tau2^2)}.
#'
#' With `sd_u1 = sd_u2 = 0` (the default) there is no study-level variation:
#' pairs from the same study are independent, so the data follow the two-level
#' model and the study grouping has no effect. Set `sd_u1` or `sd_u2` above 0,
#' with `pairs_per_study` above 1, to simulate data for the three-level model.
#'
#' Each pair is simulated as its own trial, so sampling errors are independent
#' across pairs, including pairs from the same study. In real meta-analyses,
#' several effect sizes from one study often share participants, so their
#' sampling errors are correlated; neither `gh_simulate()` nor [gh_reg()]
#' models that.
#'
#' @param n_studies Number of studies.
#' @param pairs_per_study Pairs of effect sizes per study: one number, or one
#'   per study.
#' @param n Participants per trial: one number, or one per pair.
#' @param rho Correlation of the outcome across time (the test-retest
#'   reliability): one number, or one per pair.
#' @param mu Mean true endline effect.
#' @param alpha Mean true follow-up effect when the true endline effect is 0.
#' @param beta Conditional persistence: the slope of the true follow-up effect
#'   on the true endline effect.
#' @param tau1 SD of the true endline effects across pairs within a study.
#' @param tau2 Residual SD of the true follow-up effects across pairs within a
#'   study, given the true endline effects.
#' @param sd_u1 SD of the study effects on the true endline effects.
#' @param sd_u2 SD of the study effects on the true follow-up effects, given
#'   the true endline effects.
#' @return A data frame with one row per pair: `study`, `es_id`, `n`, `rho`,
#'   the estimates `es1`, `se1`, `es2`, `se2`, and the true effects `theta1`
#'   and `theta2`.
#' @examples
#' set.seed(1)
#' d <- gh_simulate(n_studies = 100, n = 100, rho = 0.7)
#' head(d)
#' # the naive meta-regression slope is inflated (true beta = 0.5)
#' coef(lm(es2 ~ es1, d))
#'
#' # three-level data: 40 studies with 3 pairs each and study-level variation
#' d3 <- gh_simulate(n_studies = 40, pairs_per_study = 3, rho = 0.7,
#'                   tau1 = 0.15, sd_u1 = 0.2, sd_u2 = 0.05)
#' table(table(d3$study))
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
  sds <- c(tau1 = tau1, tau2 = tau2, sd_u1 = sd_u1, sd_u2 = sd_u2)
  if (!is.numeric(sds) || length(sds) != 4 || anyNA(sds) || any(sds < 0))
    stop("`tau1`, `tau2`, `sd_u1`, and `sd_u2` must each be a single number >= 0.",
         call. = FALSE)

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
