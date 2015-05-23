#' Math operations
#'
#' @name maths
#' @template args
#' @export
#' @examples
#' # do math
#' jq_('{"a": 7}', '.a + 1')
#' jq_('{"a": 7}', '.a += 1')
#' '{"a": 7}' %>%  do(.a + 1) %>% jq
#' # '{"a": 7}' %>%  do(.a += 1) %>% jq # this doesn't work quite yet
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b) %>% jq
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b) %>% jq
#' '{"a": 3}' %>%  do(4 - .a) %>% jq
#' '["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]') %>% jq
#' '5' %>%  do(10 / . * 3) %>% jq
#'
#' # comparisons
#' '[5,4,2,7]' %>% index() %>% do(. < 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. > 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. <= 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. >= 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. == 4) %>% jq
#' '[5,4,2,7]' %>% index() %>% do(. != 4) %>% jq
#'
#' # length
#' '[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj %>% jq
#'
#' # sqrt
#' '9' %>% sqrtj %>% jq
#'
#' # floor
#' '3.14159' %>% floorj %>% jq
#'
#' # find minimum
#' '[5,4,2,7]' %>% minj %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(foo) %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(bar) %>% jq
#'
#' # find maximum
#' '[5,4,2,7]' %>% maxj %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(foo) %>% jq
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(bar) %>% jq
#'
#' # increment values
#' ## requires special % operators, they get escaped internally
#' '{"foo": 1}' %>% do(.foo %+=% 1) %>% jq
#' '{"foo": 1}' %>% do(.foo %-=% 1) %>% jq
#' '{"foo": 1}' %>% do(.foo %*=% 4) %>% jq
#' '{"foo": 1}' %>% do(.foo %/=% 10) %>% jq
#' '{"foo": 1}' %>% do(.foo %//=% 10) %>% jq
#' ### fix me - %= doesn't work
#' # '{"foo": 1}' %>% do(.foo %%=% 10) %>% jq

#' @export
#' @rdname maths
do <- function(.data, ...) {
  do_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
do_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(unlist(lapply(tmp, function(x) sub_ops(deparse(x$expr)))), collapse = " ")
  dots <- comb(tryargs(.data), structure(z, type = "do"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

sub_ops <- function(x) {
  ops <- c("-=", "+=", "*=", "/=", "%=", "//=")
  if (any(vapply(ops, grepl, logical(1), x = x))) {
    for (i in seq_along(ops)) {
      x <- if (grepl(ops[[i]], x)) {
        gsub("%", "", x)
      } else {
        x
      }
    }
  }
  return(x)
}

#' @export
#' @rdname maths
lengthj <- function(.data) {
  dots <- comb(tryargs(.data), structure('length', type = "length"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
sqrtj <- function(.data) {
  dots <- comb(tryargs(.data), structure("sqrt", type = "sqrt"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
floorj <- function(.data) {
  dots <- comb(tryargs(.data), structure('floor', type = "floor"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
minj <- function(.data, ...) {
  minj_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
minj_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "min"
  } else {
    z <- sprintf("min_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "min"))
  structure(list(data = .data, args = dots), class = "jqr")
}

#' @export
#' @rdname maths
maxj <- function(.data, ...) {
  maxj_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
maxj_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "max"
  } else {
    z <- sprintf("max_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "max"))
  structure(list(data = .data, args = dots), class = "jqr")
}

# special operators
`%-=%` <- function() "+="
`%+=%` <- function() "+="
`%*=%` <- function() "*="
`%/=%` <- function() "/="
`%%=%` <- function() "%="
`%//=%` <- function() "//="
