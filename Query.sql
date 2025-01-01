--A.	KPI
---a.	Total Sales Analysis
---- i.	Total Sales for Each Month Respective
select round (SUM(transaction_qty*unit_price),2) as Total_Sales
from coffee_shop_sales
where MONTH(transaction_date)=3 -- write digit wrt to current month

---- ii.	The month-of-month increase or decrease in sales

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
ROUND(SUM(transaction_qty * unit_price), 2) AS Total_Sales,-- As Total Sales
(SUM(transaction_qty * unit_price)- LAG(SUM(transaction_qty * unit_price),1) -- As Month Sales Difference
over(order by month(transaction_date)))/ LAG(SUM(transaction_qty * unit_price),1)-- Division by Prev. Month
over(order by month(transaction_date))*100 as mom_increase_percentage -- Convert to Percentage

FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

---- iii.	The difference in Sales between the selected month and the previous month

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
ROUND(SUM(transaction_qty * unit_price), 2) AS Total_Sales,-- As Total Sales
ROUND(SUM(transaction_qty * unit_price)- LAG(SUM(transaction_qty * unit_price),1) -- As Month Sales Difference
over(order by month(transaction_date)),2) as Month_difference
FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

--- b.	Total Order Analysis

---- i.	Total Orders for Each Month Respective

SELECT MONTH(transaction_date) AS Month,
COUNT(transaction_id) AS Total_Orders	
FROM coffee_shop_sales
GROUP BY MONTH(transaction_date)
ORDER BY Month;

---- ii.	The month-of-month increase or decrease in orders

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
count(transaction_id) AS Total_Orders,-- As Total Orders
round((count(transaction_id)- LAG(count(transaction_id),1) -- As Month Orders Difference
over(order by month(transaction_date)))*100.0/ LAG(count(transaction_id),1)-- Division by Prev. Month
over(order by month(transaction_date)),2) as mom_increase_percentage -- Convert to Percentage
FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

---- iii.	The difference in Sales between the selected month and the previous month

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
count(transaction_id) AS Total_Orders,-- As Total Orders
(count(transaction_id)- LAG(count(transaction_id),1) -- As Month Orders Difference
over(order by month(transaction_date)))
FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

--- c.	Total Quantity Sold Analysis

---- i.	Total Quantity sols for Each Month Respective

SELECT MONTH(transaction_date) AS month,
SUM(transaction_qty) as Total_Quantity
FROM coffee_shop_sales
group by month(transaction_date)
order by month(transaction_date)

---- ii.	The month-of-month increase or decrease in quantity sold

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
round(sum(transaction_qty),2) AS Total_Orders,-- As Total Orders
round((sum(transaction_qty)- LAG(sum(transaction_qty),1) -- As Month Orders Difference
over(order by month(transaction_date)))*100/LAG(sum(transaction_qty),1)
over(order by month(transaction_date)),2) as mom_increase_percentage
FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

---- iii.	The difference in Quantity sold in between the selected month and the previous month

SELECT MONTH(transaction_date) AS Month,-- As Month Name	
sum(transaction_qty) AS Total_Orders,-- As Total Orders
(sum(transaction_qty)- LAG(sum(transaction_qty),1) -- As Month Orders Difference
over(order by month(transaction_date)))
FROM coffee_shop_sales
where MONTH(transaction_date) in (3,4) -- for month March and April
group by MONTH(transaction_date)
ORDER BY MONTH(transaction_date)

--- B.	Calendar Heat Map
select 
round(SUM(unit_price * transaction_qty),2) as total_sales,
SUM(transaction_qty) as total_quantity_sold,
count(transaction_id) as total_orders
from coffee_shop_sales
where transaction_date = '2023-01-05'-- Put the date on your choice

--  If you want to get exact Rounded off values then use below query to get the result:
Select
concat(round(SUM(unit_price * transaction_qty)/1000,2),'K') as total_sales,
SUM(transaction_qty) as total_quantity_sold,
count(transaction_id) as total_orders
from coffee_shop_sales
where transaction_date = '2023-01-05'-- Put the date on your choice

--- C.	Sales Analysis by Weekdays and Weekends

SELECT 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    concat(round(SUM(unit_price * transaction_qty)/1000,2),'K') AS total_sales,
    MONTH(transaction_date) AS month
FROM 
    coffee_shop_sales
GROUP BY 
    CASE 
        WHEN DATEPART(WEEKDAY, transaction_date) IN (1, 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END,
    MONTH(transaction_date)
ORDER BY month, day_type;


--- D.	Sales Analysis by Store Location

select store_location, 
MONTH(transaction_date) as month,
concat(round(SUM(unit_price* transaction_qty)/1000,2),'K') as total_sales
from coffee_shop_sales
group by store_location,
MONTH(transaction_date)
  order by MONTH(transaction_date)

--- E.	Daily Sales Analysis with Average Line

---- 1. Average Sales for Every Month
    
select  
	concat(round(AVG(total_sales)/1000,2),'K') as avg_sales
from
	(
	select 
	sum(unit_price * transaction_qty) as total_sales
	from coffee_shop_sales
	where month(transaction_date)=5
	group by (transaction_date)
         )  as internal_query

---- 2. Average Sales for Daily Trend for Each Month 
select  
DAY(transaction_date) as day_of_week,
concat(round(sum(unit_price* transaction_qty)/1000,2),'K') as total_sales
from coffee_shop_sales
where month(transaction_date)=5
group by day(transaction_date)
order by day(transaction_date) asc

---- 3. COMPARING DAILY SALES WITH AVERAGE 

select  
	 day_of_month,
	 case
		WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
	from (
		   SELECT DAY(transaction_date) AS day_of_month,
		   round(SUM(unit_price * transaction_qty),2) AS total_sales,
		   AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
		   from coffee_shop_sales
		   where MONTH(transaction_date)=5
		   GROUP BY DAY(transaction_date)
		 ) AS sales_data
		   ORDER BY day_of_month

--- F.	Sales Analysis by Product Category

select product_category,
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
where MONTH(transaction_date)=5
group by product_category
order by sum(unit_price * transaction_qty) desc

--- G.	Top 10 Product by Sales
select top 10 product_type,
round(sum(unit_price * transaction_qty),2) as total_sales
from coffee_shop_sales
where MONTH(transaction_date)=5
group by product_type
order by sum(unit_price * transaction_qty) desc

--- H.	Sales Analysis by Days and Hours
SELECT 
    round(SUM(unit_price * transaction_qty),2) AS total_sales,
    SUM(transaction_qty) AS total_qty_sales,
    COUNT(transaction_id) AS total_orders
FROM 
    coffee_shop_sales
WHERE 
    MONTH(transaction_date) = 5
    AND DATEPART(WEEKDAY, transaction_date) = 2 -- Monday
    AND DATEPART(HOUR, transaction_time) = 8; -- Hour is 8 AM

