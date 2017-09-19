jqr 1.0.0
=========

* Unbundle jq: the libjq library and headers are now available on all major platforms.
  See https://stedolan.github.io/jq/download/ for details. (#59)
* Removed a few authors due to n longer including jq in package
* No longer linking to BH and Rcpp. No longer using/importing Rcpp
* Use `R_registerRoutines` and `R_useDynamicSymbols` as required for 
packages with compiled code. (#57)
* Internal dataset changed name from "githubcommits" to "commits"
* Multiple JSON inputs now supported (see #53)

jqr 0.2.4
=========

## Fixes for CRAN

* Fixed the ASAN/valgrind problem (use after free) in jqr.cpp

jqr 0.2.3
=========

## Fixes for CRAN

* Fixes in v0.2.2 actually applied in this version

jqr 0.2.2
=========

## Fixes for CRAN

* Backport ec7c3cf (https://git.io/vwCFS)
* Backport eb2fc1d (https://git.io/vwCF5)
* Port 15c4a7f (https://git.io/vw1vM)

jqr 0.2.0
=========

## NEW FEATURES

* Released to CRAN.
