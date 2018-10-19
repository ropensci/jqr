#' Math operations
#'
#' @name maths
#' @template args
#' @export
#' @examples
#' # do math
#' jq('{"a": 7}', '.a + 1')
#' # adding null gives back same result
#' jq('{"a": 7}', '.a + null')
#' jq('{"a": 7}', '.a += 1')
#' '{"a": 7}' %>%  do(.a + 1)
#' # '{"a": 7}' %>%  do(.a += 1) # this doesn't work quite yet
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b)
#' '{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b)
#' '{"a": 3}' %>%  do(4 - .a)
#' '["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]')
#' '5' %>%  do(10 / . * 3)
#' ## many JSON inputs
#' '{"a": [1,2], "b": [3,4]} {"a": [1,5], "b": [3,10]}' %>%  do(.a + .b)
#'
#' # comparisons
#' '[5,4,2,7]' %>% index() %>% do(. < 4)
#' '[5,4,2,7]' %>% index() %>% do(. > 4)
#' '[5,4,2,7]' %>% index() %>% do(. <= 4)
#' '[5,4,2,7]' %>% index() %>% do(. >= 4)
#' '[5,4,2,7]' %>% index() %>% do(. == 4)
#' '[5,4,2,7]' %>% index() %>% do(. != 4)
#' ## many JSON inputs
#' '[5,4,2,7] [4,3,200,0.1]' %>% index() %>% do(. < 4)
#'
#' # length
#' '[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj
#'
#' # sqrt
#' '9' %>% sqrtj
#' ## many JSON inputs
#' '9 4 5' %>% sqrtj
#'
#' # floor
#' '3.14159' %>% floorj
#' ## many JSON inputs
#' '3.14159 30.14 45.9' %>% floorj
#'
#' # find minimum
#' '[5,4,2,7]' %>% minj
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(foo)
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(bar)
#' ## many JSON inputs
#' '[{"foo":1}, {"foo":14}] [{"foo":2}, {"foo":3}]' %>% minj(foo)
#'
#' # find maximum
#' '[5,4,2,7]' %>% maxj
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(foo)
#' '[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(bar)
#' ## many JSON inputs
#' '[{"foo":1}, {"foo":14}] [{"foo":2}, {"foo":3}]' %>% maxj(foo)
#'
#' # increment values
#' ## requires special % operators, they get escaped internally
#' '{"foo": 1}' %>% do(.foo %+=% 1)
#' '{"foo": 1}' %>% do(.foo %-=% 1)
#' '{"foo": 1}' %>% do(.foo %*=% 4)
#' '{"foo": 1}' %>% do(.foo %/=% 10)
#' '{"foo": 1}' %>% do(.foo %//=% 10)
#' ### fix me - %= doesn't work
#' # '{"foo": 1}' %>% do(.foo %%=% 10)
#' ## many JSON inputs
#' '{"foo": 1} {"foo": 2} {"foo": 3}' %>% do(.foo %+=% 1)
#'
#' # add
#' '["a","b","c"]' %>% ad
#' '[1, 2, 3]' %>% ad
#' '[]' %>% ad
#' ## many JSON inputs
#' '["a","b","c"] ["d","e","f"]' %>% ad
#'
#' # map
#' ## as far as I know, this only works with numbers, thus it's
#' ## in the maths section
#' '[1, 2, 3]' %>% map(.+1)
#' '[1, 2, 3]' %>% map(./1)
#' '[1, 2, 3]' %>% map(.*4)
#' # many JSON inputs
#' '[1, 2, 3] [100, 200, 300] [1000, 2000, 30000]' %>% map(.+1)

#' @export
#' @rdname maths
do <- function(.data, ...) {
  do_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
do_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(unlist(lapply(tmp, function(x) sub_ops(deparse(x$expr)))), collapse = " ")
  dots <- comb(tryargs(.data), structure(z, type = "do"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

sub_ops <- function(x) {
  ops <- c("-=", "+=", "*=", "/=", "%=", "//=")
  if (base::any(vapply(ops, grepl, logical(1), x = x))) {
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
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('length', type = "length"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
sqrtj <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure("sqrt", type = "sqrt"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
floorj <- function(.data) {
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "min"
  } else {
    z <- sprintf("min_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "min"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
maxj <- function(.data, ...) {
  maxj_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname maths
maxj_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "max"
  } else {
    z <- sprintf("max_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "max"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
ad <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('add', type = "add"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname maths
map <- function(.data, ...) {
  map_(.data, .dots = lazyeval::lazy_dots(...))
}

  #' @export
#' @rdname maths
map_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  tmp <- sprintf("map(%s)", deparse(tmp[[1]]$expr))
  dots <- comb(tryargs(.data), structure(tmp, type = "map"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

# special operators
`%-=%` <- function() "+="
`%+=%` <- function() "+="
`%*=%` <- function() "*="
`%/=%` <- function() "/="
`%%=%` <- function() "%="
`%//=%` <- function() "//="
