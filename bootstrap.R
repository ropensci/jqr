#!/usr/bin/env Rscript
url <- "http://stedolan.github.io/jq/download/source/jq-1.4.tar.gz"
if (!file.exists("jq-1.4.tar.gz")) {
  download.file(url, "jq-1.4.tar.gz")
}
if (!file.exists(Sys.getenv("TAR"))) {
  Sys.setenv(TAR="/usr/bin/tar")
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
