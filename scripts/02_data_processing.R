# 02_data_processing.R
# Script to process stock data and prepare for analysis

# Load required libraries
library(tidyverse)
library(lubridate)

# Create processed data directory if it doesn't exist
if (!dir.exists("data/processed")) {
  dir.create("data/processed", recursive = TRUE)
}

# Load raw stock data
stock_data <- readRDS("data/raw/stock_prices.rds")

# Data processing and feature engineering
stock_processed <- stock_data %>%
  arrange(symbol, date) %>%
  group_by(symbol) %>%
  mutate(
    # Calculate returns
    daily_return = (adjusted - lag(adjusted)) / lag(adjusted),
    log_return = log(adjusted) - log(lag(adjusted)),
    
    # Calculate moving averages
    ma_5 = zoo::rollmean(adjusted, k = 5, fill = NA, align = "right"),
    ma_20 = zoo::rollmean(adjusted, k = 20, fill = NA, align = "right"),
    ma_50 = zoo::rollmean(adjusted, k = 50, fill = NA, align = "right"),
    
    # Volatility (rolling standard deviation of returns)
    volatility_20 = zoo::rollapply(
      daily_return, 
      width = 20, 
      FUN = sd, 
      fill = NA, 
      align = "right",
      na.rm = TRUE
    ),
    
    # Price momentum
    momentum_5 = (adjusted - lag(adjusted, 5)) / lag(adjusted, 5),
    momentum_20 = (adjusted - lag(adjusted, 20)) / lag(adjusted, 20)
  ) %>%
  ungroup()

# Add date-related features
stock_processed <- stock_processed %>%
  mutate(
    year = year(date),
    month = month(date),
    quarter = quarter(date),
    day_of_week = wday(date, label = TRUE),
    is_month_start = date == floor_date(date, "month"),
    is_month_end = date == ceiling_date(date, "month") - days(1),
    is_quarter_start = date == floor_date(date, "quarter"),
    is_quarter_end = date == ceiling_date(date, "quarter") - days(1)
  )

# Create event dataset for key political/policy events
# These are major events that could impact for-profit education stocks
events <- tribble(
  ~event_date, ~event_type, ~event_description,
  "2008-11-04", "election", "2008 Presidential Election - Obama wins",
  "2009-01-20", "inauguration", "Obama inaugurated",
  "2009-05-02", "appointment", "Arne Duncan becomes Secretary of Education",
  "2010-11-02", "election", "2010 Midterm Elections",
  "2012-11-06", "election", "2012 Presidential Election - Obama re-elected",
  "2014-11-04", "election", "2014 Midterm Elections",
  "2015-10-01", "policy", "Gainful Employment Rule implementation",
  "2016-11-08", "election", "2016 Presidential Election - Trump wins",
  "2017-01-20", "inauguration", "Trump inaugurated",
  "2017-02-07", "appointment", "Betsy DeVos becomes Secretary of Education",
  "2018-11-06", "election", "2018 Midterm Elections",
  "2019-07-01", "policy", "Borrower Defense Rule changes",
  "2020-11-03", "election", "2020 Presidential Election - Biden wins",
  "2021-01-20", "inauguration", "Biden inaugurated",
  "2021-03-02", "appointment", "Miguel Cardona becomes Secretary of Education",
  "2022-11-08", "election", "2022 Midterm Elections",
  "2023-10-01", "policy", "New Gainful Employment regulations"
) %>%
  mutate(event_date = as.Date(event_date))

# Create event windows (e.g., +/- 10 days around each event)
event_windows <- events %>%
  rowwise() %>%
  mutate(
    window_start = event_date - days(10),
    window_end = event_date + days(10)
  ) %>%
  ungroup()

# Flag observations that fall within event windows
stock_processed <- stock_processed %>%
  mutate(in_event_window = FALSE)

for (i in 1:nrow(event_windows)) {
  stock_processed <- stock_processed %>%
    mutate(
      in_event_window = in_event_window | 
        (date >= event_windows$window_start[i] & 
         date <= event_windows$window_end[i])
    )
}

# Save processed data
saveRDS(stock_processed, "data/processed/stock_processed.rds")
saveRDS(events, "data/processed/events.rds")
saveRDS(event_windows, "data/processed/event_windows.rds")

# Create summary statistics
cat("\n=== Data Processing Summary ===\n")
cat("Total observations:", nrow(stock_processed), "\n")
cat("Date range:", min(stock_processed$date), "to", max(stock_processed$date), "\n")
cat("Companies:", paste(unique(stock_processed$symbol), collapse = ", "), "\n")
cat("Key events tracked:", nrow(events), "\n")

# Summary by company
company_summary <- stock_processed %>%
  group_by(symbol) %>%
  summarise(
    n_obs = n(),
    mean_return = mean(daily_return, na.rm = TRUE),
    sd_return = sd(daily_return, na.rm = TRUE),
    mean_volatility = mean(volatility_20, na.rm = TRUE)
  )

print(company_summary)

cat("\nProcessed data saved to data/processed/\n")
