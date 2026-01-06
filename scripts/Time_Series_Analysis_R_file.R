getwd()
############################################
# 0) Install and load required packages
############################################

# Set reliable CRAN mirror (helps in corporate networks)
options(repos = c(CRAN = "https://cloud.r-project.org"))

# Install if not already present
pkgs <- c("tidyverse","lubridate","zoo","forecast","tsibble","changepoint","ggplot2")
to_install <- pkgs[!pkgs %in% installed.packages()[,"Package"]]
if(length(to_install)) install.packages(to_install, dependencies = TRUE)

# Load
library(tidyverse)
library(lubridate)
library(zoo)
library(forecast)
library(tsibble)
library(changepoint)
library(ggplot2)

# If 'forecast' fails to load, try:
# install.packages("forecast", dependencies = TRUE)
# library(forecast)

############################################
# 1) Load data and parse dates
############################################

# Adjust the path/filename if needed
df <- read_csv("data/Dataset11.csv",
               col_types = cols(
                 Open = col_double(),
                 High = col_double(),
                 Low  = col_double(),
                 Close = col_double(),
                 Inflation = col_double(),
                 CountryName = col_character(),
                 ISO3 = col_character(),
                 Date = col_character()
               ))

# Dates are DD-MM-YYYY (e.g., "01-01-2007")
df <- df %>%
  mutate(Date = dmy(Date)) %>%
  arrange(Date)

############################################
# 2) Impute inflation NAs and smooth
############################################

# Linear interpolation across time; then a small moving average smooth
df <- df %>%
  mutate(Inflation = na.approx(Inflation, x = Date, na.rm = FALSE)) %>%
  mutate(Inflation_s = rollapply(Inflation, 3, mean, align = "right", fill = NA))

############################################
# 3) Feature engineering
############################################

df <- df %>%
  mutate(
    pct_change   = (Close / lag(Close) - 1) * 100,
    realized_vol = (High - Low) / Close,
    infl_lag1    = lag(Inflation_s, 1),
    vol_lag1     = lag(realized_vol, 1)
  ) %>%
  drop_na(Close, infl_lag1, vol_lag1)

############################################
# 4) Train/test split (train: 2007–2022, test: 2023)
############################################

train <- df %>% filter(year(Date) <= 2022)
test  <- df %>% filter(year(Date) == 2023)

y_train <- ts(train$Close, frequency = 12,
              start = c(year(min(train$Date)), month(min(train$Date))))
y_test  <- test$Close

xreg_train <- as.matrix(train %>% select(infl_lag1, vol_lag1))
xreg_test  <- as.matrix(test  %>% select(infl_lag1, vol_lag1))

############################################
# 5) Baseline models (ETS, ARIMA) and ARIMAX
############################################

fit_ets   <- ets(y_train)
fit_arima <- auto.arima(y_train, seasonal = TRUE, stepwise = FALSE, approximation = FALSE)

fit_arimax <- auto.arima(y_train, xreg = xreg_train,
                         seasonal = TRUE, stepwise = FALSE, approximation = FALSE)

############################################
# 6) Backtest on 2023
############################################

h <- length(y_test)
f_ets    <- forecast(fit_ets, h = h)
f_arima  <- forecast(fit_arima, h = h)
f_arimax <- forecast(fit_arimax, xreg = xreg_test, h = h)

rmse <- function(actual, pred) sqrt(mean((actual - pred)^2))
mape <- function(actual, pred) mean(abs((actual - pred) / actual)) * 100

metrics <- tibble(
  model = c("ETS","ARIMA","ARIMAX"),
  RMSE  = c(rmse(y_test, as.numeric(f_ets$mean)),
            rmse(y_test, as.numeric(f_arima$mean)),
            rmse(y_test, as.numeric(f_arimax$mean))),
  MAPE  = c(mape(y_test, as.numeric(f_ets$mean)),
            mape(y_test, as.numeric(f_arima$mean)),
            mape(y_test, as.numeric(f_arimax$mean)))
)
print(metrics)

# Choose best model (by RMSE here)
best_model_name <- metrics$model[which.min(metrics$RMSE)]
message("Best model by RMSE: ", best_model_name)

############################################
# 7) Fit final model on full history (prefer ARIMAX; switch if needed)
############################################

y_full <- ts(df$Close, frequency = 12,
             start = c(year(min(df$Date)), month(min(df$Date))))

xreg_full <- as.matrix(df %>% select(infl_lag1, vol_lag1))
# Fix any leading/trailing NAs in xreg_full
xreg_full <- xreg_full %>%
  zoo::na.locf(na.rm = FALSE, fromLast = FALSE) %>%
  zoo::na.locf(na.rm = FALSE, fromLast = TRUE)

# If best_model_name != "ARIMAX", you can fit ets/auto.arima without xreg
fit_final <- auto.arima(y_full, xreg = xreg_full,
                        seasonal = TRUE, stepwise = FALSE, approximation = FALSE)

############################################
# 8) Create future exogenous scenarios and forecast 12 months
############################################

future_months <- 12
last_date <- max(df$Date)
future_dates <- seq(last_date %m+% months(1), by = "month", length.out = future_months)

# Scenario: hold last lagged values (replace with shocks for stress-testing)
future_xreg <- tibble(
  Date = future_dates,
  infl_lag1 = tail(df$Inflation_s, 1),
  vol_lag1  = tail(df$realized_vol, 1)
) %>%
  select(infl_lag1, vol_lag1) %>%
  as.matrix()

f_final <- forecast(fit_final, xreg = future_xreg, h = future_months)

fc_tbl <- tibble(
  Date = future_dates,
  fc_close = as.numeric(f_final$mean),
  fc_lower80 = as.numeric(f_final$lower[,1]),
  fc_upper80 = as.numeric(f_final$upper[,1]),
  fc_lower95 = as.numeric(f_final$lower[,2]),
  fc_upper95 = as.numeric(f_final$upper[,2])
) %>%
  mutate(fc_pct_change = (fc_close / lag(fc_close) - 1) * 100)

print(fc_tbl)

############################################
# 9) Early crisis detection (alerts)
############################################

# Residual baseline from training ARIMAX (robust to trend/season)
residuals_train <- y_train - fitted(fit_arimax)
resid_sd <- sd(residuals_train, na.rm = TRUE)

# Short moving average baseline for z-score (on forecasts)
ma3 <- stats::filter(fc_tbl$fc_close, rep(1/3,3), sides = 1)

alerts <- fc_tbl %>%
  mutate(
    resid_z    = (fc_close - as.numeric(ma3)) / resid_sd,
    surge_flag = fc_pct_change > 8,
    drop_flag  = fc_pct_change < -8,
    alert_level = case_when(
      surge_flag ~ "Warning: Price surge",
      drop_flag  ~ "Warning: Price drop",
      abs(resid_z) > 2 ~ "Watch: Residual anomaly",
      TRUE ~ "Normal"
    )
  )

# Change-point detection on forecast trajectory
cpt <- changepoint::cpt.meanvar(ts(alerts$fc_close, frequency = 12), method = "PELT")
change_points <- cpts(cpt)

alerts <- alerts %>%
  mutate(change_point = row_number() %in% change_points)

print(alerts)

############################################
# 10) Visualizations
############################################

# Forecast line with uncertainty
autoplot(f_final) +
  labs(title = "12-month Close Price Forecast", y = "Price", x = "Date")

# Overlay alerts
ggplot(alerts, aes(Date, fc_close)) +
  geom_line(color = "#2c7fb8") +
  geom_ribbon(aes(ymin = fc_lower95, ymax = fc_upper95), alpha = 0.15, fill = "#a6bddb") +
  geom_point(data = alerts %>% filter(surge_flag | drop_flag | abs(resid_z) > 2),
             aes(Date, fc_close, color = alert_level), size = 3) +
  scale_color_manual(values = c("Warning: Price surge" = "red",
                                "Warning: Price drop"  = "orange",
                                "Watch: Residual anomaly" = "purple",
                                "Normal" = "grey50")) +
  labs(title = "Forecast with Early Crisis Alerts", y = "Price", x = "Date", color = "Alert") +
  theme_minimal()

############################################
# 11) (Optional) Stress-testing scenarios
############################################

# Example: inflation shock (+3 points) and volatility +30% for next 12 months
future_xreg_shock <- tibble(
  infl_lag1 = rep(tail(df$Inflation_s, 1) + 3, future_months),
  vol_lag1  = rep(tail(df$realized_vol, 1) * 1.3, future_months)
) %>% as.matrix()

f_shock <- forecast(fit_final, xreg = future_xreg_shock, h = future_months)
autoplot(f_shock) + labs(title = "Shock Scenario Forecast", y = "Price", x = "Date")

############################################
# 12) Save outputs (CSV for dashboards)
############################################

write_csv(metrics, "model_backtest_metrics.csv")
write_csv(fc_tbl, "forecast_table.csv")
write_csv(alerts, "forecast_alerts.csv")
