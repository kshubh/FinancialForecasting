# Question 1(f)
# Clear environment
rm(list=ls())

# Load required libraries
library(ggplot2)
library(readxl)

# Custom ETS(AAA) function without using built-in ets() function
ets_aaa <- function(y, alpha, beta, gamma, m, h = 7) {
  n <- length(y)
  
  # Initialize vectors for level, trend, seasonality, fitted values, and errors
  level <- numeric(n)
  trend <- numeric(n)
  season <- numeric(n + m)
  fitted <- numeric(n)
  errors <- numeric(n)
  
  # Set initial values
  level[1] <- y[1]
  trend[1] <- y[2] - y[1]
  season[1:m] <- rep(mean(y[1:m]), m)  # Initialize season with first cycle mean
  
  # Recursive calculations for ETS(AAA)
  for (t in (m + 1):n) {
    # Forecast for time t
    fitted[t] <- level[t - 1] + trend[t - 1] + season[t - m]
    
    # Error calculation
    errors[t] <- y[t] - fitted[t]
    
    # Update level, trend, and seasonal components
    level[t] <- level[t - 1] + trend[t - 1] + alpha * errors[t]
    trend[t] <- trend[t - 1] + beta * errors[t]
    season[t] <- season[t - m] + gamma * errors[t]
  }
  
  # Forecasting for h periods ahead
  forecasts <- numeric(h)
  for (i in 1:h) {
    forecasts[i] <- level[n] + i * trend[n] + season[n + i - m]
  }
  
  # Return the fitted values, errors, and forecasts
  list(fitted = fitted[(m + 1):n], errors = errors[(m + 1):n], forecasts = forecasts)
}

# Load the data
file_path <- "Q1_data.xlsx"
data <- read_excel(file_path, sheet = 1)

# Filter out rows with unexpected data
data <- data[!is.na(as.numeric(data$Currency_in_Circulation)) & !is.na(as.Date(data$Date, format = "%Y-%m-%d")), ]

# Convert 'Currency_in_Circulation' to numeric and handle any non-numeric values
data$Currency_in_Circulation <- as.numeric(data$Currency_in_Circulation)

# Convert 'Date' to Date format and correct any erroneous year entries
data$Date <- as.Date(data$Date, format = "%Y-%m-%d")
data$Date <- ifelse(format(data$Date, "%Y") == "1922", 
                    as.Date(sub("1922", "2022", as.character(data$Date)), format = "%Y-%m-%d"),
                    data$Date)
data$Date <- as.Date(data$Date)  # Ensure Date type

# Drop rows with NA values
data <- na.omit(data)

# Set parameters for the ETS(AAA) model
alpha <- 0.3    # Smoothing parameter for level
beta <- 0.1     # Smoothing parameter for trend
gamma <- 0.2    # Smoothing parameter for seasonality
m <- 365        # Seasonality (daily data with yearly seasonality)
h <- 7          # Forecast horizon

# Apply the ETS(AAA) model to the 'Currency_in_Circulation' data
result <- ets_aaa(data$Currency_in_Circulation, alpha, beta, gamma, m, h)

# Create extended date range for forecast
forecast_dates <- seq(from = max(data$Date) + 1, by = "days", length.out = h)

# Plot the actual data with fitted values and forecast
plot(data$Date, data$Currency_in_Circulation, type = "l", main = "ETS(AAA) Model",
     ylab = "Currency in Circulation", xlab = "Date", col = "black")
lines(data$Date[(m + 1):nrow(data)], result$fitted, col = "blue", lty = 2)
points(forecast_dates, result$forecasts, col = "red", pch = 19)
legend("bottomright", legend = c("Actual", "Fitted", "Forecast"), col = c("black", "blue", "red"), 
       lty = c(1, 2, NA), pch = c(NA, NA, 19))
