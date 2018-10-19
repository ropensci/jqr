jqr
=======



[![Build Status](https://travis-ci.org/ropensci/jqr.svg?branch=master)](https://travis-ci.org/ropensci/jqr)
[![Build status](https://ci.appveyor.com/api/projects/status/tfwpiaotu24sotxg?svg=true)](https://ci.appveyor.com/project/sckott/jqr)
[![Coverage Status](https://coveralls.io/repos/ropensci/jqr/badge.svg?branch=master)](https://coveralls.io/r/ropensci/jqr?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/jqr?color=0DA6CD)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/jqr)](https://cran.r-project.org/package=jqr)

R interface to jq, a JSON processor http://stedolan.github.io/jq/

`jqr` makes it easy to process large amounts of json without having to
convert from json to R, or without using regular expressions.  This
means that the eventual loading into R can be quicker.

 - Introduction vignette at <https://cran.r-project.org/package=jqr>

## Quickstart Tutorial

The `jq` command line examples from the [jq tutorial](https://stedolan.github.io/jq/tutorial/) work exactly the same in R! 


```r
library(curl)
library(jqr)
curl('https://api.github.com/repos/ropensci/jqr/commits?per_page=5') %>%
  jq('.[] | {message: .commit.message, name: .commit.committer.name}')
#> [
#>     {
#>         "message": "Try to make things a bit faster",
#>         "name": "Jeroen"
#>     },
#>     {
#>         "message": "Also force input as UTF-8, fixes #71 for realz",
#>         "name": "Jeroen Ooms"
#>     },
#>     {
#>         "message": "Set encoding to UTF-8, fixes #71",
#>         "name": "Jeroen"
#>     },
#>     {
#>         "message": "Protect input string",
#>         "name": "Jeroen"
#>     },
#>     {
#>         "message": "add a few examples for streaming from a file or url in addition to string #51",
#>         "name": "Scott Chamberlain"
#>     }
#> ]
```

Try running some of the [other examples](https://stedolan.github.io/jq/tutorial/).

## Installation

Binary packages for __OS-X__ or __Windows__ can be installed directly from CRAN:

```r
install.packages("jqr")
```

Installation from source on Linux or OSX requires [`libjq`](https://stedolan.github.io/jq/). On __Ubuntu 14.04 and 16.04 lower__ use [libjq-dev](https://launchpad.net/~opencpu/+archive/ubuntu/jq) from Launchpad:

```
sudo add-apt-repository -y ppa:opencpu/jq
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

There's a low level interface in which you can execute `jq` code just as you would on the command line:


```r
jq(str, ".[]")
#> [1] "[{\"foo\":1,\"bar\":2}, {\"foo\":3,\"bar\":4}, {\"foo\":5,\"bar\":6}]"
#> attr(,"class")
#> [1] "jqson"     "character"
```


```r
jq(str, "[.[] | {name: .foo} | keys]")
#> [1] "[[\"name\"],[\"name\"],[\"name\"]]"
#> attr(,"class")
#> [1] "jqson"     "character"
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
#> [1] "[{\"message\":\"hello\",\"name\":\"jenn\"}, {\"message\":\"world\",\"name\":\"beth\"}]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

Sort


```r
'[8,3,null,6]' %>% sortj
#> [1] "[null,3,6,8]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

reverse order


```r
'[1,2,3,4]' %>% reverse
#> [1] "[4,3,2,1]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

Show the query to be used using `peek()`


```r
'[1,2,3,4]' %>% reverse %>% peek
#> <jq query>
#>   query: reverse
```

#### get multiple outputs for array w/ > 1 element


```r
x <- '{"user":"stedolan","titles":["JQ Primer", "More JQ"]}'
jq(x, '{user, title: .titles[]}')
#> [
#>     {
#>         "user": "stedolan",
#>         "title": "JQ Primer"
#>     },
#>     {
#>         "user": "stedolan",
#>         "title": "More JQ"
#>     }
#> ]
x %>% index()
<<<<<<< HEAD
x %>% select(user, title = `.titles[]`)
jq(x, '{user, title: .titles[]}') %>% jsonlite::validate()
=======
#> [
#>     "stedolan",
#>     [
#>         "JQ Primer",
#>         "More JQ"
#>     ]
#> ]
x %>% build_object(user, title = `.titles[]`)
#> [
#>     {
#>         "user": "stedolan",
#>         "title": "JQ Primer"
#>     },
#>     {
#>         "user": "stedolan",
#>         "title": "More JQ"
#>     }
#> ]
jq(x, '{user, title: .titles[]}') %>% jsonlite::toJSON() %>% jsonlite::validate()
#> [1] TRUE
>>>>>>> master
```

#### string operations

join


```r
'["a","b,c,d","e"]' %>% join
#> [1] "\"a, b,c,d, e\""
#> attr(,"class")
#> [1] "jqson"     "character"
'["a","b,c,d","e"]' %>% join(`;`)
#> [1] "\"a; b,c,d; e\""
#> attr(,"class")
#> [1] "jqson"     "character"
```

ltrimstr


```r
'["fo", "foo", "barfoo", "foobar", "afoo"]' %>% index() %>% ltrimstr(foo)
#> [1] "[\"fo\", \"\", \"barfoo\", \"bar\", \"afoo\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

rtrimstr


```r
'["fo", "foo", "barfoo", "foobar", "foob"]' %>% index() %>% rtrimstr(foo)
#> [1] "[\"fo\", \"\", \"bar\", \"foobar\", \"foob\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

startswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% startswith(foo)
<<<<<<< HEAD
#> [1] "[false, true, false, true, false]"
#> attr(,"class")
#> [1] "jqson"     "character"
=======
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
>>>>>>> master
```

endswith


```r
'["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% endswith(foo)
#> [1] "[false, true, true, false, false]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

tojson, fromjson, tostring


```r
'[1, "foo", ["foo"]]' %>% index
#> [1] "[1, \"foo\", [\"foo\"]]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[1, "foo", ["foo"]]' %>% index %>% tostring
#> [1] "[\"1\", \"foo\", \"[\\\"foo\\\"]\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[1, "foo", ["foo"]]' %>% index %>% tojson
#> [1] "[\"1\", \"\\\"foo\\\"\", \"[\\\"foo\\\"]\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[1, "foo", ["foo"]]' %>% index %>% tojson %>% fromjson
#> [1] "[1, \"foo\", [\"foo\"]]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

contains


```r
'"foobar"' %>% contains("bar")
#> [1] "true"
#> attr(,"class")
#> [1] "jqson"     "character"
```

unique


```r
'[1,2,5,3,5,3,1,3]' %>% uniquej
#> [1] "[1,2,3,5]"
#> attr(,"class")
#> [1] "jqson"     "character"
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
#> [1] "[\"number\",\"boolean\",\"array\",\"object\",\"null\",\"string\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[0, false, [], {}, null, "hello", true, [1,2,3]]' %>% types
#> [1] "[\"number\",\"boolean\",\"array\",\"object\",\"null\",\"string\",\"boolean\",\"array\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

select elements by type


```r
'[0, false, [], {}, null, "hello"]' %>% index() %>% type(booleans)
#> [1] "false"
#> attr(,"class")
#> [1] "jqson"     "character"
```

#### key operations

get keys


```r
str <- '{"foo": 5, "bar": 7}'
str %>% keys()
#> [1] "[\"bar\",\"foo\"]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

delete by key name


```r
str %>% del(bar)
#> [1] "{\"foo\":5}"
#> attr(,"class")
#> [1] "jqson"     "character"
```

check for key existence


```r
str3 <- '[[0,1], ["a","b","c"]]'
str3 %>% haskey(2)
#> [1] "[false,true]"
#> attr(,"class")
#> [1] "jqson"     "character"
str3 %>% haskey(1,2)
#> [1] "[true,false,true,true]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

Build an object, selecting variables by name, and rename


```r
<<<<<<< HEAD
'{"foo": 5, "bar": 7}' %>% select(a = .foo)
#> [1] "{\"a\":5}"
#> attr(,"class")
#> [1] "jqson"     "character"
=======
'{"foo": 5, "bar": 7}' %>% build_object(a = .foo)
#> {
#>     "a": 5
#> }
>>>>>>> master
```

More complicated `build_object()`, using the included dataset `commits`


```r
commits %>%
  index() %>%
<<<<<<< HEAD
  select(sha = .sha, name = .commit.committer.name)
#> [1] "[{\"sha\":[\"110e009996e1359d25b8e99e71f83b96e5870790\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"a50e548cc5313c187483bc8fb1b95e1798e8ef65\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"4b258f7d31b34ff5d45fba431169e7fd4c995283\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5\"],\"name\":[\"Nicolas Williams\"]}]"
#> attr(,"class")
#> [1] "jqson"     "character"
=======
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
>>>>>>> master
```

#### Maths


```r
'{"a": 7}' %>%  do(.a + 1)
#> [1] "8"
#> attr(,"class")
#> [1] "jqson"     "character"
'{"a": [1,2], "b": [3,4]}' %>%  do(.a + .b)
#> [1] "[1,2,3,4]"
#> attr(,"class")
#> [1] "jqson"     "character"
'{"a": [1,2], "b": [3,4]}' %>%  do(.a - .b)
#> [1] "[1,2]"
#> attr(,"class")
#> [1] "jqson"     "character"
'{"a": 3}' %>%  do(4 - .a)
#> [1] "1"
#> attr(,"class")
#> [1] "jqson"     "character"
'["xml", "yaml", "json"]' %>%  do('. - ["xml", "yaml"]')
#> [1] "\". - [\\\"xml\\\", \\\"yaml\\\"]\""
#> attr(,"class")
#> [1] "jqson"     "character"
'5' %>%  do(10 / . * 3)
#> [1] "6"
#> attr(,"class")
#> [1] "jqson"     "character"
```

comparisons


```r
'[5,4,2,7]' %>% index() %>% do(. < 4)
#> [1] "[false, false, true, false]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[5,4,2,7]' %>% index() %>% do(. > 4)
#> [1] "[true, false, false, true]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[5,4,2,7]' %>% index() %>% do(. <= 4)
#> [1] "[false, true, true, false]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[5,4,2,7]' %>% index() %>% do(. >= 4)
#> [1] "[true, true, false, true]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[5,4,2,7]' %>% index() %>% do(. == 4)
#> [1] "[false, true, false, false]"
#> attr(,"class")
#> [1] "jqson"     "character"
'[5,4,2,7]' %>% index() %>% do(. != 4)
#> [1] "[true, false, true, true]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

length


```r
'[[1,2], "string", {"a":2}, null]' %>% index %>% lengthj
#> [1] "[2, 6, 1, 0]"
#> attr(,"class")
#> [1] "jqson"     "character"
```

sqrt


```r
'9' %>% sqrtj
#> [1] "3"
#> attr(,"class")
#> [1] "jqson"     "character"
```

floor


```r
'3.14159' %>% floorj
#> [1] "3"
#> attr(,"class")
#> [1] "jqson"     "character"
```

find minimum


```r
'[5,4,2,7]' %>% minj
#> [1] "2"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj
#> [1] "{\"foo\":2,\"bar\":3}"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(foo)
#> [1] "{\"foo\":1,\"bar\":14}"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% minj(bar)
#> [1] "{\"foo\":2,\"bar\":3}"
#> attr(,"class")
#> [1] "jqson"     "character"
```

find maximum


```r
'[5,4,2,7]' %>% maxj
#> [1] "7"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj
#> [1] "{\"foo\":1,\"bar\":14}"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(foo)
#> [1] "{\"foo\":2,\"bar\":3}"
#> attr(,"class")
#> [1] "jqson"     "character"
'[{"foo":1, "bar":14}, {"foo":2, "bar":3}]' %>% maxj(bar)
#> [1] "{\"foo\":1,\"bar\":14}"
#> attr(,"class")
#> [1] "jqson"     "character"
```

## Combine into valid JSON

`jq` sometimes creates pieces of JSON that are valid in themselves, but together are not.
`combine()` is a way to make valid JSON.

This outputs a few pieces of JSON


```r
(x <- commits %>%
  index() %>%
<<<<<<< HEAD
  select(sha = .sha, name = .commit.committer.name))
#> [1] "[{\"sha\":[\"110e009996e1359d25b8e99e71f83b96e5870790\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"a50e548cc5313c187483bc8fb1b95e1798e8ef65\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"4b258f7d31b34ff5d45fba431169e7fd4c995283\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5\"],\"name\":[\"Nicolas Williams\"]}]"
#> attr(,"class")
#> [1] "jqson"     "character"
=======
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
>>>>>>> master
```

Use `combine()` to put them together.


```r
combine(x)
#> [1] "[{\"sha\":[\"110e009996e1359d25b8e99e71f83b96e5870790\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"7b6a018dff623a4f13f6bcd52c7c56d9b4a4165f\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"a50e548cc5313c187483bc8fb1b95e1798e8ef65\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"4b258f7d31b34ff5d45fba431169e7fd4c995283\"],\"name\":[\"Nicolas Williams\"]}, {\"sha\":[\"d1cb8ee0ad3ddf03a37394bfa899cfd3ddd007c5\"],\"name\":[\"Nicolas Williams\"]}]"
#> attr(,"class")
#> [1] "jqson"
#> attr(,"pretty")
#> [1] TRUE
```

## return valid JSON or not

You can toggle whether you get back valid JSON as a single string or 
a vector of strings which are individually valid, but are not valid 
all together.


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

By default in low and high level interfaces `jsonify = TRUE`, such that you 
get back a single valid JSON string. Compare these two outcomes:


```r
jq(str, ".[]", jsonify = TRUE)
#> [1] "[{\"foo\":1,\"bar\":2}, {\"foo\":3,\"bar\":4}, {\"foo\":5,\"bar\":6}]"
#> attr(,"class")
#> [1] "jqson"     "character"
jq(str, ".[]", jsonify = FALSE)
#> [1] "{\"foo\":1,\"bar\":2}" "{\"foo\":3,\"bar\":4}" "{\"foo\":5,\"bar\":6}"
#> attr(,"class")
#> [1] "jqson"     "character"
```

Where the first can be read directly by e.g., `jsonlite::fromJSON`:


```r
jq(str, ".[]", jsonify = TRUE) %>% jsonlite::fromJSON()
#>   foo bar
#> 1   1   2
#> 2   3   4
#> 3   5   6
```

Whereas the second can not:


```r
jq(str, ".[]", jsonify = FALSE) %>% jsonlite::fromJSON()
#> Error: parse error: trailing garbage
#>                      {"foo":1,"bar":2} {"foo":3,"bar":4} {"foo":5,"bar
#>                      (right here) ------^
```

Note that toggling `jsonify` with the low level interface works out of the box, 
but with the high level interface:

* if you are using pipes, you have to assign the result to an object first, 
then use `jsonlite::fromJSON` or similar


```r
x <- '[8,3,null,6]' %>% sortj() 
x %>% jsonlite::fromJSON()
#> [1] NA  3  6  8
```

* you can avoid pipes and use `jsonlite::fromJSON` in a more straight-forward 
way:


```r
jsonlite::fromJSON(jq(sortj_('[8,3,null,6]')))
#> [1] NA  3  6  8
```


## Meta

* Please [report any issues or bugs](https://github.com/ropensci/jqr/issues).
* License: MIT
* Get citation information for `jqr` in R doing `citation(package = 'jqr')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![rofooter](http://www.ropensci.org/public_images/github_footer.png)](http://ropensci.org)
