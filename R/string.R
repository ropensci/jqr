#' Give back a character string
#'
#' @export
#' @param .data (list) input, using higher level interface
#' @seealso \code{\link{peek}}
#' @examples
#' '{"a": 7}' %>% do(.a + 1) %>% string
#' '[8,3,null,6]' %>% sortj %>% string
string <- function(.data) {
  pipe_autoexec(toggle = FALSE)
  .data$data
}
