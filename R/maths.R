#' Math operations
#'
#' @name maths
#' @param .data input
#' @param dots dots
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
