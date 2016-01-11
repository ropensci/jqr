#' index and related functions
#'
#' @export
#' @template args
#' @details
#' \itemize{
#'  \item \code{index}/\code{index_} - queries like: \code{.[]}, \code{.[0]}, \code{.[1:5]},
#'  \code{.["foo"]}
#'  \item \code{indexif}/\code{indexif_} - queries like: \code{.[foo?]}
#'  \item \code{dotindex}/\code{dotindex_} - queries like: \code{.[].foo}, \code{.[].foo.bar}
#' }
#' @examples
#' str <- '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]'
#' str %>% index
#' str %>% indexif
#' str %>% indexif(name)
#' '{"name":"JSON", "good":true}' %>% indexif(name)
#' '{"name":"JSON", "good":true}' %>% indexif(good)
#' '{"name":"JSON", "good":true}' %>% indexif(that)
#' '{"a": 1, "b": 1}' %>% index
#' '[]' %>% index
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% index(0)
#' '["a","b","c","d","e"]' %>% index(2)
#' '["a","b","c","d","e"]' %>% index('2:4')
#' '["a","b","c","d","e"]' %>% index('2:5')
#' '["a","b","c","d","e"]' %>% index(':3')
#' '["a","b","c","d","e"]' %>% index('-2:')
#'
#' str %>% index %>% select(bad = .name)
#'
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% dotindex(name)
#' '[{"name":"JSON", "good":true}, {"name":"XML", "good":false}]' %>% dotindex(good)
#' '[{"name":"JSON", "good":{"foo":5}}, {"name":"XML", "good":{"foo":6}}]' %>% dotindex(good)
#' '[{"name":"JSON", "good":{"foo":5}}, {"name":"XML", "good":{"foo":6}}]' %>% dotindex(good.foo)
index <- function(.data, ...) {
  index_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname index
index_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  if (length(tmp) == 0) {
    z <- '.[]'
  } else {
    z <- paste0(".[", collapse_vec(tmp[[1]]$expr), "]")
  }
  dots <- comb(tryargs(.data), structure(z, type = "index"))
  structure(list(data = .data, args = dots), class = "jqr")
}

#' @export
#' @rdname index
indexif <- function(.data, ...) {
  indexif_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname index
indexif_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  if (length(tmp) == 0) {
    z <- '.[]'
  } else {
    z <- sprintf('.["%s"]?', as.character(tmp[[1]]$expr))
    # z <- sprintf('.[%s?]', as.character(tmp[[1]]$expr))
  }
  dots <- comb(tryargs(.data), structure(z, type = "indexif"))
  structure(list(data = .data, dots), class = "jqr")
}

#' @export
#' @rdname index
dotindex <- function(.data, ...) {
  dotindex_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname index
dotindex_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- sprintf(".[].%s", as.character(tmp[[1]]$expr))
  dots <- comb(tryargs(.data), structure(z, type = "dotindex"))
  structure(list(data = .data, dots), class = "jqr")
}

# helpers ----------------------
collapse_vec <- function(x) {
  if (length(x) > 1) {
    if (!any(sapply(x, is.numeric))) stop("Only supports numeric vectors", call. = FALSE)
    paste0(min(x), ":", max(x))
  } else {
    x
  }
}
