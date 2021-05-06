if(!file.exists("../windows/jq-1.6/include/jq.h")){
  if(getRversion() < "3.3.0") setInternet2()
  download.file("https://github.com/rwinlib/jq/archive/v1.6.zip", "lib.zip", quiet = TRUE)
  dir.create("../windows", showWarnings = FALSE)
  unzip("lib.zip", exdir = "../windows")
  unlink("lib.zip")
}
