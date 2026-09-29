# Fitting tests need a compiled Stan model; skip them on CRAN and when the
# backend is unavailable.
skip_if_no_backend <- function(backend) {
  skip_on_cran()
  if (backend == "cmdstanr" && !ghreg:::.has_cmdstan()) skip("CmdStan not available")
  if (backend == "rstan") {
    skip_if_not_installed("rstan")
    # On GitHub's Windows runners the rstan compile fails inside R CMD check's
    # test run (the compiler output is cut off before the error), though the
    # same compile succeeds in the examples, which still cover Windows.
    if (.Platform$OS.type == "windows" && nzchar(Sys.getenv("CI")))
      skip("rstan compile fails in the Windows CI test run; covered by the examples")
  }
}
