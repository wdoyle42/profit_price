# 03_time_series_models.R
# Script for time series modeling and event study analysis

# Load required libraries
library(tidyverse)
library(forecast)
library(tseries)
library(lubridate)

# Create output directories if they don't exist
if (!dir.exists("output/figures")) {
  dir.create("output/figures", recursive = TRUE)
}
if (!dir.exists("output/tables")) {
  dir.create("output/tables", recursive = TRUE)
}

# Load processed data
stock_data <- readRDS("data/processed/stock_processed.rds")
events <- readRDS("data/processed/events.rds")
event_windows <- readRDS("data/processed/event_windows.rds")

# Function to perform ARIMA analysis for a given stock
fit_arima_model <- function(data, symbol_name) {
  cat("\n=== ARIMA Model for", symbol_name, "===\n")
  
  # Filter data for specific symbol
  stock_ts <- data %>%
    filter(symbol == symbol_name) %>%
    arrange(date)
  
  # Create time series object (using adjusted prices)
  ts_data <- ts(stock_ts$adjusted, frequency = 252) # 252 trading days per year
  
  # Check stationarity with ADF test
  adf_test <- adf.test(ts_data, alternative = "stationary")
  cat("ADF Test p-value:", adf_test$p.value, "\n")
  
  # If not stationary, use differenced series
  if (adf_test$p.value > 0.05) {
    cat("Series is non-stationary, using first difference\n")
    ts_data <- diff(ts_data)
  }
  
  # Fit ARIMA model
  arima_model <- auto.arima(ts_data, seasonal = FALSE)
  cat("ARIMA model:\n")
  print(summary(arima_model))
  
  # Forecast
  forecast_result <- forecast(arima_model, h = 30) # 30 days ahead
  
  return(list(
    model = arima_model,
    forecast = forecast_result,
    adf_test = adf_test
  ))
}

# Function to perform event study analysis
event_study_analysis <- function(data, events_df, event_type = NULL) {
  # Filter events if type specified
  if (!is.null(event_type)) {
    events_df <- events_df %>% filter(event_type == !!event_type)
  }
  
  results <- list()
  
  for (i in 1:nrow(events_df)) {
    event <- events_df[i, ]
    
    # Define event window (-10 to +10 days)
    window_start <- event$event_date - days(10)
    window_end <- event$event_date + days(10)
    
    # Extract data for event window
    event_window_data <- data %>%
      filter(date >= window_start & date <= window_end) %>%
      mutate(
        days_from_event = as.numeric(date - event$event_date),
        event_id = i
      )
    
    results[[i]] <- event_window_data
  }
  
  # Combine all event windows
  combined_results <- bind_rows(results)
  
  # Calculate average abnormal returns
  abnormal_returns <- combined_results %>%
    group_by(symbol, days_from_event) %>%
    summarise(
      mean_return = mean(daily_return, na.rm = TRUE),
      median_return = median(daily_return, na.rm = TRUE),
      n = n(),
      .groups = "drop"
    )
  
  return(list(
    event_windows = combined_results,
    abnormal_returns = abnormal_returns
  ))
}

# Run ARIMA models for each stock
arima_results <- list()
for (symbol in unique(stock_data$symbol)) {
  arima_results[[symbol]] <- fit_arima_model(stock_data, symbol)
}

# Save ARIMA results
saveRDS(arima_results, "output/arima_models.rds")

# Event study analysis
cat("\n=== Event Study Analysis ===\n")

# All events
all_events_study <- event_study_analysis(stock_data, events)
saveRDS(all_events_study, "output/event_study_all.rds")

# Elections only
election_study <- event_study_analysis(stock_data, events, "election")
saveRDS(election_study, "output/event_study_elections.rds")

# Policy changes only
policy_study <- event_study_analysis(stock_data, events, "policy")
saveRDS(policy_study, "output/event_study_policy.rds")

# Appointments only
appointment_study <- event_study_analysis(stock_data, events, "appointment")
saveRDS(appointment_study, "output/event_study_appointments.rds")

cat("\nEvent study results:\n")
cat("- All events:", nrow(all_events_study$event_windows), "observations\n")
cat("- Election events:", nrow(election_study$event_windows), "observations\n")
cat("- Policy events:", nrow(policy_study$event_windows), "observations\n")
cat("- Appointment events:", nrow(appointment_study$event_windows), "observations\n")

# Calculate cumulative abnormal returns (CAR)
calculate_car <- function(event_study_results) {
  car <- event_study_results$abnormal_returns %>%
    arrange(symbol, days_from_event) %>%
    group_by(symbol) %>%
    mutate(
      cumulative_return = cumsum(mean_return)
    ) %>%
    ungroup()
  
  return(car)
}

car_all <- calculate_car(all_events_study)
car_elections <- calculate_car(election_study)
car_policy <- calculate_car(policy_study)
car_appointments <- calculate_car(appointment_study)

# Save CAR results
saveRDS(car_all, "output/car_all_events.rds")
saveRDS(car_elections, "output/car_elections.rds")
saveRDS(car_policy, "output/car_policy.rds")
saveRDS(car_appointments, "output/car_appointments.rds")

# Print summary statistics
cat("\n=== Cumulative Abnormal Returns Summary ===\n")
print(car_all %>% 
        filter(days_from_event == 10) %>% 
        select(symbol, cumulative_return))

cat("\nAll time series models and event studies saved to output/\n")
