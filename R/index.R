#' index and related functions
#'
#' @export
#' @param .data input
#' @param dots dots
#' @param x What to index to
#' @examples
#' str <- '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]'
#' str %>% index
#' str %>% indexif
#' str %>% indexif('that')
#' '{"a": 1, "b": 1}' %>% index
#' '[]' %>% index
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% index(0)
#' '["a","b","c","d","e"]' %>% index(2)
#' '["a","b","c","d","e"]' %>% index(2:4)
#' '["a","b","c","d","e"]' %>% index(2:5)
#' '["a","b","c","d","e"]' %>% index(":3")
#' '["a","b","c","d","e"]' %>% index("-2:")
#'
#' str %>% index %>% select(bad = .name)
index <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", collapse_vec(x), "]"))
}

#' @export
#' @rdname index
index_ <- function(.data, dots) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure(dots, type="index"))
  structure(list(data=.data, args=dots), class="jqr")
}

#' @export
#' @rdname index
indexif <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", x, "]?"))
}

#' @export
#' @rdname index
indexif_ <- function(.data, dots) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure(dots, type="indexif"))
  structure(list(data=.data, dots), class="jqr")
}

collapse_vec <- function(x) {
  if (length(x) > 1) {
    if (!any(sapply(x, is.numeric))) stop("Only supports numeric vectors", call. = FALSE)
    paste0(min(x), ":", max(x))
  } else {
    x
  }
}
