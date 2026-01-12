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

## 🚀 Quick Start Guide

Ready to reproduce the analysis? Here is your step-by-step roadmap.

### 🛠 Step 1: Installation
First, clone the repo or download the ZIP file. Then, initialize your R environment by running the installer script:

> 📂 **Open:** `scripts/00_Install_Packages.R`
>
> ▶️ **Action:** Run the full script to install `tidyverse`, `xgboost`, and other dependencies.

### 📊 Step 2: Execution Pipeline
Run the analysis scripts in this specific sequence:

| Order | Analysis Type | File Path | Outcome |
| :--- | :--- | :--- | :--- |
| **1** | **Linear Regression** | `scripts/Assignment_2_...R` | Check statistical significance of price/inflation. |
| **2** | **XGBoost Model** | `scripts/Temporal_Analysis.R` | Train model & view Feature Importance. |
| **3** | **Time Series** | `scripts/Time_Series_...R` | Generate ARIMA forecasts & anomaly detection. |

> **💡 Note:** We have set the random seed to `123` to ensure you get the exact same results as shown in the report.

## 📊 Data Source & Methodology
Data: The primary dataset contains daily/monthly food price indices and inflation rates for Afghanistan.

Preprocessing: Missing values in inflation data were handled using linear interpolation (for Time Series) or removal (for Regression), documented within the scripts.

Reproducibility: A fixed random seed (set.seed(123)) is used in machine learning scripts to ensure that training/testing splits and model results are identical on every run.

## 👤 Author
Project Team: [LIU YIQIAN / WQD7001 GA12]

Date: 6th January 2026
