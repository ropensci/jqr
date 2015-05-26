#' Manipulation operations
#'
#' @name manip
#' @template args
#' @export
#' @seealso \code{\link{add}}
#' @examples
#' # join
#' jq_('["a","b,c,d","e"]', 'join(", ")')
#' '["a","b,c,d","e"]' %>% join %>% jq
#' '["a","b,c,d","e"]' %>% join(`;`) %>% jq
#' '["a","b,c,d","e"]' %>% join(`yep`) %>% jq
#'
#' # split
#' jq_('"a, b,c,d, e"', 'split(", ")')
#'
#' # ltrimstr
#' jq_('["fo", "foo", "barfoo", "foobar", "afoo"]', '[.[]|ltrimstr("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "afoo"]' %>% index() %>% ltrimstr(foo) %>% jq
#'
#' # rtrimstr
#' jq_('["fo", "foo", "barfoo", "foobar", "foob"]', '[.[]|rtrimstr("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "foob"]' %>% index() %>% rtrimstr(foo) %>% jq
#'
#' # startswith
#' jq_('["fo", "foo", "barfoo", "foobar", "barfoob"]', '[.[]|startswith("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% startswith(foo) %>% jq
#'
#' # endswith
#' jq_('["fo", "foo", "barfoo", "foobar", "barfoob"]', '[.[]|endswith("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% endswith(foo) %>% jq
#' '["fo", "foo", "barfoo", "foobar", "barfoob"]' %>% index %>% endswith(bar) %>% jq
#'
#' # get index (location) of a character
#' ## input has to be quoted
#' '"a,b, cd, efg, hijk"' %>% index_loc(", ") %>% jq
#' '"a,b, cd, efg, hijk"' %>% index_loc(",") %>% jq
#' '"a,b, cd, efg, hijk"' %>% index_loc("j") %>% jq
#' '"a,b, cd, efg, hijk"' %>% rindex_loc(", ") %>% jq
#' '"a,b, cd, efg, hijk"' %>% indices(", ") %>% jq
#'
#' # tojson, fromjson, tostring, tonumber
#' '[1, "foo", ["foo"]]' %>% index %>% tostring %>% jq
#' '[1, "1"]' %>% index %>% tonumber %>% jq
#' '[1, "foo", ["foo"]]' %>% index %>% tojson %>% jq
#' '[1, "foo", ["foo"]]' %>% index %>% tojson %>% fromjson %>% jq
#'
#' # contains
#' '"foobar"' %>% contains("bar") %>% jq
#' '["foobar", "foobaz", "blarp"]' %>% contains(`["baz", "bar"]`) %>% jq
#' '["foobar", "foobaz", "blarp"]' %>% contains(`["bazzzzz", "bar"]`) %>% jq
#' str <- '{"foo": 12, "bar":[1,2,{"barp":12, "blip":13}]}'
#' str %>% contains(`{foo: 12, bar: [{barp: 12}]}`) %>% jq
#' str %>% contains(`{foo: 12, bar: [{barp: 15}]}`) %>% jq
#'
#' # unique
#' '[1,2,5,3,5,3,1,3]' %>% uniquej %>% jq
#' str <- '[{"foo": 1, "bar": 2}, {"foo": 1, "bar": 3}, {"foo": 4, "bar": 5}]'
#' str %>% uniquej(foo) %>% jq
#' '["chunky", "bacon", "kitten", "cicada", "asparagus"]' %>% uniquej(length) %>% jq
#'
#' # group
#' x <- '[{"foo":1, "bar":10}, {"foo":3, "bar":100}, {"foo":1, "bar":1}]'
#' x %>% group(foo)
#' x %>% group(foo) %>% jq

#' @export
#' @rdname manip
join <- function(.data, ...) {
  join_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
join_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("join(\"%s \")", setdef(tmp, ",")), type = "join"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
splitj <- function(.data, ...) {
  splitj_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
splitj_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("split(\"%s \")", setdef(tmp, ",")), type = "split"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
ltrimstr <- function(.data, ...) {
  ltrimstr_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
ltrimstr_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("ltrimstr(\"%s\")", deparse(tmp[[1]]$expr)), type = "ltrimstr"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
rtrimstr <- function(.data, ...) {
  rtrimstr_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
rtrimstr_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("rtrimstr(\"%s\")", deparse(tmp[[1]]$expr)), type = "rtrimstr"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
startswith <- function(.data, ...) {
  startswith_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
startswith_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("startswith(\"%s\")", deparse(tmp[[1]]$expr)), type = "startswith"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
endswith <- function(.data, ...) {
  endswith_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
endswith_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("endswith(\"%s\")", deparse(tmp[[1]]$expr)), type = "endswith"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
index_loc <- function(.data, ...) {
  index_loc_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
index_loc_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("index(%s)", deparse(tmp[[1]]$expr)), type = "index_loc"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
rindex_loc <- function(.data, ...) {
  rindex_loc_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
rindex_loc_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("rindex(%s)", deparse(tmp[[1]]$expr)), type = "rindex_loc"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
indices <- function(.data, ...) {
  indices_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
indices_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("indices(%s)", deparse(tmp[[1]]$expr)), type = "rindex_loc"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tojson <- function(.data) {
  dots <- comb(tryargs(.data), structure('tojson', type = "tojson"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
fromjson <- function(.data) {
  dots <- comb(tryargs(.data), structure('fromjson', type = "fromjson"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tostring <- function(.data) {
  dots <- comb(tryargs(.data), structure('tostring', type = "tostring"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tonumber <- function(.data) {
  dots <- comb(tryargs(.data), structure('tonumber', type = "tonumber"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
contains <- function(.data, ...) {
  contains_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
contains_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("contains(%s)", deparse(tmp[[1]]$expr)), type = "contains"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
uniquej <- function(.data, ...) {
  uniquej_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
uniquej_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  if (base::length(tmp) == 0) {
    z <- "unique"
  } else {
    val <- deparse(tmp[[1]]$expr)
    if (val == "length") {
      z <- "unique_by(length)"
    } else {
      z <- sprintf("unique_by(.%s)", val)
    }
  }
  dots <- comb(tryargs(.data), structure(z, type = "unique"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
group <- function(.data, ...) {
  group_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
group_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("group_by(.%s)", deparse(tmp[[1]]$expr)), type = "group"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

setdef <- function(w, def) {
  if (base::length(w) == 0) {
    def
  } else {
    deparse(w[[1]]$expr)
  }
}
