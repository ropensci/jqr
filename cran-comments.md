R CMD CHECK passed on my local OS X install with R 3.2.5 and
R development version, Ubuntu running on Travis-CI, and WinBuilder.

This submission fixes some warnings from the included C library jq.

In addition, this submission includes fixes for failing tests on 
Solaris.

Kurt emailed about getting pedantic warnings. As I have explained
in emails with him, we can't reproduce those warnings WITH 
THIS VERSION that we are submitting.a

We think this version will fix all warnings seen earlier.

Thanks! Scott Chamberlain
