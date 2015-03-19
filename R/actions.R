del <- function(.data, ...) {
  del_(.data, .dots = lazyeval::lazy_dots(...))
}

del_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0("del(", tmp[[1]]$expr, ")", collapse = "")
  dots <- comb(tryargs(.data), structure(z, type="del"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

keys <- function(.data) {
  dots <- comb(tryargs(.data), structure("keys", type="keys"))
  structure(list(data=.data, args=dots), class="jqr")
}

types <- function(.data, ...) {
  types_(.data, .dots = lazyeval::lazy_dots(...))
}

types_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(pluck(tmp, "expr"), collapse = ",")
  dots <- comb(tryargs(.data), structure(z, type="types"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

######## hmmmm, these two aren't making sense yet
array <- function(.data) {
  array_(.data, dots = "[%s]")
}

array_ <- function(.data, dots) {
  structure(list(data=.data, structure(dots, type="array")), class="jqr")
}

hash <- function(.data) {
  array_(.data, dots = "{%s}")
}

hash_ <- function(.data, dots) {
  structure(list(data=.data, structure(dots, type="hash")), class="jqr")
}
#########
