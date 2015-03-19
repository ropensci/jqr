#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package. \code{jq_}
#' provides access to the low level interface in which you can use jq query strings just
#' as you would on the command line. \code{show} prints the query resulting from \code{jq}
#' all in one character string just as you would execute it on the command line.
#'
#' @param .data (list) input, using higher level interface
#' @param data (character) JSON data
#' @param query (character) A query string
#' @export
jq <- function(.data) {
  jqr(.data$data, make_query(.data))
}

#' @export
#' @rdname jq
jq_ <- function(data, query) {
  jqr(data, query)
}

#' @export
#' @rdname jq
show <- function(.data) {
  make_query(.data)
}

make_query <- function(x) {
  paste0(pop(x), collapse = " | ")
}
