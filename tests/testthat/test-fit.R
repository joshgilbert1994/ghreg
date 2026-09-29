for (backend in c("cmdstanr", "rstan")) {
  test_that(paste("gh_reg() recovers beta with", backend), {
    skip_if_no_backend(backend)
    set.seed(10)
    d <- gh_simulate(n_studies = 150, n = 400, rho = 0.7, beta = 0.5,
                     tau1 = 0.3, tau2 = 0.05)
    fit <- gh_reg(d, es1, se1, es2, se2, rho = 0.7, backend = backend, seed = 1,
                  chains = 2)
    expect_s3_class(fit, "gh_reg")
    expect_equal(fit$levels, 2L)
    expect_equal(fit$summary$term, c("beta", "alpha", "mu", "tau1", "tau2"))
    sm <- summary(fit)
    expect_s3_class(sm, "tbl_df")
    expect_identical(sm, fit$summary)
    expect_named(sm, c("term", "estimate", "std.error", "ci.lower", "ci.upper",
                       "rhat", "ess_bulk", "ess_tail"))
    expect_equal(sm$estimate, unname(coef(fit)))
    expect_named(summary(fit, diagnostics = FALSE),
                 c("term", "estimate", "std.error", "ci.lower", "ci.upper"))
    b <- as_draws_df(fit)$beta
    expect_equal(summary(fit, ci.level = 0.9)$ci.lower[1], unname(quantile(b, 0.05)))
    expect_error(summary(fit, ci.level = 95), "between 0 and 1")
    expect_equal(unname(coef(fit)["beta"]), 0.5, tolerance = 0.15)
    expect_equal(nobs(fit), 150)
    expect_equal(nrow(as_draws_df(fit)), 2000)
    expect_output(print(fit), "2-level model: 150 pairs")
  })
}

test_that("the two backends agree on a three-level model", {
  skip_if_no_backend("cmdstanr")
  skip_if_no_backend("rstan")
  args <- list(persist_sim, quote(es1), quote(se1), quote(es2), quote(se2),
               study = quote(study), rho = quote(rho), seed = 1)
  a <- suppressWarnings(do.call(gh_reg, c(args, backend = "cmdstanr")))
  b <- suppressWarnings(do.call(gh_reg, c(args, backend = "rstan")))
  expect_equal(a$levels, 3L)
  expect_equal(coef(a), coef(b), tolerance = 0.1)
})

test_that("gh_sensitivity() refits over rho", {
  skip_if_no_backend(gh_backend())
  s <- suppressWarnings(
    gh_sensitivity(persist_sim, es1, se1, es2, se2, study = study,
                   rho = c(0, 0.8), parameters = c("beta", "tau1"), seed = 1,
                   chains = 2, iter_warmup = 300, iter_sampling = 300))
  expect_s3_class(s, c("gh_sensitivity", "tbl_df"))
  expect_named(s, c("rho", "term", "estimate", "std.error", "ci.lower", "ci.upper",
                    "rhat", "ess_bulk", "ess_tail", "divergences"))
  expect_equal(s$rho, c(0, 0, 0.8, 0.8))
  # more correlated sampling error means less of the slope is real
  expect_gt(s$estimate[s$term == "beta" & s$rho == 0],
            s$estimate[s$term == "beta" & s$rho == 0.8])
  grDevices::pdf(NULL)
  expect_silent(plot(s, ref = c(Naive = 0.5)))
  grDevices::dev.off()
  expect_error(gh_sensitivity(persist_sim, es1, se1, es2, se2, rho = "a"), "numeric")
})

test_that("fits after the same seed don't share output files", {
  skip_if_no_backend("cmdstanr")
  run <- function() {
    set.seed(5)
    d <- gh_simulate(n_studies = 40)
    gh_reg(d, es1, se1, es2, se2, rho = 0.5, backend = "cmdstanr", chains = 1,
           iter_warmup = 200, iter_sampling = 200)
  }
  a <- suppressWarnings(run())
  b <- suppressWarnings(run())
  expect_false(any(a$fit$output_files() %in% b$fit$output_files()))
})

test_that("ghreg doesn't mask broom generics", {
  ns <- getNamespaceExports("ghreg")
  expect_false(any(c("tidy", "glance", "augment") %in% ns))
})
