# Attach devtools and testhat in start-up .Rprofile file ------------------
if (interactive()) {
  # Welcome message
  message(paste0("Yo ", Sys.info()["user"], ", let's get rolling now!"))
  # Attach development packages
  suppressMessages(require(devtools))
  suppressMessages(require(testthat))
  suppressMessages(require(rlang))
  
  # Personal defaults -------------------------------------------------------
  options(
    usethis.full_name = "Yang Wu",
    usethis.description = list(
      `Authors@R` = 'person("Yang", "Wu", email = "yangwu2020@gmail.com", role = c("aut", "cre"),
      comment = c(ORCID = "0000-0001-9847-0112"))',
      License = "MIT + file LICENSE",
      Version = "0.0.0.9000"
    ),
    usethis.protocol = "ssh",
    error = rlang::entrace
  )
}
