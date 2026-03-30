-- SECTION 1: SALES & REVENUE


-- Q1: Monthly Revenue Trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m')  AS month,
    ROUND(SUM(total_amount), 2)       AS total_revenue
FROM orders
WHERE order_status = 'completed'
GROUP BY month
ORDER BY month;

-- Q2: Revenue by Order Status
SELECT 
order_status, 
count(order_status) as Total_Count,round(sum(total_amount)) as total_Amount
FROM orders
GROUP BY order_status
ORDER BY Count(order_status) DESC;

-- Q3: Top 10 Highest Revenue Orders
SELECT order_id,
       user_id,
       order_status,
       total_amount
FROM orders
Order by order_id
LIMIT 10;       

-- Q4: Average Order Value Per Month
SELECT
DATE_FORMAT(order_date,'%Y-%m') AS month,
ROUND(AVG(total_amount)) as Average_amount_per_month,
count(order_id) as order_id_count
FROM orders
group by month
order by month;



-- SECTION 2: PRODUCTS & CATEGORIES



-- Q5: Top 5 Best-Selling Categories by Quantity Sold
SELECT
products.category,
sum(order_items.quantity) as total_quantity
from order_items
inner join products on order_items.product_id=products.product_id
group by products.category
LIMIT 5;

-- Q6: Top 10 Products by Revenue
select
products.product_name,
products.category,
sum(order_items.item_total) as item_Amount
from products 
Join order_items on 
products.product_id=order_items.product_id
Group by order_items.product_id,products.product_name,products.category
order by item_Amount DESC
LIMIT 10;

-- Q7: Category-wise Average Product Rating
SELECT
category,
count(product_name),
AVG(rating) as Average_product_rating
from products  
group by category
order by Average_product_rating DESC;

-- Q8: Price Distribution by Category (Min, Avg, Max)
SELECT
category,
count(product_name) total_product,
MIN(price) as Min_price,
MAX(price) as Max_Price,
AVG(price) as Average_price
from products
group by category
order by total_product DESC;



-- SECTION 3: USERS & DEMOGRAPHICS



-- Q9: New User Signups Per Month
SELECT
DATE_FORMAT(signup_date,'%Y-%m') as month,
count(user_id) as Number_of_users
from users
group by month
order by month;

-- Q10: Gender-wise Distribution of Users
SELECT
gender,
COUNT(user_id) AS total_users,
ROUND(COUNT(user_id) * 100.0 / SUM(COUNT(user_id)) OVER(), 2) AS percentage
from users
group by gender;

-- Q11: Top 10 Cities by Number of Users
SELECT
city,
COUNT(user_id) as Total_users
from users
group by city
order by Total_users DESC
LIMIT 10;

-- Q12: Top 10 Users by Total Spending
SELECT
u.user_id,
u.name,
ROUND(sum(o.total_amount),2) as Total_Spending
from orders o 
join users u on
o.user_id=u.user_id
where o.order_status='completed'
group by o.user_id,u.name
order by Total_Spending DESC
LIMIT 10;



-- SECTION 4: REVIEWS & RATINGS



-- Q13: Rating Distribution (1 to 5)
SELECT 
rating,
count(review_id) as total_rating,
ROUND(COUNT(review_id)*100.0/SUM(COUNT(review_id)) over(),2) as Rating_Distribution
FROM reviews
group by rating
order by rating;

-- Q14: Average Rating per Category
Select
p.category,
AVG(r.rating) AS Average_rating,
count(r.review_id) as total_review
from reviews r
JOIN products p on r.product_id=p.product_id
GROUP BY p.category
order by Average_rating DESC;

-- Q15: Monthly Average Rating Trend
SELECT
DATE_FORMAT(review_date,'%Y-%m') as month,
avg(rating) as average_rating_per_month
from reviews
group by month
order by month;

-- Q16: Top 5 Most Reviewed Products
 SELECT
 p.product_name,
 p.category,
 count(r.review_id) as Total_review,
 ROUND(AVG(r.rating),2) as avg_rating
 from reviews r
 join products p on r.product_id=p.product_id
 group by r.product_id,p.product_name,p.category
 order by Total_review DESC
 LIMIT 5;



-- SECTION 5: USER BEHAVIOR (EVENTS)



-- Q17: Event Type Breakdown (view / cart / purchase)
SELECT
event_type,
count(event_type) as total_event
from events
group by event_type
Order by total_event DESC;

-- Q18: Top 10 Most Viewed Products
SELECT
 p.product_name,
 e.event_type,
 p.category,
 count(e.event_type) as total_event
 from events e 
 join products p on e.product_id=p.product_id
 where event_type='view'
 group by p.product_id,p.product_name,p.category
 order by total_event DESC
 LIMIT 10;

-- Q19: Events Per Day of Week
SELECT
DAYNAME(event_timestamp)  AS day_of_week,
DAYOFWEEK(event_timestamp) AS day_num,
COUNT(event_id) AS total_events
FROM events
GROUP BY day_of_week, day_num
ORDER BY day_num;



SECTION 6: ADVANCED / JOIN QUERIES



-- Q21: Users Who Never Placed an Order
select
u.user_id,
u.name,
o.order_id
from users u 
left join orders o on u.user_id=o.user_id
where o.order_id is NULL;

-- Q22: Products Ordered But Never Reviewed
SELECT
p.product_id,
p.product_name,
p.category,
count(o.order_item_id) as total_times_order
from order_items o
join products p on o.product_id=p.product_id
left join reviews r on o.product_id=r.product_id
where review_id is NULL
GROUP BY product_id,product_name,category;


-- Q23: Average Days Between Signup and First Order
 SELECT
    ROUND(AVG(DATEDIFF(signup_date,first_order_place)), 2) AS Average_time_for_first_order
FROM (
    SELECT
        u.user_id,
        u.signup_date,
        MIN(o.order_date) AS first_order_place
    FROM users u
    JOIN orders o ON u.user_id = o.user_id
    GROUP BY u.user_id, u.signup_date
) sub;

-- Repeat customers — users with more than 1 order
SELECT
    order_count_bucket,
    COUNT(*) AS num_users
FROM (
    SELECT
        user_id,
        CASE
            WHEN COUNT(order_id) = 1            THEN '1 order'
            WHEN COUNT(order_id) BETWEEN 2 AND 3 THEN '2-3 orders'
            WHEN COUNT(order_id) BETWEEN 4 AND 6 THEN '4-6 orders'
            ELSE '7+ orders'
        END AS order_count_bucket
    FROM orders
    GROUP BY user_id
) bucketed
GROUP BY order_count_bucket
ORDER BY
    CASE order_count_bucket
        WHEN '1 order'    THEN 1
        WHEN '2-3 orders' THEN 2
        WHEN '4-6 orders' THEN 3
        ELSE 4
     END;   









