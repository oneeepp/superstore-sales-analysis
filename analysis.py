"""
Superstore Sales Analysis - Python/Pandas
Cross-validation of the same business questions answered in SQL.
Data source: Sample Superstore dataset (Kaggle)
"""

import pandas as pd

df = pd.read_csv("SampleSuperstore.csv")

# Data quality check: confirm no missing values before analysis
print("Missing values per column:")
print(df.isnull().sum())
print("\nDataset shape:", df.shape)


# Q1: Total sales by region
print("\n--- Q1: Total sales by region ---")
print(df.groupby("Region")["Sales"].sum().sort_values(ascending=False))

# Q2: verage profit by costomer segment
print("\n--- Q2: Average profit by segment ---")
print(df.groupby("Segment")["Profit"].mean().sort_values(ascending=False))

# Q3: Sales and profit by sub-category
print("\n--- Q3: Sales and profit by sub-category ---")
print(df.groupby("Sub-Category")[["Sales", "Profit"]].sum())

# Q4 & Q5: Profit margin and average discount rate by sub-category
print("\n--- Q4 & Q5: Profit margin vs discount rate ---")
sub_category_stats = df.groupby("Sub-Category")[["Sales", "Profit"]].sum()
sub_category_stats["Profit Margin %"] = (sub_category_stats["Profit"] /
                                         sub_category_stats["Sales"] * 100).round(2)
sub_category_stats["Avg Discount"] = df.groupby(
    "Sub-Category")["Discount"].mean().round(3)
print(sub_category_stats.sort_values("Profit Margin %"))

# Q7: Which state has the largest total loss
print("\n--- Q7: States with the largest losses ---")
print(df.groupby("State")["Profit"].sum().sort_values().head(10))
