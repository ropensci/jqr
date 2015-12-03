#!/usr/bin/env Rscript

## This is no longer designed to be run regularly; but this is how the
## jq sources were included.  When we upgrade this will need to be
## rerun, but from now should be run only by mantainers, rather than
## by users.

jq_version <- readLines("inst/jq_version")
jq_tar <- sprintf("jq-%s.tar.gz", jq_version)
jq_path <- "src/jq"

url <- sprintf("https://github.com/stedolan/jq/archive/%s", jq_tar)
if (!file.exists(jq_tar)) {
  downloader::download(url, jq_tar)
}
if (!file.exists(Sys.getenv("TAR"))) {
  Sys.setenv(TAR="/usr/bin/tar")
}
if (file.exists(jq_path)) {
  unlink(jq_path, recursive=TRUE)
}

untar(jq_tar, compressed=TRUE, exdir="src")
## Heh - the download goes into the wrong directory :(
invisible(file.rename(sprintf("src/jq-jq-%s", jq_version), jq_path))

header <-
  c("The following license applies to code from the jq library which will",
    "be linked into the installed package")
writeLines(c(header, "", readLines(file.path(jq_path, "COPYING"))),
           "inst/COPYING.jq")

header <-
  c("This is the AUTHORS file from jq:")
writeLines(c(header, "", readLines(file.path(jq_path, "AUTHORS"))),
           "inst/AUTHORS.jq")

## Drop some of the bits:
drop <- c("autom4te.cache", "build", "config", "docs", "m4",
          "scripts", "tests", ## Files:
######################################################################
          "aclocal.m4", "ChangeLog", "compile-ios.sh",
          "configure", "configure.ac", "Dockerfile", "jq.1.default",
          "jq.1.prebuilt", "Makefile.am", "Makefile.in", "NEWS",
          "README", "README.md", "setup.sh", ".travis.yml")
unlink(file.path(jq_path, drop), recursive=TRUE)

## These are bad news.
invisible(file.remove(file.path(jq_path, c("main.c", "jq_test.c"))))

writeLines(file.path("src", dir(jq_path, glob2rx("*.c"))),
           "inst/jq_sources")
