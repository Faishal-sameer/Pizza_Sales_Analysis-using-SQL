use PIZZA_PROJECT



--1. Retrieve the total number of orders placed.

SELECT
	COUNT(O.order_details_id) AS Total_Order
FROM
	order_details O

--2. Calculate the total revenue generated from pizza sales.

SELECT
	SUM(P.Price*O.quantity) as Revenues
FROM
	pizzas P
JOIN
	order_details O
ON
	P.pizza_id=O.pizza_id

--3. Identify the highest-priced pizza.

select
	top 1
	pt.name as pizza_name,
	max(p.price) as highest_pizza_price
from
	pizza_types pt
join
	pizzas p
on
	p.pizza_type_id=pt.pizza_type_id
group by
	pt.name
order by
	highest_pizza_price desc

--4. Identify the most common pizza size ordered.

select
	p.size as pizza_size,
	count(o.order_id) as tot_ordered
from	
	pizzas p
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	p.size
order by
	tot_ordered desc
--5. List the top 5 most ordered pizza types along with their quantities.

select
	top 10
	pt.name as Pizza_Name,
	SUM(O.quantity) AS Quantity,
	count(o.order_details_id) as Total_Order
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.name
order by
	Total_Order desc,Quantity desc



--6. Join the necessary tables to find the total quantity of each pizza category ordered.

select
	pt.category as pizza_category,
	sum(o.quantity) as total_quantity
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.category
order by
	total_quantity desc


--7. Determine the distribution of orders by hour of the day.

select
	case	
		when Per_Hour>12 then concat(per_hour,'-PM') else concat(per_hour,'-AM') END AS Hours,
	Total_Order
from(
select
	DATEPART(HOUR,o.time) as Per_Hour,
	count(od.order_details_id) as Total_Order
from
	order_details od
join
	orders o
on
	od.order_id=o.order_id
group by
	DATEPART(HOUR,o.time) 
) abc


--8. Find the category-wise distribution of pizzas.

select
	pt.category as categories,
	count(o.order_details_id) as total_Distribution
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.category



--9. Group the orders by date and calculate the average number of pizzas ordered per day

select
	DATEPART(day,o.date) as per_day,
	avg(od.quantity) as avg_quantity,
	avg(od.quantity*p.price) as avg_sales,
	avg(od.order_details_id) as avg_order

from
	order_details od
join
	orders o
on
	od.order_id=o.order_id
join
	pizzas p
on
	od.pizza_id=p.pizza_id
group by
	DATEPART(day,o.date)
order by
	1 asc


--10. Determine the top 3 most ordered pizza types based on revenue.

select
	top 3
	pt.name as pizza_name,
	sum(p.price*o.quantity) as revenues
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.name
order by
	revenues desc


--11. Calculate the percentage contribution of each pizza type to total revenue.
with cte as(
select
	pt.name as pizza_name,
	sum(o.quantity*p.price) as revenues
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.name	
),
total_revenues as (
select 
	sum(revenues) as tot_revenues 
from 
	cte
)
select
	c.pizza_name,
	(100*c.revenues/t.tot_revenues) as percentage
from
	cte c,total_revenues t
-------------------------------------------------------------
---alternative way


select
	pizza_name,
	100*Revenues/ sum(revenues)over() as percentage_distribution
from(
select
	pt.name as pizza_name,
	sum(o.quantity*p.price) as revenues
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	p.pizza_id=o.pizza_id
group by
	pt.name	
)ctttrr

--12. Analyze the cumulative revenue generated over time.
select
	order_date,
	revenues,
	sum(revenues)over(order by order_date asc) as cumulative_revenues
from(
select
	o.date as order_date,
	sum(od.quantity*p.price) as revenues
from
	order_details od
join
	orders o
on
	od.order_id=o.order_id
join
	pizzas p
on
	p.pizza_id=od.pizza_id
group by
	o.date
)abcs



--13. Determine the top 3 most ordered pizza types based on revenue for each pizza category
select
	pizza_name,
	pizza_category,
	revenues,
	rn
from(
select
	pt.name as pizza_name,
	pt.category as pizza_category,
	sum(p.price*o.quantity) as revenues,
	ROW_NUMBER()over(partition by pt.category order by sum(p.price*o.quantity)  desc) as rn
from
	pizza_types pt
join
	pizzas p
on
	pt.pizza_type_id=p.pizza_type_id
join
	order_details o
on
	o.pizza_id=p.pizza_id
group by
	pt.name,pt.category
) abc
where
	rn <=3


