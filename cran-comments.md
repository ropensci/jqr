I have read and agree to the the CRAN policies at
http://cran.r-project.org/web/packages/policies.html

R CMD CHECK passed on my local OS X install with R 3.2.4 and
R development version, Ubuntu running on Travis-CI, and WinBuilder.

This is a new package.

This is a re-submission of the first submission. I was asked to
look over again the authors, license, and copyright information.

In terms of authors and copyright, I have updated the DESCRIPTION
file with ctb and cph notes for jq, some C code by David Gay, and
the bison parser.

In terms of license, jq is MIT and other C code included by David Gay
is also MIT licensed. A dependency in jq, bison, is GPL licensed.
However, bison has a special exception:

	 As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception. This special exception was
   added by the Free Software Foundation in version 2.2 of Bison.

If I understand this correctly, this means we can license this package
under MIT since this package is not a parser generator itself. The fact
that jq is licensed under MIT suggests that we can as well. I hope
I have interpreted this correctly. Please let me know if you disagree.

Note that CHECK says that 'jq' should be sentence cased, but that is
an improper spelling of the software.

Thanks! Scott Chamberlain
