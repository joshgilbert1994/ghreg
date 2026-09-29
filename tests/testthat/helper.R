# Fitting tests need a compiled Stan model; skip them on CRAN and when the
# backend is unavailable.
skip_if_no_backend <- function(backend) {
  skip_on_cran()
  if (backend == "cmdstanr" && !ghreg:::.has_cmdstan()) skip("CmdStan not available")
  if (backend == "rstan") {
    skip_if_not_installed("rstan")
    # rstan's compile fails intermittently on GitHub's Windows runners (the
    # compiler output is cut off before the error); Ubuntu and macOS CI still
    # run these tests.
    if (.Platform$OS.type == "windows" && nzchar(Sys.getenv("CI")))
      skip("rstan compile is unreliable on Windows CI")
  }
}
