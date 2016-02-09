#' Peek at a query
#'
#' Prints the query resulting from \code{jq} all in one character string just
#' as you would execute it on the command line. Output gets class of json,
#' and pretty prints to the console for easier viewing.
#'
#' @export
#' @param .data (list) input, using higher level interface
#' @seealso \code{\link{jq}}.
#' @examples
#' '{"a": 7}' %>% do(.a + 1) %>% peek
#' '[8,3,null,6]' %>% sortj %>% peek
peek <- function(.data) {
  pipe_autoexec(toggle = FALSE)
  if (!inherits(.data, "jqr")) stop("must be of class jqr", call. = FALSE)
  structure(make_query(.data), class = "jq_query")
}

#' @export
print.jq_query <- function(x, ...) {
  cat("<jq query>", sep = "\n")
  cat(sprintf("  query: %s\n", x))
}
