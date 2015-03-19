#' Math operations
#'
#' @name maths
#' @template args
#' @export
length <- function(.data) {
  length_(.data, dots = "length")
}

#' @export
#' @rdname maths
length_ <- function(.data, dots) {
  dots <- comb(tryargs(.data), structure(dots, type="length"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}
