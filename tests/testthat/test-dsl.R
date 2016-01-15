context("jqr dsl")

ac <- as.character

x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'

test_that("index", {
  expect_is(index(x), "jqr")
  expect_named(index(x), c("data", "args"))
  expect_is(index(x) %>% jq, "jqson")
  expect_is(jq(index(x)), "jqson")
  expect_equal(ac(x %>% index() %>% jq)[1], '{"message":"hello","name":"jenn"}')
})

test_that("dot", {
  expect_is(dot(x), "jqr")
  expect_named(dot(x), c("data", "args"))
  expect_equal(ac(x %>% dot() %>% jq), '[{"message":"hello","name":"jenn"},{"message":"world","name":"beth"}]')
})

test_that("keys", {
  # get keys
  str1 <- '{"foo": 5, "bar": 7}'
  expect_is(keys(str1), "jqr")
  expect_named(keys(str1), c("data", "args"))
  expect_equal(ac(str1 %>% keys() %>% jq), '[\"bar\",\"foo\"]')

  # delete by key name
  expect_is(del(str1, bar), "jqr")
  expect_named(del(str1, bar), c("data", "args"))
  expect_equal(ac(str1 %>% del(bar) %>% jq), '{\"foo\":5}')

  # check for key existence
  str2 <- '[[0,1], ["a","b","c"]]'
  #str2 %>% haskey(1,2) %>% jq
  expect_is(haskey(str2, 2), "jqr")
  expect_named(haskey(str2, 2), c("data", "args"))
  expect_equal(ac(str2 %>% haskey(2) %>% jq), '[false,true]')
})

test_that("join", {
  str <- '["a","b,c,d","e"]'

  expect_is(str %>% join %>% jq, "jqson")
  expect_equal(ac(str %>% join %>% jq), '\"a, b,c,d, e\"')
  expect_named(join(str), c("data", "args"))
  expect_equal(ac(str %>% join(`;`) %>% jq), '\"a; b,c,d; e\"')
  expect_equal(ac(str %>% join(`yep`) %>% jq), '\"ayep b,c,dyep e\"')
})


test_that("split", {
  str <- "a, b,c,d, e"
  ### TODO - split is failing right now, perhaps a memory leak?
})

test_that("ltrimstr", {
  str <- '["fo", "foo", "barfoo", "foobar", "afoo"]'
  expect_is(str %>% index() %>% ltrimstr(foo) %>% jq, "jqson")
  expect_equal(ac(str %>% index() %>% ltrimstr(foo) %>% jq), c('\"fo\"', '\"\"', '\"barfoo\"', '\"bar\"', '\"afoo\"'))
  expect_named(ltrimstr(str %>% index(), foo), c("data", "args"))
})

test_that("rtrimstr", {
  str <- '["fo", "foo", "barfoo", "foobar", "foob"]'
  expect_is(str %>% index() %>% rtrimstr(foo) %>% jq, "jqson")
  expect_equal(ac(str %>% index() %>% rtrimstr(foo) %>% jq), c('\"fo\"', '\"\"', '\"bar\"', '\"foobar\"', '\"foob\"'))
  expect_named(rtrimstr(str %>% index(), foo), c("data", "args"))
})

test_that("startswith", {
  str <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
  expect_is(str %>% index %>% startswith(foo) %>% jq, "jqson")
  expect_equal(ac(str %>% index %>% startswith(foo) %>% jq), c("false","true","false","true","false"))
})

test_that("endswith", {
  str <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
  expect_is(str %>% index %>% endswith(foo) %>% jq, "jqson")
  expect_equal(ac(str %>% index %>% endswith(foo) %>% jq), c("false","true","true","false","false"))
  expect_equal(ac(str %>% index %>% endswith(bar) %>% jq), c("false","false","false","true","false"))
})

test_that("tojson, fromjson, tostring, tonumber", {
  str <- '[1, "foo", ["foo"]]'

  expect_is(str %>% index %>% tostring %>% jq, "jqson")
  expect_equal(ac(str %>% index %>% tostring %>% jq)[1], '\"1\"')

  expect_is('[1, "1"]' %>% index %>% tonumber %>% jq, "jqson")
  expect_equal(ac('[1, "1"]' %>% index %>% tonumber %>% jq)[1], '1')

  expect_is(str %>% index %>% tojson %>% jq, "jqson")
  expect_equal(ac(str %>% index %>% tojson %>% jq)[2], '\"\\\"foo\\\"\"')

  expect_is(str %>% index %>% tojson %>% fromjson %>% jq, "jqson")
  expect_equal(ac(str %>% index %>% tojson %>% fromjson %>% jq)[3], '[\"foo\"]')
})

test_that("contains", {
  str1 <- '["foobar", "foobaz", "blarp"]'
  str2 <- '{"foo": 12, "bar":[1,2,{"barp":12, "blip":13}]}'

  expect_is('"foobar"' %>% contains("bar") %>% jq, "jqson")

  expect_equal(ac(str1 %>% contains(`["baz", "bar"]`) %>% jq), "true")
  expect_equal(ac(str1 %>% contains(`["bazzzzz", "bar"]`) %>% jq), "false")

  expect_equal(ac(str2 %>% contains(`{foo: 12, bar: [{barp: 12}]}`) %>% jq), "true")
  expect_equal(ac(str2 %>% contains(`{foo: 12, bar: [{barp: 15}]}`) %>% jq), "false")
})

test_that("unique", {
  str <- '[{"foo": 1, "bar": 2}, {"foo": 1, "bar": 3}, {"foo": 4, "bar": 5}]'
  str2 <- '["chunky", "bacon", "kitten", "cicada", "asparagus"]'

  expect_is('[1,2,5,3,5,3,1,3]' %>% uniquej %>% jq, "jqson")
  expect_equal(ac('[1,2,5,3,5,3,1,3]' %>% uniquej %>% jq), '[1,2,3,5]')

  expect_is(str %>% uniquej(foo) %>% jq, 'jqson')
  expect_is(ac(str %>% uniquej(foo) %>% jq), 'character')
  expect_equal(ac(str %>% uniquej(foo) %>% jq), '[{\"foo\":1,\"bar\":2},{\"foo\":4,\"bar\":5}]')

  expect_is(str2 %>% uniquej(length) %>% jq, 'jqson')
  expect_equal(ac(str2 %>% uniquej(length) %>% jq), '[\"bacon\",\"chunky\",\"asparagus\"]')
})

test_that("maths", {
  # do math
  expect_equal(jqr('{"a": 7}', '.a + 1', 0), "8")
  expect_equal(jqr('{"a": 7}', '.a += 1', 0), '{\"a\":8}')
  expect_is('{"a": 7}' %>%  do(.a + 1), "jqson")
  expect_is('{"a": 7}' %>%  do(.a + 1) %>% jq, "jqson")
  expect_equal(ac('{"a": 7}' %>%  do(.a + 1) %>% jq), "8")

  # add two elements together
  expect_equal(ac('{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b) %>% jq), "[1,2,3,4]")
  expect_equal(ac('{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b) %>% jq), "[1,2]")

  # comparisons
  expect_equal(ac('[5,4,2,7]' %>% index() %>% do(. < 4) %>% jq), c("false","false","true","false"))

  # length
  expect_equal(ac('[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj %>% jq), c("2","6","1","0"))

  # sqrt
  expect_equal(ac('9' %>% sqrtj %>% jq), "3")

  # floor
  expect_equal(ac('3.14159' %>% floorj %>% jq), "3")

  # find minimum
  expect_equal(ac('[5,4,2,7]' %>% minj %>% jq), "2")

  # find maximum
  expect_equal(ac('[5,4,2,7]' %>% maxj %>% jq), "7")

  # increment values
  expect_equal(ac('{"foo": 1}' %>% do(.foo %+=% 1) %>% jq), '{\"foo\":2}')
})

test_that("select variables", {
  expect_equal(ac('{"foo": 5, "bar": 7}' %>% select(a = .foo) %>% jq), '{"a":5}')

  # using json dataset, just first element
  x <- githubcommits %>% index(0)
  expect_equal(ac(x %>% select(message = .commit.message, name = .commit.committer.name) %>% jq),
               '{\"message\":[\"Add wrapping and clamping to jv_array_slice\\n\\nFix #716.  Fix #717.\"],\"name\":[\"Nicolas Williams\"]}')
  expect_equal(ac(x %>% select(sha = .commit.tree.sha, author = .author.login) %>% jq),
               '{\"sha\":[\"a52a4b412c3ba4bd2e237f37a5f11fd565e74bae\"],\"author\":[\"tgockel\"]}')

  # using json dataset, all elements
  x <- index(githubcommits)
  zz <- x %>%
     select(message = .commit.message, name = .commit.committer.name)
  expect_is(zz, "jqson")
  expect_equal(base::length(zz), 5)
})

test_that("paths", {
  str1 <- '[1,[[],{"a":2}]]'
  str2 <- '[{"name":"JqSON", "good":true}, {"name":"XML", "good":false}]'

  expect_is(str1 %>% paths %>% jq, 'jqson')
  expect_equal(ac(str1 %>% paths %>% jq), c("[0]", "[1]", "[1,0]", "[1,1]", "[1,1,\"a\"]"))
  expect_is(str1 %>% paths, 'jqson')

  expect_is(str2 %>% paths %>% jq, 'jqson')
  expect_is(str2 %>% paths, 'jqson')
  expect_equal(ac(str2 %>% paths %>% jq), c("[0]", "[0,\"name\"]", "[0,\"good\"]", "[1]", "[1,\"name\"]", "[1,\"good\"]"))
  expect_is(str2 %>% paths, 'jqson')
})

test_that("recurse", {
  x <- '{"foo":[{"foo": []}, {"foo":[{"foo":[]}]}]}'

  expect_is(x %>% recurse(.foo[]) %>% jq, 'jqson')
  expect_equal(ac(x %>% recurse(.foo[]) %>% jq),
               c("{\"foo\":[{\"foo\":[]},{\"foo\":[{\"foo\":[]}]}]}",
                 "{\"foo\":[]}", "{\"foo\":[{\"foo\":[]}]}", "{\"foo\":[]}"))
  expect_is(x %>% recurse(.foo[]), 'jqson')
  expect_is(x %>% recurse(.foo[]) %>% jq, 'jqson')

  expect_is(recurse('{"a":0, "b":[1]}'), "jqr")
  expect_is('{"a":0, "b":[1]}' %>% recurse, "jqson")
  expect_equal(recurse('{"a":0, "b":[1]}') %>% string, '{"a":0, "b":[1]}')

  expect_equal(x %>% recurse(.foo[]), x %>% recurse_(".foo[]"))
})
