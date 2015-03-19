#' index and related functions
#'
#' @export
#' @template args
#' @param x What to index to
index <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", x, "]"))
}

#' @export
#' @rdname index
index_ <- function(.data, dots) {
  dots <- comb(tryargs(.data), structure(dots, type="index"))
  structure(list(data=.data, args=dots), class="jqr")
}

#' @export
#' @rdname index
indexif <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", x, "]?"))
}

#' @export
#' @rdname index
indexif_ <- function(.data, dots) {
  dots <- comb(tryargs(.data), structure(dots, type="indexif"))
  structure(list(data=.data, dots), class="jqr")
}
