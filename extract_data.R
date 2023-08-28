library(curl)
url = "https://ftp.cdc.gov/pub/pax_h/74484.tar.bz2"
# file = tempfile(fileext = ".tar.bz2")
file = basename(url)
if (!file.exists(file)) {
  curl::curl_download(url, file)
}
tdir = "csv_example"
dir.create(tdir, showWarnings = FALSE, recursive = TRUE)
file_list = untar(file, exdir = tdir, list = TRUE)
head(file_list)
tail(file_list)

untar(file, exdir = tdir)

