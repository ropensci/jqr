#' jqr execute function
#'
#' @export
jq <- function(.data) {
  jqr(.data$data, make_query(.data))
}

#' @export
#' @rdname jq
show <- function(.data) {
  make_query(.data)
}

make_query <- function(x) {
  paste0(pop(x), collapse = " | ")
}
