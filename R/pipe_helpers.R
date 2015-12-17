# Check whether inside a pipeline.
is_piped <- function() {
  parents <- lapply(sys.frames(), parent.env)

  is_magrittr_env <-
    vapply(parents, identical, logical(1), y = environment(`%>%`))

  answer <- any(is_magrittr_env)

  list(answer = answer,
       env    = if (answer) sys.frames()[[min(which(is_magrittr_env))]])
}

# Utility for hacking the effect into the pipeline
activate_jq_for_result <- function(env) {
  res <- NULL

  jq_result <- function(v) {
    if (missing(v)) {
      res
    } else {
      res <<- v
      res$value <<- jq(res$value)
    }
  }

  makeActiveBinding("result", jq_result, env)
}

check_piped <- function(z) {
  if (isTRUE(z$answer) &&
      !exists('.jq_activated', envir = z$env, inherits = FALSE)) {

    z$env$.jq_activated <- TRUE
    activate_jq_for_result(z$env)
  }
}

# If this function is used in a pipeline it will end up calling jq!
# other than activating jq, it is just an identity function.
# f <- function(x) {
#   piped <- is_piped()
#   if (isTRUE(piped$answer) &&
#       !exists('.jq_activated', envir = piped$env, inherits = FALSE)) {
#
#     piped$env$.jq_activated <- TRUE
#     activate_jq_for_result(piped$env)
#   }
#   x
# }

# f <- function(x) {
#   check_piped(is_piped())
#   x
# }
#
# # This is just a jq placeholder.
# # Here just squares the number
# jq <- function(x) {
#   print("jq Called!")
#   x^2
# }
#
# # -----------------------
# 10 %>% f %>% f %>% f
# #> "jq Called!"
# #> 100
#
# f(f(f(10)))
# #> 10
