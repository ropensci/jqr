#' paths outputs the paths to all the elements in its input
#'
#' @export
#' @param .data input
#' @examples
#' '[1,[[],{"a":2}]]' %>% paths %>% jq(TRUE)
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% paths %>% jq(TRUE)
paths <- function(.data) {
  dots <- comb(tryargs(.data), structure('paths', type = "paths"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
