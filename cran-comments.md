R CMD CHECK passed on my local OS X install with R 3.3.0 and
R development version, Ubuntu running on Travis-CI, and WinBuilder.

This version actually includes fixes for pedantic warnings and Solaris
errors that we said were included last submission, but were not as 
we accidentally had included some files in .gitignore we did not 
mean to include.

This submission fixes pedantic warnings from the included C library jq.

In addition, this submission includes fixes for failing tests on 
Solaris.

Thanks! Scott Chamberlain
