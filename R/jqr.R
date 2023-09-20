#' JQ Streaming API
#'
#' Low level JQ API. First create a program using a `query` and `flags` and then
#' feed pieces of data.
#'
#' @export
#' @rdname jqr_core
#' @useDynLib jqr C_jqr_new
#' @param query string with a valid jq program
#' @inheritParams jq
jqr_new <- function(query, flags = jq_flags()){
  stopifnot(is.character(query))
  stopifnot(is.numeric(flags))
  .Call(C_jqr_new, query, as.integer(flags %% 2048), as.integer(flags %/% 2048))
}

#' @export
#' @rdname jqr_core
#' @useDynLib jqr C_jqr_feed
#' @param jqr_program object returned by [jqr_new]
#' @param json character vector with json data. If the JSON object is incomplete, you
#' must set `finalize` to `FALSE` otherwise you get an error.
#' @param finalize completes the parsing and verifies that the JSON string is valid. Set
#' this to `TRUE` when feeding the final piece of data.
#' @param unlist if `TRUE` returns a single character vector with all output for each
#' each string in `json` input
#' @examples program <- jqr_new(".[]")
#' jqr_feed(program, c("[123, 456]", "[77, 88, 99]"))
#' jqr_feed(program, c("[41, 234]"))
#' jqr_feed(program, "", finalize = TRUE)
jqr_feed <- function(jqr_program, json, unlist = TRUE, finalize = FALSE){
  stopifnot(inherits(jqr_program, 'jqr_program'))
  stopifnot(is.character(json))
  stopifnot(!is.na(json))
  stopifnot(is.logical(finalize))
  out <- .Call(C_jqr_feed, jqr_program, enc2utf8(json), finalize)
  out <- lapply(out, rev);
  out <- rev(out)
  if(isTRUE(unlist))
    return(as.character(unlist(out, recursive = FALSE)))
  return(out)
}

jqr <- function(x, ...) {
  UseMethod("jqr", x)
}

jqr.default <- function(x, query, flags){
  stopifnot(is.character(query))
  stopifnot(is.numeric(flags))
  program <- jqr_new(query, flags = flags)
  jqr_feed(program, json = x, unlist = TRUE, finalize = TRUE)
}

jqr.connection <- function(x, query, flags, out = NULL){
  con <- x
  val <- invisible()
  stopifnot(inherits(con, 'connection'))
  if(is.character(out))
    out <- file(out)
  get_output <- if(!length(out)){
    out <- rawConnection(raw(0), "r+")
    on.exit(close(out), add = TRUE)
    TRUE
  }
  callback <- if(is.function(out)){
    out
  } else if(inherits(out, 'connection')){
    if(!isOpen(out)){
      open(out, 'w')
      on.exit(close(out), add = TRUE)
    }
    function(buf){
      writeLines(buf, out, useBytes = TRUE)
    }
  } else {
    stop("Argument 'out' must be connection or callback function")
  }
  program <- jqr_new(query, flags = flags)
  if(!isOpen(con)){
    open(con, 'r')
    on.exit(close(con), add = TRUE)
  }
  while(length(json <- readLines(con, n = 100, warn = FALSE, encoding = 'UTF-8')))
    callback(jqr_feed(program, json))
  jqr_feed(program, character(0), finalize = TRUE)
  if(isTRUE(get_output)){
    seek(out, 0)
    readLines(out, encoding = 'UTF-8')
  }
}
