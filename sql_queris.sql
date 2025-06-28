create database Orders;
use orders;

SELECT 
    *
FROM
    orders;

-- find top 10 highest reveue generating product 
SELECT 
    product_id, SUM(sale_price) AS sales
FROM
    orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;


-- find top 5 selling product in each region
with cte as(
	select region ,product_id,sum(sale_price) as sales
	from orders
	group by product_id,region
	order by region,sales desc)
select * from(
select *,
	row_number() over(partition by region order by sales desc) as rnk
from cte) A
where rnk<=5;

-- find month over month  growth  comparison for 2022 and 2023  sales  eg : jan 2022  vs jan 2023
with cte as(
select 
	year(order_date) as order_year,
	month(order_date) as order_month,
	sum(sale_price) as sales
from orders
group by 1,2)
select  order_month,
	sum(case when order_year=2022 then sales else 0 end) as sales_2022,
	sum(case when order_year=2023 then sales else 0 end) as sales_2023
from  cte
group by order_month
order by order_month;

-- for  each category 	which month has highest  sales
with cte as(
select category,
	date_format(order_date,'%M-%Y') as mnt_year,
    sum(sale_price) as sales
from orders
group by category,date_format(order_date,'%M-%Y'))
select * from(
select *,
	row_number() over(partition by category order by sales desc) as rnk
from cte)a
where rnk=1;
 
--  which sub category had highest growth by profit  in 2023 compare to 20222
with cte as(
select sub_category,
	year(order_date) as year,
    sum(sale_price)as sales
from orders
group by 1,2),
cte2 as(
select 
	sub_category,
    sum(case when year=2022 then sales else 0 end) as sales_2022,
    sum(case when year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category)
select *,
	round(((sales_2023 - sales_2022) * 100/sales_2022),2) as growth
from cte2
order by round(((sales_2023 - sales_2022) * 100/sales_2022),2) desc

	




