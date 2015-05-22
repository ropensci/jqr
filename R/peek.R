#' Peek at a query
#'
#' Prints the query resulting from \code{jq} all in one character string just
#' as you would execute it on the command line. Output gets class of json,
#' and pretty prints to the console for easier viewing. The \code{jqr}
#' doesn't do pretty printing.
#'
#' @export
#' @param .data (list) input, using higher level interface
#' @seealso \code{\link{jq}}, \code{\link{jq_}}
#' @examples
#' '{"a": 7}' %>%  do(.a + 1) %>% peek
#' '[8,3,null,6]' %>% sort %>% peek
peek <- function(.data) {
  if (!is(.data, "jqr")) stop("must be of class jqr", call. = FALSE)
  structure(make_query(.data), class = "jq_query")
}

#' @export
print.jq_query <- function(x, ...) {
  cat("<jq query>", sep = "\n")
  cat("  query: ", x)
}

make_query <- function(x) {
  paste0(pop(x), collapse = " | ")
}
