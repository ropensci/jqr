jqr 1.2.3
=========

* New maintainer

jqr 1.2.2
=========

* fix a failing test

jqr 1.2.1
=========

* Windows: update to libjq 1.6

jqr 1.2.0
=========

### MINOR IMPROVEMENTS

* fix to internal method `pipeline_on_exit()` for compatibility with the upcoming magrittr v2.0 (#82) thanks @lionel- !
* `jq()` errors better now when any NA class passed to it (#78)

jqr 1.1.0
=========

### NEW FEATURES

* All functions now support connection objects (file paths, urls) as input types for streaming. see new methods `jqr_feed` and `jqr_new` (#55)
* fix `jq()` to be able to accept `json` objects as input (#62)
* gains new functions `build_array()`/`build_array_()` and `build_object()`/`build_object_()` for building arrays and objects, respectively. and `select()` changes to only do filtering (instead of also doing construction) to match jq behavior (#66) (#67)
* `jq_flags()` gains parameters `stream` and `seq`

### MINOR IMPROVEMENTS

* fixed `strncpy` call in `src/jqr.c` (#75)

### BUG FIXES

* fix `select()` to handle operators other than `=` (#65) (#67)

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

### Fixes for CRAN

* Fixed the ASAN/valgrind problem (use after free) in jqr.cpp

jqr 0.2.3
=========

### Fixes for CRAN

* Fixes in v0.2.2 actually applied in this version

jqr 0.2.2
=========

### Fixes for CRAN

* Backport ec7c3cf (https://git.io/vwCFS)
* Backport eb2fc1d (https://git.io/vwCF5)
* Port 15c4a7f (https://git.io/vw1vM)

jqr 0.2.0
=========

## NEW FEATURES

* Released to CRAN.
