#' Build arrays and objects
#' 
#' @name build
#' @template args
#' @examples
#' ## BUILD ARRAYS
#' x <- '{"user":"jqlang", "projects": ["jq", "wikiflow"]}' 
#' jq(x, "[.user, .projects[]]")
#' x %>% build_array(.user, .projects[])
#' 
#' jq('[1, 2, 3]', '[ .[] | . * 2]')
#' '[1, 2, 3]' %>% build_array(.[] | . * 2)
#' 
#' 
#' ## BUILD OBJECTS
#' '{"foo": 5, "bar": 7}' %>% build_object(a = .foo) %>% peek
#' '{"foo": 5, "bar": 7}' %>% build_object(a = .foo)
#'
#' # using json dataset, just first element
#' x <- commits %>% index(0)
#' x %>%
#'    build_object(message = .commit.message, name = .commit.committer.name)
#' x %>% build_object(sha = .commit.tree.sha, author = .author.login)
#'
#' # using json dataset, all elements
#' x <- index(commits)
#' x %>% build_object(message = .commit.message, name = .commit.committer.name)
#' x %>% build_object(sha = .sha, name = .commit.committer.name)
#'
#' # many JSON inputs
#' '{"foo": 5, "bar": 7} {"foo": 50, "bar": 7} {"foo": 500, "bar": 7}' %>%
#'   build_object(hello = .foo)

#' @export
#' @rdname build
build_array <- function(.data, ...) {
  build_array_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname build
build_array_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  tmp <- lapply(tmp, function(x) deparse(x$expr))
  z <- paste0("[", paste0(tmp, collapse = ", "), "]")
  dots <- comb(tryargs(.data), structure(z, type = "array"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}


#' @export
#' @rdname build
build_object <- function(.data, ...) {
  build_object_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname build
build_object_ <- function(.data, ..., .dots) {
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
  dots <- comb(tryargs(.data), structure(z, type = "object"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
