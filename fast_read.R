library(dbplyr)
library(dplyr)
library(duckdb)
library(arrow)
options(digits.secs = 3)

## this reads each csv file in the csv_ds dataset
## and converts it to a .parquet file
# ds = open_dataset("converted_parquet")
ds = open_dataset("data/acc_data.parquet",
                  schema(
                    HEADER_TIMESTAMP = arrow::timestamp("us", timezone = "UTC"),
                    X = double(),
                    Y = double(),
                    Z = double()
                  ))

con <- DBI::dbConnect(duckdb::duckdb())
acc_tbl <- to_duckdb(ds, con, "acc")
acc_tbl = acc_tbl %>%
  mutate(
    HEADER_TIMESTAMP = lubridate::floor_date(HEADER_TIMESTAMP,
                                             unit = "seconds"),
    vm = sqrt(X^2 + Y^2 + Z^2)
  ) %>%
  group_by(HEADER_TIMESTAMP)
acc_tbl %>% collect()
# %>%
#   summarise(
#     mean_vm = mean(vm, na.rm = TRUE),
#     sd_vm = sd(vm, na.rm = TRUE)
#   )
# acc_tbl %>% collect()
