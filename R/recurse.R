#' Search through a recursive structure - extract data from all levels
#'
#' @export
#' @template args
#' @examples
#' x <- '{"name": "/", "children": [
#'   {"name": "/bin", "children": [
#'     {"name": "/bin/ls", "children": []},
#'     {"name": "/bin/sh", "children": []}]},
#'   {"name": "/home", "children": [
#'     {"name": "/home/stephen", "children": [
#'       {"name": "/home/stephen/jq", "children": []}]}]}]}'
#' x %>% recurse(.children[]) %>% select(name)
#' x %>% recurse(.children[]) %>% select(name) %>% string
recurse <- function(.data, ...) {
  recurse_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname recurse
recurse_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- if (length(tmp) == 0) {
    "recurse_down"
  } else {
    sprintf("recurse(%s)", setdef(tmp, ''))
  }
  dots <- comb(tryargs(.data), structure(z, type = "recurse"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
