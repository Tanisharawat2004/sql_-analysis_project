create database pizza_sales;
CREATE TABLE orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);


use pizza_sales;


CREATE TABLE order_details (
    order_details INT NOT NULL PRIMARY KEY,
    order_id INT NOT NULL,
    pizza_id TEXT NOT NULL,
    order_time INT NOT NULL
);



show tables;



# basic questions 
# 1.retrive the total number of orders placed


SELECT 
    COUNT(order_id) AS total_orders
FROM
    order_details;
    
    
    

# 2. calculate the total revenue generated from pizza sales
select * from pizzas;
select * from order_details;


SELECT 
   round(sum(p.price * o.order_time),2) AS total_revenue
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id;



# 3. identify the highest priced pizza

select * from pizzas;
select * from pizza_types;

SELECT 
    p.name, p2.price
FROM
    pizza_types AS p
        JOIN
    pizzas AS p2 ON p.pizza_type_id = p2.pizza_type_id
ORDER BY p2.price DESC limit 1;




# 4. identify the most common pizza size orderd
select * from pizzas;

SELECT 
    p.size, COUNT(o.order_details) AS order_count
FROM
    pizzas AS p
        JOIN
    order_details AS o ON p.pizza_id = o.pizza_id
GROUP BY p.size
ORDER BY order_count DESC;




# 5. list the top 5 most orderd pizzaa types along with their quantities

select * from pizza_types;
select * from order_details;
select * from orders;
select * from pizzas;


SELECT 
    pt.name, SUM(od.order_time) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;





-- intermediate query
#1. join the nesscessary tables to find the quanitty of each pizza

select * from pizza_types;
select * from order_details;
select * from orders;
select * from pizzas;



SELECT 
    pt.category, SUM(od.order_time) AS quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;




#determine the distribution of the orders by hours of the day

SELECT 
    HOUR(order_time) AS hours,
    COUNT(order_id) AS distribution_of_orders
FROM
    orders
GROUP BY HOUR(order_time);




# join the relatable tables to find the category wise ditribution of pizzas

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;



#  group the orders by date  and calculate the average no of pizzas orderd per day

select * from orders;
select * from order_details;


SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizzas_orderd
FROM
    (SELECT 
        o.order_date, SUM(od.order_time) AS quantity
    FROM
        order_details AS od
    JOIN orders AS o ON od.order_id = o.order_id
    GROUP BY o.order_date) AS order_quantity;


-- determine the top 3 most ordered pizza types based on revenue

select * from pizza_types;
select * from pizzas;
select * from order_details;


SELECT 
    pt.name, SUM(p.price * od.order_time) AS total_revenue
FROM
    order_details AS od
        JOIN
    pizzas AS p ON p.pizza_id = od.pizza_id
        JOIN
    pizza_types AS pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC
LIMIT 3;







# advanced query


-- 1. calculated the percentage contiribution of each pizza_type as total_revenue


SELECT 
    pt.category,
    (SUM(od.order_time * p.price) / (SELECT 
            ROUND(SUM(od.order_time * p.price), 2) AS total_sales
        FROM
            order_details AS od
                JOIN
            pizzas AS p ON od.pizza_id = p.pizza_id)) * 100 AS revenue
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY revenue; 



# 3. cumulative revenue generated over the time
select order_date,
sum(revenue) over(order by order_date) as cumulative_revenue
from
(
select o.order_date ,sum(p.price * od.order_time) as revenue
from orders as o
join order_details as od on o.order_id = od.order_id 
join pizzas as p
on p.pizza_id = od.pizza_id 
group by o.order_date ) 
as sales;





# determine the top 3  most ordered pizza types revenue on each pizza category

SELECT 
    *
FROM
    pizza_types;

select name ,revenue from
(select  category , name ,revenue,
rank () over(partition by category  order by revenue desc) as rn
from
(
select  pt.name,pt.category, sum(p.price * od.order_time) as revenue
from  pizza_types as pt
join pizzas as p on p.pizza_type_id = p.pizza_type_id
join order_details as od on od.pizza_id= p.pizza_id
group by pt.category , pt.name) as  a 
) as b
where rn <=3;
