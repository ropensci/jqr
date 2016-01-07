#' Manipulation operations
#'
#' @name manip
#' @template args
#' @export
#' @seealso \code{\link{add}}
#' @examples
#' # join
#' str <- '["a","b,c,d","e"]'
#' jq(str, 'join(", ")')
#' str %>% join
#' str %>% join(`;`)
#' str %>% join(`yep`)
#'
#' # split
#' jq('"a, b,c,d, e"', 'split(", ")')
#'
#' # ltrimstr
#' jq('["fo", "foo", "barfoo", "foobar", "afoo"]', '[.[]|ltrimstr("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "afoo"]' %>% index() %>% ltrimstr(foo)
#'
#' # rtrimstr
#' jq('["fo", "foo", "barfoo", "foobar", "foob"]', '[.[]|rtrimstr("foo")]')
#' '["fo", "foo", "barfoo", "foobar", "foob"]' %>% index() %>% rtrimstr(foo)
#'
#' # startswith
#' str <- '["fo", "foo", "barfoo", "foobar", "barfoob"]'
#' jq(str, '[.[]|startswith("foo")]')
#' str %>% index %>% startswith(foo)
#'
#' # endswith
#' jq(str, '[.[]|endswith("foo")]')
#' str %>% index %>% endswith(foo)
#' str %>% index %>% endswith_("foo")
#' str %>% index %>% endswith(bar)
#' str %>% index %>% endswith_("bar")
#'
#' # get index (location) of a character
#' ## input has to be quoted
#' str <- '"a,b, cd, efg, hijk"'
#' str %>% index_loc(", ")
#' str %>% index_loc(",")
#' str %>% index_loc("j")
#' str %>% rindex_loc(", ")
#' str %>% indices(", ")
#'
#' # tojson, fromjson, tostring, tonumber
#' '[1, "foo", ["foo"]]' %>% index %>% tostring
#' '[1, "1"]' %>% index %>% tonumber
#' '[1, "foo", ["foo"]]' %>% index %>% tojson
#' '[1, "foo", ["foo"]]' %>% index %>% tojson %>% fromjson
#'
#' # contains
#' '"foobar"' %>% contains("bar")
#' '["foobar", "foobaz", "blarp"]' %>% contains(`["baz", "bar"]`)
#' '["foobar", "foobaz", "blarp"]' %>% contains(`["bazzzzz", "bar"]`)
#' str <- '{"foo": 12, "bar":[1,2,{"barp":12, "blip":13}]}'
#' str %>% contains(`{foo: 12, bar: [{barp: 12}]}`)
#' str %>% contains(`{foo: 12, bar: [{barp: 15}]}`)
#'
#' # unique
#' '[1,2,5,3,5,3,1,3]' %>% uniquej
#' str <- '[{"foo": 1, "bar": 2}, {"foo": 1, "bar": 3}, {"foo": 4, "bar": 5}]'
#' str %>% uniquej(foo)
#' str %>% uniquej_("foo")
#' '["chunky", "bacon", "kitten", "cicada", "asparagus"]' %>% uniquej(length)
#'
#' # group
#' x <- '[{"foo":1, "bar":10}, {"foo":3, "bar":100}, {"foo":1, "bar":1}]'
#' x %>% group(foo)
#' x %>% group_("foo")

#' @export
#' @rdname manip
join <- function(.data, ...) {
  join_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname manip
join_ <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
  tmp <- lazyeval::all_dots(.dots, ...)
  dots <- comb(tryargs(.data), structure(sprintf("indices(%s)", deparse(tmp[[1]]$expr)), type = "rindex_loc"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tojson <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('tojson', type = "tojson"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
fromjson <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('fromjson', type = "fromjson"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tostring <- function(.data) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure('tostring', type = "tostring"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}

#' @export
#' @rdname manip
tonumber <- function(.data) {
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
  pipe_autoexec(toggle = TRUE)
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
