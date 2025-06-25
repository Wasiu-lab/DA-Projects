-- Use the 'world' database
USE world;
-- Create the 'orders' table
-- CREATE TABLE orders (
--     order_id INT PRIMARY KEY,
--     order_date DATE,
--     ship_mode VARCHAR(20),
--     segment VARCHAR(20),
--     country VARCHAR(20),
--     city VARCHAR(20),
--     state VARCHAR(20),
--     postal_code VARCHAR(20),
--     region VARCHAR(20),
--     category VARCHAR(20),
--     sub_category VARCHAR(20),
--     product_id VARCHAR(50),
--     quantity INT,
--     discount DECIMAL(7,2),
--     sale_price DECIMAL(7,2),
--     profit DECIMAL(7,2)
-- );

SELECT * FROM orders;

-- find the top highest revenue generating product 
select product_id, sum(sale_price) as sales 
from orders
group by product_id
order by sales desc
limit 10;

-- find top 5 highest selling products in each regions  
with cte as  (
select region, product_id, sum(sale_price) as sales 
from orders
group by region, product_id)
select * from(
select *, row_number() over (partition by region order by sales desc) as rn
from cte) A 
where rn<=5;

-- Find month over month growth comparison for 2022 and 2023 sales eg jan 2022 vs jan 2023 
-- we have to put in diffrent column thereb we use cte 
with cte as (
select year(order_date) as order_year, month(order_date) as order_month, sum(sale_price) as sales
from orders 
group by order_year, order_month
)
select order_month,
-- to get the aggregate we use sum
sum(case when order_year=2022 then sales else 0 end) as sales_2022, 
sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month
order by order_month;

-- for each category which month had the highest sales
with cte as (
select category, month(order_date) as order_month, year(order_date) as order_year, sum(sale_price) as sale
from orders
group by category, order_month, order_year
order by category, order_month, order_year
)
select * from (
select *, 
row_number()  over(partition by category order by sale desc) as rn
from cte
) A 
where rn=1;

-- which sub category had the highest growth by profit in 2023 compared to 2022  
WITH cte AS (
    SELECT sub_category,
        YEAR(order_date) AS order_year,
        SUM(sale_price) AS sales
    FROM orders
    GROUP BY sub_category,YEAR(order_date)
),
-- Pivoting sales data to compare across years
cte2 as (SELECT 
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category
ORDER BY sub_category)
select *,
round((sales_2023-sales_2022)*100/sales_2022, 2) as growth_percent
from cte2
order by growth_percent desc
limit 1;

-- Top-Selling Products or Categories
SELECT
  sub_category,
  SUM(sale_price) AS total_sales,
  SUM(quantity) AS total_quantity,
  SUM(profit) AS total_profit
FROM orders
GROUP BY sub_category
ORDER BY total_sales DESC
LIMIT 10;

-- Loss-Making Products (Negative Profit)
SELECT
  product_id,
  sub_category,
  SUM(profit) AS total_loss,
  COUNT(*) AS loss_count
FROM orders
WHERE profit < 0
GROUP BY product_id, sub_category
ORDER BY total_loss ASC
LIMIT 10;

