-- ============================================
-- SQL Business Analytics â€” Query Portfolio
-- ============================================

-- Q1: Monthly Revenue with Month-over-Month Growth
WITH monthly AS (
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        SUM(amount) AS revenue
    FROM orders
    GROUP BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 
          / LAG(revenue) OVER (ORDER BY month), 1) AS mom_growth_pct
FROM monthly;

-- Q2: Customer Lifetime Value (CLV)
SELECT 
    customer_id,
    MIN(order_date) AS first_order,
    MAX(order_date) AS last_order,
    DATEDIFF(MAX(order_date), MIN(order_date)) AS lifespan_days,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(amount), 2) AS lifetime_value,
    ROUND(SUM(amount) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders
GROUP BY customer_id
ORDER BY lifetime_value DESC
LIMIT 20;

-- Q3: Cohort Retention Analysis
WITH first_purchase AS (
    SELECT customer_id, MIN(DATE_FORMAT(order_date, '%Y-%m')) AS cohort
    FROM orders GROUP BY customer_id
),
activity AS (
    SELECT 
        o.customer_id,
        fp.cohort,
        PERIOD_DIFF(DATE_FORMAT(o.order_date, '%Y%m'), DATE_FORMAT(STR_TO_DATE(CONCAT(fp.cohort, '-01'), '%Y-%m-%d'), '%Y%m')) AS month_number
    FROM orders o
    JOIN first_purchase fp ON o.customer_id = fp.customer_id
)
SELECT 
    cohort,
    month_number,
    COUNT(DISTINCT customer_id) AS active_customers
FROM activity
GROUP BY cohort, month_number
ORDER BY cohort, month_number;

-- Q4: Running Total and 3-Month Moving Average
SELECT 
    month,
    revenue,
    SUM(revenue) OVER (ORDER BY month) AS running_total,
    ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3m
FROM monthly_revenue;
