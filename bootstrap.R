#!/usr/bin/env Rscript
url <- "http://stedolan.github.io/jq/download/source/jq-1.4.tar.gz"
download.file(url, "jq-1.4.tar.gz")
if (!file.exists(Sys.getenv("TAR"))) {
  Sys.setenv(TAR="/usr/bin/tar")
}
untar("jq-1.4.tar.gz", compressed=TRUE, exdir="src")
