add_R_h <- function(dat) {
  str <- '#include <R.h>'
  if (!any(grepl(str, dat, fixed=TRUE))) {
    dat <- c(str, dat)
  }
  dat
}

replace_abort <- function(filename) {
  dat <- readLines(filename)
  re_abort <- "\\b(abort|exit)\\s*\\([^)]*\\);"
  re_msg <- 'fprintf\\([^,]*,\\s*\"'
  i <- grep(re_abort, dat, perl=TRUE)
  j <- i - 1L
  if (length(i) == 0) {
    stop("not found")
  }
  if (!all(grepl(re_msg, dat[j]))) {
    stop("didn't find message")
  }
  dat[j] <- sub('\\\\n"', '"', sub(re_msg, "Rprintf(\"", dat[j]))

  writeLines(add_R_h(dat[-i]), filename)
}

replace_printf <- function(filename) {
  dat <- readLines(filename)
  re_printf <- "\\bprintf\\("
  i <- grep(re_printf, dat, perl=TRUE)
  if (length(i) == 0) {
    stop("not found")
  }
  dat[i] <- sub(re_printf, "Rprintf(", dat[i])
  writeLines(add_R_h(dat), filename)
}

replace_printf_stderr <- function(filename) {
  dat <- readLines(filename)
  re_printf <- "\\bfprintf\\(\\s*stderr,\\s*"
  i <- grep(re_printf, dat, perl=TRUE)
  if (length(i) == 0) {
    stop("not found")
  }
  dat[i] <- sub(re_printf, "REprintf(", dat[i])
  writeLines(add_R_h(dat), filename)
}

replace_stdout_hack <- function(filename) {
  dat <- readLines(filename)
  re_stdout <- "stdout"
  i <- grep(re_stdout, dat, perl=TRUE)
  if (length(i) == 0) {
    stop("not found")
  }
  dat[i] <- sub(re_stdout, "(FILE *) 0", dat[i])
  writeLines(dat, filename)
}

replace_stderr_hack <- function(filename) {
  dat <- readLines(filename)
  re_stderr <- "stderr"
  i <- grep(re_stderr, dat, perl=TRUE)
  if (length(i) == 0) {
    stop("not found")
  }
  dat[i] <- sub(re_stderr, "(FILE *) 0", dat[i])
  writeLines(dat, filename)
}

replace_fwrite <- function(filename) {
  dat <- readLines(filename)
  str <- 'fwrite(s, 1, len, fout);'
  i <- grep(str, dat, fixed=TRUE)
  if (length(i) != 1L) {
    stop("Not expected")
  }

  repl <- 'if ((int) fout == 0) { // stdout
      Rprintf("%s, "s);
    } else if ((int) fout == 1) { // stderr
      REprintf("%s", s);
    } else {
      fwrite(s, 1, len, fout);
    }'
  dat[i] <- sub(str, repl, dat[i])

  writeLines(add_R_h(dat), filename)
}

## system("git checkout -- src")
replace_abort("src/jq/jv_alloc.c")
replace_abort("src/jq/lexer.c")

replace_printf("src/jq/bytecode.c")
replace_printf("src/jq/execute.c")

replace_printf_stderr("src/jq/execute.c")
replace_printf_stderr("src/jq/locfile.c")

## This one is a hack, dealing with the symptom rather than the cause.
## However, I've looked at the source code and am pretty sure that
## stdout is never used here.  More extensive surgery could remove it
## entirely from lexer.c but that would require a manual patch.
replace_stdout_hack("src/jq/lexer.c")

## This replaces the symptom but then does the right thing and prints
## stdout/stderr to R's output and error stream (with
## Rprintf/REprintf).
replace_stdout_hack("src/jq/jv_print.c")
replace_stderr_hack("src/jq/jv_print.c")
replace_fwrite("src/jq/jv_print.c")
