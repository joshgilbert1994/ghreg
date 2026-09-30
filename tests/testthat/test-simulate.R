test_that("gh_simulate() returns one row per pair", {
  set.seed(1)
  d <- gh_simulate(n_studies = 10, pairs_per_study = 1:10, n = 50)
  expect_equal(nrow(d), 55)
  expect_equal(as.vector(table(d$study)), 1:10)
  expect_named(d, c("study", "es_id", "n", "rho", "es1", "se1", "es2", "se2",
                    "theta1", "theta2"))
  expect_true(all(d$se1 > 0 & d$se2 > 0))
})

test_that("true effects follow the persistence model", {
  set.seed(2)
  d <- gh_simulate(n_studies = 200, beta = 0.5, alpha = 0.1, es_sd2 = 0)
  expect_equal(d$theta2, 0.1 + 0.5 * d$theta1)
})

test_that("sampling errors are correlated rho", {
  set.seed(3)
  d <- gh_simulate(n_studies = 3000, n = 60, rho = 0.7, es_sd1 = 0)
  e1 <- d$es1 - d$theta1
  e2 <- d$es2 - d$theta2
  expect_equal(cor(e1, e2), 0.7, tolerance = 0.05)
  expect_equal(sd(e1), 2 / sqrt(60), tolerance = 0.05)
  expect_equal(mean(d$se1), 2 / sqrt(60), tolerance = 0.05)
})

test_that("gh_simulate() checks its inputs", {
  expect_error(gh_simulate(n_studies = 5, n = 1:3), "one value per pair")
  expect_error(gh_simulate(rho = 1), "\\(-1, 1\\)")
  expect_error(gh_simulate(n = 2), "at least 4")
  expect_error(gh_simulate(study_sd1 = -0.1), ">= 0")
  expect_error(gh_simulate(es_sd2 = c(0.1, 0.2)), ">= 0")
})

test_that("study_sd1 and study_sd2 add study-level clustering", {
  set.seed(4)
  d <- gh_simulate(n_studies = 400, pairs_per_study = 4, es_sd1 = 0.1, es_sd2 = 0,
                   study_sd1 = 0.3, study_sd2 = 0.2, beta = 0.5, alpha = 0)
  # between-study SD of the study means of theta1 is about sqrt(.3^2 + .1^2/4)
  expect_equal(sd(tapply(d$theta1, d$study, mean)), sqrt(0.3^2 + 0.1^2 / 4),
               tolerance = 0.1)
  r2 <- d$theta2 - 0.5 * d$theta1
  # with es_sd2 = 0, the residual is constant within study and has SD study_sd2
  expect_true(all(tapply(r2, d$study, function(x) diff(range(x))) < 1e-12))
  expect_equal(sd(tapply(r2, d$study, mean)), 0.2, tolerance = 0.1)
  d0 <- gh_simulate(n_studies = 50, pairs_per_study = 2, study_sd1 = 0)
  expect_true(all(d0$theta1 == 0.5))
})

test_that("the default heterogeneity is at the study level", {
  set.seed(6)
  d <- gh_simulate(n_studies = 20, pairs_per_study = 3)
  # es_sd1 = 0 by default, so true effects are constant within study
  expect_true(all(tapply(d$theta1, d$study, function(x) diff(range(x))) < 1e-12))
  expect_gt(sd(d$theta1), 0)
})
