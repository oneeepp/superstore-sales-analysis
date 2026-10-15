CREATE DATABASE portfolio_project;
-- ===== Part 1: Overview =====

-- Q1: What is the total sales amount for each region?
SELECT Region, ROUND(SUM(Sales), 2) AS total_sales
FROM SampleSuperstore_1
GROUP BY Region
ORDER BY total_sales DESC;

-- Q2: What is the average profit per record for each customer segment?
SELECT Segment, ROUND(AVG(Profit), 2) AS avg_profit
FROM SampleSuperstore_1
GROUP BY Segment
ORDER BY avg_profit DESC;

-- ===== Part 2: Which products lose money? =====

-- Q3: Which sub-category has the highest sales and profit?
SELECT `Sub-Category`, ROUND(SUM(Sales),2) AS total_sales, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;


-- Q4: What is the profit margin (profit / sales) for each sub-category, and which ones have negative margins?
SELECT `Sub-Category`, CONCAT(ROUND((SUM(Profit) / SUM(Sales)* 100),2), '%') AS profit_margin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY (SUM(Profit)/SUM(Sales)) DESC;

-- Q5: Within each category, which sub-category contributes the highest profit?
SELECT `Sub-Category`, Category, total_profit, rank_in_category
FROM (
SELECT `Sub-Category`, Category, ROUND(SUM(Profit),2) AS total_profit, RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rank_in_category
FROM SampleSuperstore_1
GROUP BY `Sub-Category`, Category
) AS ranking
WHERE rank_in_category = 1;

-- ===== Part 3: Why do they lose money? =====

-- Q6: What is the average discount rate and profit margin for each sub-category? Do they correspond?
SELECT `Sub-Category`, ROUND(AVG(Discount),2) AS percentage_discount, ROUND(SUM(Profit)/SUM(Sales) * 100,2) AS percentage_profit_margin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY percentage_discount;

-- Q7: After grouping discount into bins, what is the profit margin for each bin? At what discount level does profit turn negative? 
-- SELECT MIN(Discount) AS min_discount, MAX(Discount) AS max_discount
-- FROM SampleSuperstore_1
SELECT
CASE
    WHEN Discount <= 0.2 THEN 'Low'
    WHEN Discount <= 0.3 THEN 'Medium'
    ELSE 'High'
END AS group_discount, ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin, COUNT(*) AS record_total
FROM SampleSuperstore_1
GROUP BY group_discount
ORDER BY profit_margin DESC;
-- Conclusion: 30% discount is a turning point.
-- Below 30%, profit margin stays positive; above 30%, it turns negative.
-- This aligns with Q9: Tables in East has a 37.38% discount and the worst margin (-28.17%).
-- However, some cases lose money even below 30% (e.g. Supplies in East: 6.79% discount, -10.74% margin),
-- suggesting additional data is needed to explain those losses.

-- ===== Part 4: Where do they lose money? =====

-- Q8: Which State has the highest total loss (most negative profit)?
SELECT State, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY State
ORDER BY total_profit ASC;
-- Conclusion: Texas has the largest total loss (-25,729.36) and California the highest profit.
-- State-level data alone does not explain why; further analysis of sub-categories
-- and discounts within Texas would be needed.

-- Q9: What is the profit margin for each of the three unprofitable sub-categories in each region?
SELECT `Sub-Category`, Region, ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin, COUNT(*) AS record_total, ROUND(AVG(Discount)*100,2) AS avg_discount
FROM SampleSuperstore_1
WHERE `Sub-Category` IN ('Tables','Bookcases','Supplies')
GROUP BY `Sub-Category`, Region
ORDER BY profit_margin;
-- Conclusion: Tables is not unprofitable in every region; West has a positive margin (1.75%).
-- Tables in East has the worst margin (-28.17%) with the highest avg discount (37.38%),
-- suggesting high discounts may be a key driver of the loss.
-- However, Supplies in East has a low discount (6.79%) but still loses money (-10.74%),
-- indicating that factors beyond discounting also contribute to losses.

-- ===== Part 5: Ruling out other factors =====

-- Q10: Does ship mode affect average profit?
SELECT `Ship Mode`, ROUND(AVG(Profit),2) AS avg_profit, COUNT(*) AS record_count, ROUND(SUM(Profit)/SUM(Sales)*100,2) AS profit_margin
FROM SampleSuperstore_1
GROUP BY `Ship Mode`
ORDER BY avg_profit DESC;
-- Conclusion: Profit margin differs slightly across ship modes.
-- First Class has the highest margin (13.93%) and Standard Class the lowest (12.08%),
-- a gap of about 1.85 percentage points.
-- Same Day has the smallest sample, so its result is less stable.
-- This is a correlation, not causation; other factors may be involved.

-- Q11: After grouping quantity into bins, does the average discount differ across bins?
SELECT 
CASE
    WHEN Quantity <= 3 THEN 'Low'
    WHEN Quantity <= 6 THEN 'Medium'
    ELSE 'High'
END AS group_quantity, ROUND(AVG(Discount)*100,2) AS avg_discount, COUNT(*) AS record_count, MAX(Quantity) AS max_quantity
FROM SampleSuperstore_1
GROUP BY group_quantity;
-- Conclusion: Quantity was grouped into three bins: 1-3, 4-6 and 7-14.
-- All bins have enough records. The average discount is 15.39%, 15.92% and 15.95%,
-- a maximum gap of about 0.56 percentage points.
-- Quantity shows almost no relationship with discount.
-- Discount differences may be related to other factors, such as product category.

-- ===== Part 6: Supplementary analysis =====

-- Q12: In each region, which category has the most orders?
SELECT Region, Category, record_category
FROM(
SELECT Region, Category, COUNT(*) AS record_category, RANK() OVER(PARTITION BY Region ORDER BY COUNT(*) DESC) AS rank_category
FROM SampleSuperstore_1
GROUP BY Region, Category) AS ranking_category
WHERE rank_category = 1
ORDER BY record_category DESC;
-- Conclusion: Office Supplies has the most records in all four regions,
-- indicating consistently high demand across regions.

-- Q13: Within each region, what percentage of records does each category account for? Does the share of Office Supplies differ across regions?
SELECT Region, Category, percent_cate
FROM(SELECT Region, Category, COUNT(*) AS record_category, 
       SUM(COUNT(*)) OVER(PARTITION BY Region) AS region_total,
       ROUND(COUNT(*)/SUM(COUNT(*)) OVER(PARTITION BY Region)* 100,2)  AS percent_cate, 
       RANK() OVER(PARTITION BY Region ORDER BY COUNT(*) DESC) AS rnk
FROM SampleSuperstore_1
GROUP BY Region, Category) AS t
WHERE rnk = 1
ORDER BY percent_cate DESC;
-- Conclusion: The share of Office Supplies ranges from 59.23% (West) to 61.42% (South),
-- a gap of about 2 percentage points. The distribution is very similar across regions.
