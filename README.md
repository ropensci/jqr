jqr
=======




[![R-CMD-check](https://github.com/ropensci/jqr/workflows/R-CMD-check/badge.svg)](https://github.com/ropensci/jqr/actions?query=workflow%3AR-CMD-check)
[![codecov](http://app.codecov.io/gh/ropensci/jqr/branch/master/graph/badge.svg)](http://app.codecov.io/gh/ropensci/jqr)
[![cran checks](https://cranchecks.info/badges/worst/jqr)](https://cranchecks.info/pkgs/jqr)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/jqr?color=0DA6CD)](https://github.com/r-hub/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/jqr)](https://cran.r-project.org/package=jqr)

R interface to jq, a JSON processor http://jqlang.github.io/jq/

`jqr` makes it easy to process large amounts of json without having to
convert from json to R, or without using regular expressions.  This
means that the eventual loading into R can be quicker.

 - Introduction vignette at <https://cran.r-project.org/package=jqr>

## Quickstart Tutorial

The `jq` command line examples from the [jq tutorial](https://jqlang.github.io/jq/tutorial/) work exactly the same in R!


```r
library(curl)
library(jqr)
curl('https://api.github.com/repos/ropensci/jqr/commits?per_page=5') %>%
  jq('.[] | {message: .commit.message, name: .commit.committer.name}')
#> [
#>     {
#>         "message": "update cran comments and codemeta.json",
#>         "name": "Scott Chamberlain"
#>     },
#>     {
#>         "message": "change license to \"jqr authors\"",
#>         "name": "Scott Chamberlain"
#>     },
#>     {
#>         "message": "fix ci",
#>         "name": "Jeroen Ooms"
#>     },
#>     {
#>         "message": "Windows: update to libjq 1.6",
#>         "name": "Jeroen Ooms"
#>     },
#>     {
#>         "message": "Small tweak for autobrew",
#>         "name": "Jeroen Ooms"
#>     }
#> ]
```

Try running some of the [other examples](https://jqlang.github.io/jq/tutorial/).

## Installation

Binary packages for __OS-X__ or __Windows__ can be installed directly from CRAN:

```r
install.packages("jqr")
```

Installation from source on Linux or OSX requires [`libjq`](https://jqlang.github.io/jq/). On __Ubuntu 14.04 and 16.04 lower__ use [libjq-dev](https://launchpad.net/~cran/+archive/ubuntu/jq) from Launchpad:

```
sudo add-apt-repository -y ppa:cran/jq
sudo apt-get update -q
sudo apt-get install -y libjq-dev
```

More __recent Debian or Ubuntu__ install [libjq-dev](https://packages.debian.org/testing/libjq-dev) directly from Universe:

```
sudo apt-get install -y libjq-dev
```

On __Fedora__ we need [jq-devel](https://apps.fedoraproject.org/packages/jq-devel):

```
sudo yum install jq-devel
````

On __CentOS / RHEL__ we install [jq-devel](https://apps.fedoraproject.org/packages/jq-devel) via EPEL:

```
sudo yum install epel-release
sudo yum install jq-devel
```

On __OS-X__ use [jq](https://github.com/Homebrew/homebrew-core/blob/master/Formula/jq.rb) from Homebrew:

```
brew install jq
```

On __Solaris__ we can have [libjq_dev](https://www.opencsw.org/packages/libjq_dev) from [OpenCSW](https://www.opencsw.org/):
```
pkgadd -d http://get.opencsw.org/now
/opt/csw/bin/pkgutil -U
/opt/csw/bin/pkgutil -y -i libjq_dev
```


```r
library(jqr)
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

Note that we print the output to look like a valid JSON object to make it
easier to look at. However, it's a simple character string or vector of strings.
A trick you can do is to wrap your jq program in brackets like `[.[]]` instead
of `.[]`, e.g.,


```r
jq(str, ".[]") %>% unclass
#> [1] "{\"foo\":1,\"bar\":2}" "{\"foo\":3,\"bar\":4}" "{\"foo\":5,\"bar\":6}"
# vs.
jq(str, "[.[]]") %>% unclass
#> [1] "[{\"foo\":1,\"bar\":2},{\"foo\":3,\"bar\":4},{\"foo\":5,\"bar\":6}]"
```

Combine many jq arguments - they are internally combined with a pipe ` | `

(note how these are identical)


```r
jq(str, ".[] | {name: .foo} | keys")
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
jq(str, ".[]", "{name: .foo}", "keys")
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

Also accepts many JSON inputs now


```r
jq("[123, 456]   [77, 88, 99]", ".[]")
#> [
#>     123,
#>     456,
#>     77,
#>     88,
#>     99
#> ]
jq('{"foo": 77} {"bar": 45}', ".[]")
#> [
#>     77,
#>     45
#> ]
jq('[{"foo": 77, "stuff": "things"}] [{"bar": 45}] [{"n": 5}]', ".[] | keys")
#> [
#>     [
#>         "foo",
#>         "stuff"
#>     ],
#>     [
#>         "bar"
#>     ],
#>     [
#>         "n"
#>     ]
#> ]

# if you have jsons in a vector
jsons <- c('[{"foo": 77, "stuff": "things"}]', '[{"bar": 45}]', '[{"n": 5}]')
jq(paste0(jsons, collapse = " "), ".[]")
#> [
#>     {
#>         "foo": 77,
#>         "stuff": "things"
#>     },
#>     {
#>         "bar": 45
#>     },
#>     {
#>         "n": 5
#>     }
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


```r
'[1,2,3,4]' %>% reverse %>% peek
#> <jq query>
#>   query: reverse
```

#### get multiple outputs for array w/ > 1 element


```r
x <- '{"user":"jqlang","titles":["JQ Primer", "More JQ"]}'
jq(x, '{user, title: .titles[]}')
#> [
#>     {
#>         "user": "jqlang",
#>         "title": "JQ Primer"
#>     },
#>     {
#>         "user": "jqlang",
#>         "title": "More JQ"
#>     }
#> ]
x %>% index()
#> [
#>     "jqlang",
#>     [
#>         "JQ Primer",
#>         "More JQ"
#>     ]
#> ]
x %>% build_object(user, title = `.titles[]`)
#> [
#>     {
#>         "user": "jqlang",
#>         "title": "JQ Primer"
#>     },
#>     {
#>         "user": "jqlang",
#>         "title": "More JQ"
#>     }
#> ]
jq(x, '{user, title: .titles[]}') %>% jsonlite::toJSON() %>% jsonlite::validate()
#> [1] TRUE
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
'["fo", "foo"] ["barfoo", "foobar", "barfoob"]' %>% index %>% startswith(foo)
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


#### filter

With filtering via `select()` you can use various operators, like `==`,
`&&`, `||`. We translate these internally for you to what `jq` wants
to see (`==`, `and`, `or`).

Simple, one condition


```r
'{"foo": 4, "bar": 7}' %>% select(.foo == 4)
#> {
#>     "foo": 4,
#>     "bar": 7
#> }
```

More complicated. Combine more than one condition; combine each individual
filtering task in parentheses


```r
x <- '{"foo": 4, "bar": 2} {"foo": 5, "bar": 4} {"foo": 8, "bar": 12}'
x %>% select((.foo < 6) && (.bar > 3))
#> {
#>     "foo": 5,
#>     "bar": 4
#> }
x %>% select((.foo < 6) || (.bar > 3))
#> [
#>     {
#>         "foo": 4,
#>         "bar": 2
#>     },
#>     {
#>         "foo": 5,
#>         "bar": 4
#>     },
#>     {
#>         "foo": 8,
#>         "bar": 12
#>     }
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

Build an object, selecting variables by name, and rename


```r
'{"foo": 5, "bar": 7}' %>% build_object(a = .foo)
#> {
#>     "a": 5
#> }
```

More complicated `build_object()`, using the included dataset `commits`


```r
commits %>%
  index() %>%
  build_object(sha = .sha, name = .commit.committer.name)
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
(x <- commits %>%
  index() %>%
  build_object(sha = .sha, name = .commit.committer.name))
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
* Please note that this package is released with a [Contributor Code of Conduct](https://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.

[![rofooter](https://www.ropensci.org/public_images/github_footer.png)](https://ropensci.org)
