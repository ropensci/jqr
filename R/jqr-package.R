#' jqr: An R client for the C library jq
#'
#' @section Low-level:
#' Low level interface, in which you can execute `jq` code just as you
#' would on the command line. Available via \code{\link{jq}}
#'
#' @section High-level DSL:
#' High-level, uses a suite of functions to construct queries. Queries
#' are constucted, then excuted internally with \code{\link{jq}}
#'
#' @section Pipes:
#' The high level DSL supports piping, though you don't have to use
#' pipes.
#'
#' @section NSE and SE:
#' Most DSL functions have NSE (non-standard evaluation) and SE
#' (standard evaluation) versions, which make \code{jqr} easy to use
#' for interactive use as well as programming.
#'
#' @section jq version:
#' \code{jqr} is currenlty using \code{jq v1.4}
#'
#' @section indexing:
#' note that \code{jq} indexing starts at \code{0}, whereas R indexing
#' starts at \code{1}. So when you want the first thing in an array using \code{jq},
#' for example, you want \code{0}, not \code{1}
#'
#' @importFrom lazyeval all_dots lazy_dots
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
