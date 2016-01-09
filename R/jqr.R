#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package. \code{jq}
#' also provides access to the low level interface in which you can use jq query strings just
#' as you would on the command line. Output gets class of json, and pretty prints to
#' the console for easier viewing. The \code{jqr} doesn't do pretty printing.
#'
#' @export
#' @param x \code{json} object or character string with json data.
#' @param query (character) A query string
#' @param ... Not currently used.
#' @seealso \code{\link{peek}}
#' @examples
#' '{"a": 7}' %>%  do(.a + 1)
#' '[8,3,null,6]' %>% sortj
#'
#' x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'
#' jq(index(x))
#'
#' jq('{"a": 7, "b": 4}', 'keys')
#' jq('[8,3,null,6]', 'sort')
jq <- function(x, ...) {
  UseMethod("jq", x)
}

#' @rdname jq
#' @export
jq.jqr <- function(x, ...) {
  pipe_autoexec(toggle = FALSE)
  structure(jqr(x$data, make_query(x)), class = c("json", "character"))
}

#' @rdname jq
#' @export
jq.character <- function(x, query, ...) {
  structure(jqr(x, query), class = c("json", "character"))
}

#' @export
jq.default <- function(x, ...) {
  stop(sprintf("jq method not implemented for %s.", class(x)[1]))
}

#' @export
print.json <- function(x, ...) {
  cat(jsonlite::prettify(combine(x)))
}
