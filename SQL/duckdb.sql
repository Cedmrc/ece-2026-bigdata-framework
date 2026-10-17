-- Exercise 1: Average orders per user

SELECT
    ROUND(
        (SELECT COUNT(*) FROM orders) * 1.0 /
        (SELECT COUNT(*) FROM users),
        2
    ) AS avg_orders_per_user,

    ROUND(
        (SELECT AVG(quantity) FROM orders),
        2
    ) AS avg_quantity_per_order;

-- Exercise 2: First and last order

SELECT
    u.username,
    MIN(o.date) AS first_order,
    MAX(o.date) AS last_order,
    DATE_DIFF(
        'day',
        MIN(o.date)::DATE,
        MAX(o.date)::DATE
    ) AS days_between
FROM users u
JOIN orders o
ON u.uuid = o.user_uuid
GROUP BY u.uuid, u.username
ORDER BY u.username;

-- Exercise 3: Hour with highest sales

SELECT
    HOUR(date) AS order_hour,
    SUM(quantity) AS total_quantity
FROM orders
GROUP BY order_hour
ORDER BY total_quantity DESC
LIMIT 1;

-- Exercise 4: Monthly sales variation

WITH monthly AS (
    SELECT
        product,
        STRFTIME(date, '%Y-%m') AS month,
        SUM(quantity) AS quantity
    FROM orders
    GROUP BY product, month
),
previous_month AS (
    SELECT
        product,
        month,
        quantity,
        LAG(quantity) OVER (
            PARTITION BY product
            ORDER BY month
        ) AS previous_quantity
    FROM monthly
)
SELECT
    product,
    month,
    quantity,
    previous_quantity,
    ROUND(
        100.0 * (quantity - previous_quantity)
        / NULLIF(previous_quantity, 0),
        2
    ) AS variation_pct
FROM previous_month
ORDER BY product, month;

-- Exercise 5: Users who ordered every product

SELECT
    u.username,
    u.name,
    COUNT(DISTINCT o.product) AS different_products
FROM users u
JOIN orders o
ON u.uuid = o.user_uuid
GROUP BY u.uuid, u.username, u.name
HAVING COUNT(DISTINCT o.product) = (
    SELECT COUNT(DISTINCT product)
    FROM orders
)
ORDER BY u.username;