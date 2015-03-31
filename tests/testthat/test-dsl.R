context("jqr dsl")

ac <- as.character

x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'

test_that("index", {
  expect_is(x %>% index(), "jqr")
  expect_named(x %>% index(), c("data", "args"))
  expect_is(x %>% index() %>% jq, "json")
  expect_equal(ac(x %>% index() %>% jq)[1], '{"message":"hello","name":"jenn"}')
})

test_that("dot", {
  expect_is(x %>% dot(), "jqr")
  expect_named(x %>% dot(), c("data", "args"))
  expect_equal(ac(x %>% dot() %>% jq), '[{"message":"hello","name":"jenn"},{"message":"world","name":"beth"}]')
})

test_that("keys", {
  # get keys
  str1 <- '{"foo": 5, "bar": 7}'
  expect_is(str1 %>% keys(), "jqr")
  expect_named(str1 %>% keys(), c("data", "args"))
  expect_equal(ac(str1 %>% keys() %>% jq), '[\"bar\",\"foo\"]')

  # delete by key name
  expect_is(str1 %>% del(bar), "jqr")
  expect_named(str1 %>% del(bar), c("data", "args"))
  expect_equal(ac(str1 %>% del(bar) %>% jq), '{\"foo\":5}')

  # check for key existence
  str2 <- '[[0,1], ["a","b","c"]]'
  str2 %>% haskey(1,2) %>% jq
  expect_is(str2 %>% haskey(2), "jqr")
  expect_named(str2 %>% haskey(2), c("data", "args"))
  expect_equal(ac(str2 %>% haskey(2) %>% jq), '[false,true]')
})

test_that("join", {
  str <- '["a","b,c,d","e"]'

  expect_is(str %>% join %>% jq, "json")
  expect_equal(ac(str %>% join %>% jq), '\"a, b,c,d, e\"')
  expect_named(str %>% join, c("data", "args"))
  expect_equal(ac(str %>% join(`;`) %>% jq), '\"a; b,c,d; e\"')
  expect_equal(ac(str %>% join(`yep`) %>% jq), '\"ayep b,c,dyep e\"')
})


test_that("split", {
  str <- "a, b,c,d, e"
  ### TODO - split is failing right now, perhaps a memory leak?
})

test_that("ltrimstr", {
  str <- '["fo", "foo", "barfoo", "foobar", "afoo"]'
  expect_is(str %>% index() %>% ltrimstr(foo) %>% jq, "json")
  expect_equal(ac(str %>% index() %>% ltrimstr(foo) %>% jq), c('\"fo\"', '\"\"', '\"barfoo\"', '\"bar\"', '\"afoo\"'))
  expect_named(str %>% index() %>% ltrimstr(foo), c("data", "args"))
})

test_that("rtrimstr", {
  str <- '["fo", "foo", "barfoo", "foobar", "foob"]'
  expect_is(str %>% index() %>% rtrimstr(foo) %>% jq, "json")
  expect_equal(ac(str %>% index() %>% rtrimstr(foo) %>% jq), c('\"fo\"', '\"\"', '\"bar\"', '\"foobar\"', '\"foob\"'))
  expect_named(str %>% index() %>% rtrimstr(foo), c("data", "args"))
})

test_that("startswith", {
  str <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
  expect_is(str %>% index %>% startswith(foo) %>% jq, "json")
  expect_equal(ac(str %>% index %>% startswith(foo) %>% jq), c("false","true","false","true","false"))
})

test_that("endswith", {
  str <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
  expect_is(str %>% index %>% endswith(foo) %>% jq, "json")
  expect_equal(ac(str %>% index %>% endswith(foo) %>% jq), c("false","true","true","false","false"))
  expect_equal(ac(str %>% index %>% endswith(bar) %>% jq), c("false","false","false","true","false"))
})

test_that("tojson, fromjson, tostring", {
  str <- '[1, "foo", ["foo"]]'

  expect_is(str %>% index %>% tostring %>% jq, "json")
  expect_equal(ac(str %>% index %>% tostring %>% jq)[1], '\"1\"')

  expect_is(str %>% index %>% tojson %>% jq, "json")
  expect_equal(ac(str %>% index %>% tojson %>% jq)[2], '\"\\\"foo\\\"\"')

  expect_is(str %>% index %>% tojson %>% fromjson %>% jq, "json")
  expect_equal(ac(str %>% index %>% tojson %>% fromjson %>% jq)[3], '[\"foo\"]')
})

test_that("contains", {
  str1 <- '["foobar", "foobaz", "blarp"]'
  str2 <- '{"foo": 12, "bar":[1,2,{"barp":12, "blip":13}]}'

  expect_is('"foobar"' %>% contains("bar") %>% jq, "json")

  expect_equal(ac(str1 %>% contains(`["baz", "bar"]`) %>% jq), "true")
  expect_equal(ac(str1 %>% contains(`["bazzzzz", "bar"]`) %>% jq), "false")

  expect_equal(ac(str2 %>% contains(`{foo: 12, bar: [{barp: 12}]}`) %>% jq), "true")
  expect_equal(ac(str2 %>% contains(`{foo: 12, bar: [{barp: 15}]}`) %>% jq), "false")
})

test_that("unique", {
  str <- '[{"foo": 1, "bar": 2}, {"foo": 1, "bar": 3}, {"foo": 4, "bar": 5}]'
  str2 <- '["chunky", "bacon", "kitten", "cicada", "asparagus"]'

  expect_is('[1,2,5,3,5,3,1,3]' %>% unique %>% jq, "json")
  expect_equal(ac('[1,2,5,3,5,3,1,3]' %>% unique %>% jq), '[1,2,3,5]')

  expect_is(str %>% unique(foo) %>% jq, 'json')
  expect_is(ac(str %>% unique(foo) %>% jq), 'character')
  expect_equal(ac(str %>% unique(foo) %>% jq), '[{\"foo\":1,\"bar\":2},{\"foo\":4,\"bar\":5}]')

  expect_is(str2 %>% unique(length) %>% jq, 'json')
  expect_equal(ac(str2 %>% unique(length) %>% jq), '[\"bacon\",\"chunky\",\"asparagus\"]')
})
