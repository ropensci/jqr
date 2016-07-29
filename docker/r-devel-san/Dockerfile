FROM rocker/r-devel-san

ENV UBSAN_OPTIONS print_stacktrace=1
ENV ASAN_OPTIONS malloc_context_size=10:fast_unwind_on_malloc=false

RUN apt-get -qq update \
  && apt-get -qq dist-upgrade -y \
  && apt-get -qq install git pandoc pandoc-citeproc libssl-dev libcurl4-openssl-dev -y \
  && RDscript -e 'install.packages("jqr", dependencies = TRUE, quiet = TRUE)'


RUN git clone https://github.com/ropensci/jqr \
  && RD CMD build jqr --no-build-vignettes \
  && RD CMD INSTALL jqr_*.tar.gz --install-tests

RUN RDscript -e 'sessionInfo()'

RUN RDscript -e 'library(jqr); jqr=jqr:::jqr; testthat::test_dir("jqr/tests/testthat")' || true

RUN RDscript -e 'library(jqr); testthat::test_examples("jqr/man")'|| true

RUN RD CMD check jqr*.tar.gz
