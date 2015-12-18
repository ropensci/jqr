#' Pretty print
#'
#' @export
#' @param .data input
#' @examples
#' x <- '{"foo":[{"foo": []}, {"foo":[{"foo":[]}]}]}'
#' x %>% recurse(.foo[])
#' x %>% recurse(.foo[]) %>% pretty
pretty <- function(.data) {
  pipe_autoexec(toggle = FALSE)
  # .data$data
  cat(jq(.data), sep = "\n")
}
