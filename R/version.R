#' JQ version
#'
#' Returns the version of libjq.
#'
#' @useDynLib jqr C_jq_version
#' @export
jq_version <- function(){
  .Call(C_jq_version)
}
