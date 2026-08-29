-- SQL for Business Analytics
-- Dialect: MySQL 8.0

-- Q1. Monthly revenue with month-over-month growth.
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
        / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 1) AS mom_growth_pct
FROM monthly
ORDER BY month;

-- Q2. Customer lifetime value and order frequency.
SELECT
    customer_id,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    COUNT(*) AS completed_orders,
    ROUND(SUM(amount), 2) AS lifetime_value,
    ROUND(AVG(amount), 2) AS average_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY customer_id
ORDER BY lifetime_value DESC
LIMIT 20;

-- Q3. Monthly cohort retention.
WITH first_purchase AS (
    SELECT customer_id, DATE_FORMAT(MIN(order_date), '%Y-%m-01') AS cohort_month
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
), activity AS (
    SELECT
        o.customer_id,
        fp.cohort_month,
        TIMESTAMPDIFF(MONTH, STR_TO_DATE(fp.cohort_month, '%Y-%m-%d'),
            DATE_FORMAT(o.order_date, '%Y-%m-01')) AS month_number
    FROM orders o
    JOIN first_purchase fp USING (customer_id)
    WHERE o.status = 'Completed'
), cohort_size AS (
    SELECT cohort_month, COUNT(DISTINCT customer_id) AS customers
    FROM activity
    WHERE month_number = 0
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.month_number,
    COUNT(DISTINCT a.customer_id) AS active_customers,
    ROUND(100.0 * COUNT(DISTINCT a.customer_id) / cs.customers, 1) AS retention_rate_pct
FROM activity a
JOIN cohort_size cs USING (cohort_month)
GROUP BY a.cohort_month, a.month_number, cs.customers
ORDER BY a.cohort_month, a.month_number;

-- Q4. Running revenue and three-month moving average.
WITH monthly AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(amount) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_revenue,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_average_3m
FROM monthly
ORDER BY month;

-- Q5. Products frequently bought together.
SELECT
    p1.product_name AS product_a,
    p2.product_name AS product_b,
    COUNT(*) AS orders_together
FROM order_items i1
JOIN order_items i2 ON i1.order_id = i2.order_id AND i1.product_id < i2.product_id
JOIN products p1 ON p1.product_id = i1.product_id
JOIN products p2 ON p2.product_id = i2.product_id
GROUP BY p1.product_name, p2.product_name
HAVING COUNT(*) >= 3
ORDER BY orders_together DESC
LIMIT 25;

-- Q6. Product ranking within each category.
WITH product_sales AS (
    SELECT p.category, p.product_name, SUM(oi.line_amount) AS revenue
    FROM order_items oi
    JOIN orders o USING (order_id)
    JOIN products p USING (product_id)
    WHERE o.status = 'Completed'
    GROUP BY p.category, p.product_name
)
SELECT
    category,
    product_name,
    ROUND(revenue, 2) AS revenue,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
FROM product_sales
ORDER BY category, category_rank, product_name;

-- Q7. Customers inactive for 90+ days.
SELECT
    c.customer_id,
    c.customer_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(CURRENT_DATE, MAX(o.order_date)) AS days_since_last_order,
    ROUND(SUM(o.amount), 2) AS historical_value
FROM customers c
JOIN orders o USING (customer_id)
WHERE o.status = 'Completed'
GROUP BY c.customer_id, c.customer_name
HAVING DATEDIFF(CURRENT_DATE, MAX(o.order_date)) >= 90
ORDER BY historical_value DESC;

-- Q8. Data-quality checks before reporting.
SELECT
    COUNT(*) AS order_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(customer_id IS NULL) AS missing_customer_ids,
    SUM(amount < 0) AS negative_amounts,
    SUM(status NOT IN ('Completed', 'Cancelled', 'Returned')) AS invalid_statuses
FROM orders;
