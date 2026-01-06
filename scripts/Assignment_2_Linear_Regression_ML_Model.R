getwd()
# -------------------------------
# 1. Install and load packages
# -------------------------------
install.packages(c("tidyverse", "caret"), dependencies = TRUE)
library(tidyverse)
library(caret)

# -------------------------------
# 2. Load the dataset
# -------------------------------
data <- read.csv("AFG_Dataset.csv", header = TRUE, sep = ",")

# -------------------------------
# 3. Clean the data
# -------------------------------
# Remove rows with missing Inflation values
data_clean <- data %>% drop_na(Inflation)

# -------------------------------
# 4. Split into training and test sets
# -------------------------------
set.seed(123)  # for reproducibility
trainIndex <- createDataPartition(data_clean$Inflation, p = 0.8, list = FALSE)
trainData <- data_clean[trainIndex, ]
testData  <- data_clean[-trainIndex, ]

# -------------------------------
# 5. Fit linear regression model
# -------------------------------
lm_model <- lm(Inflation ~ Open + High + Low + Close, data = trainData)

# -------------------------------
# 6. Model summary
# -------------------------------
summary(lm_model)

# -------------------------------
# 7. Predict on test set
# -------------------------------
predictions <- predict(lm_model, newdata = testData)

# -------------------------------
# 8. Evaluate model performance
# -------------------------------
MAE <- mean(abs(predictions - testData$Inflation))
MSE <- mean((predictions - testData$Inflation)^2)
RMSE <- sqrt(MSE)

cat("MAE:", MAE, "\nMSE:", MSE, "\nRMSE:", RMSE, "\n")

# -------------------------------
# 9. Plot Actual vs Predicted
# -------------------------------
ggplot(data.frame(Actual = testData$Inflation, Predicted = predictions),
       aes(x = Actual, y = Predicted)) +
  geom_point(color = "blue", alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Actual vs Predicted Inflation",
       x = "Actual Inflation",
       y = "Predicted Inflation") +
  theme_minimal()
# Fit the linear regression model
lm_model <- lm(Inflation ~ Open + High + Low + Close, data = trainData)

# Show the summary of the model
summary(lm_model)
# Fit the linear regression model
lm_model <- lm(Inflation ~ Open + High + Low + Close, data = trainData)

# Show the coefficients (intercept + slopes)
coef(lm_model)

# Optionally, print the equation in a nice format
eq <- paste0(
  "Inflation = ",
  round(coef(lm_model)[1], 4), " + ",
  round(coef(lm_model)[2], 4), "*Open + ",
  round(coef(lm_model)[3], 4), "*High + ",
  round(coef(lm_model)[4], 4), "*Low + ",
  round(coef(lm_model)[5], 4), "*Close"
)

cat(eq)
