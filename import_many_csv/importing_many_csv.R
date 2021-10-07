# Importing many csv ------------------------------------------------------

library(tidyverse)
library(data.table)


# File paths ---------------------------------------------------------------

# Make sure current working directory is set
# Vector of file names
vector_of_csv <- list.files(path = "car_data/", pattern = ".csv")
vector_of_csv
# Create relative paths
# This function is vectorized
vector_of_paths <- paste0("car_data/", vector_of_csv)
vector_of_paths
# Alternatively, use the stringr package
vector_of_paths <- str_c("car_data/", vector_of_csv)
vector_of_paths
# Absolute paths
str_c(getwd(), "/car_data/", vector_of_csv)


# Method 1: Using for loop ------------------------------------------------------

# Instantiate empty container
container_loop <- vector(mode = "list", length = length(vector_of_paths))
# For loop
for (i in seq_along(vector_of_paths)) {
  container_loop[[i]] <- read_csv(
    file = vector_of_paths[[i]],
    # First row used as column names
    col_names = TRUE,
    # Manually specify the "drv" field to be consistent across different csv files
    # Use col_types = NULL to impute column types
    col_types = list(drv = col_character()),
    # Defaults to no index column
    id = NULL
  )
}
# Number of data frames
length(container_loop)
# Examine one data frame
container_loop[[5]]
# Check classes
container_loop[[1]] %>% sloop::s3_class()
# Row-bind data frames
df_loop <- rbindlist(
  l = container_loop,
  # Bind by matching column names
  use.names = TRUE,
  # Fill missing colunmn with NAs
  fill = TRUE,
  # Do not create column showing which list item those rows come from
  idcol = NULL
)
# Examine data frame type
# The subclass "spec_tbl_df" is lost
sloop::s3_class(df_loop)
# Examine data frame
psych::headTail(
  x = df_loop,
  top = 5,
  bottom = 5
)


# Method 2: Using purrr functionals ---------------------------------------

# Row-binding
df_purrr <- map_dfr(
  .x = vector_of_paths,
  .f = read_csv,
  # First row used as column names
  col_names = TRUE,
  # Manually specify the "drv" field to be consistent across different csv files
  col_types = list(drv = col_character()),
  # Defaults to no index column
  id = NULL
)
# Examine data frame
psych::headTail(
  x = df_purrr,
  top = 5,
  bottom = 5
)


# Method 2: Using map() and reduce() --------------------------------------

# Using map
# Return a list object, each element is a data frame
df_map_reduce <- map(
  .x = vector_of_paths,
  .f = read_csv,
  col_names = TRUE,
  col_types = list(drv = col_character()),
  id = NULL
) %>%
  # Concatenate data frame using reduce() with binary function r
  reduce(
    .x = .,
    .f = bind_rows,
    # No idex column
    id = NULL
  )
# Examine data frame
psych::headTail(
  x = df_map_reduce,
  top = 5,
  bottom = 5
)


# All three methods produce equivalent results ----------------------------

all_equal(
  target = df_loop,
  current = df_purrr
)
all_equal(
  target = df_map_reduce,
  current = df_purrr
)

# Write data frame to disk as a .csv file ---------------------------------

# Write to current working directory
write_csv(
  x = df_purrr, 
  file = "final_data.csv",
  na = "NA",
  # Overwrite if file already exist
  append = FALSE,
  col_names = TRUE
)

# Clear global environment ------------------------------------------------

rlang::env_unbind(env = rlang::caller_env(), nms = names(rlang::global_env()))
