#' select variables
#'
#' @import lazyeval
#' @export
#' @template args
select <- function(.data, ...) {
  select_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname select
select_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  vals <- unname(Map(function(x,y) {
    sprintf("%s: %s", x, as.character(y$expr))
  }, names(tmp), tmp))
  z <- paste0("{", paste0(vals, collapse = ", "), "}")
  dots <- comb(tryargs(.data), structure(z, type="select"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}
