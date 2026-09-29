#' ghreg: Persistence Meta-Regression Adjusted for Correlated Sampling Error
#'
#' Meta-analyses of intervention effects often measure persistence by
#' regressing follow-up effect sizes on endline effect sizes. Because both
#' effect sizes come from the same participants and outcomes, their sampling
#' errors are correlated, and the naive slope is usually too large. ghreg fits
#' the Bayesian meta-regression of Gilbert and Himmelsbach (2026), which models
#' both sampling errors and their correlation, and supports the sensitivity
#' analysis the paper recommends when that correlation is unknown.
#'
#' @section Main functions:
#' \itemize{
#'   \item [gh_reg()] fits the model for a given sampling correlation.
#'   \item [gh_sensitivity()] refits it over a range of sampling correlations.
#'   \item [gh_simulate()] simulates meta-analytic data from the model.
#'   \item [gh_prior()] sets the priors.
#' }
#'
#' @references Gilbert, J. B., & Himmelsbach, Z. (2026). *Why fadeout is
#'   (probably) worse than we think: Adjusting for correlated sampling error in
#'   meta-analyses of behavioral interventions* (EdWorkingPaper No. 26-1394).
#'   Annenberg Institute at Brown University. \doi{10.26300/87r9-qm15}
#' @keywords internal
#' @importFrom stats coef nobs
"_PACKAGE"
