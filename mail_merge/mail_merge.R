# Automating Emails -------------------------------------------------------

library(blastula)
library(htmltools)
library(tidyverse)
library(data.table)
library(dtplyr)

# Set up ------------------------------------------------------------------

# A one time task to create a credentials file
# Executing the function below returns a prompt to enter email address password
# blastula::create_smtp_creds_file(
#  file = "gmail_credentials",
#  user = "yangwu2020@gmail.com",
#  provider = "gmail"
# )

# Email Rendering Function ------------------------------------------------

# Create a function that renders Rmd file to email based on varying parameters
# Make sure the parameters are specified in the template YAML
# For most use cases of mail merging, usually there shouldn't be too many parameters (> 10)
# Ensure the file path for "template.Rmd" is correct (relative to working directory or absolute)
auto_create_emails <- function(name, signoff, template_path) {

  # Render
  email <- blastula::render_email(
    # The email template
    input = template_path,
    # There is only "params" in the YAML header of the Rmd file
    # Therefore, the list supplied to render_options has 1 element named "params'
    render_options = list(
      # A named list for arguments passed on to rmarkdown::render() when it renders "params"
      params = list(
        name = name,
        signoff = signoff
      )
    )
  )

  # Output is an object of the class "blastula_message" "email_message"
  email
}

# Create Mailing List -----------------------------------------------------

# Or import csv or xlsx file
mail_list <- tibble::tribble(
  ~address, ~name, ~signoff,
  "li@cs.princeton.edu", "Kai Li", "Yang Wu",
  "kenwy2010@hotmail.com", "Ken Wu", "Yourself",
  "ywu@advancingjustice-aajc.org", "Yang", "Your Intern"
) %>%
  # Create “lazy” data table that tracks the operations performed on it
  dtplyr::lazy_dt()

# Create List of Emails ---------------------------------------------------

# Use purrr to apply the user-defined function above to each row of the mailing list
mail_list <- mail_list %>%
  # Create a new column that contains objects of the class "blastula_message" "email_message"
  dplyr::mutate(
    email = purrr::pmap(
      # Parameters
      .l = list(name, signoff),
      .f = auto_create_emails,
      # Constant argument since we use the same template
      template_path = "template.Rmd"
    )
  ) %>%
  # Access post data wrangling results
  tibble::as_tibble()

# Sanity check to see if the emails are rendered correctly
mail_list$email[[2]]

# Send Emails -------------------------------------------------------------

mail_list <- mail_list %>%
  dtplyr::lazy_dt() %>%
  # Send emails via blastula::smtp_send(), which returns NULL when an email is successfully sent
  # Create a new column "outcome" to track whether emails are sent successfully
  # The sent emails are a "side-effect" of the function
  dplyr::mutate(
    outcome = purrr::pmap(
      # Arguments to pass on to blastula::smtp_send()
      .l = list(email = email, to = address),
      .f = smtp_send,
      # Additional constant arguments
      from = "yangwu2020@gmail.com",
      subject = "Automated Email Test Run",
      credentials = blastula::creds_file("gmail_credentials")
    )
  ) %>%
  tibble::as_tibble()
