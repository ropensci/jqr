#' Search through a recursive structure, and extract interesting data from all levels
#'
#' @export
#' @template args
#' @examples
#' x <- '{"foo":[{"foo": []}, {"foo":[{"foo":[]}]}]}'
#' x %>% recurse(.foo[])
#' x %>% recurse(.foo[]) %>% jq(TRUE)
#' '{"a":0, "b":[1]}' %>% recurse
#' '{"a":0, "b":[1]}' %>% recurse %>% jq(TRUE)
recurse <- function(.data, ...) {
  recurse_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname recurse
recurse_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- if (length(tmp) == 0) {
    "recurse_down"
  } else {
    sprintf("recurse(%s)", setdef(tmp, ''))
  }
  dots <- comb(tryargs(.data), structure(z, type = "recurse"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
