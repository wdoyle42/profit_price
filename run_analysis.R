# run_analysis.R
# Master script to run the entire analysis pipeline

# This script runs all analysis steps in sequence:
# 1. Data collection
# 2. Data processing
# 3. Time series modeling
# 4. Generate the main analysis report

cat("========================================\n")
cat("For-Profit University Stock Analysis\n")
cat("========================================\n\n")

# Check for required packages
required_packages <- c(
  "tidyverse", "quantmod", "tseries", "forecast", 
  "lubridate", "knitr", "rmarkdown", "zoo"
)

missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, repos = "https://cloud.r-project.org/")
}

# Step 1: Data Collection
cat("\n[Step 1/4] Collecting stock price data...\n")
cat("--------------------\n")
source("scripts/01_data_collection.R")

# Step 2: Data Processing
cat("\n[Step 2/4] Processing data and creating features...\n")
cat("--------------------\n")
source("scripts/02_data_processing.R")

# Step 3: Time Series Modeling
cat("\n[Step 3/4] Running time series models and event studies...\n")
cat("--------------------\n")
source("scripts/03_time_series_models.R")

# Step 4: Generate Main Analysis Report
cat("\n[Step 4/4] Generating analysis report...\n")
cat("--------------------\n")

# Check if pandoc is available (required for R Markdown)
if (Sys.which("pandoc") == "") {
  cat("Warning: pandoc not found. Cannot generate PDF/HTML reports.\n")
  cat("You can still run the analysis and view the .Rmd file in RStudio.\n")
} else {
  tryCatch({
    rmarkdown::render(
      "analysis/main_analysis.Rmd",
      output_format = "all"
    )
    cat("\nAnalysis report generated successfully!\n")
    cat("Check the analysis/ directory for output files.\n")
  }, error = function(e) {
    cat("Error generating report:", e$message, "\n")
    cat("You can open analysis/main_analysis.Rmd in RStudio to knit it manually.\n")
  })
}

cat("\n========================================\n")
cat("Analysis pipeline completed!\n")
cat("========================================\n")
cat("\nOutput files created:\n")
cat("- data/raw/stock_prices.rds\n")
cat("- data/processed/stock_processed.rds\n")
cat("- output/arima_models.rds\n")
cat("- output/event_study_*.rds\n")
cat("- output/car_*.rds\n")
cat("- analysis/main_analysis.html (if pandoc available)\n")
cat("- analysis/main_analysis.pdf (if pandoc and LaTeX available)\n")
