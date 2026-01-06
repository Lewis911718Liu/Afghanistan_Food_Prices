# Afghanistan_Food_Prices
WQD7001 GA2 Project
# Analysis of Food Commodity Prices & Inflation in Afghanistan

## 📌 Project Overview
This project analyzes the relationship between food commodity prices (Open, High, Low, Close) and national inflation rates in Afghanistan. Using a hybrid modeling approach, we aim to identify temporal patterns, forecast future prices, and evaluate economic indicators.

The analysis is implemented in **R** and includes three main modeling techniques:
1.  **Linear Regression:** To understand the correlation between price indicators and inflation.
2.  **XGBoost (Machine Learning):** To capture non-linear patterns and feature importance.
3.  **Time Series Analysis (ARIMA/ETS):** To forecast future trends based on historical data.

---

## 📂 Repository Structure

The project is organized as follows to ensure reproducibility:

```text
├── data/
│   ├── Dataset11.csv          # Main dataset (Food prices & Inflation)
│   └── AFG_Dataset.csv        # Supplementary dataset
├── scripts/
│   ├── 00_Install_Packages.R  # 🛠 START HERE: Setup environment
│   ├── Time_Series_Analysis_R_file.R
│   ├── Temporal_Analysis.R    # XGBoost Implementation
│   └── Assignment_2_Linear_Regression_ML_Model.R
├── results/                   # Generated plots and outputs
└── README.md                  # Project documentation
 ```

## 🚀 How to Reproduce the Results
Step 1: Clone the Repository
Download this repository to your local machine using git clone or by downloading the ZIP file.

Step 2: Environment Setup
To ensure you have the correct R packages installed, open RStudio and run the setup script:

Open scripts/00_Install_Packages.R.

Run the entire script. (This will automatically install tidyverse, xgboost, forecast, caret, and other dependencies.)

Step 3: Run the Analysis
You can run the analysis scripts in the following order:

Linear Regression: * Open scripts/Assignment_2_Linear_Regression_ML_Model.R

Run to see the statistical significance of High/Low prices on Inflation.

Temporal Patterns (XGBoost):

Open scripts/Temporal_Analysis.R

Run to train the ML model and visualize Feature Importance.

Note: Random seed is set to 123 for consistent results.

Time Series Forecasting:

Open scripts/Time_Series_Analysis_R_file.R

Run to generate ARIMA forecasts and detect price anomalies.

## 📊 Data Source & Methodology
Data: The primary dataset contains daily/monthly food price indices and inflation rates for Afghanistan.

Preprocessing: Missing values in inflation data were handled using linear interpolation (for Time Series) or removal (for Regression), documented within the scripts.

Reproducibility: A fixed random seed (set.seed(123)) is used in machine learning scripts to ensure that training/testing splits and model results are identical on every run.

## 👤 Author
Project Team: [LIU YIQIAN / WQD7001 GA12]

Date: 6th January 2026
