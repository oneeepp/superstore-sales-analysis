CREATE DATABASE portfolio_project;
-- Q1: 每个地区的销售额是多少？ What is the total sales amount for each region?
SELECT Region, SUM(Sales) AS total_sales
FROM SampleSuperstore_1
GROUP BY Region
ORDER BY total_sales DESC;

-- Q2: 每个客户类型的平均利润是多少？ What is the average profit per order for each customer segment?
SELECT Segment, ROUND(AVG(Profit), 2) AS avg_profit
FROM SampleSuperstore_1
GROUP BY Segment
ORDER BY avg_profit DESC;

-- Q3: 哪个子品类销售额/利润最高？
SELECT `Sub-Category`, ROUND(SUM(Sales),2) AS total_sales, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY total_sales DESC;


-- Q4: 销售额和利润的比例是多少？ What is the profit margin (profit / sales) for each sub-category, and which ones have negative margins?
SELECT `Sub-Category`, CONCAT(ROUND((SUM(Profit) / SUM(Sales)* 100),2), '%') AS profit_margin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY (SUM(Profit)/SUM(Sales)) DESC;

-- Q5: 每个子品类的平均折扣率和利润率分别是多少？两者是否对应？What is the average discount rate and profit margin for each sub-category? Do they correspond?
SELECT `Sub-Category`, ROUND(AVG(Discount),2) AS percentage_discount, ROUND(SUM(Profit)/SUM(Sales) * 100,2) AS percentage_profit_martin
FROM SampleSuperstore_1
GROUP BY `Sub-Category`
ORDER BY percentage_discount;

-- Q6: 在每个大品类（Category）内部，哪个子品类（Sub-Category）利润贡献最高？Within each category, which sub-category contributes the highest profit?;
SELECT `Sub-Category`, Category, total_profit, rank_in_category
FROM (
SELECT `Sub-Category`, Category, ROUND(SUM(Profit),2) AS total_profit, RANK() OVER(PARTITION BY Category ORDER BY SUM(Profit) DESC) AS rank_in_category
FROM SampleSuperstore_1
GROUP BY `Sub-Category`, Category
) AS ranking
WHERE rank_in_category = 1;

-- Q7: 哪个 State（州）亏损最严重？Which State has the highest total loss (most negative profit)?
SELECT State, ROUND(SUM(Profit),2) AS total_profit
FROM SampleSuperstore_1
GROUP BY State
ORDER BY total_profit ASC