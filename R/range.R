#' Produce range of numbers
#'
#' @export
#' @param x Input, single number or number range.
#' @param array (logical) Create array. Deafult: FALSE
#' @examples
#' rangej(2:4)
#' rangej(2:4) %>% jq
#' rangej(2:4, TRUE)
#' rangej(2:4, TRUE) %>% jq
#' # not working for some reason
#' # rangej(4, TRUE) %>% jq
rangej <- function(x, array = FALSE) {
  x <- get_jq_seq(x, array)
  structure(list(data = "null", args = structure(x, type = "range")), class = "jqr")
}

get_jq_seq <- function(y, z) {
  tmp <- as.character(y)
  if (length(tmp) == 1) {
    tmp2 <- sprintf("range(%s)", tmp)
  } else {
    tmp2 <- sprintf("range(%s)", paste(tmp[1], tmp[length(tmp)], collapse = "", sep = ";"))
  }
  if (z) {
    sprintf("[%s]", tmp2)
  } else {
    tmp2
  }
}
