#' Define and use functions
#'
#' @export
#' @param .data input
#' @param fxn A function definition, without \code{def} (added internally)
#' @param action What to do with the function on the data
#' @examples
#' jq("[1,2,10,20]", 'def increment: . + 1; map(increment)')
#' "[1,2,10,20]" %>% funs('increment: . + 1', 'map(increment)')
#' "[1,2,10,20]" %>% funs('increment: . / 100', 'map(increment)')
#' "[1,2,10,20]" %>% funs('increment: . / 100', 'map(increment)')
#' '[[1,2],[10,20]]' %>% funs('addvalue(f): f as $x | map(. + $x)', 'addvalue(.[0])')
#' "[1,2]" %>% funs('f(a;b;c;d;e;f): [a+1,b,c,d,e,f]', 'f(.[0];.[1];.[0];.[0];.[0];.[0])')
#' "[1,2,3,4]" %>% funs('fac: if . == 1 then 1 else . * (. - 1 | fac) end', '[.[] | fac]')
funs <- function(.data, fxn, action) {
  pipe_autoexec(toggle = TRUE)
  fxn_both <- sprintf("def %s; %s", fxn, action)
  dots <- comb(tryargs(.data), structure(fxn_both, type = "funs"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
