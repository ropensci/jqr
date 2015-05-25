#' Logical tests
#'
#' @export
#' @name logicaltests
#' @template args
#' @examples
#' # any
#' '[true, false]' %>% any %>% jq
#' '[false, false]' %>% any %>% jq
#' '[]' %>% any %>% jq
#'
#' # all
#' '[true, false]' %>% all %>% jq
#' '[true, true]' %>% all %>% jq
#' '[]' %>% add %>% jq

#' @export
#' @rdname logicaltests
all <- function(.data) {
  dots <- comb(tryargs(.data), structure('all', type = "all"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname logicaltests
any <- function(.data) {
  dots <- comb(tryargs(.data), structure('any', type = "any"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
