#' Pretty print
#'
#' @export
#' @param .data input
#' @examples
#' x <- '{"foo":[{"foo": []}, {"foo":[{"foo":[]}]}]}'
#' x %>% recurse(.foo[])
#' x %>% recurse(.foo[]) %>% pretty
#' '{"a":0, "b":[1]}' %>% recurse
#' # '{"a":0, "b":[1]}' %>% recurse %>% pretty
pretty <- function(.data) {
  check_piped(is_piped(), pretty = TRUE)
  .data
  # structure(.data, class = "json", pretty = TRUE)
}

#' @export
print.json <- function(x, ...){
  if (attr(x, "pretty")) {
    cat(x, sep = "\n")
  } else {
    cat(x, "\n")
  }
}
