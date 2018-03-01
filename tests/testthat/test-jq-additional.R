context("jq/jqr additional")

jqr_conv <- function(json, program, ...) {
  jsonlite::fromJSON(jqr(json, program, 0), ...)
}

test_that("can read form a character string", {
  expect_equal(jqr_conv('{"a": 7, "b": 4}', 'keys'), c('a', 'b'))
})

test_that("can read form a file", {
  cat('{"a": 7, "b": 4}\n', file = (f=tempfile(fileext = ".json")))
  expect_equal(jqr_conv(f, 'keys'), c('a', 'b'))
})

test_that("can read form a url", {
  x <- 'https://api.github.com/'
  expect_true(
    all(c("authorizations_url", 'code_search_url', 'commit_search_url') %in%
        jqr_conv(x, 'keys'))
  )
})
