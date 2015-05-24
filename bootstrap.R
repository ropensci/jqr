#!/usr/bin/env Rscript

## This is no longer designed to be run regularly; but this is how the
## jq sources were included.  When we upgrade to 1.5 (or in general)
## this will need to be rerun, but from now should be run only by
## mantainers, rather than by users.

url <- "http://stedolan.github.io/jq/download/source/jq-1.4.tar.gz"
if (!file.exists("jq-1.4.tar.gz")) {
  download.file(url, "jq-1.4.tar.gz")
}
if (!file.exists(Sys.getenv("TAR"))) {
  Sys.setenv(TAR="/usr/bin/tar")
}
if (file.exists("src/jq-1.4")) {
  unlink("src/jq-1.4", recursive=TRUE)
}

untar("jq-1.4.tar.gz", compressed=TRUE, exdir="src")

## This file is necessary, but it causes a WARNING.  I don't see any
## reference to this file on CRAN (lt~obsolete.m4 user:cran), so it
## seems worth dealing with.  I'm just renaming it for now and
## updating references.
files <- c("aclocal.m4", "Makefile.in")
fix <- function(str) {
  sub("lt~obsolete.m4", "lt__obsolete.m4", str, fixed=TRUE)
}
for (f in file.path("src/jq-1.4", files)) {
  str <- fix(readLines(f))
  writeLines(str, f)
}
ok <- file.rename("src/jq-1.4/config/m4/lt~obsolete.m4",
                  "src/jq-1.4/config/m4/lt__obsolete.m4")

header <-
  c("The following license applies to code from the jq library which will",
    "be linked into the installed package")
writeLines(c(header, "", readLines("src/jq-1.4/COPYING")),
           "inst/COPYING.jq")

## Drop some of the bits:
unlink("src/jq-1.4/docs", recursive=TRUE)
unlink("src/jq-1.4/tests", recursive=TRUE)

## Rewite the version script
writeLines(c("#!/bin/sh", "echo 1.4"), "src/jq-1.4/scripts/version")
