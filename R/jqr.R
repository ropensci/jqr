#' Execute a query with jq
#'
#' \code{jq} is meant to work with the high level interface in this package.
#' \code{jq} also provides access to the low level interface in which you can
#' use jq query strings just as you would on the command line. Output gets
#' class of json, and pretty prints to the console for easier viewing.
#' \code{jqr} doesn't do pretty printing.
#'
#' @export
#' @param x \code{json} object or character string with json data. this can
#' be one or more valid json objects
#' @param ... character specification of jq query. Each element in code{...}
#'   will be combined with " | ", which is convenient for long queries.
#' @param flags See \code{\link{jq_flags}}
#' @seealso \code{\link{peek}}
#' @examples
#' '{"a": 7}' %>%  do(.a + 1)
#' '[8,3,null,6]' %>% sortj
#'
#' x <- '[{"message": "hello", "name": "jenn"},
#'   {"message": "world", "name": "beth"}]'
#' jq(index(x))
#'
#' jq('{"a": 7, "b": 4}', 'keys')
#' jq('[8,3,null,6]', 'sort')
#'
#' # many json inputs
#' jq("[123, 456] [77, 88, 99]", ".[]")
#' 
#' # file path
#' cat('{"a": 7, "b": 4}\n', file = (f=tempfile(fileext = ".json")))
#' jq(f, "keys")
#' 
#' # URL
#' x <- 'https://api.github.com/'
#' jq(x, "keys")
#' jq(x, ".meta | keys")
jq <- function(x, ...) {
  UseMethod("jq", x)
}

#' @rdname jq
#' @export
jq.jqr <- function(x, ...) {
  pipe_autoexec(toggle = FALSE)
  flags <- `if`(is.null(attr(x, "jq_flags")), jq_flags(), attr(x, "jq_flags"))
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
jq.character <- function(x, ..., flags = jq_flags()) {
  query <- query_from_dots(...)
  structure(jqr(x, query, flags),
            class = c("jqson", "character"))
}

#' @rdname jq
#' @export
jq.json <- function(x, ..., flags = jq_flags()) {
  jq(unclass(x), ..., flags = flags)
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

#' @useDynLib jqr C_jqr_string
jqr_apply <- function(json, program, flags){
  json <- consume_input(json)
  json <- paste(json, collapse = "\n")
  stopifnot(is.character(program))
  stopifnot(is.numeric(flags))
  out <- .Call(C_jqr_string, json, program, as.integer(flags))
  out <- lapply(out, rev);
  rev(out)
}

jqr <- function(json, program, flags = jq_flags()){
  out <- jqr_apply(json, program, flags)
  as.character(unlist(out, recursive = FALSE))
}

consume_input <- function(x) {
  if (file.exists(x) || grepl("https?://.+", x)) readLines(x, warn = FALSE) else x
}
