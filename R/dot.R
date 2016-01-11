#' dot and related functions
#'
#' @export
#' @template args
#' @examples
#' str <- '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]'
#' str %>% dot
#' str %>% index %>% dotstr(name)
#' '{"foo": 5, "bar": 8}' %>% dot
#' '{"foo": 5, "bar": 8}' %>% dotstr(foo)
#' '{"foo": {"bar": 8}}' %>% dotstr(foo.bar)
dot <- function(.data) {
  dot_(.data, dots = ".")
}

#' @export
#' @rdname dot
dot_ <- function(.data, dots = ".") {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure(dots, type = "dot"))
  structure(list(data = .data, args = dots), class = "jqr")
}

#' @export
#' @rdname dot
dotstr <- function(.data, ...) {
  dotstr_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname dot
dotstr_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- sprintf(".%s", deparse(tmp[[1]]$expr))
  dots <- comb(tryargs(.data), structure(z, type = "dotsr"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
