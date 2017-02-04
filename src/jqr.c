#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <jq.h>
#include <string.h>

void error_cb(void * data, jv x) {
  char buf[1000];
  strncpy(buf, jv_string_value(x), 1000);
  jv_free(x);
  Rf_errorcall(R_NilValue, buf);
}

// called for each json object within the string
SEXP jqr_process(jq_state * state, jv value, int flags) {
  SEXP ret = R_NilValue;
  jq_start(state, value, 0);
  jv result = jq_next(state);
  while (jv_is_valid(result)) {
    jv x = jv_dump_string(result, flags);
    const char *str = jv_string_value(x);
    ret = PROTECT(Rf_cons(Rf_mkString(str), ret));
    jv_free(x);
    result = jq_next(state);
  }

  jv_free(result);
  UNPROTECT(Rf_length(ret));
  return ret;
}

SEXP C_jqr_string(SEXP json, SEXP program, SEXP flags) {
  // compile the 'jq' string
  jq_state * state = jq_init();
  jq_set_error_cb(state, error_cb, NULL);
  if(!jq_compile(state, CHAR(STRING_ELT(program, 0))))
    Rf_error("Failed to compile program");

  // create parser for json
  int is_partial = 0;
  jv_parser * parser = jv_parser_new(0);
  jv_parser_set_buf(parser, CHAR(STRING_ELT(json, 0)), Rf_length(STRING_ELT(json, 0)), is_partial);

  // start parsing
  SEXP out = R_NilValue;
  jv value = jv_parser_next(parser);

  // loop over each top level json object within the string
  while (jv_is_valid(value)) {
    out = PROTECT(Rf_cons(jqr_process(state, value, Rf_asInteger(flags)), out));
    value = jv_parser_next(parser);
  }
  UNPROTECT(Rf_length(out));

  // Check for JSON parsing problems
  if (jv_invalid_has_msg(jv_copy(value))) {
    error_cb(NULL, jv_invalid_get_msg(value));
  } else {
    jv_free(value);
  }

  // Cleanup
  jv_parser_free(parser);
  jq_teardown(&state);
  return out;
}
