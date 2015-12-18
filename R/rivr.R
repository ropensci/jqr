##' Create stream/iterator that works by applying jq to a
##' stream/iterator.
##' @title Create jq stream/iterator
##' @param it Any iterator that yields valid jq source input
##' @param program JQ program, operating on whatever unit \code{it}
##' returns.
##' @keywords internal
jq_iterator <- function(it, program) {
  rivr::transform_iterator(it, make_jq(program))
}

## Convenience function; a lot of syntax for a very simple operation.
##' @export
##' @rdname jq_iterator
make_jq <- function(program) {
  function(x) {
    jqr(x, program)
  }
}
