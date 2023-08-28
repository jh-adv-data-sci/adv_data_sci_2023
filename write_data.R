library(data.table)
library(dplyr)
library(vroom)
library(arrow)
library(readr)
library(fst)
path = here::here("csv_example")
files = list.files(path = path, pattern = "^GT3", full.names = TRUE)

data = readr::read_csv(files)
readr::stop_for_problems(data)

dt = as.data.table(data)

con <- DBI::dbConnect(duckdb::duckdb())
data_tbl <- to_duckdb(data, con, "acc")

data_dir = here::here("data")
dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

stub = file.path(data_dir, "acc_data")
# RDS File
fname = paste0(stub, ".rds")
if (!file.exists(fname)) {
  readr::write_rds(data, fname, compress = "none")
}
fname = paste0(stub, "_compressed.rds")
if (!file.exists(fname)) {
  readr::write_rds(data, fname,
                   compress = "gz",
                   compression = 9)
}

# CSV file
fname = paste0(stub, ".csv")
if (!file.exists(fname)) {
  readr::write_csv(data, fname)
}
# CSV GZ file
fname = paste0(stub, "_compressed.csv.gz")
if (!file.exists(fname)) {
  conn = gzfile(fname,
                compression = 9, open = "wb")
  readr::write_csv(data, conn)
  close(conn)
}

fname = paste0(stub, ".feather")
if (!file.exists(fname)) {
  arrow::write_feather(data, fname)
}
fname = paste0(stub, "_compressed.feather")
if (!file.exists(fname)) {
  arrow::write_feather(data, fname,
                       compression = "zstd", compression_level = 9)
}

fname = paste0(stub, ".parquet")
if (!file.exists(fname)) {
  arrow::write_parquet(data, fname)
}

if(!dir.exists("converted_parquet")) {

  dir.create("converted_parquet", showWarnings = FALSE)

  ## this doesn't yet read the data in,
  # it only creates a connection
  csv_ds <- open_dataset(files,
                         format = "csv")

  ## this reads each csv file in the csv_ds dataset
  ## and converts it to a .parquet file
  write_dataset(csv_ds,
                "converted_parquet",
                format = "parquet")
}

fname = paste0(stub, ".fst")
if (!file.exists(fname)) {
  fst::write_fst(data, fname, compress = 0)
}
fname = paste0(stub, "_compressed.fst")
if (!file.exists(fname)) {
  fst::write_fst(data, fname, compress = 100)
}
