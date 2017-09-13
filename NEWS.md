jqr 0.3.0
=========

* Update bundled libjq to stedolan/jq@0b82185 (1.5-patched), specifically
jq `v1.5rc2-174-g597c1f6`
* Use `R_registerRoutines` and `R_useDynamicSymbols` as required for 
packages with compiled code. (#57)

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
