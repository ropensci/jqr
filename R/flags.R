#' Flags for use with jq
#'
#' The \code{flags} function is provided for the high-level DSL
#' approach, whereas the \code{jq_flags} function is used to provide
#' the low-level \code{jq} with the appropriate flags.
#'
#' @param pretty Pretty print the json (different to jsonlite's
#'   pretty printing).
#' @param ascii Force jq to produce pure ASCII output with non-ASCII
#'   characters replaced by equivalent escape sequences.
#' @param color Add ANSI escape sequences for coloured output
#' @param sorted Output fields of each object with keys in sorted order
#' @export
#' @examples
#' '{"a": 7, "z":0, "b": 4}' %>% flags(sorted = TRUE)
#' '{"a": 7, "z":0, "b": 4}' %>% dot %>% flags(sorted = TRUE)
#' jq('{"a": 7, "z":0, "b": 4}', ".") %>% flags(sorted = TRUE)
#' jq('{"a": 7, "z":0, "b": 4}', ".", flags = jq_flags(sorted = TRUE))
jq_flags <- function(pretty = FALSE, ascii = FALSE, color = FALSE, sorted = FALSE) {
  sum(c(integer(0),
        if (pretty) 1L,
        if (ascii)  2L,
        if (color)  4L,
        if (sorted) 8L))
}


#' @rdname jq_flags
#' @param .data A \code{jqr} object.
#' @export
flags <- function(.data, pretty = FALSE, ascii = FALSE, color = FALSE, sorted = FALSE)
{
  jq_obj <- `if`(inherits(.data, "jqr"), .data, dot_(.data, dots = "."))

  pipe_autoexec(toggle = TRUE)

  attr(jq_obj, "jq_flags") <- jq_flags(pretty, ascii, color, sorted)

  jq_obj
}
