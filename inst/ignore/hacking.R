dot <- function(.data) {
  dot_(.data, dots = ".")
}

dot_ <- function(.data, dots) {
  structure(list(data=.data, structure(dots, type="dot")), class="jqr")
}

index <- function(.data, x = "") {
  index_(.data, dots = paste0(".[", x, "]"))
}

index_ <- function(.data, dots) {
  structure(list(data=.data, structure(dots, type="index")), class="jqr")
}

dotstr <- function(.data, ...) {
  dotstr_(.data, .dots = lazyeval::lazy_dots(...))
  # dotstr_(.data, dots = paste0(".", x))
}

dotstr_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  z <- sprintf(".%s", deparse(tmp[[1]]$expr))
  dots <- cpt(list(pop(.data), structure(z, type="select")))
  structure(list(data=getdata(.data), args=dots), class="jqr")
  # structure(list(data=getdata(.data), args=structure(dots, type="dotstr")), class="jqr")
}

select <- function(.data, ...) {
  select_(.data, .dots = lazyeval::lazy_dots(...))
}

select_ <- function(.data, ..., .dots) {
  tmp <- lazyeval::all_dots(.dots, ...)
  vals <- unname(Map(function(x,y) {
    sprintf("%s: %s", x, as.character(y$expr))
  }, names(tmp), tmp))
  z <- paste0("{", paste0(vals, collapse = ", "), "}")
  dots <- cpt(list(pop(.data), structure(z, type="select")))
  structure(list(data=getdata(.data), args=dots), class="jqr")
}

pop <- function(x) {
  if(!is.null(names(x))){
    tmp <- x[ !names(x) %in% "data" ]
    if(length(tmp) == 1) {
      tmp[[1]]
    } else {
      tmp
    }
  } else {
    NULL
  }
}

getdata <- function(x) {
  if("data" %in% names(x)){
    x$data
  } else {
    x
  }
}

# put them together
# '.[] | {message: .message, name: .name}'
# '{"adf": 5}'
x <- '[{"message": "hello", "name": "jenn"}, {"message": "world", "name": "beth"}]'

x %>%
  index() %>%
  select(message = .message, name = .name)

x %>% index() %>% dotstr("name") %>% show
x %>% index() %>% dotstr("name") %>% jq
x %>% index() %>% select(name = .name) %>% jq

library("httr")
library("jsonlite")
out <- minify(content(GET('https://api.github.com/repos/stedolan/jq/commits?per_page=5'), "text"))

# jq '.'
out %>% dot() %>% jq
# jq '.[]'
out %>% index() %>% jq
# jq '.[0]'
out %>% index(0) %>% jq
# jq '.[1]'
out %>% index(1) %>% jq
# jq '.[0] | {message: .commit.message, name: .commit.committer.name}'
out %>% index(0) %>% select(message = .commit.message, name = .commit.committer.name) %>% jq
# jq '.[] | {message: .commit.message, name: .commit.committer.name}'
out %>% index() %>% select(message = .commit.message, name = .commit.committer.name) %>% jq
# jq '[.[] | {message: .commit.message, name: .commit.committer.name}]'
# not done yet, make fxn array()






