#!/usr/local/bin/Rscript
#
# This script is used to set up a user-level library when a new major/minor version of R is installed, which does 
# not automatically port over the packages we have installed in the previous R version. 
#
# The script can be run from the command line--- `Rscript -q -e path/to/setup_user_lib.R --old_r_version x.x` --- for
# MacOS and  Linux. The `Rscript` scripting front-end should come with every new R installation. For more information, 
# see section '3.7 Package libraries' of Hadley Wickham's R package (2e): https://r-pkgs.org/structure.html#sec-library 
# and the 'Running R in batch mode on Linux' blog post: https://www.cureffi.org/2014/01/15/running-r-batch-mode-linux/. 
#
# Note: this script also depends on the argparse package, and so it requires a Python binary on the host system.
#
# Install some starter package into the user library ----------------------

cat("Creating user library directory", Sys.getenv("R_LIBS_USER"), '\n')
dir.create(path = Sys.getenv("R_LIBS_USER"), showWarnings = FALSE, recursive = TRUE)

# The first element of .libPaths() is the user library path
cat("Installing starter package into user library \n")
install.packages(pkgs = c("argparse", "rlang", "usethis", "devtools"), lib = .libPaths()[[1]], repos = "https://cloud.r-project.org")
suppressPackageStartupMessages(library("argparse"))

# Parse command line arguments -------------------------------------------

new_r_version <- as.double(sub("\\.\\d+$", "", paste0(R.version[["major"]], ".", R.version[["minor"]])))
parser <- ArgumentParser(description = paste0("Set up a user-level library for R version ", new_r_version))
parser$add_argument("--old_r_version", type = "character", required = TRUE,  help = "Old R version number from which to copy packages")
args <- parser$parse_args()

# Port over packages from the old version --------------------------------

old_pkgs <- list.files(paste0("~/Library/R/x86_64/", args$old_r_version,"/library"))
cat("Installing packages from old R version", args$old_r_version, "into new user library for R version", new_r_version, "\n")
install.packages(pkgs=old_pkgs, lib=.libPaths()[[1]], repos = "https://cloud.r-project.org")
cat("Finished setting up user library for R version", new_r_version, "\n")