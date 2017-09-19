#' Select variables
#'
#' @export
#' @template args
#' @examples
#' '{"foo": 5, "bar": 7}' %>% select(a = .foo) %>% peek
#' '{"foo": 5, "bar": 7}' %>% select(a = .foo)
#'
#' # using json dataset, just first element
#' x <- commits %>% index(0)
#' x %>%
#'    select(message = .commit.message, name = .commit.committer.name)
#' x %>% select(sha = .commit.tree.sha, author = .author.login)
#'
#' # using json dataset, all elements
#' x <- index(commits)
#' x %>% select(message = .commit.message, name = .commit.committer.name)
#' x %>% select(sha = .sha, name = .commit.committer.name)
#'
#' # many JSON inputs
#' '{"foo": 5, "bar": 7} {"foo": 50, "bar": 7} {"foo": 500, "bar": 7}' %>%
#'   select(hello = .foo)
select <- function(.data, ...) {
  select_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname select
select_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  vals <- unname(Map(function(x,y) {
    if (nchar(x) == 0) {
      as.character(y$expr)
    } else {
      sprintf("%s: %s", x, as.character(y$expr))
    }
  }, names(tmp), tmp))
  z <- paste0("{", paste0(vals, collapse = ", "), "}")
  dots <- comb(tryargs(.data), structure(z, type = "select"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
