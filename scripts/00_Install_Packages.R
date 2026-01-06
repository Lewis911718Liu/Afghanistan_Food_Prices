# -------------------------------------------------------------------
# Script: 00_Install_Packages.R
# Purpose: Automatically detect and install all R packages required for this project.
# How to run: Open this file in RStudio, Select All (Ctrl+A), and click 'Run'.
# -------------------------------------------------------------------

# 1. Define the "Recipe List" of required packages
required_packages <- c(
  "tidyverse",    # Core data science suite (includes ggplot2, dplyr, readr, etc.)
  "lubridate",    # For easy date and time manipulation
  "zoo",          # For rolling averages and irregular time series
  "forecast",     # For ARIMA/ETS modeling and forecasting
  "tsibble",      # Tidy data structures for time series
  "changepoint",  # For detecting structural changes in time series
  "xgboost",      # Extreme Gradient Boosting (Machine Learning)
  "caret"         # For data splitting and model training workflows
)

# 2. Function to check and install missing packages
install_if_missing <- function(p) {
  if (!requireNamespace(p, quietly = TRUE)) {
    message(paste("Installing package:", p))
    install.packages(p, dependencies = TRUE)
  } else {
    message(paste("Already installed:", p))
  }
}

# Execute the installation function for the list
invisible(lapply(required_packages, install_if_missing))

# 3. Print success message
message("------------------------------------------------")
message("🎉 Environment setup complete! All required packages are ready.")
message("------------------------------------------------")