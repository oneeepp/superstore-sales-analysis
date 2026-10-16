# Superstore Sales & Profit Analysis

## Overview

This project analyzes the Sample Superstore dataset to examine sales and profit performance across products, with a focus on evaluating whether the current discount strategy is effective or contributing to losses.

## Tools Used

- MySQL (database)
- TablePlus (query tool)
- SQL (aggregate functions, window functions, subqueries, CASE expressions)

## Questions & Findings

### Part 1: Overview

#### Q1: What is the total sales amount for each region?

```sql
SELECT Region, ROUND(SUM(Sales), 2) AS total_sales
FROM SampleSuperstore_1
GROUP BY Region
ORDER BY total_sales DESC;
```

| Region | Total Sales |
|---|---|
| West | $725,458 |
| East | $678,781 |
| Central | $501,240 |
| South | $391,722 |

**Finding:** The West region generates the highest sales, nearly double that of the South region, which lags significantly behind.

---

#### Q2: What is the average profit per record for each customer segment?

```sql
SELECT Segment, ROUND(AVG(Profit), 2) AS avg_profit
FROM SampleSuperstore_1
GROUP BY Segment
ORDER BY avg_profit DESC;
```

| Segment | Avg Profit |
|---|---|
| Home Office | $33.82 |
| Corporate | $30.46 |
| Consumer | $25.84 |

**Finding:** Home Office orders are the most profitable on average, though the gap between segments is relatively small.

---

### Part 2: Which products lose money?

#### Q3: Which sub-category has the highest sales and profit?

```sql
SELECT `Sub-Category`, ROUND(SUM(Sales),2) AS total_sales, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;
```

| Sub-Category | Total Sales | Total Profit |
|---|---|---|
| Phones | $330,007 | $44,516 |
| Chairs | $328,449 | $26,590 |
| Storage | $223,844 | $21,279 |
| **Tables** | $206,966 | **-$17,725** |
| Binders | $203,413 | $30,222 |
| Copiers | $149,528 | $55,618 |
| Bookcases | $114,880 | **-$3,473** |
| Supplies | $46,674 | **-$1,189** |

**Finding:** Sales ranking and profit ranking do not match. Tables ranks 4th in sales but has the largest loss of any sub-category — a clear sign of a problem worth investigating further.

---

#### Q4: What is the profit margin (profit / sales) for each sub-category?

```sql
SELECT `Sub-Category`,
       CONCAT(ROUND((SUM(Profit)/SUM(Sales))*100, 2), '%') AS profit_margin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY (SUM(Profit)/SUM(Sales)) DESC;
```

| Sub-Category | Profit Margin |
|---|---|
| Labels | 44.42% |
| Paper | 43.39% |
| Envelopes | 42.27% |
| Copiers | 37.2% |
| ... | ... |
| Machines | 1.79% |
| Supplies | -2.55% |
| Bookcases | -3.02% |
| **Tables** | **-8.56%** |

**Finding:** Tables has the worst profit margin of all sub-categories at -8.56%, confirming it as the most problematic product line.

---

#### Q5: Within each category, which sub-category contributes the highest profit?

```sql
SELECT `Sub-Category`, Category, total_profit, rank_in_category
FROM (
    SELECT `Sub-Category`, Category, ROUND(SUM(Profit),2) AS total_profit,
           RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rank_in_category
    FROM SampleSuperstore_1
    GROUP BY `Sub-Category`, Category
) AS ranking
WHERE rank_in_category = 1;
```

| Category | Top Sub-Category | Profit |
|---|---|---|
| Furniture | Chairs | $26,590 |
| Office Supplies | Paper | $34,054 |
| Technology | Copiers | $55,618 |

**Finding:** Copiers is the single biggest profit driver across the entire store, even though it's not a top seller by volume.

---

### Part 3: Why do they lose money?

#### Q6: What is the average discount rate and profit margin for each sub-category? Do they correspond?

```sql
SELECT `Sub-Category`, ROUND(AVG(Discount),2) AS avg_discount,
       ROUND(SUM(Profit)/SUM(Sales) * 100, 2) AS profit_margin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY avg_discount;
```

| Sub-Category | Avg Discount | Profit Margin |
|---|---|---|
| Labels | 0.07 | 44.42% |
| Paper | 0.07 | 43.39% |
| Supplies | 0.08 | -2.55% |
| Chairs | 0.17 | 8.1% |
| Bookcases | 0.21 | -3.02% |
| **Tables** | **0.26** | **-8.56%** |
| Machines | 0.31 | 1.79% |
| **Binders** | **0.37** | **14.86%** |

**Finding:** Most sub-categories show a negative correlation between discount rate and profit margin — higher discounts tend to result in lower or negative margins (e.g., Tables, Bookcases). However, exceptions exist: Binders has the highest discount rate of all sub-categories (0.37) but remains highly profitable (14.86%), and Supplies has a low discount rate but still posts a loss. This suggests discounting alone doesn't fully explain profitability — other factors (e.g., product cost, shipping) likely play a role.

---

#### Q7: After grouping discount into bins, what is the profit margin for each bin? At what discount level does profit turn negative?

```sql
SELECT
CASE
    WHEN Discount <= 0.2 THEN 'Low'
    WHEN Discount <= 0.3 THEN 'Medium'
    ELSE 'High'
END AS group_discount, ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin, COUNT(*) AS record_total
FROM SampleSuperstore_1
GROUP BY group_discount
ORDER BY profit_margin DESC;
```

| Discount Bin | Profit Margin | Records |
|---|---|---|
| Low (0–20%) | 28.33% | 4,944 |
| Medium (21–30%) | 11.82% | 3,657 |
| High (31–80%) | -48.16% | 1,166 |

**Finding:** 30% discount is a turning point. Below 30%, profit margin stays positive; above 30%, it turns sharply negative. This aligns with Q9: Tables in East has a 37.38% discount and the worst margin (-28.17%). However, some cases lose money even below 30% (e.g., Supplies in East: 6.79% discount, -10.74% margin), suggesting additional data is needed to explain those losses.

---

### Part 4: Where do they lose money?

#### Q8: Which state has the highest total loss?

```sql
SELECT State, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY State
ORDER BY total_profit ASC;
```

| State | Total Profit |
|---|---|
| **Texas** | **-$25,729** |
| Ohio | -$16,971 |
| Pennsylvania | -$15,560 |
| Illinois | -$12,608 |
| North Carolina | -$7,491 |

**Finding:** Texas has the largest total loss of any state. State-level data alone does not explain why; further analysis of sub-categories and discounts within Texas would be needed.

---

#### Q9: What is the profit margin for each of the three unprofitable sub-categories in each region?

```sql
SELECT `Sub-Category`, Region, ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin,
       COUNT(*) AS record_total, ROUND(AVG(Discount)*100,2) AS avg_discount
FROM SampleSuperstore_1
WHERE `Sub-Category` IN ('Tables','Bookcases','Supplies')
GROUP BY `Sub-Category`, Region
ORDER BY profit_margin;
```

| Sub-Category | Region | Profit Margin | Records | Avg Discount |
|---|---|---|---|---|
| Tables | East | -28.17% | 80 | 37.38% |
| Supplies | East | -10.74% | 56 | 6.79% |
| Tables | South | -10.53% | 51 | 22.25% |
| Tables | Central | -9.09% | 72 | 26.25% |
| Bookcases | Central | -8.27% | 50 | 23.28% |
| ... | ... | ... | ... | ... |
| Tables | West | 1.75% | 116 | 20% |
| Supplies | West | 3.45% | 69 | 3.77% |
| Bookcases | South | 12.29% | 28 | 10% |

**Finding:** Tables is not unprofitable in every region; West has a positive margin (1.75%). Tables in East has the worst margin (-28.17%) with the highest average discount (37.38%), suggesting high discounts may be a key driver of the loss. However, Supplies in East has a low discount (6.79%) but still loses money (-10.74%), indicating that factors beyond discounting also contribute to losses.

---

### Part 5: Ruling out other factors

#### Q10: Does ship mode affect average profit?

**Finding:** Profit margin differs slightly across ship modes. First Class has the highest margin (13.93%) and Standard Class the lowest (12.08%), a gap of about 1.85 percentage points. Same Day has the smallest sample, so its result is less stable. This is a correlation, not causation; other factors may be involved.

#### Q11: After grouping quantity into bins, does the average discount differ across bins?

**Finding:** Quantity was grouped into three bins: 1–3, 4–6, and 7–14. The average discount is 15.39%, 15.92%, and 15.95%, a maximum gap of about 0.56 percentage points. Quantity shows almost no relationship with discount.

---

### Part 6: Supplementary analysis

#### Q12: In each region, which category has the most records?

**Finding:** Office Supplies has the most records in all four regions, indicating consistently high demand across regions.

#### Q13: Within each region, what percentage of records does each category account for?

**Finding:** The share of Office Supplies ranges from 59.23% (West) to 61.42% (South), a gap of about 2 percentage points. The distribution is very similar across regions.

---

## Python Analysis

Reproduced key business questions from the SQL analysis using Python and Pandas. A data quality check was performed before the analysis, confirming no missing values across all 9,994 rows.

All results matched the SQL queries exactly, validating the reliability of the findings. This also demonstrates that the same business question can be approached with different tools — SQL works well for querying within a database environment, while Pandas offers more flexibility for data manipulation and further modelling.

**Key Pandas operations used:** `groupby` aggregation, calculated columns, sorting, and data quality checks.

**File:** `analysis.py`

## Key Insight

High sales do not guarantee profitability. Tables ranks 4th in sales but has the worst profit margin (-8.56%), while Labels ranks 16th in sales but achieves the highest margin (44.42%).

A discount rate of 30% appears to be the turning point: below 30%, profit margins stay positive; above 30%, they turn sharply negative. This is supported by the cross-regional analysis — Tables in East, with an average discount of 37.38%, has the worst margin of any region-subcategory combination (-28.17%).

Ship Mode and Quantity were ruled out as significant factors — neither shows a meaningful relationship with profit margin or discount levels.

However, discounting does not explain all losses. Supplies in East has a low discount (6.79%) but still loses money (-10.74%), and Binders remains highly profitable (14.86%) despite having the highest discount rate (37%). This suggests other factors such as product cost structure may also play a role and would require additional data to investigate.

## Files in this Repo

- `queries.sql` — All SQL queries used in this analysis (Q1–Q13), with comments explaining each business question and conclusions
- `analysis.py` — Python/Pandas version of the analysis, used for cross-validation
- `superstore_excel_analysis.xlsx` — Excel analysis workbook
- `practice_superstore.pbix` — Power BI dashboard file
- `superstore sale dashboard powerbi.png` — Power BI dashboard screenshot
- `Pivot - Profit by Region & Category.png` — Pivot table screenshot
- `SampleSuperstore.csv` — Source dataset
- `README.md` — This file
