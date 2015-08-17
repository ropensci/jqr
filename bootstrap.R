#!/usr/bin/env Rscript

## This is no longer designed to be run regularly; but this is how the
## jq sources were included.  When we upgrade to 1.5 (or in general)
## this will need to be rerun, but from now should be run only by
## mantainers, rather than by users.

url <- "https://github.com/stedolan/jq/archive/jq-1.5.tar.gz"
if (!file.exists("jq-1.5.tar.gz")) {
  downloader::download(url, "jq-1.5.tar.gz")
}
if (!file.exists(Sys.getenv("TAR"))) {
  Sys.setenv(TAR="/usr/bin/tar")
}
if (file.exists("src/jq-1.5")) {
  unlink("src/jq-1.5", recursive=TRUE)
}

untar("jq-1.5.tar.gz", compressed=TRUE, exdir="src")
## Heh - the download goes into the wrong directory :(
file.rename("src/jq-jq-1.5", "src/jq-1.5")

header <-
  c("The following license applies to code from the jq library which will",
    "be linked into the installed package")
writeLines(c(header, "", readLines("src/jq-1.5/COPYING")),
           "inst/COPYING.jq")

## Drop some of the bits:
unlink("src/jq-1.5/docs", recursive=TRUE)
unlink("src/jq-1.5/tests", recursive=TRUE)

## Rewite the version script
writeLines(c("#!/bin/sh", "echo 1.5"), "src/jq-1.5/scripts/version")

owd <- setwd("src/jq-1.5")
on.exit(setwd(owd))
system2("autoreconf", "-i")
