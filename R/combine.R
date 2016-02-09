#' Combine json pieces
#'
#' @export
#' @param x Input, of class json
#' @examples
#' x <- '{"foo": 5, "bar": 7}' %>% select(a = .foo)
#' combine(x)
#'
#' (x <- githubcommits %>% index() %>%
#'  select(sha = .sha, name = .commit.committer.name))
#' combine(x)
combine <- function(x) {
  pipe_autoexec(toggle = FALSE)
  if (!inherits(x, "jqson")) stop("Must be class jqson", call. = FALSE)
  if (!jsonlite::validate(x)) {
    tmp <- paste0("[", paste0(x, collapse = ", "), "]")
    tmpval <- jsonlite::validate(tmp)
    if (tmpval) {
      x <- tmp
    } else {
      stop(attr(tmpval, "err"), call. = FALSE)
    }
  }
  structure(x, class = "jqson", pretty = TRUE)
}
