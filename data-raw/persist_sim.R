# Builds data/persist_sim.rda. Run from the package root after devtools::load_all().
# The design follows the simulations in Gilbert & Himmelsbach (2026): each ES
# pair is a simulated RCT with outcomes correlated rho across time, analyzed by
# a difference in means. Here studies contribute several pairs, trial sizes vary,
# and rho varies across outcomes.

set.seed(2027)
n_studies <- 60
pairs <- sample(1:5, n_studies, replace = TRUE)
K <- sum(pairs)

persist_sim <- gh_simulate(
  n_studies = n_studies, pairs_per_study = pairs,
  n = sample(40:200, K, replace = TRUE),
  rho = round(rbeta(K, 6, 3), 2),
  mu = 0.4, alpha = 0, beta = 0.4,
  study_sd1 = 0.15, study_sd2 = 0.05, es_sd1 = 0.15, es_sd2 = 0.05
)

usethis::use_data(persist_sim, overwrite = TRUE)
