#' @useDynLib jqr C_jqr_new
jqr_new <- function(filter, output_flags){
  stopifnot(is.character(filter))
  stopifnot(is.numeric(output_flags))
  .Call(C_jqr_new, filter, as.integer(output_flags))
}

#' @useDynLib jqr C_jqr_feed
jqr_feed <- function(ptr, json, finalize){
  stopifnot(inherits(ptr, 'jqr_program'))
  stopifnot(is.character(json))
  stopifnot(is.logical(finalize))
  .Call(C_jqr_feed, ptr, json, finalize)
}
