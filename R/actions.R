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
