#' JQ Streaming API
#'
#' Low level JQ API. First create a program using a `filter` and `flags` and then
#' feed pieces of data.
#'
#' @export
#' @rdname jqr_core
#' @useDynLib jqr C_jqr_new
#' @param filter string with a valid jq program
#' @inheritParams jq
jqr_new <- function(filter, flags = jq_flags()){
  stopifnot(is.character(filter))
  stopifnot(is.numeric(flags))
  .Call(C_jqr_new, filter, as.integer(flags))
}

#' @export
#' @rdname jqr_core
#' @useDynLib jqr C_jqr_feed
#' @param jqr_program object returned by [jqr_new]
#' @param json character vector with json data. If the JSON object is incomplete, you
#' must set `finalize` to `FALSE` otherwise you get an error.
#' @param finalize completes the parsing and verifies that the JSON string is valid. Set
#' this to `TRUE` when feeding the final piece of data.
#' @param unlist if `TRUE` returns a single character vector with all output for each
#' each string in `json` input
#' @examples program <- jqr_new(".[]")
#' jqr_feed(program, c("[123, 456]", "[77, 88, 99]"))
#' jqr_feed(program, c("[41, 234]"))
#' jqr_feed(program, "", finalize = TRUE)
jqr_feed <- function(jqr_program, json, unlist = TRUE, finalize = FALSE){
  stopifnot(inherits(jqr_program, 'jqr_program'))
  stopifnot(is.character(json))
  stopifnot(is.logical(finalize))
  out <- .Call(C_jqr_feed, jqr_program, json, finalize)
  out <- lapply(out, rev);
  out <- rev(out)
  if(isTRUE(unlist))
    return(as.character(unlist(out, recursive = FALSE)))
  return(out)
}
