#' Sort and related
#'
#' @export
#' @template args
#' @examples
#' # sort
#' '[8,3,null,6]' %>% sortj
#' '[{"foo":4, "bar":10}, {"foo":3, "bar":100}, {"foo":2, "bar":1}]' %>%
#'   sortj(foo)
#'
#' # reverse order
#' '[1,2,3,4]' %>% reverse
#'
#' # many JSON inputs
#' '[{"foo":7}, {"foo":4}] [{"foo":300}, {"foo":1}] [{"foo":2}, {"foo":1}]' %>%
#'   sortj(foo)
#'
#' '[1,2,3,4] [10,20,30,40] [100,200,300,4000]' %>%
#'   reverse
sortj <- function(.data, ...) {
  sortj_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname sortj
sortj_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "sort"
  } else {
    z <- sprintf("sort_by(.%s)", deparse(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "sort"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname sortj
reverse <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure("reverse", type = "reverse"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
