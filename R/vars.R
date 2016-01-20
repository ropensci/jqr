#' Variables
#'
#' @export
#' @template args
#' @examples
#' x <- '{
#'  "posts": [
#'    {"title": "Frist psot", "author": "anon"},
#'    {"title": "A well-written article", "author": "person1"}
#'  ],
#'  "realnames": {
#'    "anon": "Anonymous Coward",
#'    "person1": "Person McPherson"
#'  }
#' }'
#'
#' x %>% dotstr(posts[])
#' x %>% dotstr(posts[]) %>% string
#' x %>% vars(realnames = names) %>% dotstr(posts[]) %>%
#'    select(title, author = "$names[.author]")
vars <- function(.data, ...) {
  vars_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname vars
vars_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  vals <- unlist(unname(Map(function(x,y) {
      sprintf(".%s as $%s", x, get_expr(y))
  }, names(tmp), tmp)))
  vals <- paste0(vals, collapse = ", ")
  dots <- comb(tryargs(.data), structure(vals, type = "vars"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
