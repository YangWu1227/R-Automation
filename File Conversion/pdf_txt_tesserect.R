# Packages  ---------------------------------------------------------------

library(tesseract)
library(pdftools)
library(magrittr)
library(stringr)
library(purrr)
library(tictoc)
library(furrr)

# Function to convert .pdf to .txt ----------------------------------------

pdf_convert_txt <- function(pdf) {

  # Case id
  # The pdf file names are such that the first 13 characters are the case id's
  case_id <- str_sub(
    string = pdf,
    start = 1L,
    end = 13L
  )
  # File path for writing .txt file to subdirectory
  txt_file_path <- paste0(
    # Subdirectory
    paste0(case_id, "/"),
    # Ensure .txt file name does not include .pdf extension (last 4 char)
    str_sub(
      string = pdf,
      start = 1L,
      end = -5L
    ),
    # File extension
    ".txt"
  )

  # Create subdirectory using case id as its name
  if (dir.exists(paths = case_id) == FALSE) dir.create(path = case_id)

  # Convert pdf to png
  # This function creates one .png file per pdf page in current working directory
  # It also returns a character vector of .png file names
  pdf_convert(
    pdf = pdf,
    format = "png",
    dpi = 80,
  ) %>%
    # Pass the character vector of .png file names to tesseract::ocr()
    # This function returns plain text by default
    ocr(image = .) %>%
    # Concatenate and save plain text .txt file to subdirectory created above
    cat(file = txt_file_path)
}


# Set CPU cores to use ----------------------------------------------------

# Check number of available cores on the current machine
availableCores()

# Set a plan for future multisessions
plan(
  multisession,
  workers = 6
)


# Apply pdf_convert_txt() to all .pdf files in current working dir -------------------

# Use future_map() and time execution time using tic() and toc()
future_map(
  .x = list.files(pattern = ".pdf"),
  .f = pdf_convert_txt
)

# Remove all png files in current working directory
file.remove(
  list.files(pattern = ".png")
)


# Set R session back to sequential ----------------------------------------

plan(sequential)


