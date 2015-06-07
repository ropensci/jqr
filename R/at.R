#' Format strings and escaping
#'
#' @export
#' @template args
#' @examples
#' x <- '{"user":"stedolan","titles":["JQ Primer", "More JQ"]}'
#' x %>% at(base64) %>% peek
#' x %>% at(base64) %>% jq
#' x %>% index() %>% at(base64) %>% jq
#'
#' y <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
#' y %>% index() %>% at(base64) %>% jq
#'
#' ## prepare for shell use
#' y %>% index() %>% at(sh) %>% jq
#'
#' ## rendered as csv with double quotes
#' z <- '[1, 2, 3, "a"]'
#' z %>% at(csv) %>% jq
#'
#' ## rendered as csv with double quotes
#' z %>% index() %>% jq
#' z %>% index() %>% at(text) %>% jq
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
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(paste0("@", get_expr(tmp)), type = "at"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

get_expr <- function(x) {
  if (is(x, "lazy_dots")) {
    as.character(x[[1]]$expr)
  } else {
    as.character(x$expr)
  }
}
