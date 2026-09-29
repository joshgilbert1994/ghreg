d <- data.frame(study = c(1, 1, 2, 3), es1 = c(.2, .4, .1, .5), se1 = .1,
                es2 = c(.1, .3, 0, .2), se2 = .12, r = c(.5, .6, .7, .8))
q <- function(x) rlang::quo(!!rlang::enexpr(x))
prep <- function(..., study = NULL, rho = 0.5) {
  ghreg:::.gh_data(d, q(es1), q(se1), q(es2), q(se2), rlang::enquo(study),
                   rlang::enquo(rho))
}

test_that("inputs are evaluated in the data", {
  x <- prep(study = study, rho = r)
  expect_equal(x$sdata$K, 4)
  expect_equal(x$sdata$J, 3)
  expect_equal(x$sdata$g, c(1, 1, 2, 3))
  expect_equal(x$sdata$has_study, 1L)
  expect_equal(x$sdata$c12, d$r * .1 * .12)
  expect_equal(prep(study = "study", rho = "r")$sdata, x$sdata)
})

test_that("rho is recycled from a single value", {
  expect_equal(prep(rho = 0.3)$rho, rep(0.3, 4))
})

test_that("one pair per study gives the two-level model", {
  expect_equal(prep()$sdata$has_study, 0L)
  expect_message(x <- prep(study = es_id <- 1:4), "two-level")
  expect_equal(x$sdata$has_study, 0L)
})

test_that("bad inputs are caught before sampling", {
  expect_error(prep(rho = 1), "\\(-1, 1\\)")
  expect_error(prep(rho = c(.1, .2)), "one value per pair")
  expect_error(prep(rho = "nope"), "numeric")
  expect_error(prep(study = c(1, 2)), "same length")
  expect_error(ghreg:::.gh_data(transform(d, se1 = -1), q(es1), q(se1), q(es2),
                                q(se2), q(NULL), q(.5)), "positive")
  expect_error(ghreg:::.gh_data(transform(d, es2 = c(NA, .3, 0, .2)), q(es1), q(se1), q(es2),
                                q(se2), q(NULL), q(.5)), "Missing")
  expect_error(gh_reg(d, es1, se1, es2, se2), "`rho`")
  expect_error(gh_reg(d, es1, se1, es2, se2, rho = .5, prior = list()), "gh_prior")
})

test_that("priors are validated", {
  p <- gh_prior(beta = c(.5, .25))
  expect_s3_class(p, "gh_prior")
  expect_equal(p$p_beta, c(.5, .25))
  expect_equal(gh_prior()$sd_scale, .5)
  expect_error(gh_prior(beta = c(0, -1)), "sd > 0")
  expect_error(gh_prior(sd_scale = 0), "positive")
  expect_output(print(p), "normal\\(0.5, 0.25\\)")
})

test_that("gh_backend() respects the option", {
  withr::local_options(ghreg.backend = "rstan")
  expect_equal(gh_backend(), "rstan")
})
