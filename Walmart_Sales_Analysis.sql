create database walmart;
use walmart ;
select * from walmart;
select count(distinct branch)
from walmart;

-- Business Problems
-- Q1 :- Find the diffrent payment method and number of transaction ,number of qty sold
select   payment_method ,
count(*)  as no_payment ,
sum(quantity) as total_qty_sold
from walmart
group by payment_method;

-- Q2:- Identify the highest-rated category in each branch ,displaying the branch ,category ,avg rating
select * from (select branch , category , avg(rating) as avg_rating,										
rank() over (partition by branch order by  avg(rating) desc) asRank 
from walmart
group by branch , category ) AS ranked_categories where asRank = 1;

-- -------------------- Checking Data type of each column ---------------------------
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'walmart'  
  AND TABLE_NAME = 'walmart';  
-- -----------------------------------------------------------------------------------

-- Q3:- Identify the busiest day for each branch based on the number transaction.
select * from
	(select 
		branch,
		DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name ,
		count(*) as no_transaction,
		rank() over(partition by branch order by count(*) desc)  asrank
		from walmart
		group by branch ,day_name) AS ranked
where  asrank=1; 

-- Q4 :- Calculate the total quantity of items sold per payment method.List payment_method and total_quantity.
select payment_method ,
	sum(quantity) as total_sold_item  ,
	count(*) as no_transaction 
	from walmart
	group by payment_method;

-- Q5:- Determine the average ,minimum and maximum rating of category for each city. List the city,
-- average_rating ,min_rating and max_rating
select 
	city , category, avg(rating) as average_rating ,
	min(rating) as min_rating,
	max(rating) as max_rating
from walmart
group by city, category;

-- Q6:-calculate the total profit for each category by considering total_profit as (unit_price * quantity * 
-- profit_margin ).List category and total_profit from highest to lowest profit.
select category ,
sum(total * profit_margin) as total_profit
from walmart
group by category
order by total_profit desc;

-- Q7:- Determine most common payment_method for each Branch. Display Branch and the preferred_payment_method.
with cte
as 
(select 
	branch , payment_method,
	count(*) as total_transaction ,
    rank() over(partition by branch order by count(*) desc) asrank
	from walmart
	group by payment_method,branch)
select * from cte where asrank=1;

-- Q8:-categorize sales into 3 group MORNING , AFTERNOON ,EVENING . Find out each of shift and number of invoices. 
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
   COUNT(*) AS total_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, total_invoices DESC;

-- Q9:-Identify 5 branch with highest decrease ratio in revenue 
-- compare to last year(current year 2023 and last year 2022)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;






















































































  