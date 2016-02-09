##' @useDynLib jqr
##' @importFrom Rcpp evalCpp
NULL

cpt <- function(l) Filter(Negate(is.null), l)

comb <- function(x, y) {
  cpt(do.call("c", list(x, list(y))))
}

tryargs <- function(x) {
  res <- tryCatch(x$args, error = function(e) e)
  if (inherits(res, "simpleError")) {
    list()
  } else {
    x$args
  }
}

pop <- function(x) {
  if (!is.null(names(x))) {
    tmp <- x[ !names(x) %in% "data" ]
    if (base::length(tmp) == 1) {
      tmp[[1]]
    } else {
      tmp
    }
  } else {
    NULL
  }
}

getdata <- function(x) {
  if ("data" %in% names(x)) {
    x$data
  } else {
    x
  }
}

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

make_query <- function(x) {
  paste0(pop(x), collapse = " | ")
}
