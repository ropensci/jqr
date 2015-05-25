#' Logical tests
#'
#' @export
#' @name logicaltests
#' @param .data input
#' @examples
#' # any
#' '[true, false]' %>% anyj %>% jq
#' '[false, false]' %>% anyj %>% jq
#' '[]' %>% anyj %>% jq
#'
#' # all
#' '[true, false]' %>% allj %>% jq
#' '[true, true]' %>% allj %>% jq
#' '[]' %>% allj %>% jq

#' @export
#' @rdname logicaltests
allj <- function(.data) {
  dots <- comb(tryargs(.data), structure('all', type = "all"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname logicaltests
anyj <- function(.data) {
  dots <- comb(tryargs(.data), structure('any', type = "any"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
