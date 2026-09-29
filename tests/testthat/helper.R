# Fitting tests need a compiled Stan model; skip them on CRAN and when the
# backend is unavailable.
skip_if_no_backend <- function(backend) {
  skip_on_cran()
  if (backend == "cmdstanr" && !ghreg:::.has_cmdstan()) skip("CmdStan not available")
  if (backend == "rstan") skip_if_not_installed("rstan")
}
