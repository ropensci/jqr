#' Select variables
#'
#' @import lazyeval
#' @export
#' @template args
#' @examples
#' '{"foo": 5, "bar": 7}' %>% select(a = .foo) %>% peek
#' '{"foo": 5, "bar": 7}' %>% select(a = .foo) %>% jq
#'
#' # using json dataset, just first element
#' x <- githubcommits %>% index(0)
#' x %>%
#'    select(message = .commit.message, name = .commit.committer.name) %>% jq
#' x %>%
#'    select(sha = .commit.tree.sha, author = .author.login) %>% jq
#'
#' # using json dataset, all elements
#' x <- githubcommits %>% index()
#' x %>%
#'    select(message = .commit.message, name = .commit.committer.name) %>% jq
#' ## pretty (newline after each element)
#' x %>%
#'  select(sha = .sha, name = .commit.committer.name) %>% jq(TRUE)
select <- function(.data, ...) {
  select_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname select
select_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  vals <- unname(Map(function(x,y) {
    sprintf("%s: %s", x, as.character(y$expr))
  }, names(tmp), tmp))
  z <- paste0("{", paste0(vals, collapse = ", "), "}")
  dots <- comb(tryargs(.data), structure(z, type = "select"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
