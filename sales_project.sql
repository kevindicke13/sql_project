/* Tables Overview
Part A */

ALTER TABLE ext_customers 
ADD PRIMARY KEY (customer_id);

ALTER TABLE ext_products 
ADD PRIMARY KEY (product_id);

ALTER TABLE ext_orders 
ADD PRIMARY KEY (order_id);

ALTER TABLE ext_order_items 
ADD PRIMARY KEY (order_item_id);

ALTER TABLE ext_promotions 
ADD PRIMARY KEY (promotion_id);

ALTER TABLE ext_orders 
ADD FOREIGN KEY (customer_id) REFERENCES ext_customers(customer_id);

ALTER TABLE ext_order_items 
ADD FOREIGN KEY (order_id) REFERENCES ext_orders(order_id);

ALTER TABLE ext_order_items 
ADD FOREIGN KEY (product_id) REFERENCES ext_products(product_id);

ALTER TABLE ext_promotions 
ADD FOREIGN KEY (product_id) REFERENCES ext_products(product_id);


--Part B

--1. Customer segmentation: How many customers are from each region?
SELECT *
FROM ext_promotions;

SELECT region, count(*) AS customer_count
FROM ext_customers
GROUP BY region 
ORDER BY customer_count DESC;

--2. Regional performance: What’s the average order total per region?
SELECT ext_customers.region , avg(ext_orders.total_amount) AS avg_order_total
FROM ext_customers
JOIN ext_orders
ON ext_customers.customer_id = ext_orders.customer_id 
GROUP BY ext_customers.region
ORDER BY avg_order_total DESC;

--3.Product mix analysis: Which product categories have the highest average price?
SELECT avg(unit_price) AS avg_unit_price, category
FROM ext_products
GROUP BY category
ORDER BY avg_unit_price;

--4.Trend analysis: Find the total revenue generated per month. Hint: you can use Date_trunc()
SELECT 
	  Date_trunc('month', order_date::date) AS MONTH,
	  sum(total_amount) AS total_revenue
FROM ext_orders	  
GROUP BY  Date_trunc('month', order_date::date)
ORDER BY MONTH;

--5.Product performance: List the top 10 products by total sales quantity.

SELECT sum(ext_order_items.quantity)AS total_quantity, ext_products.product_name
FROM ext_order_items
JOIN ext_products
ON ext_order_items.product_id = ext_products.product_id
GROUP BY ext_products.product_name
ORDER BY total_quantity desc
LIMIT 10;

--6.Customer loyalty / retention: Which customers placed more than 5 orders in the past 6 months?

SELECT ext_customers.first_name, ext_customers.last_name, count(ext_orders.customer_id) AS orders_count
FROM ext_customers
JOIN ext_orders
ON ext_customers.customer_id = ext_orders.customer_id
WHERE order_date BETWEEN '2025-04-01' AND '2025-10-01'
GROUP BY ext_customers.customer_id, ext_customers.first_name, ext_customers.last_name
HAVING count(ext_orders.customer_id) > 5
ORDER BY orders_count DESC;

--7.Pricing analysis: Find product categories whose average order item discount is greater than 10%.

SELECT products.category,
	AVG(order_item.discount) AS avg_discount_percent
FROM ext_order_items AS order_item
JOIN ext_products AS products
	ON order_item.product_id = products.product_id
GROUP BY products.category
HAVING AVG (order_item.discount) > 0.01
ORDER BY avg_discount_percent DESC;

--8. Regional target checking: Which regions have generated more than $50,000 in total sales?

SELECT ext_customers.region, 
	   sum(ext_orders.total_amount) AS total_sum_amount
FROM ext_customers 
JOIN ext_orders 
ON ext_customers.customer_id = ext_orders.customer_id
WHERE ext_orders.total_amount > 50.000
GROUP BY ext_customers.region
ORDER BY total_sum_amount DESC;

--9. RFM-style segmentation: Identify customers whose average order value is above the overall average.

SELECT ext_customers.first_name, ext_customers.last_name, 
	   avg(ext_orders.total_amount) AS avg_total_amount
FROM ext_customers 
JOIN ext_orders 
ON ext_customers.customer_id = ext_orders.customer_id
GROUP BY ext_customers.first_name, ext_customers.last_name
HAVING avg(ext_orders.total_amount) > (SELECT avg(total_amount) FROM ext_orders)
ORDER BY avg_total_amount desc;

--10. Catalog management: Which products have never been sold?

SELECT
	DISTINCT ext_order_items.product_id,
	ext_products.product_id
FROM ext_products 
FULL JOIN ext_order_items 
ON ext_products.product_id = ext_order_items.product_id 
WHERE quantity IS NULL
ORDER BY ext_products.product_id, ext_order_items.product_id;

--11. Regional sales by segment: Find the total revenue per category and region for the last quarter, showing only categories with total revenue above $10,000. Hint: you can use Date_trunc()
SELECT ext_customers.region, 
	   sum(ext_orders.total_amount) AS total_revenue,
	   ext_products.category
FROM ext_orders 
JOIN ext_order_items ON ext_orders.order_id = ext_order_items.order_id
JOIN ext_products ON ext_order_items.product_id = ext_products.product_id
JOIN ext_customers ON ext_orders.customer_id = ext_customers.customer_id
WHERE ext_orders.order_date BETWEEN '2025-07-15' AND '2025-10-15'
GROUP BY ext_customers.region, ext_products.category
HAVING sum(ext_orders.total_amount) > 10.000
ORDER BY total_revenue DESC;

--12. Cross-category affinity: Which customers bought products from more than 3 categories?

SELECT
	CONCAT(first_name, ' ' ,last_name) AS customer,
	COUNT(DISTINCT p.category)
FROM ext_orders o
JOIN ext_customers c ON o.customer_id = c.customer_id 
JOIN ext_order_items oi ON oi.order_id = o.order_id
JOIN ext_products p ON oi.product_id = p.product_id 
GROUP BY CONCAT(first_name, ' ' ,last_name)
HAVING COUNT(DISTINCT p.category) > 3
ORDER BY COUNT(DISTINCT p.category) DESC;

--13. Promotion performance: Calculate the average discount applied per product category, but only include categories with at least 50 items sold.

CREATE VIEW discount_view AS (
SELECT 
	category,
	AVG(oi.discount) AS average_discount
FROM ext_promotions pm
JOIN ext_order_items oi ON pm.product_id = oi.product_id 
JOIN ext_products pd ON pd.product_id = oi.product_id 
GROUP BY category
ORDER BY average_discount DESC
)

CREATE VIEW sold_view AS (
SELECT category,
	SUM(quantity) AS units_sold
FROM ext_products p
JOIN ext_order_items oi ON oi.product_id = p.product_id 
GROUP BY  category
HAVING SUM(quantity) > 50 
)

SELECT 
	dv.category,
	average_discount,
	units_sold
FROM discount_view dv
JOIN sold_view sv ON dv.category = sv.category

--14. Campaign analysis: Identify the top 5 customers who spent the most during an active promotion period. 

SELECT ext_customers.first_name, 
	   ext_customers.last_name,
	   sum(ext_orders.total_amount) AS total_spend
FROM ext_orders
JOIN ext_customers ON ext_orders.customer_id = ext_customers.customer_id
JOIN ext_order_items ON ext_orders.order_id = ext_order_items.order_id
JOIN ext_promotions ON ext_order_items.product_id = ext_promotions.product_id
WHERE ext_orders.order_date BETWEEN ext_promotions.start_date AND ext_promotions.end_date
GROUP BY ext_customers.customer_id, ext_customers.first_name, 
	     ext_customers.last_name 
ORDER BY total_spend DESC
LIMIT 5;	     

--15. Promo ROI : For each promotion, calculate the total incremental revenue (total sales of that product during the promotion period).

SELECT ext_promotions.promotion_id,
	   ext_promotions.product_id,
	   ext_products.product_name,
	   sum(ext_order_items.quantity * ext_order_items.unit_price * (1 - ext_order_items.discount)) AS total_revenue_during_promo
FROM ext_promotions 
JOIN ext_order_items ON ext_promotions.product_id = ext_order_items.product_id
JOIN ext_orders ON ext_order_items.order_id = ext_orders.order_id
JOIN ext_products ON ext_promotions.product_id = ext_products.product_id
--WHERE ext_orders.order_date BETWEEN ext_promotions.start_date AND ext_promotions.end_date 
GROUP BY ext_promotions.promotion_id, ext_promotions.product_id, ext_products.product_name
ORDER BY total_revenue_during_promo DESC;








