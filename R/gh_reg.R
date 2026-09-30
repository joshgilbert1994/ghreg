#' Persistence meta-regression adjusted for correlated sampling error
#'
#' Fits the Gilbert and Himmelsbach (2026) meta-regression of follow-up effect
#' sizes on endline effect sizes, accounting for the sampling error in both and
#' for the correlation between them. The slope `beta` is the *conditional
#' persistence* of effects: 1 means effects fully persist, 0 means they fully
#' fade out.
#'
#' @section Model:
#' For effect-size pair \eqn{j} in study \eqn{k}, with observed endline and
#' follow-up effect sizes \eqn{\delta_{1jk}} and \eqn{\delta_{2jk}},
#' \deqn{\theta_{1jk} = \mu + u_{1k} + \epsilon_{1jk}}{theta1_jk = mu + u1_k + eps1_jk}
#' \deqn{\theta_{2jk} = \alpha + \beta \theta_{1jk} + u_{2k} + \epsilon_{2jk}}{theta2_jk = alpha + beta * theta1_jk + u2_k + eps2_jk}
#' \deqn{(\delta_{1jk}, \delta_{2jk}) \sim N\left((\theta_{1jk}, \theta_{2jk}),
#'   \Sigma_{jk}\right),}{(es1_jk, es2_jk) ~ N((theta1_jk, theta2_jk), Sigma_jk),}
#' where \eqn{\Sigma_{jk}} has variances `se1^2` and `se2^2` and correlation
#' `rho`, and
#' \eqn{u_{1k} \sim N(0, \sigma_{S1}^2)}{u1_k ~ N(0, sigma_S1^2)},
#' \eqn{u_{2k} \sim N(0, \sigma_{S2}^2)}{u2_k ~ N(0, sigma_S2^2)},
#' \eqn{\epsilon_{1jk} \sim N(0, \sigma_{E1}^2)}{eps1_jk ~ N(0, sigma_E1^2)},
#' and \eqn{\epsilon_{2jk} \sim N(0, \sigma_{E2}^2)}{eps2_jk ~ N(0, sigma_E2^2)}.
#' The same `beta` links the true effects within and between studies.
#'
#' The four standard deviations \eqn{\sigma_{S1}}{sigma_S1},
#' \eqn{\sigma_{S2}}{sigma_S2}, \eqn{\sigma_{E1}}{sigma_E1}, and
#' \eqn{\sigma_{E2}}{sigma_E2} are reported as `study_sd1`, `study_sd2`,
#' `es_sd1`, and `es_sd2`: S (study) is the between-study level and E (effect
#' size) the level of effect-size pairs within studies. The "1" SDs describe
#' the true endline effects. The "2" SDs are *residual*: they describe the
#' true follow-up effects after conditioning on the true endline effects, so
#' the total SD of the true follow-up effects is at least as large (larger
#' whenever `beta` is not 0).
#'
#' With `study = NULL`, or when every study contributes one pair, the study
#' level is dropped, since only the sum of the study- and pair-level variances
#' would be identified, and the model is the two-level model in the paper. Its
#' \eqn{\tau_1}{tau_1} and \eqn{\tau_2}{tau_2} are `es_sd1` and `es_sd2`.
#'
#' The study effects \eqn{u_{1k}} and \eqn{u_{2k}} capture clustering of the
#' *true* effects within studies. The sampling errors of different pairs are
#' assumed independent, even within a study. When a study reports several
#' effect sizes from the same participants, their sampling errors are likely
#' correlated as well, which the model does not account for.
#'
#' The latent \eqn{\theta}, \eqn{\epsilon}, and \eqn{u} are integrated out
#' analytically, so Stan samples only the hyperparameters. The posterior is the
#' same as that of the latent-variable program in the paper's appendix, but
#' sampling is faster and free of the funnel geometry that causes divergent
#' transitions when sampling error is large relative to `es_sd1`.
#'
#' @section The sampling correlation `rho`:
#' For a difference in means with a constant treatment effect, the correlation
#' between the endline and follow-up effect sizes equals the correlation of the
#' outcome across time (its test-retest reliability). It is rarely reported, so
#' the paper treats it as a sensitivity parameter: fit the model over a grid of
#' values with [gh_sensitivity()]. `rho` can also be a column of
#' study-specific values.
#'
#' @param data A data frame with one row per pair of effect sizes, or `NULL`
#'   to take the variables from the calling environment.
#' @param es1,se1 Endline effect sizes and their standard errors.
#' @param es2,se2 Follow-up effect sizes and their standard errors.
#' @param study Optional study identifier, for data with more than one pair of
#'   effect sizes per study.
#' @param rho The correlation between the sampling errors of `es1` and `es2`:
#'   a single number, or a vector or column with one value per pair, each in
#'   (-1, 1).
#' @param prior Priors, from [gh_prior()].
#' @param backend `"cmdstanr"` or `"rstan"`; see [gh_backend()].
#' @param chains Number of Markov chains.
#' @param cores Number of chains to run in parallel.
#' @param iter_warmup,iter_sampling Warmup and sampling iterations per chain.
#' @param seed Random seed for Stan.
#' @param refresh How often Stan reports progress; 0 is silent.
#' @param ... Further arguments to `$sample()` (cmdstanr) or
#'   [rstan::sampling()], such as `adapt_delta`
#'   (cmdstanr) or `control = list(adapt_delta = .99)` (rstan).
#'
#' @details `es1`, `se1`, `es2`, `se2`, `study`, and `rho` are evaluated in
#'   `data`, so they can be bare column names, expressions such as
#'   `sqrt(var1)`, or column names as strings.
#'
#' @return An object of class `gh_reg` with elements
#'   \describe{
#'     \item{`summary`}{posterior summary of the parameters, a tibble with
#'       columns `term`, `estimate`, `std.error`, `ci.lower`, `ci.upper`,
#'       `rhat`, `ess_bulk`, and `ess_tail`; see [summary.gh_reg()]}
#'     \item{`draws`}{posterior draws, a `posterior::draws_array`}
#'     \item{`fit`}{the `CmdStanMCMC` or `stanfit` object}
#'     \item{`levels`}{2 or 3}
#'     \item{`n_pairs`, `n_studies`}{sample sizes}
#'     \item{`rho`}{the sampling correlations used, one per pair}
#'     \item{`divergences`, `max_treedepth`}{sampler diagnostics}}
#'   The parameters are
#'   \describe{
#'     \item{`beta`}{conditional persistence}
#'     \item{`alpha`}{mean true follow-up effect when the true endline effect
#'       is 0}
#'     \item{`mu`}{mean true endline effect}
#'     \item{`study_sd1`}{between-study SD of the true endline effects
#'       (three-level model only)}
#'     \item{`study_sd2`}{between-study residual SD of the true follow-up
#'       effects, given the true endline effects (three-level model only)}
#'     \item{`es_sd1`}{SD of the true endline effects across effect-size pairs
#'       within a study}
#'     \item{`es_sd2`}{residual SD of the true follow-up effects across
#'       effect-size pairs within a study, given the true endline effects}}
#'
#' @references Gilbert, J. B., & Himmelsbach, Z. (2026). *Why fadeout is
#'   (probably) worse than we think: Adjusting for correlated sampling error in
#'   meta-analyses of behavioral interventions* (EdWorkingPaper No. 26-1394).
#'   Annenberg Institute at Brown University. \doi{10.26300/87r9-qm15}
#'
#' @seealso [gh_sensitivity()] to vary `rho`, [gh_prior()], [gh_simulate()].
#' @examples
#' \donttest{
#' # 2 chains of 2000 draws give the default 4000 draws within CRAN's limit
#' # of 2 cores; the default is 4 chains of 1000 run in parallel
#' fit <- gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = 0.6,
#'               chains = 2, iter_sampling = 2000)
#' fit
#' coef(fit)
#'
#' # study-specific sampling correlations
#' gh_reg(persist_sim, es1, se1, es2, se2, study = study, rho = rho,
#'        chains = 2, iter_sampling = 2000)
#' }
#' @export
gh_reg <- function(data, es1, se1, es2, se2, study = NULL, rho,
                   prior = gh_prior(), backend = gh_backend(), chains = 4,
                   cores = chains, iter_warmup = 1000, iter_sampling = 1000,
                   seed = NULL, refresh = 0, ...) {
  call <- match.call()
  if (missing(rho))
    stop("`rho`, the sampling correlation between `es1` and `es2`, is required.\n",
         "It is usually unknown: see ?gh_sensitivity to fit a range of values.",
         call. = FALSE)
  d <- .gh_data(data, rlang::enquo(es1), rlang::enquo(se1), rlang::enquo(es2),
                rlang::enquo(se2), rlang::enquo(study), rlang::enquo(rho))
  if (!inherits(prior, "gh_prior")) stop("`prior` must come from gh_prior().", call. = FALSE)
  backend <- match.arg(backend, c("cmdstanr", "rstan"))

  pars <- c("beta", "alpha", "mu",
            if (d$sdata$has_study) c("study_sd1[1]", "study_sd2[1]"),
            "es_sd1", "es_sd2")
  s <- .gh_sample(backend, c(d$sdata, unclass(prior)), pars, chains = chains,
                  cores = cores, iter_warmup = iter_warmup,
                  iter_sampling = iter_sampling, seed = seed, refresh = refresh, ...)

  out <- structure(
    list(summary = .summarise(s$draws), draws = s$draws, fit = s$fit,
         levels = if (d$sdata$has_study) 3L else 2L, n_pairs = d$sdata$K,
         n_studies = d$sdata$J, rho = d$rho, prior = prior, backend = backend,
         divergences = s$divergences, max_treedepth = s$treedepth, call = call),
    class = "gh_reg")
  .check_fit(out)
  out
}

# Evaluate the inputs in `data` and build the Stan data list.
.gh_data <- function(data, es1, se1, es2, se2, study, rho) {
  if (!is.null(data) && !is.data.frame(data))
    stop("`data` must be a data frame or NULL.", call. = FALSE)
  get <- function(q, what) {
    x <- rlang::eval_tidy(q, data)
    if (is.character(x) && length(x) == 1 && !is.null(data) && x %in% names(data))
      x <- data[[x]]
    if (is.null(x)) stop("`", what, "` is missing.", call. = FALSE)
    x
  }
  num <- function(q, what) {
    x <- get(q, what)
    if (!is.numeric(x)) stop("`", what, "` must be numeric.", call. = FALSE)
    as.numeric(x)
  }
  y1 <- num(es1, "es1"); s1 <- num(se1, "se1")
  y2 <- num(es2, "es2"); s2 <- num(se2, "se2")
  r <- num(rho, "rho")
  K <- length(y1)
  g <- if (rlang::quo_is_null(study)) seq_len(K) else get(study, "study")

  lens <- c(se1 = length(s1), es2 = length(y2), se2 = length(s2), study = length(g))
  if (K < 2) stop("At least two pairs of effect sizes are needed.", call. = FALSE)
  if (any(lens != K))
    stop("`es1`, `se1`, `es2`, `se2`, and `study` must have the same length.", call. = FALSE)
  if (!length(r) %in% c(1, K))
    stop("`rho` must be a single number or have one value per pair.", call. = FALSE)
  r <- rep_len(r, K)
  if (anyNA(c(y1, y2, s1, s2, r)) || anyNA(g))
    stop("Missing values are not supported; drop incomplete pairs first.", call. = FALSE)
  if (any(s1 <= 0 | s2 <= 0)) stop("Standard errors must be positive.", call. = FALSE)
  if (any(abs(r) >= 1)) stop("`rho` must be in (-1, 1).", call. = FALSE)

  gi <- match(g, unique(g))
  has_study <- as.integer(any(tabulate(gi) > 1))
  if (!rlang::quo_is_null(study) && !has_study)
    message("Every study has one pair of effect sizes: fitting the two-level model.")

  list(sdata = list(K = K, J = max(gi), g = gi, has_study = has_study,
                    y1 = y1, y2 = y2, v1 = s1^2, v2 = s2^2, c12 = r * s1 * s2),
       rho = r)
}

# Posterior summary as a tibble with broom-like column names: estimate and
# std.error are the posterior mean and SD, ci.lower and ci.upper are
# equal-tailed quantiles.
.summarise <- function(draws, ci.level = 0.95) {
  if (!is.numeric(ci.level) || length(ci.level) != 1 || ci.level <= 0 ||
      ci.level >= 1)
    stop("`ci.level` must be a number between 0 and 1.", call. = FALSE)
  a <- (1 - ci.level) / 2
  s <- posterior::summarise_draws(
    draws, estimate = mean, std.error = stats::sd,
    ci.lower = ~ unname(stats::quantile(.x, a)),
    ci.upper = ~ unname(stats::quantile(.x, 1 - a)),
    rhat = posterior::rhat, ess_bulk = posterior::ess_bulk,
    ess_tail = posterior::ess_tail)
  names(s)[names(s) == "variable"] <- "term"
  tibble::as_tibble(as.data.frame(s))
}

.check_fit <- function(x) {
  if (x$divergences > 0)
    warning(x$divergences, " divergent transitions after warmup; consider raising ",
            "adapt_delta or checking the priors.", call. = FALSE)
  if (any(x$summary$rhat > 1.01, na.rm = TRUE))
    warning("Some R-hat values exceed 1.01; run longer chains.", call. = FALSE)
  # 100 effective draws per chain (Vehtari et al., 2021): 400 with 4 chains
  min_ess <- 100 * posterior::nchains(x$draws)
  low <- x$summary$term[x$summary$ess_bulk < min_ess]
  if (length(low))
    warning("Bulk effective sample size is below ", min_ess, " (100 per chain) ",
            "for ", paste(low, collapse = ", "), "; run longer chains.",
            call. = FALSE)
  invisible(x)
}
