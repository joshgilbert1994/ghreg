# Compiling and sampling with either Stan interface. Compiled models are
# cached in tools::R_user_dir("ghreg", "cache") and in .ghreg_env, so each
# model is compiled once per machine (per Stan version) and loaded once per session.

.ghreg_env <- new.env(parent = emptyenv())

#' Choose a Stan backend
#'
#' Returns the backend `gh_reg()` uses by default: the `ghreg.backend` option
#' if set, otherwise `"cmdstanr"` when cmdstanr and CmdStan are installed, and
#' `"rstan"` otherwise.
#'
#' @return `"cmdstanr"` or `"rstan"`.
#' @examples
#' gh_backend()
#' # options(ghreg.backend = "rstan")  # to always use rstan
#' @export
gh_backend <- function() {
  opt <- getOption("ghreg.backend")
  if (!is.null(opt)) return(match.arg(opt, c("cmdstanr", "rstan")))
  if (.has_cmdstan()) "cmdstanr" else "rstan"
}

.has_cmdstan <- function() {
  suppressWarnings(requireNamespace("cmdstanr", quietly = TRUE)) &&
    !is.null(suppressWarnings(suppressMessages(tryCatch(
      cmdstanr::cmdstan_version(error_on_NA = FALSE), error = function(e) NULL))))
}

.stan_file <- function() {
  f <- system.file("stan", "gh_reg.stan", package = "ghreg")
  if (!nzchar(f)) stop("Can't find the Stan program; try reinstalling ghreg.", call. = FALSE)
  f
}

.cache_dir <- function() {
  dir <- tools::R_user_dir("ghreg", "cache")
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  dir
}

.gh_model <- function(backend) {
  key <- paste0("model_", backend)
  if (is.null(.ghreg_env[[key]])) {
    .ghreg_env[[key]] <- switch(backend,
                                cmdstanr = .compile_cmdstanr(),
                                rstan = .compile_rstan())
  }
  .ghreg_env[[key]]
}

.compile_cmdstanr <- function() {
  if (!.has_cmdstan())
    stop("The cmdstanr backend needs cmdstanr and CmdStan:\n",
         "  install.packages(\"cmdstanr\", repos = c(\"https://stan-dev.r-universe.dev\", getOption(\"repos\")))\n",
         "  cmdstanr::install_cmdstan()\n",
         "or use backend = \"rstan\".", call. = FALSE)
  # copy only when the program changed, so cmdstanr reuses the executable
  code <- readLines(.stan_file())
  src <- file.path(.cache_dir(), "gh_reg.stan")
  if (!file.exists(src) || !identical(readLines(src), code)) writeLines(code, src)
  if (!file.exists(sub("\\.stan$", "", src)) && !file.exists(sub("\\.stan$", ".exe", src)))
    message("Compiling the Stan model (once per machine; about a minute)...")
  cmdstanr::cmdstan_model(src, quiet = TRUE)
}

.compile_rstan <- function() {
  if (!requireNamespace("rstan", quietly = TRUE))
    stop("The rstan backend needs rstan: install.packages(\"rstan\").", call. = FALSE)
  # rstan compiles models against these headers but lists them only in
  # LinkingTo, which installers such as pak skip for binary packages. ghreg
  # imports them so they get installed; StanHeaders and RcppParallel come with
  # rstan itself.
  have <- c(BH = requireNamespace("BH", quietly = TRUE),
            RcppEigen = requireNamespace("RcppEigen", quietly = TRUE))
  miss <- names(have)[!have]
  if (length(miss))
    stop("rstan needs these packages to compile models: ",
         paste(miss, collapse = ", "), ".\nInstall them with install.packages(c(",
         paste0("\"", miss, "\"", collapse = ", "), ")).", call. = FALSE)
  code <- paste(readLines(.stan_file()), collapse = "\n")
  id <- paste(utils::packageVersion("rstan"), R.version$major, R.version$minor,
              .hash(code), sep = "_")
  rds <- file.path(.cache_dir(), paste0("gh_reg_rstan_", id, ".rds"))
  if (file.exists(rds)) {
    mod <- tryCatch(readRDS(rds), error = function(e) NULL)
    if (!is.null(mod)) return(mod)
  }
  message("Compiling the Stan model (once per machine; about a minute)...")
  mod <- rstan::stan_model(model_code = code, model_name = "gh_reg")
  saveRDS(mod, rds)
  mod
}

.hash <- function(x) {
  f <- tempfile()
  on.exit(unlink(f))
  writeLines(x, f)
  unname(tools::md5sum(f))
}

.gh_sample <- function(backend, sdata, pars, chains, cores, iter_warmup,
                       iter_sampling, seed, refresh, ...) {
  mod <- .gh_model(backend)
  if (is.null(seed)) seed <- sample.int(.Machine$integer.max, 1)
  if (backend == "cmdstanr") {
    # cmdstanr's default CSV names come from the clock (to the minute) and R's
    # RNG, so fits after the same set.seed() can overwrite each other
    .ghreg_env$n_fits <- (if (is.null(.ghreg_env$n_fits)) 0 else .ghreg_env$n_fits) + 1
    base <- sprintf("gh_reg-%s-%d-%d", format(Sys.time(), "%Y%m%d%H%M%S"),
                    Sys.getpid(), .ghreg_env$n_fits)
    fit <- mod$sample(data = sdata, chains = chains, parallel_chains = cores,
                      output_basename = base,
                      iter_warmup = iter_warmup, iter_sampling = iter_sampling,
                      seed = seed, refresh = refresh, show_messages = FALSE,
                      show_exceptions = FALSE, ...)
    draws <- fit$draws(pars, format = "draws_array")
    diag <- fit$diagnostic_summary(quiet = TRUE)
    divergences <- sum(diag$num_divergent)
    treedepth <- sum(diag$num_max_treedepth)
  } else {
    # gh_reg() runs its own convergence checks, the same for both backends
    fit <- suppressWarnings(
      rstan::sampling(mod, data = sdata, chains = chains, cores = cores,
                      iter = iter_warmup + iter_sampling, warmup = iter_warmup,
                      seed = seed, refresh = refresh, show_messages = FALSE, ...))
    draws <- posterior::as_draws_array(as.array(fit, pars = sub("\\[1\\]$", "", pars)))
    divergences <- rstan::get_num_divergent(fit)
    treedepth <- rstan::get_num_max_treedepth(fit)
  }
  posterior::variables(draws) <- sub("\\[1\\]$", "", posterior::variables(draws))
  list(fit = fit, draws = draws, divergences = as.integer(sum(divergences)),
       treedepth = as.integer(sum(treedepth)))
}
