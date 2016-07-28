#include <Rcpp.h>
extern "C" {
#include <jq.h>
}

// The jv objects haven't been done with RAII yet because the free
// semantics are unclear from main.c and the ruby interface.  Probably
// things are not actually being free'd enough, based on the code I
// see.  But I think we're safe, exception wise.

#include <boost/shared_ptr.hpp>
typedef boost::shared_ptr<jq_state>  jq_state_ptr;
typedef boost::shared_ptr<jv_parser> jv_parser_ptr;

// Once we can rely on C++11 (i.e., new windows toolchain) this should work:
// #include <memory> // std::make_shared, std::shared_ptr
// typedef std::shared_ptr<jq_state>  jq_state_ptr;
// typedef std::shared_ptr<jv_parser> jv_parser_ptr;

void jqr_err_cb(void *, jv x) {
  char buf[1000];
  strncpy(buf, jv_string_value(x), 1000);
  jv_free(x);
  Rcpp::stop(buf);
}

void delete_jq_state(jq_state* state) {
  jq_teardown(&state);
}

void delete_jv_parser(jv_parser* parser) {
  jv_parser_free(parser);
}

jq_state_ptr make_jq_state() {
  jq_state_ptr state(jq_init(), delete_jq_state);
  if (state.get() == NULL) {
    Rcpp::stop("Error allocating jq");
  }
  jq_set_error_cb(state.get(), jqr_err_cb, NULL);
  return state;
}

jv_parser_ptr make_jv_parser() {
  return jv_parser_ptr(jv_parser_new(0), delete_jv_parser);
}

// when is this called >1 time?
std::vector<std::string> jqr_process(jq_state_ptr state, jv value, int flags) {
  std::vector<std::string> ret;
  jq_start(state.get(), value, 0);

  jv result = jq_next(state.get());

  while (jv_is_valid(result)) {
    jv dumped = jv_dump_string(result, flags);
    // A lot of unnecessary copying here (char* to string to R - read
    // how one is *meant* to do this).
    const char *str = jv_string_value(dumped);
    std::string str_cpp(str);
    ret.push_back(str_cpp);

    result = jq_next(state.get());
  }

  jv_free(result);
  return ret;
}

std::vector<std::string> jqr_parse(jq_state_ptr state, jv_parser_ptr parser, int flags) {
  jv value = jv_parser_next(parser.get());
  std::vector<std::string> ret;

  // This loop is not dealt with properly yet; will just take last.
  while (jv_is_valid(value)) {
    ret = jqr_process(state, value, flags);
    value = jv_parser_next(parser.get());
  }

  if (jv_invalid_has_msg(jv_copy(value))) {
    jv msg = jv_invalid_get_msg(value);
    const char * msg_str = jv_string_value(msg);
    jv_free(msg);
    jv_free(value);
    Rcpp::stop(msg_str);
  } else {
    jv_free(value);
  }
  return ret;
}

// [[Rcpp::export]]
std::vector<std::string> jqr(std::string json, std::string program, int flags) {
  jq_state_ptr state = make_jq_state();

  int compiled = jq_compile(state.get(), program.c_str());
  // This doesn't get here because it's picked up in the callback, but
  // serves as an extra check.
  if (!compiled) {
    Rcpp::stop("compile error [should never be seen]");
  }

  int is_partial = 0;
  jv_parser_ptr parser = make_jv_parser();
  jv_parser_set_buf(parser.get(), json.c_str(), json.size(), is_partial);

  return jqr_parse(state, parser, flags);
}
