getwd()
# -------------------------------
# 1. Load libraries
# -------------------------------
library(tidyverse)
library(lubridate)
library(zoo)
library(xgboost)

# -------------------------------
# 2. Load and prepare data
# -------------------------------
df <- read_csv("data/Dataset11.csv")

# Parse date
df <- df %>%
  mutate(Date = dmy(Date)) %>%
  arrange(Date)

# Fill missing inflation values (linear interpolation)
df$Inflation <- na.approx(df$Inflation, x = df$Date, na.rm = FALSE)

# -------------------------------
# 3. Feature engineering
# -------------------------------
df <- df %>%
  mutate(
    Month = month(Date),
    Year  = year(Date),
    # Lag features
    Close_lag1  = lag(Close, 1),
    Close_lag3  = lag(Close, 3),
    Close_lag6  = lag(Close, 6),
    Close_lag12 = lag(Close, 12),
    # Rolling statistics
    RollMean_3  = rollmean(Close, 3, fill = NA, align = "right"),
    RollMean_6  = rollmean(Close, 6, fill = NA, align = "right"),
    RollStd_6   = rollapply(Close, 6, sd, fill = NA, align = "right"),
    # Seasonality (harmonics)
    sin12 = sin(2*pi*Month/12),
    cos12 = cos(2*pi*Month/12)
  ) %>%
  drop_na()

# -------------------------------
# 4. Train/test split
# -------------------------------
split_date <- as_date("2022-01-01")
train <- df %>% filter(Date < split_date)
test  <- df %>% filter(Date >= split_date)

X_train <- train %>% select(Close_lag1, Close_lag3, Close_lag6, Close_lag12,
                            RollMean_3, RollMean_6, RollStd_6,
                            Inflation, sin12, cos12) %>% as.matrix()
y_train <- train$Close

X_test <- test %>% select(Close_lag1, Close_lag3, Close_lag6, Close_lag12,
                          RollMean_3, RollMean_6, RollStd_6,
                          Inflation, sin12, cos12) %>% as.matrix()
y_test <- test$Close

set.seed(123)

dtrain <- xgb.DMatrix(X_train, label = y_train)
dtest  <- xgb.DMatrix(X_test,  label = y_test)

# -------------------------------
# 5. Train XGBoost model
# -------------------------------
params <- list(
  objective = "reg:squarederror",
  eval_metric = "rmse",
  max_depth = 4,
  eta = 0.08,
  subsample = 0.8,
  colsample_bytree = 0.8
)

xgb_fit <- xgb.train(params, dtrain, nrounds = 500,
                     watchlist = list(train = dtrain, test = dtest),
                     early_stopping_rounds = 30, verbose = 0)

# -------------------------------
# 6. Evaluate performance
# -------------------------------
pred_test <- predict(xgb_fit, dtest)

rmse <- sqrt(mean((pred_test - y_test)^2))
mae  <- mean(abs(pred_test - y_test))
cat("RMSE:", rmse, "\nMAE:", mae, "\n")

# -------------------------------
# 7. Plot actual vs predicted
# -------------------------------
df_pred <- tibble(Date = test$Date, Actual = y_test, Pred = pred_test)

ggplot(df_pred, aes(Date)) +
  geom_line(aes(y = Actual, color = "Actual")) +
  geom_line(aes(y = Pred, color = "Pred")) +
  labs(title = "XGBoost: Actual vs Predicted Close Prices",
       y = "Close Price", color = "")
# View feature importance
importance <- xgb.importance(model = xgb_fit)
print(importance)

# Plot top features
xgb.plot.importance(importance_matrix = importance)
