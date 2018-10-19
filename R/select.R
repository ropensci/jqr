#' Select - filtering
#' 
#' The function \code{select(foo)} produces its input unchanged if 
#' \code{foo} returns TRUE for that input, and produces no output otherwise
#'
#' @export
#' @template args
#' @note this function has changed what it does dramatically. we were 
#' using this function for object construction, which is now done with 
#' \code{\link{build_object}}
#' @examples
#' jq('[1,5,3,0,7]', 'map(select(. >= 2))')
#' '[1,5,3,0,7]' %>% map(select(. >= 2)) 
#' 
#' 
#' '{"foo": 4, "bar": 7}' %>% select(.foo == 4)
#' '{"foo": 5, "bar": 7} {"foo": 4, "bar": 7}' %>% select(.foo == 4)
#' '[{"foo": 5, "bar": 7}, {"foo": 4, "bar": 7}]' %>% index() %>% 
#'   select(.foo == 4)
#' '{"foo": 4, "bar": 7} {"foo": 5, "bar": 7} {"foo": 8, "bar": 7}' %>% 
#'   select(.foo < 6)
#' 
#' x <- '{"foo": 4, "bar": 2} {"foo": 5, "bar": 4} {"foo": 8, "bar": 12}'
#' jq(x, 'select((.foo < 6) and (.bar > 3))')
#' jq(x, 'select((.foo < 6) or (.bar > 3))')
#' x %>% select((.foo < 6) && (.bar > 3))
#' x %>% select((.foo < 6) || (.bar > 3))
#' 
#' x <- '[{"foo": 5, "bar": 7}, {"foo": 4, "bar": 7}, {"foo": 4, "bar": 9}]'
#' jq(x, '.[] | select(.foo == 4) | {user: .bar}')
#' x %>% index() %>% select(.foo == 4) %>% build_object(user = .bar)
select <- function(.data, ...) {
  select_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname select
select_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- paste0(unlist(lapply(tmp, function(x) {
    sub_ops_sel(sub_ops(deparse(x$expr)))
  })), collapse = ", ")
  dots <- comb(tryargs(.data), structure(sprintf("select(%s)", z), 
    type = "select"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

sub_ops_sel <- function(x) {
  ops <- c("&&", "\\|\\|")
  use <- c("and", "or")
  if (base::any(vapply(ops, grepl, logical(1), x = x))) {
    for (i in seq_along(ops)) x <- gsub(ops[[i]], use[[i]], x)
  }
  return(x)
}
