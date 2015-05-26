#' index and related functions
#'
#' @export
#' @param .data input
#' @param dots dots
#' @param x What to index to
#' @examples
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% index %>% jq(TRUE)
#' '{"a": 1, "b": 1}' %>% index %>% jq
#' '[]' %>% index %>% jq
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% index(0) %>% jq
#' '["a","b","c","d","e"]' %>% index(2) %>% jq
#' '["a","b","c","d","e"]' %>% index(2:4) %>% jq
#' '["a","b","c","d","e"]' %>% index(2:5) %>% jq
#' '["a","b","c","d","e"]' %>% index(":3") %>% jq
#' '["a","b","c","d","e"]' %>% index("-2:") %>% jq
index <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", collapse_vec(x), "]"))
}

#' @export
#' @rdname index
index_ <- function(.data, dots) {
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
