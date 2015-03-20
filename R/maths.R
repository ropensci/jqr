#' Math operations
#'
#' @name maths
#' @template args
#' @export
#' @examples \dontrun{
#' # do math
#' jqr('{"a": 7}', '.a + 1')
#' jqr('{"a": 7}', '.a += 1')
#' '{"a": 7}' %>%  do(.a + 1) %>% jq
#' # '{"a": 7}' %>%  do(.a += 1) %>% jq # this doesn't work quite yet
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b) %>% jq
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b) %>% jq
#' '{"a": 3}' %>%  do(4 - .a) %>% jq
#' '["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]') %>% jq
#' '5' %>%  do(10 / . * 3) %>% jq
#' ## comparisons
#' '[5,4,2,7]' %>% index() %>% do(. < 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. > 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. <= 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. >= 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. == 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. != 4) %>% jq
#'
#' # length
#' '[[1,2], "string", {"a":2}, null]' %>% index %>% length %>% jq
#'
#' # sqrt
#' '9' %>% sqrt %>% jq
#'
#' # floor
#' '3.14159' %>% floor %>% jq
#'
#' # find minimum
#' '[5,4,2,7]' %>% min %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% min %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% min(foo) %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% min(bar) %>% jq
#'
#' # find maximum
#' '[5,4,2,7]' %>% max %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% max %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% max(foo) %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% max(bar) %>% jq
#' }

#' @export
#' @rdname maths
do <- function(.data, ...) {
  do_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
do_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(unlist(lapply(tmp, function(x) deparse(x$expr))), collapse = " ")
  dots <- comb(tryargs(.data), structure(z, type="do"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

#' @export
#' @rdname maths
length <- function(.data) {
  dots <- comb(tryargs(.data), structure('length', type="length"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

#' @export
#' @rdname maths
sqrt <- function(.data) {
  dots <- comb(tryargs(.data), structure("sqrt", type="sqrt"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

#' @export
#' @rdname maths
floor <- function(.data) {
  dots <- comb(tryargs(.data), structure('floor', type="floor"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

#' @export
#' @rdname maths
min <- function(.data, ...) {
  min_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
min_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  if(base::length(tmp) == 0) {
    z <- "min"
  } else {
    z <- sprintf("min_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type="min"))
  structure(list(data=.data, args=dots), class="jqr")
}

#' @export
#' @rdname maths
max <- function(.data, ...) {
  max_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
max_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  if(base::length(tmp) == 0) {
    z <- "max"
  } else {
    z <- sprintf("max_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type="max"))
  structure(list(data=.data, args=dots), class="jqr")
}
