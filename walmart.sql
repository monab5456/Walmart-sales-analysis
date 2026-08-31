-- Q. Which product categories are the major drivers of revenue and profit?
SELECT 
	category, 
	round(sum(profit),2) as total_profit,
	round(sum(sales_price),2) as revenue
FROM walmart 
group by category 
ORDER BY revenue DESC,total_profit DESC;

-- Q. Which branches and cities are the strongest and weakest performers based on revenue, profit, and transaction volume?
--  Branch 
SELECT 
	"Branch", 
	round(sum(profit),2) as total_profit,
	round(sum(sales_price),2) as revenue,
	count(*) as transaction_volume,
	round(avg(profit),2) as profit_per_transaction,
	round(avg(sales_price),2) as revenue_per_transaction
FROM walmart 
GROUP BY "Branch" 
ORDER BY transaction_volume DESC ;
-- city
SELECT 
	"City", 
	round(sum(profit),2) as total_profit,
	round(sum(sales_price),2) as revenue,
	count(*) as transaction_volume,
	round(avg(profit),2) as profit_per_transaction,
	round(avg(sales_price),2) as revenue_per_transaction
FROM walmart 
GROUP BY "City" 
ORDER BY transaction_volume DESC;

-- Sales quantity analysis
-- total quantity sold by categorywise:
SELECT category,sum(quantity) as Total_quantity FROM walmart GROUP BY category ORDER BY sum(quantity) DESC;
-- total quantity sold by citywise:
SELECT "City",sum(quantity) as Total_quantity FROM walmart GROUP BY "City" ORDER BY sum(quantity) DESC;
-- total quantity sold by "Branch":
SELECT "Branch",sum(quantity) as Total_quantity FROM walmart GROUP BY "Branch" ORDER BY sum(quantity) DESC;
-- total quantity sold per YEAR:
SELECT extract(year from "DateTime") as year, sum(quantity) from walmart group by extract(year from "DateTime") ORDER by sum(quantity) DESC;



-- Q.What are the most frequently used payment methods, and 
-- how do transaction volume, quantity sold, and revenue differ across them?
SELECT 
	payment_method,
	count(*) as Transaction_vol,
	round(sum(quantity),2) as total_quantity,
	round(sum(sales_price),2) as revenue 
from walmart
GROUP BY payment_method 
ORDER BY Transaction_vol desc;

-- Q.Are highly rated categories also generating high revenue?
SELECT 
	category,
	round(avg(rating),2) as avg_rating,
	round(sum(sales_price),2) as revenue 
	FROM walmart 
group by category 
ORDER by avg_rating desc;

-- Q.What are the average, minimum, and maximum ratings for each category in each city?
SELECT 
	category,
	"City",
	round(avg(rating)) as avg_rating,
	min(rating) as min_rating,
	max(rating) as max_rating
FROM walmart GROUP BY category,"City";

-- Q.What are the peak sales days and hours, and how do these patterns differ across branches?
WITH cte1 AS(
	select 
		"Branch",
		extract(day from "DateTime") as day,
		extract(hour from "DateTime") as hour,
	count(*) as sales
from walmart
GROUP BY extract(day from "DateTime"),extract(hour from "DateTime"),"Branch"),
cte2 as (
	SELECT *,dense_rank() over(partition by "Branch" ORDER by sales) AS dnrk FROM cte1)
select "Branch",day, hour,sales FROM cte2 where dnrk = 1;

-- Q.Which branches experienced the largest revenue decline over year, and 
-- what happened to their transaction volume during the same period?

WITH current_year AS (
SELECT
	"Branch",
	EXTRACT(YEAR FROM "DateTime") AS current_year,
	SUM(sales_price) AS current_revenue,
	COUNT(*) AS current_transaction
FROM walmart
GROUP BY"Branch", EXTRACT(YEAR FROM "DateTime")),
previous_year AS (
SELECT
	"Branch",
	current_year,
	current_revenue,
	current_transaction,
	LAG(current_revenue) OVER (PARTITION BY "Branch" ORDER BY current_year) AS previous_year_revenue,
	LAG(current_transaction) OVER (PARTITION BY "Branch" ORDER BY current_year) AS previous_year_transaction 
FROM current_year)
SELECT
    "Branch",
    current_year,
    ROUND(current_revenue, 2) AS total_revenue,
    current_transaction AS transaction_no,
	ROUND((current_revenue - previous_year_revenue)/ previous_year_revenue * 100,2) AS yoy_revenue_rate,
	current_transaction - previous_year_transaction AS yoy_transaction_rate
FROM previous_year
WHERE previous_year_revenue IS NOT NULL
ORDER BY yoy_revenue_rate ASC;