#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package. \code{jq}
#' also provides access to the low level interface in which you can use jq query strings just
#' as you would on the command line. Output gets class of json, and pretty prints to
#' the console for easier viewing. The \code{jqr} doesn't do pretty printing.
#'
#' @export
#' @param x \code{json} object or character string with json data.
#' @param ... character specification of jq query. Each element in code{...}
#'   will be combined with " | ", which is convenient for long queries.
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
jq.jqr <- function(x, ..., flags=jq_flags()) {
  pipe_autoexec(toggle = FALSE)
  res <- structure(jqr(x$data, make_query(x), flags),
                   class = c("jqson", "character"))
  query <- query_from_dots(...)
  if (query != "")
    jq(res, query)
  else
    res
}

#' @rdname jq
#' @export
jq.character <- function(x, ..., flags=jq_flags()) {
  query <- query_from_dots(...)
  structure(jqr(x, query, flags),
            class = c("jqson", "character"))
}

#' @export
jq.default <- function(x, ...) {
  stop(sprintf("jq method not implemented for %s.", class(x)[1]))
}

#' @export
print.jqson <- function(x, ...) {
  cat(jsonlite::prettify(combine(x)))
}

#' Helper function for createing a jq query string from ellipses.
#' @noRd
query_from_dots <- function(...)
{
  dots <- list(...)
  if (!all(vapply(dots, is.character, logical(1))))
    stop("jq query specification must be character.")

  paste(unlist(dots), collapse = " | ")
}

##' Flags for use with jq
##' @title Flags for use with jq
##' @param pretty Pretty print the json (different to jsonlite's
##'   pretty printing).
##' @param ascii Force jq to produce pure ASCII output with non-ASCII
##'   characters replaced by equivalent escape sequences.
##' @param color Add ANSI escape sequences for coloured output
##' @param sorted Output fields of each object with keys in sorted order
##' @export
jq_flags <- function(pretty=FALSE, ascii=FALSE, color=FALSE, sorted=FALSE) {
  sum(c(integer(0),
        if (pretty) 1L,
        if (ascii)  2L,
        if (color)  4L,
        if (sorted) 8L))
}
