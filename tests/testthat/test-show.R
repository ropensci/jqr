context("show")

test_that("show works as expected", {
  a <- '[1,2,5,3,5,3,1,3]' %>% unique %>% show
  expect_is(a, "jq_query")
  expect_equal(a[[1]], "unique")

  b <- str %>% unique(foo) %>% show
  expect_is(b, 'jq_query')
  expect_equal(b[[1]], 'unique_by(.foo)')

  d <- '[0, false, [], {}, null, "hello"]' %>% index() %>% type(booleans) %>% show
  expect_is(d, 'jq_query')
  expect_equal(d[[1]], '.[] | booleans')

  e <- '[5,4,2,7]' %>% index() %>% do(. < 4) %>% show
  expect_is(e, 'jq_query')
  expect_equal(e[[1]], ".[] | . < 4")

  f <- '[[1,2], "string", {"a":2}, null]' %>% index %>% length %>% show
  expect_is(f, 'jq_query')
  expect_equal(f[[1]], ".[] | length")

  str3 <- '[[0,1], ["a","b","c"]]'
  g <- str3 %>% haskey(1,2) %>% show
  expect_is(g, 'jq_query')
  expect_equal(g[[1]], 'map(has(1,2))')

  str <- '{"foo": 12, "bar":[1,2,{"barp":12, "blip":13}]}'
  h <- str %>% contains(`{foo: 12, bar: [{barp: 12}]}`) %>% show
  expect_is(h, 'jq_query')
  expect_is(unclass(h), 'character')
  expect_equal(h[[1]], "contains({foo: 12, bar: [{barp: 12}]})")
})


test_that("show fails well", {
  expect_error(show(), "\".data\" is missing")
  expect_error(5 %>% show, "must be of class jqr")
})
