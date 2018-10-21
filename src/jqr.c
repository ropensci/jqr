#define R_NO_REMAP
#define STRICT_R_HEADERS

#include <Rinternals.h>
#include <R_ext/Visibility.h>
#include <jq.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
  int is_finalized;
  int output_flags;
  jq_state * state;
  jv_parser * parser;
} jqr_program;

static void error_cb(void * data, jv x) {
  char buf[1000];
  strncpy(buf, jv_string_value(x), 999);
  jv_free(x);
  Rf_errorcall(R_NilValue, buf);
}

static SEXP make_string(const char * str){
  return Rf_ScalarString(Rf_mkCharCE(str, CE_UTF8));
}

// called for each json object within the string
static SEXP jqr_process(jqr_program * program, jv value) {
  SEXP ret = R_NilValue;
  jq_start(program->state, value, 0);
  jv result = jq_next(program->state);
  while (jv_is_valid(result)) {
    jv x = jv_dump_string(result, program->output_flags);
    const char *str = jv_string_value(x);
    ret = PROTECT(Rf_cons(make_string(str), ret));
    jv_free(x);
    result = jq_next(program->state);
  }

  jv_free(result);
  UNPROTECT(Rf_length(ret));
  return ret;
}

static jqr_program * get_program(SEXP ptr){
  jqr_program * program = R_ExternalPtrAddr(ptr);
  if(!program)
    Rf_error("jqr pointer is dead. You cannot save/cache compiled jq programs between r sessions");
  if(program->is_finalized)
    Rf_error("jqr stream has already been finalized");
  return program;
}

static void fin_jqr_program(SEXP ptr){
  jqr_program * program = R_ExternalPtrAddr(ptr);
  if(program == NULL)
    return;
  jv_parser_free(program->parser);
  jq_teardown(&program->state);
  free(program);
  R_ClearExternalPtr(ptr);
}

/* Triple loop:
 *  1. over each string in the character vector
 *  2. over each json object within a string
 *  3. over each output element after running the program on each a object
 */
attribute_visible SEXP C_jqr_feed(SEXP ptr, SEXP json, SEXP finalize){
  SEXP out = R_NilValue;
  jqr_program * program = get_program(ptr);
  for(R_xlen_t i = 0; i < Rf_length(json); i++){
    // load the json string
    SEXP str = STRING_ELT(json, i);
    program->is_finalized = Rf_asLogical(finalize) && (i == Rf_length(json) - 1);
    jv_parser_set_buf(program->parser, CHAR(str), Rf_length(str), !program->is_finalized);

    // loop over each json object within a string
    jv value = jv_parser_next(program->parser);
    while (jv_is_valid(value)) {
      out = PROTECT(Rf_cons(jqr_process(program, value), out));
      //jv_free(value); TODO: uncomment
      value = jv_parser_next(program->parser);
    }

    // Check for JSON parsing problems
    if (jv_invalid_has_msg(jv_copy(value))) {
      error_cb(NULL, jv_invalid_get_msg(value));
    } else {
      jv_free(value);
    }
  }
  UNPROTECT(Rf_length(out));
  return out;
}

attribute_visible SEXP C_jqr_new(SEXP jq_filter, SEXP output_flags, SEXP parser_flags){
  jqr_program * program = calloc(1, sizeof(jqr_program));
  program->parser = jv_parser_new(Rf_asInteger(parser_flags));
  program->state = jq_init();
  program->output_flags = Rf_asInteger(output_flags);
  jq_set_error_cb(program->state, error_cb, NULL);
  const char * str = CHAR(STRING_ELT(jq_filter, 0));
  if(!jq_compile(program->state, str))
    Rf_errorcall(R_NilValue, "Invalid jq filter: '%s'", str);
  SEXP ptr = PROTECT(R_MakeExternalPtr(program, R_NilValue, jq_filter));
  R_RegisterCFinalizerEx(ptr, fin_jqr_program, 1);
  Rf_setAttrib(ptr, R_ClassSymbol, Rf_mkString("jqr_program"));
  UNPROTECT(1);
  return ptr;
}
