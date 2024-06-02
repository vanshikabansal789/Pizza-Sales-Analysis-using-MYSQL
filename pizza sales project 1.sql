create database pizzahut;
use pizzahut;
create table orders ( order_id int not null, order_date date not null, order_time time not null, primary key(order_id)); -- csv file is big so we created the table structure here & then used table import wizard
create table order_details ( order_details_id int not null, order_id int not null, pizza_id text not null, quantity int not null, primary key (order_details_id) ); -- csv file is big so we created the table structure here & then used table import wizard
-- Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id) AS Total_orders
FROM
    orders;

-- Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id;
    
    -- Identify the highest priced pizza.
    SELECT 
    pt.name, p.price
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.
SELECT 
    p.size, COUNT(od.order_details_id) AS total_times_ordered
FROM
    pizzas AS p
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_times_ordered DESC
LIMIT 1;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT 
    pt.name, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;

-- Find the total quantity of each pizza category ordered.
SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Determine the distribution of orders by hour of the day.
select hour(order_time) , count(order_id)
from orders
group by hour(order_time)
order by hour(order_time);

-- Find the category wise distribution of pizza orders.
select category, count(name)
from pizza_types
group by category;

-- Group the orders by date and calculate the average no. of pizzas ordered per day.
SELECT 
    round(AVG(qty_ordered),0) as average_orders_per_day
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS qty_ordered
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS p1;
    
    -- Determine the top 3 most ordered pizza types based on their revenue.
    SELECT 
    pt.name, ROUND(SUM(od.quantity * p.price), 0) AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;
    
    -- 	Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category, round((ROUND(SUM(od.quantity * p.price), 0)/(select ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON od.pizza_id = p.pizza_id)*100),0) as percentage_contribution
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

-- Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over (order by order_date) as cumulative_revenue
from
(select o.order_date, sum(od.quantity * p.price) as revenue
from orders as o
JOIN order_details as od
ON o.order_id=od.order_id
JOIN pizzas as p
ON od.pizza_id=p.pizza_id
group by o.order_date) as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name, revenue
from
(select category, name, revenue, 
rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name, sum(od.quantity*p.price) as revenue
from pizza_types as pt
JOIN pizzas as p
on pt.pizza_type_id=p.pizza_type_id
JOIN order_details as od
on od.pizza_id=p.pizza_id
group by pt.category, pt.name) as A) as B 
where rn<=3;
