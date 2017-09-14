## Test environments

* local OS X install, R 3.4.1 patched
* ubuntu 12.04 (on travis-ci), R 3.4.1
* win-builder (devel and release)

## R CMD check results

0 errors | 0 warnings | 1 note

## Reverse dependencies

We've checked the 1 reverse dependency, and no problems resulted.

---

This version upates the `jq` version and includes the mandatory 
addition of R_registerRoutines and R_useDynamicSymbols for 
packages with compiled code.

Thanks!
Scott Chamberlain
