##' @useDynLib jqr
##' @importFrom Rcpp evalCpp
NULL

cpt <- function (l) Filter(Negate(is.null), l)
