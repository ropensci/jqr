#include <Rcpp.h>
extern "C" {
#include <jq.h>
}

// Looks like, based on the Ruby version, running a RcppR6 thing
// around the source might be sensible.

// The way that the Ruby version works is this.

// 1: create a JQ object with some source as an attribute `src` and
//    optionally an argument `parse_json` (default: true)
// 2: main method is `search` which takes argument `program` and a
//    block argument that I don't yet understand
// 3: on search, we create a jq object with the `program` argument.
//    that calls to `rb_jq_initialize`.  There is considerable effort
//    taken to ensure that this does close on exit with
//    `rb_jq_close`.
// 4: Then call `rb_jq_update` with the `src` attribute.

// #include <memory> // shared_ptr
// Eventually I want an object that holds jq_state and jv_parser
// together as either:
//
// A C++ class with a destructor that we pass around a smart pointer
// A pair of smart pointers that call the destructors
//    http://stackoverflow.com/questions/12340810/using-custom-deleter-with-stdshared-ptr
// Probably need same for jv_result

// I really have no idea when we're meant to hit this function
// repeatedly.  It's not things of the form '. | . |'
Rcpp::CharacterVector jqr_process(jq_state *state, jv value) {
  Rprintf("process\n");
  Rcpp::CharacterVector ret;
  jq_start(state, value, 0);

  jv result = jq_next(state);

  while (jv_is_valid(result)) {
    jv dumped = jv_dump_string(result, 0);
    // A lot of unnecessary copying here (char* to string to R - read
    // how one is *meant* to do this).
    const char *str = jv_string_value(dumped);
    std::string tmp(str);
    ret.push_back(tmp);

    result = jq_next(state);
  }
  // TODO: This will not get free'd if the above fails!
  jv_free(result);
  return ret;
}

Rcpp::CharacterVector jqr_parse(jq_state *state, struct jv_parser *parser) {
  jv value = jv_parser_next(parser);
  Rcpp::CharacterVector ret;

  while (jv_is_valid(value)) {
    ret = jqr_process(state, value);
    value = jv_parser_next(parser);
  }

  if (jv_invalid_has_msg(jv_copy(value))) {
    jv msg = jv_invalid_get_msg(value);
    jv_free(msg);
    jv_free(value);
    Rcpp::stop(jv_string_value(msg));
  } else {
    jv_free(value);
  }
  return ret;
}

// [[Rcpp::export]]
Rcpp::CharacterVector jqr(std::string json, std::string program) {
  jq_state *state = jq_init();
  if (state == NULL) {
    Rcpp::stop("Error allocating jq");
  }

  const char * program_c = program.c_str();
  int compiled = jq_compile(state, program_c);
  if (!compiled) {
    jq_teardown(&state);
    Rcpp::stop("compile error");
  }
  // parser = NULL;
  // closed = 0;

  int is_partial = 0;
  jv_parser *parser = jv_parser_new(0);
  jv_parser_set_buf(parser, json.c_str(), json.size(), is_partial);
  Rcpp::CharacterVector ret = jqr_parse(state, parser);
  jv_parser_free(parser);

  // On exit:
  jq_teardown(&state);
  // parser = NULL;
  // closed = 1;

  return ret;
}
