# Check R version ---------------------------------------------------------

# This is a variable (a list) holding detailed information about the version of R running
R.version

# Edit environment variable 'R_LIBS_USER' ---------------------------------

# This is by default set to ‘Library/R/R.version$arch/x.y/library’ for CRAN macOS builds
# This function opens the configuration file for edit
usethis::edit_r_environ()

# Check current library trees within which packages are searched for
# R_LIBS_USER features possible expansion of specifiers for R version specific information
# Read the documentation ?.libPaths() to get currently available conversion specifications
# This should return a character vector of file paths of all libraries
.libPaths()

# Obtain values of 'R_LIBS_USER'
# Modify if need be (especially when upgrading R for a change in the minor version)
# Minor version is represented by the 'y' in 'x.y.z' (e.g. '4.1.2')
# Patch release is represented by the 'z' 'x.y.z' 
# Read the documentation ?Sys.getenv() to get the ‘environment variables’ list
Sys.getenv("R_LIBS_USER")

# Creates the new directory associated with a specific version of R
# The packages will be re-installed in this new directory
fs::dir_create(Sys.getenv("R_LIBS_USER"))


# List of packages installed in all libraries known to .libPaths() --------

lapply(.libPaths(), list.dirs, recursive = FALSE, full.names = FALSE)

# Core set of base and recommended packages -------------------------------

core <- c(
  "base","boot", "class", "cluster", "codetools", "compiler", "datasets", "foreign", 
  "graphics", "grDevices", "grid", "KernSmooth", "lattice", "MASS", "Matrix", "methods", 
  "mgcv", "nlme", "nnet", "parallel", "rpart", "spatial", "splines", "stats", "stats4", 
  "survival", "tcltk", "tools", "translations", "utils"
)

# List of add-on packages in previous library -----------------------------

# Change the file path in dir_ls() as necessary
pkgs <- fs::path_file(fs::dir_ls("/Library/Frameworks/R.framework/Versions/4.1/Resources/library"))

# Install add-on packages in the new library ------------------------------

# Since the argument 'lib' is missing, this defaults to the first element of .libPaths()
# The first element of .libPaths() is our user library set using Sys.getenv("R_LIBS_USER")
# The actual directory is created via fs::dir_create(Sys.getenv("R_LIBS_USER"))
install.packages(pkgs)

# Further resources on setup https://rstats.wtf/maintaining-r.html --------