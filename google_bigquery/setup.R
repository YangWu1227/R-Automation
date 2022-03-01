# Packages ----------------------------------------------------------------

library(bigrquery)
library(DBI)
library(pool)
library(dplyr)

# Set up an account via https://cloud.google.com/ and create a new project

# Enable API for google cloud platform (GCP) https://gargle.r-lib.org/articles/get-api-credentials.html

# Set up billing for account

# Create service account and create key (.json file)

# Set environment variable ------------------------------------------------

Sys.setenv(BIGQUERY_TEST_PROJECT = "project_name")

Sys.setenv(path_to_bq_token = "path_to_key_json.json")

# For non-interactive use -------------------------------------------------
# Refer to https://gargle.r-lib.org/articles/non-interactive-auth.html

bq_auth(path = Sys.getenv("path_to_bq_token"))

# DBI ---------------------------------------------------------------------

conn <- dbConnect(
  bigrquery::bigquery(),
  project = "bigquery-public-data",
  dataset = "pypi",
  # Obtains the 'BIGQUERY_TEST_PROJECT' environment variable
  billing = bq_test_project()
)

# List all tables
dbListTables(conn)

# Query
dbGetQuery(conn, "SELECT * FROM table;", n = 10)

dbDisconnect(conn)

# Dplyr -------------------------------------------------------------------

df <- tbl(conn, "table")

df |>
  select(var1, var2, starts_with("prefix")) |>
  head(10) |>
  collect()

# Pool --------------------------------------------------------------------

pool <- dbPool(
  drv = bigrquery::bigquery(),
  project = "bigquery-public-data",
  dataset = "pypi",
  billing = bq_test_project()
)
onStop(function() {
  poolClose(pool)
})

# Query
dbGetQuery(pool, "SELECT * FROM table;", n = 10)
