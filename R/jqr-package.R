#' jqr: An R client for the C library jq
#'
#' @section Low-level:
#' Low level interface, in which you can execute `jq` code just as you
#' would on the command line. Available via \code{\link{jq_}}
#'
#' @section High-level DSL:
#' High-level, uses a suite of functions to construct queries. Queries
#' are constucted, then excuted internally with `jq()`.
#'
#' @section Pipes:
#' The high level DSL supports piping, though you don't have to use
#' pipes.
#'
#' @section jq version:
#' \code{jqr} is currenlty using \code{jq v1.4}
#'
#' @docType package
#' @aliases jqr-package
#' @name jqr
NULL

#' GitHub Commits Data
#'
#' @docType data
#' @keywords datasets
#' @name githubcommits
#' @format A character string of json github commits data for the jq repo.
NULL
