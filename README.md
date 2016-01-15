jqr
=======



[![Build Status](https://travis-ci.org/ropensci/jqr.png?branch=master)](https://travis-ci.org/ropensci/jqr)
[![Coverage Status](https://coveralls.io/repos/ropensci/jqr/badge.svg?branch=master)](https://coveralls.io/r/ropensci/jqr?branch=master)

R interface to jq, a JSON processor http://stedolan.github.io/jq/

`jqr` is currenlty using `jq v1.4` - [v1.4 manual](https://stedolan.github.io/jq/manual/v1.4/)

`jqr` makes it easy to process large amounts of json without having to
convert from json to R, or without using regular expressions.  This
means that the eventual loading into R can be quicker.

[Introduction](vignettes/jqr_vignette.md)

## Install


Install `jqr` via devtools:


```r
devtools::install_github("ropensci/jqr")
```


```r
library("jqr")
```

## Interfaces

### low level

There's a low level interface in which you can execute `jq` code just as you would on the command line:


```r
str <- '[{
    "foo": 1,
    "bar": 2
  },
  {
    "foo": 3,
    "bar": 4
  },
  {
    "foo": 5,
    "bar": 6
}]'
```


```r
jq(str, ".[]")
#> [
#>     {
#>         "foo": 1,
#>         "bar": 2
#>     },
#>     {
#>         "foo": 3,
#>         "bar": 4
#>     },
#>     {
#>         "foo": 5,
#>         "bar": 6
#>     }
#> ]
```


```r
jq(str, "[.[] | {name: .foo} | keys]")
#> [
#>     [
#>         "name"
#>     ],
#>     [
#>         "name"
#>     ],
#>     [
#>         "name"
#>     ]
#> ]
```

### high level

The other is higher level, and uses a suite of functions to construct queries. Queries are constucted, then excuted internally with `jq()` after the last piped command.

You don't have to use pipes though. See examples below.

Examples:

Index


```r
x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'
x %>% index()
#> [
#>     {
#>         "message": "hello",
#>         "name": "jenn"
#>     },
#>     {
#>         "message": "world",
#>         "name": "beth"
#>     }
#> ]
```

Sort


```r
'[8,3,null,6]' %>% sortj
#> [
#>     null,
#>     3,
#>     6,
#>     8
#> ]
```

reverse order


```r
'[1,2,3,4]' %>% reverse
#> [
#>     4,
#>     3,
#>     2,
#>     1
#> ]
```

Show the query to be used using `peek()`

FIXME - broken right now


```r
'[1,2,3,4]' %>% reverse %>% peek
```

#### get multiple outputs for array w/ > 1 element


```r
x <- '{"user":"stedolan","titles":["JQ Primer", "More JQ"]}'
jq(x, '{user, title: .titles[]}')
x %>% index()
x %>% select(user, title = `.titles[]`)
x %>% select(user, title = `.titles[]`) %>% combine
x %>% select(user, title = `.titles[]`) %>% combine %>% jsonlite::validate()
```

#### string operations

join


```r
'["a","b,c,d","e"]' %>% join
#> "a, b,c,d, e"
'["a","b,c,d","e"]' %>% join(`;`)
#> "a; b,c,d; e"
```

ltrimstr


```r
'["fo", "foo", "barfoo", "foobar", "afoo"]' %>% index() %>% ltrimstr(foo)
#> [
#>     "fo",
#>     "",
#>     "barfoo",
#>     "bar",
#>     "afoo"
#> ]
```

rtrimstr


```r
'["fo", "foo", "barfoo", "foobar", "foob"]' %>% index() %>% rtrimstr(foo)
#> [
#>     "fo",
#>     "",
#>     "bar",
#>     "foobar",
#>     "foob"
#> ]
```

startswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% startswith(foo)
#> [
#>     false,
#>     true,
#>     false,
#>     true,
#>     false
#> ]
```

endswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% endswith(foo)
#> [
#>     false,
#>     true,
#>     true,
#>     false,
#>     false
#> ]
```

tojson, fromjson, tostring


```r
'[1, "foo", ["foo"]]' %>% index
#> [
#>     1,
#>     "foo",
#>     [
#>         "foo"
#>     ]
#> ]
'[1, "foo", ["foo"]]' %>% index %>% tostring
#> [
#>     "1",
#>     "foo",
#>     "[\"foo\"]"
#> ]
'[1, "foo", ["foo"]]' %>% index %>% tojson
#> [
#>     "1",
#>     "\"foo\"",
#>     "[\"foo\"]"
#> ]
'[1, "foo", ["foo"]]' %>% index %>% tojson %>% fromjson
#> [
#>     1,
#>     "foo",
#>     [
#>         "foo"
#>     ]
#> ]
```

contains


```r
'"foobar"' %>% contains("bar")
#> true
```

unique


```r
'[1,2,5,3,5,3,1,3]' %>% uniquej
#> [
#>     1,
#>     2,
#>     3,
#>     5
#> ]
```

#### types

get type information for each element


```r
'[0, false, [], {}, null, "hello"]' %>% types
#> [
#>     "number",
#>     "boolean",
#>     "array",
#>     "object",
#>     "null",
#>     "string"
#> ]
'[0, false, [], {}, null, "hello", true, [1,2,3]]' %>% types
#> [
#>     "number",
#>     "boolean",
#>     "array",
#>     "object",
#>     "null",
#>     "string",
#>     "boolean",
#>     "array"
#> ]
```

select elements by type


```r
'[0, false, [], {}, null, "hello"]' %>% index() %>% type(booleans)
#> false
```

#### key operations

get keys


```r
str <- '{"foo": 5, "bar": 7}'
str %>% keys()
#> [
#>     "bar",
#>     "foo"
#> ]
```

delete by key name


```r
str %>% del(bar)
#> {
#>     "foo": 5
#> }
```

check for key existence


```r
str3 <- '[[0,1], ["a","b","c"]]'
str3 %>% haskey(2)
#> [
#>     false,
#>     true
#> ]
str3 %>% haskey(1,2)
#> [
#>     true,
#>     false,
#>     true,
#>     true
#> ]
```

Select variables by name, and rename


```r
'{"foo": 5, "bar": 7}' %>% select(a = .foo)
#> {
#>     "a": 5
#> }
```

More complicated `select()`, using the included dataset `githubcommits`


```r
githubcommits %>%
  index() %>%
  select(sha = .sha, name = .commit.committer.name)
#> [
#>     {
#>         "sha": [
#>             "110e009996e1359d25b8e99e71f83b96e5870790"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "a50e548cc5313c187483bc8fb1b95e1798e8ef65"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "4b258f7d31b34ff5d45fba431169e7fd4c995283"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     }
#> ]
```

#### Maths


```r
'{"a": 7}' %>%  do(.a + 1)
#> 8
'{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b)
#> [
#>     1,
#>     2,
#>     3,
#>     4
#> ]
'{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b)
#> [
#>     1,
#>     2
#> ]
'{"a": 3}' %>%  do(4 - .a)
#> 1
'["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]')
#> ". - [\"xml\", \"yaml\"]"
'5' %>%  do(10 / . * 3)
#> 6
```

comparisons


```r
'[5,4,2,7]' %>% index() %>% do(. < 4)
#> [
#>     false,
#>     false,
#>     true,
#>     false
#> ]
'[5,4,2,7]' %>% index() %>% do(. > 4)
#> [
#>     true,
#>     false,
#>     false,
#>     true
#> ]
'[5,4,2,7]' %>% index() %>% do(. <= 4)
#> [
#>     false,
#>     true,
#>     true,
#>     false
#> ]
'[5,4,2,7]' %>% index() %>% do(. >= 4)
#> [
#>     true,
#>     true,
#>     false,
#>     true
#> ]
'[5,4,2,7]' %>% index() %>% do(. == 4)
#> [
#>     false,
#>     true,
#>     false,
#>     false
#> ]
'[5,4,2,7]' %>% index() %>% do(. != 4)
#> [
#>     true,
#>     false,
#>     true,
#>     true
#> ]
```

length


```r
'[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj
#> [
#>     2,
#>     6,
#>     1,
#>     0
#> ]
```

sqrt


```r
'9' %>% sqrtj
#> 3
```

floor


```r
'3.14159' %>% floorj
#> 3
```

find minimum


```r
'[5,4,2,7]' %>% minj
#> 2
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj
#> {
#>     "foo": 2,
#>     "bar": 3
#> }
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(foo)
#> {
#>     "foo": 1,
#>     "bar": 14
#> }
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(bar)
#> {
#>     "foo": 2,
#>     "bar": 3
#> }
```

find maximum


```r
'[5,4,2,7]' %>% maxj
#> 7
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj
#> {
#>     "foo": 1,
#>     "bar": 14
#> }
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(foo)
#> {
#>     "foo": 2,
#>     "bar": 3
#> }
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(bar)
#> {
#>     "foo": 1,
#>     "bar": 14
#> }
```

#### Combine into valid JSON

`jq` sometimes creates pieces of JSON that are valid in themselves, but together are not.
`combine()` is a way to make valid JSON.

This outputs a few pieces of JSON


```r
(x <- githubcommits %>%
  index() %>%
  select(sha = .sha, name = .commit.committer.name))
#> [
#>     {
#>         "sha": [
#>             "110e009996e1359d25b8e99e71f83b96e5870790"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "a50e548cc5313c187483bc8fb1b95e1798e8ef65"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "4b258f7d31b34ff5d45fba431169e7fd4c995283"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     }
#> ]
```

Use `combine()` to put them together.


```r
combine(x)
#> [
#>     {
#>         "sha": [
#>             "110e009996e1359d25b8e99e71f83b96e5870790"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "a50e548cc5313c187483bc8fb1b95e1798e8ef65"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "4b258f7d31b34ff5d45fba431169e7fd4c995283"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     },
#>     {
#>         "sha": [
#>             "d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"
#>         ],
#>         "name": [
#>             "Nicolas Williams"
#>         ]
#>     }
#> ]
```

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/jqr/issues).
* License: MIT
* Get citation information for `jqr` in R doing `citation(package = 'jqr')`

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
