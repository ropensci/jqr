# from @smbache Stefan Milton Bache

#' Information on Potential Pipeline
#'
#' This function figures out whether it is called from within a pipeline.
#' It does so by examining the parent evironment of the active system frames,
#' and whether any of these are the same as the enclosing environment of
#' \code{\%>\%}.
#'
#' @return A list with the values \code{is_piped} (logical) and \code{env}
#'   (an environment reference). The former is \code{TRUE} if a pipeline is
#'   identified as \code{FALSE} otherwise. The latter holds a reference to
#'   the \code{\%>\%} frame where the pipeline is created and evaluated.
#'
#' @noRd
pipeline_info <- function() {
  parents <- lapply(sys.frames(), parent.env)

  is_magrittr_env <-
    vapply(parents, identical, logical(1), y = environment(`%>%`))

  is_piped <- any(is_magrittr_env)

  list(is_piped = is_piped,
       env      = if (is_piped) sys.frames()[[max(which(is_magrittr_env))]])
}

#' Toggle Auto Execution On or Off for Pipelines
#'
#' A call to \code{pipe_autoexec} allows a function to toggle auto execution of
#' \code{jq} on or off at the end of a pipeline.
#'
#' @param toggle logical: \code{TRUE} toggles auto execution on, \code{FALSE}
#'   toggles auto execution off.
#'
#' @details Once auto execution is turned on the \code{result} identifier inside
#' the pipeline is bound to an "Active Binding". This will not be changed on
#' toggling auto execution off, but rather the function to be executed is
#' changed to \code{identity}.
#'
#' @noRd
pipe_autoexec <- function(toggle) {
  if (!identical(toggle, TRUE) && !identical(toggle, FALSE)) {
    stop("Argument 'toggle' must be logical.")
  }

  info <- pipeline_info()

  if (isTRUE(info[["is_piped"]])) {
    jq_exit <- function(j) if (inherits(j, "jqr")) jq(j) else j
    pipeline_on_exit(info$env)
    info$env$.jq_exitfun <- if (toggle) jq_exit else identity
  }

  invisible()
}

#' Setup On-Exit Action for a Pipeline
#'
#' A call to \code{pipeline_on_exit} will setup the pipeline for auto
#' execution by overriding the return value from an \code{on.exit}
#' expression pushed in the magrittr frame.
#'
#' @param env A reference to the \code{\%>\%} environment.
#'
#' @noRd
pipeline_on_exit <- function(env) {
  # Only activate the first time; after this the binding is already active.
  if (exists(".jq_exitfun", envir = env, inherits = FALSE, mode = "function")) {
    return(invisible())
  }
  env$.jq_exitfun <- identity

  # Need to be a bit careful with scoping since `env` is foreign. We
  # inline closures in calls with `do.call()` and `as.call()`. Usage
  # of `do.call()` instead of `eval()` is necessary so that
  # `on.exit()`, `return()`, and `returnValue()` are evaluated in the
  # correct environment upstack and not in the duplicate call frame
  # that `eval()` pushes on the stack.
  exit_clo <- function() {
    out <- do.call(returnValue, list(), envir = env)

    # Will be `NULL` in case of error. This doesn't matter here since
    # we only modify return values that inherit from `"jqr"`.
    if (!is.null(out)) {
      do.call(return, alist(.jq_exitfun(returnValue())), envir = env)
    }
  }

  do.call(on.exit, list(as.call(list(exit_clo)), add = TRUE), envir = env)
}

utils::globalVariables(".jq_exitfun")
