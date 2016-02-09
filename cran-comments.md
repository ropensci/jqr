I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

R CMD CHECK passed on my local OS X install with R 3.2.3 and
R development version, Ubuntu running on Travis-CI, and WinBuilder.

This is a new package.

We did notice warnings on Windows systems with the WinBuilder check, but 
they're coming from the libjq C library which this package wraps.

Thanks! Scott Chamberlain
