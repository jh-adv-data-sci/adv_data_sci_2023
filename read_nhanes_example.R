# Read the DB data
library(DBI)
library(RSQLite)
library(dplyr)

fname = here::here("data", "nhanes_wave_i.sqlite")
nhanes = dbConnect(RSQLite::SQLite(), fname)

table_names = tbl(nhanes, "table_labels")
column_names = tbl(nhanes, "column_labels")
smoking_cn = column_names %>%
  filter(name_table %in% "SMQ_I")
