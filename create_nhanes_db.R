# Create DB
library(DBI)
library(RSQLite)
library(haven)
library(nhanesA)
library(dplyr)

# list all the XPT files from NHANES
x = list.files(path = "data", pattern = ".XPT", full.names = TRUE)
tables = sub(".XPT", "", basename(x))
names(x) = tables

# Read the data in
dfs = lapply(x, read_xpt)

# translate the columns to real data
conv_dfs = mapply(function(x, y) {
  nhanesTranslate(
    nh_table = y,
    colnames = colnames(x),
    data = x,
    nchar = 1000
  )
}, dfs, names(dfs), SIMPLIFY = FALSE)

# make a table of the column name translations
cn = lapply(conv_dfs, function(x) {
  res = sapply(x, attr, "label")
  tibble::tibble(
    name_column = colnames(x),
    label_column = res
  )
})
cn = dplyr::bind_rows(cn, .id = "name_table")

# make a table of table labels
table_labels = sapply(conv_dfs, attr, "label")
if (is.null(table_labels$OHXREF_I)) {
  table_labels$OHXREF_I = "Oral Health - Recommendation of Care"
}
if (is.null(table_labels$DEMO_I)) {
  table_labels$DEMO_I = "Demographic Variables and Sample Weights"
}
table_labels = tibble::tibble(
  name_table = names(table_labels),
  label_table = unname(unlist(c(table_labels)))
)

# write the output in a SQLITE db
fname = paste0("data/", "nhanes_wave_i.sqlite")
if (file.exists(fname)) {
  file.remove(fname)
}
nhanes = dbConnect(RSQLite::SQLite(), fname)
dbWriteTable(nhanes, "table_labels", table_labels)
dbWriteTable(nhanes, "column_labels", cn)
mapply(function(table, name_table) {
  dbWriteTable(nhanes, name_table, table)
  NULL
}, conv_dfs, names(conv_dfs))

mapply(function(table, name_table) {
  dbWriteTable(nhanes, paste0("RAW_", name_table), table)
  NULL
}, dfs, names(dfs))




