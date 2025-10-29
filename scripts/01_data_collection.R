# 01_data_collection.R
# Script to collect stock price data for for-profit university companies

# Load required libraries
library(quantmod)
library(tidyverse)
library(lubridate)

# Create data directories if they don't exist
if (!dir.exists("data/raw")) {
  dir.create("data/raw", recursive = TRUE)
}

# Define stock symbols for for-profit university companies
# LOPE - Grand Canyon Education, Inc.
# STRA - Strategic Education, Inc.
# APEI - American Public Education, Inc.
# ATGE - Adtalem Global Education Inc.

stock_symbols <- c("LOPE", "STRA", "APEI", "ATGE")

# Define date range for analysis
# Starting from 2010 to capture multiple election cycles
start_date <- "2010-01-01"
end_date <- Sys.Date()

# Function to download stock data
download_stock_data <- function(symbol, start, end) {
  tryCatch({
    cat("Downloading data for", symbol, "...\n")
    
    # Download data from Yahoo Finance
    stock_data <- getSymbols(
      symbol,
      src = "yahoo",
      from = start,
      to = end,
      auto.assign = FALSE
    )
    
    # Convert to data frame
    df <- data.frame(
      date = index(stock_data),
      open = as.numeric(Op(stock_data)),
      high = as.numeric(Hi(stock_data)),
      low = as.numeric(Lo(stock_data)),
      close = as.numeric(Cl(stock_data)),
      volume = as.numeric(Vo(stock_data)),
      adjusted = as.numeric(Ad(stock_data))
    )
    
    df$symbol <- symbol
    
    return(df)
    
  }, error = function(e) {
    cat("Error downloading", symbol, ":", e$message, "\n")
    return(NULL)
  })
}

# Download data for all stocks
stock_data_list <- lapply(stock_symbols, function(symbol) {
  download_stock_data(symbol, start_date, end_date)
})

# Combine all stock data
all_stock_data <- bind_rows(stock_data_list)

# Save raw data
saveRDS(all_stock_data, "data/raw/stock_prices.rds")
write.csv(all_stock_data, "data/raw/stock_prices.csv", row.names = FALSE)

cat("\nData collection complete!\n")
cat("Downloaded", nrow(all_stock_data), "observations for", 
    length(unique(all_stock_data$symbol)), "companies\n")

# Create a summary of the data
summary_stats <- all_stock_data %>%
  group_by(symbol) %>%
  summarise(
    start_date = min(date),
    end_date = max(date),
    n_observations = n(),
    mean_price = mean(adjusted, na.rm = TRUE),
    min_price = min(adjusted, na.rm = TRUE),
    max_price = max(adjusted, na.rm = TRUE)
  )

print(summary_stats)

# Save summary
write.csv(summary_stats, "data/raw/data_summary.csv", row.names = FALSE)
