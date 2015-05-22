#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package. \code{jq_}
#' provides access to the low level interface in which you can use jq query strings just
#' as you would on the command line. Output gets class of json, and pretty prints to
#' the console for easier viewing. The \code{jqr} doesn't do pretty printing.
#'
#' @export
#' @param .data (list) input, using higher level interface
#' @param data (character) JSON data
#' @param query (character) A query string
#' @param pretty (logical) Add newlines when printed. Default: FALSE
#' @seealso \code{\link{peek}}
#' @examples
#' '{"a": 7}' %>%  do(.a + 1) %>% jq
#' '[8,3,null,6]' %>% sort %>% jq
jq <- function(.data, pretty = FALSE) {
  structure(jqr(.data$data, make_query(.data)), class = "json", pretty = pretty)
}

#' @export
#' @rdname jq
jq_ <- function(data, query) {
  jqr(data, query)
}

#' @export
print.json <- function(x, ...){
  if (attr(x, "pretty")) {
    cat(x, sep = "\n")
  } else {
    cat(x, "\n")
  }
}
