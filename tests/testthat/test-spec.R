## This is the test suite from Ruby, ported over.
context("Ruby test suite")

## NOTE: No conversion in/out of a JSON string here, in contrast with
## the Ruby version.  We'll do that explicitly somewhere else - for
## now the jqr function does the string -> string conversions only.
##
## Doing the conversions for things that return lists requires more
## care; we'll need to loop over the returned list.

jqr_conv <- function(json, program, ...) {
  jsonlite::fromJSON(jqr(json, program, 0), ...)
}

test_that("int", {
  expect_that(jqr('1', '.', 0),      equals("1"))
  expect_that(jqr_conv('1', '.'), equals(1L))
})

test_that("float", {
  expect_that(jqr('1.2', '.', 0),      equals("1.2"))
  expect_that(jqr_conv('1.2', '.'), equals(1.2))
})

test_that("string", {
  expect_that(jqr('"Zzz"', '.', 0),      equals('"Zzz"'))
  expect_that(jqr_conv('"Zzz"', '.'), equals("Zzz"))
})

test_that("array", {
  expect_that(jqr('[1, "2", 3]', '.', 0),      equals('[1,"2",3]'))
  expect_that(jqr_conv('[1, "2", 3]', '.'), equals(c("1", "2", "3")))
  ## To get the same behaviour as Ruby:
  expect_that(jqr_conv('[1, "2", 3]', '.', simplifyVector=FALSE),
              equals(list(1L, "2", 3L)))
})

test_that("hash", {
  str <- '{"foo":100, "bar":"zoo"}'
  expect_that(jqr(str, '.', 0), equals('{"foo":100,"bar":"zoo"}'))
  expect_that(jqr_conv(str, '.'), equals(list(foo=100L, bar="zoo")))
})

test_that("composition", {
  src <- '{
    "glossary": {
        "title": "example glossary",
    "GlossDiv": {
            "title": "S",
      "GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
          "SortAs": "SGML",
          "GlossTerm": "Standard Generalized Markup Language",
          "Acronym": "SGML",
          "Abbrev": "ISO 8879:1986",
          "GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
            "GlossSeeAlso": ["GML", "XML"]
                    },
          "GlossSee": "markup"
                }
            }
        }
    }
}'

  expect_that(jqr(src, ".", 0), equals(unclass(jsonlite::minify(src))))
  expect_that(jqr_conv(src, "."),
              equals(jsonlite::fromJSON(src)))
})

test_that("each value", {
  src <- '{"menu": {
  "id": "file",
  "value": "File",
  "popup": {
    "menuitem": [
      {"value": "New", "onclick": "CreateNewDoc()"},
      {"value": "Open", "onclick": "OpenDoc()"},
      {"value": "Close", "onclick": "CloseDoc()"}
    ]
  }
}}
'

  expect_that(jqr(src, '.menu.popup.menuitem[].value', 0),
              equals(c('"New"', '"Open"', '"Close"')))
})

test_that("compile error", {
  skip_on_os("solaris")
  expect_error(jqr("{}", "...", 0))
})

test_that("runtime error", {
  ## Hmm - this is meant to crash on Ruby but does not here (and does
  ## not on the command line either).
  skip_on_os("solaris")
  expect_that(jqr('{}', '.', 0), equals("{}"))
  ## expect {
  ##   jqr('{}', '.') do |value|
  ##     raise 'runtime error'
  ##   end
  ## }.to raise_error(RuntimeError)
})

test_that("query for hash", {
  src <- list(FOO=100L, BAR=c(200L, 200L))
  expect_that(jqr(jsonlite::toJSON(src), ".BAR[]", 0),
              equals(c("200", "200")))
})

test_that("query for array", {
  src <- list('FOO', 100L, 'BAR', c(200L, 200L))

  expect_that(jqr(jsonlite::toJSON(src), ".[3][]", 0),
              equals(c("200", "200")))
})
