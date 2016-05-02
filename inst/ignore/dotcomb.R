#' Combine N jq things by x
#'
#' @export
#' @template args
#' @examples
#' str <- '{\"name\":\"Fratercula arctica\",\"result\":[{\"taxonid\":22694927,\"scientific_name\":\"Fratercula arctica\",\"kingdom\":\"ANIMALIA\",\"phylum\":\"CHORDATA\",\"class\":\"AVES\",\"order\":\"CHARADRIIFORMES\",\"family\":\"ALCIDAE\",\"genus\":\"Fratercula\",\"main_common_name\":\"Atlantic Puffin\",\"authority\":\"(Linnaeus, 1758)\",\"published_year\":2015,\"category\":\"VU\",\"criteria\":\"A4abcde\",\"marine_system\":true,\"freshwater_system\":false,\"terrestrial_system\":true,\"assessor\":\"BirdLife International\",\"reviewer\":\"Symes, A.\"},{\"taxonid\":22694927,\"scientific_name\":\"Fratercula arctica\",\"kingdom\":\"ANIMALIA\",\"phylum\":\"CHORDATA\",\"class\":\"AVES\",\"order\":\"CHARADRIIFORMES\",\"family\":\"ALCIDAE\",\"genus\":\"Fratercula\",\"main_common_name\":\"Atlantic Puffin\",\"authority\":\"(Linnaeus, 1758)\",\"published_year\":2015,\"category\":\"VU\",\"criteria\":\"A4abcde\",\"marine_system\":true,\"freshwater_system\":false,\"terrestrial_system\":true,\"assessor\":\"BirdLife International\",\"reviewer\":\"Symes, A.\"}]}'
#'
#' str %>% dotstr(result[]) %>% dotstr(class) %>% peek
#' str %>% dotstr(result[]) %>% dotstr(class)
#' str %>% dotstr(result[]) %>% dotstr(class) %>% dont_pipe() %>% peek
#' str %>% dotstr(result[]) %>% dotstr(class) %>% dont_pipe()
dont_pipe <- function(.data, ...) {
  dont_pipe_(.data, .dots = lazyeval::lazy_dots(...))
}

#' @export
#' @rdname dont_pipe
dont_pipe <- function(.data, ..., .dots) {
  pipe_autoexec(toggle = TRUE)
  dots <- comb(tryargs(.data), structure("dont_pipe", type = "dont_pipe"))
  structure(list(data = getdata(.data), args = dots), class = "jqr")
}
