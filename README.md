jqr
=======



[![Build Status](https://travis-ci.org/ropensci/jqr.png?branch=master)](https://travis-ci.org/ropensci/jqr)
[![Coverage Status](https://coveralls.io/repos/ropensci/jqr/badge.svg?branch=master)](https://coveralls.io/r/ropensci/jqr?branch=master)

R interface to jq, a JSON processor  http://stedolan.github.io/jq/

## Install

Get dependencies not on CRAN


```r
devtools::install_github("vsbuffalo/rivr")
```

To install `jqr`, after cloning the repo the first time, run (from the command line)

```
./bootstrap.R
```

which will download the 1.4 release of [jq](http://stedolan.github.io/jq/).  This does not need to be run on subsequent runs, and will stop being required once [this issue](https://github.com/ropensci/jqr/issues/1) is resolved.


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
jq_(str, ".[]")
#> [1] "{\"foo\":1,\"bar\":2}" "{\"foo\":3,\"bar\":4}" "{\"foo\":5,\"bar\":6}"
```


```r
jq_(str, "[.[] | {name: .foo} | keys]")
#> [1] "[[\"name\"],[\"name\"],[\"name\"]]"
```

### high level

The other is higher level, and uses a suite of functions to construct queries. Queries are constucted, then excuted with the function `jq()`.

Examples:

Index


```r
x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'
x %>% index() %>% jq
#> {"message":"hello","name":"jenn"} {"message":"world","name":"beth"}
```

Sort


```r
'[8,3,null,6]' %>% sortj %>% jq
#> [null,3,6,8]
```

reverse order


```r
'[1,2,3,4]' %>%  reverse %>% jq
#> [4,3,2,1]
```

Show the query to be used using `peek()`


```r
'[1,2,3,4]' %>%  reverse %>% peek
#> <jq query>
#>   query:  reverse
```

#### string operations

join


```r
'["a","b,c,d","e"]' %>% join %>% jq
#> "a, b,c,d, e"
'["a","b,c,d","e"]' %>% join(`;`) %>% jq
#> "a; b,c,d; e"
```

ltrimstr


```r
'["fo", "foo", "barfoo", "foobar", "afoo"]' %>% index() %>% ltrimstr(foo) %>% jq
#> "fo" "" "barfoo" "bar" "afoo"
```

rtrimstr


```r
'["fo", "foo", "barfoo", "foobar", "foob"]' %>% index() %>% rtrimstr(foo) %>% jq
#> "fo" "" "bar" "foobar" "foob"
```

startswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% startswith(foo) %>% jq
#> false true false true false
```

endswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% endswith(foo) %>% jq
#> false true true false false
```

tojson, fromjson, tostring


```r
'[1, "foo", ["foo"]]' %>% index %>% tostring %>% jq
#> "1" "foo" "[\"foo\"]"
'[1, "foo", ["foo"]]' %>% index %>% tojson %>% jq
#> "1" "\"foo\"" "[\"foo\"]"
'[1, "foo", ["foo"]]' %>% index %>% tojson %>% fromjson %>% jq
#> 1 "foo" ["foo"]
```

contains


```r
'"foobar"' %>% contains("bar") %>% jq
#> true
```

unique


```r
'[1,2,5,3,5,3,1,3]' %>% uniquej %>% jq
#> [1,2,3,5]
```

#### types

get type information for each element


```r
'[0, false, [], {}, null, "hello"]' %>% types %>% jq
#> ["number","boolean","array","object","null","string"]
'[0, false, [], {}, null, "hello", true, [1,2,3]]' %>% types %>% jq
#> ["number","boolean","array","object","null","string","boolean","array"]
```

select elements by type


```r
'[0, false, [], {}, null, "hello"]' %>% index() %>% type(booleans) %>% jq
#> false
```

#### key operations

get keys


```r
str <- '{"foo": 5, "bar": 7}'
str %>% keys() %>% jq
#> ["bar","foo"]
```

delete by key name


```r
str %>% del(bar) %>% jq
#> {"foo":5}
```

check for key existence


```r
str3 <- '[[0,1], ["a","b","c"]]'
str3 %>% haskey(2) %>% jq
#> [false,true]
str3 %>% haskey(1,2) %>% jq
#> [true,false,true,true]
```

Select variables by name, and rename


```r
'{"foo": 5, "bar": 7}' %>% select(a = .foo) %>% jq
#> {"a":5}
```

More complicated `select()`, using the included dataset `githubcommits`


```r
githubcommits %>%
  index() %>% 
  select(sha = .sha, name = .commit.committer.name) %>% 
  jq(TRUE)
#> {"sha":["110e009996e1359d25b8e99e71f83b96e5870790"],"name":["Nicolas Williams"]}
#> {"sha":["7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"],"name":["Nicolas Williams"]}
#> {"sha":["a50e548cc5313c187483bc8fb1b95e1798e8ef65"],"name":["Nicolas Williams"]}
#> {"sha":["4b258f7d31b34ff5d45fba431169e7fd4c995283"],"name":["Nicolas Williams"]}
#> {"sha":["d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"],"name":["Nicolas Williams"]}
```

#### Maths


```r
'{"a": 7}' %>%  do(.a + 1) %>% jq
#> 8
'{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b) %>% jq
#> [1,2,3,4]
'{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b) %>% jq
#> [1,2]
'{"a": 3}' %>%  do(4 - .a) %>% jq
#> 1
'["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]') %>% jq
#> ". - [\"xml\", \"yaml\"]"
'5' %>%  do(10 / . * 3) %>% jq
#> 6
```

comparisons


```r
'[5,4,2,7]' %>% index() %>% do(. < 4) %>% jq
#> false false true false
'[5,4,2,7]' %>% index() %>% do(. > 4) %>% jq
#> true false false true
'[5,4,2,7]' %>% index() %>% do(. <= 4) %>% jq
#> false true true false
'[5,4,2,7]' %>% index() %>% do(. >= 4) %>% jq
#> true true false true
'[5,4,2,7]' %>% index() %>% do(. == 4) %>% jq
#> false true false false
'[5,4,2,7]' %>% index() %>% do(. != 4) %>% jq
#> true false true true
```

length


```r
'[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj %>% jq
#> 2 6 1 0
```

sqrt


```r
'9' %>% sqrtj %>% jq
#> 3
```

floor


```r
'3.14159' %>% floorj %>% jq
#> 3
```

find minimum


```r
'[5,4,2,7]' %>% minj %>% jq
#> 2
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj %>% jq
#> {"foo":2,"bar":3}
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(foo) %>% jq
#> {"foo":1,"bar":14}
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(bar) %>% jq
#> {"foo":2,"bar":3}
```

find maximum


```r
'[5,4,2,7]' %>% maxj %>% jq
#> 7
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj %>% jq
#> {"foo":1,"bar":14}
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(foo) %>% jq
#> {"foo":2,"bar":3}
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(bar) %>% jq
#> {"foo":1,"bar":14}
```

#### Combine into valid JSON

`jq` sometimes creates pieces of JSON that are valid in themselves, but together are not. 
`combine()` is a way to make valid JSON.

This outputs a few pieces of JSON


```r
(x <- githubcommits %>% 
  index() %>%
  select(sha = .sha, name = .commit.committer.name) %>% 
  jq(TRUE))
#> {"sha":["110e009996e1359d25b8e99e71f83b96e5870790"],"name":["Nicolas Williams"]}
#> {"sha":["7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"],"name":["Nicolas Williams"]}
#> {"sha":["a50e548cc5313c187483bc8fb1b95e1798e8ef65"],"name":["Nicolas Williams"]}
#> {"sha":["4b258f7d31b34ff5d45fba431169e7fd4c995283"],"name":["Nicolas Williams"]}
#> {"sha":["d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"],"name":["Nicolas Williams"]}
```

Use `combine()` to put them together.


```r
combine(x)
#> [{"sha":["110e009996e1359d25b8e99e71f83b96e5870790"],"name":["Nicolas Williams"]}, {"sha":["7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f"],"name":["Nicolas Williams"]}, {"sha":["a50e548cc5313c187483bc8fb1b95e1798e8ef65"],"name":["Nicolas Williams"]}, {"sha":["4b258f7d31b34ff5d45fba431169e7fd4c995283"],"name":["Nicolas Williams"]}, {"sha":["d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5"],"name":["Nicolas Williams"]}]
```

#### Streaming

Write `mtcars` to a temporary file


```r
writeLines(jsonlite::toJSON(mtcars, collapse = FALSE),
             tmp <- tempfile())
```

Build a file iterator


```r
it_f <- rivr::file_iterator(tmp)
it_j <- jq_iterator(it_f, '{cyl: ."cyl"}')
replicate(NROW(mtcars), it_j$yield())
#>  [1] "{\"cyl\":6}" "{\"cyl\":6}" "{\"cyl\":4}" "{\"cyl\":6}" "{\"cyl\":8}"
#>  [6] "{\"cyl\":6}" "{\"cyl\":8}" "{\"cyl\":4}" "{\"cyl\":4}" "{\"cyl\":6}"
#> [11] "{\"cyl\":6}" "{\"cyl\":8}" "{\"cyl\":8}" "{\"cyl\":8}" "{\"cyl\":8}"
#> [16] "{\"cyl\":8}" "{\"cyl\":8}" "{\"cyl\":4}" "{\"cyl\":4}" "{\"cyl\":4}"
#> [21] "{\"cyl\":4}" "{\"cyl\":8}" "{\"cyl\":8}" "{\"cyl\":8}" "{\"cyl\":8}"
#> [26] "{\"cyl\":4}" "{\"cyl\":4}" "{\"cyl\":4}" "{\"cyl\":8}" "{\"cyl\":6}"
#> [31] "{\"cyl\":8}" "{\"cyl\":4}"
```

> the streaming bit is a [work in progress](https://github.com/ropensci/jqr/issues/8)

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/jqr/issues).
* License: MIT
* Get citation information for `jqr` in R doing `citation(package = 'jqr')`

[![rofooter](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)
