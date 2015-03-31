skip_if_no_rivr <- function() {
  if ("rivr" %in% .packages(TRUE)) {
    return()
  }
  skip("rivr is not available")
}
