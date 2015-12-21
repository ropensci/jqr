#' Outputs paths to all the elements in its input
#'
#' @export
#' @param .data input
#' @examples
#' '[1,[[],{"a":2}]]' %>% paths
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% paths
paths <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('paths', type = "paths"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
