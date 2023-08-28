library(vroom)
library(data.table)
path = here::here("csv_example")
files = list.files(path = path, pattern = "^GT3", full.names = TRUE)

df = vroom::vroom(files)
head(df)
dim(df)
tail(df)

vroom_read = function(files) {
  df = vroom::vroom(files)
  stopifnot(nrow(vroom::problems(df)) == 0)
}

datatable_read = function(files) {
  res = lapply(files, fread)
  res = dplyr::bind_rows(res)
}

readr_read = function(files) {
  df = readr::read_csv(files)
  readr::stop_for_problems(df)
  df
}

results = microbenchmark::microbenchmark(
  data.table = datatable_read(files),
  vroom = vroom_read(files),
  readr = readr::read_csv(files),
  times = 5L
)
