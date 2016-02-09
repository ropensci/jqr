#' Format strings and escaping
#'
#' @export
#' @template args
#' @examples
#' x <- '{"user":"stedolan","titles":["JQ Primer", "More JQ"]}'
#' # x %>% at(base64) %>% peek
#' x %>% at(base64)
#' x %>% index() %>% at(base64)
#'
#' y <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
#' y %>% index() %>% at(base64)
#'
#' ## prepare for shell use
#' y %>% index() %>% at(sh)
#'
#' ## rendered as csv with double quotes
#' z <- '[1, 2, 3, "a"]'
#' z %>% at(csv)
#'
#' ## rendered as csv with double quotes
#' z %>% index()
#' z %>% index() %>% at(text)
#'
#' ## % encode for URI's
#' #### DOESNT WORK --------------------------
#'
#' ## html escape
#' #### DOESNT WORK --------------------------
#'
#' ## serialize to json
#' #### DOESNT WORK --------------------------
at <- function(.data, ...) {
  at_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname at
at_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(paste0("@", get_expr(tmp)), type = "at"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

get_expr <- function(x) {
  if (inherits(x, "lazy_dots")) {
    as.character(x[[1]]$expr)
  } else {
    as.character(x$expr)
  }
}
