#' Types and related functions
#'
#' @name types
#' @template args
#' @export
#' @examples
#' # get type information for each element
#' jq('[0, false, [], {}, null, "hello"]', 'map(type)')
#' '[0, false, [], {}, null, "hello"]' %>% types
#' '[0, false, [], {}, null, "hello", true, [1,2,3]]' %>% types
#'
#' # select elements by type
#' jq('[0, false, [], {}, null, "hello"]', '.[] | numbers,booleans')
#' '[0, false, [], {}, null, "hello"]' %>% index() %>% type(booleans)
types <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure("map(type)", type="types"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

#' @export
#' @rdname types
type <- function(.data, ...) {
  type_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname types
type_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(pluck(tmp, "expr"), collapse = ",")
  dots <- comb(tryargs(.data), structure(z, type="types"))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}
