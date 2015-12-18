# context("rivr")

# test_that("Streaming", {
#   skip_if_no_rivr()

#   ## TODO: need rivr-style json streams or something here?
#   writeLines(jsonlite::toJSON(iris, collapse=FALSE),
#              tmp <- tempfile())

#   ## Start by building a file iterator:
#   it_f <- rivr::file_iterator(tmp)
#   it_j <- jq_iterator(it_f, '{len: ."Petal.Length"}')
#   x <- it_j$yield()
#   y <- sprintf('{"len":%s}', iris$Petal.Length[[1]])
#   expect_that(x, equals(y))

#   ## Then drain everything else:
#   dat <- rivr:::drain(it_j)

#   expect_that(unlist(dat),
#               equals(sprintf('{"len":%s}', iris$Petal.Length[-1])))
# })
