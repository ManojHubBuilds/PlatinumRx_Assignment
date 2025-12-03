-- CLINIC MANAGEMENT SYSTEM QUERIES

----------------------------------------------------------
-- 1. Revenue from each sales channel in a given year (2021)
----------------------------------------------------------
SELECT sales_channel,
       SUM(amount) AS total_revenue
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY sales_channel;



----------------------------------------------------------
-- 2. Top 10 most valuable customers in 2021
----------------------------------------------------------
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE EXTRACT(YEAR FROM datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;



----------------------------------------------------------
-- 3. Month-wise revenue, expense, profit, status (2021)
----------------------------------------------------------
WITH revenue AS (
    SELECT DATE_TRUNC('month', datetime) AS month,
           SUM(amount) AS total_revenue
    FROM clinic_sales
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY month
),
expense AS (
    SELECT DATE_TRUNC('month', datetime) AS month,
           SUM(amount) AS total_expense
    FROM expenses
    WHERE EXTRACT(YEAR FROM datetime) = 2021
    GROUP BY month
)
SELECT r.month,
       r.total_revenue,
       e.total_expense,
       (r.total_revenue - e.total_expense) AS profit,
       CASE 
           WHEN (r.total_revenue - e.total_expense) > 0 THEN 'Profitable'
           ELSE 'Not Profitable'
       END AS status
FROM revenue r
LEFT JOIN expense e ON r.month = e.month
ORDER BY r.month;



----------------------------------------------------------
-- 4. For each city, find the most profitable clinic in a month
----------------------------------------------------------
WITH clinic_profit AS (
    SELECT c.city,
           c.cid,
           DATE_TRUNC('month', cs.datetime) AS month,
           SUM(cs.amount) - (
               SELECT COALESCE(SUM(e.amount), 0)
               FROM expenses e
               WHERE e.cid = c.cid
               AND DATE_TRUNC('month', e.datetime) = DATE_TRUNC('month', cs.datetime)
           ) AS profit_value
    FROM clinics c
    JOIN clinic_sales cs ON cs.cid = c.cid
    WHERE EXTRACT(YEAR FROM cs.datetime) = 2021
    GROUP BY c.city, c.cid, month
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city, month ORDER BY profit_value DESC) AS rnk
    FROM clinic_profit
)
SELECT city, cid, month, profit_value
FROM ranked
WHERE rnk = 1
ORDER BY month, city;



----------------------------------------------------------
-- 5. For each state, find the second least profitable clinic in a month
----------------------------------------------------------
WITH clinic_profit AS (
    SELECT c.state,
           c.cid,
           DATE_TRUNC('month', cs.datetime) AS month,
           SUM(cs.amount) - (
               SELECT COALESCE(SUM(e.amount), 0)
               FROM expenses e
               WHERE e.cid = c.cid
               AND DATE_TRUNC('month', e.datetime) = DATE_TRUNC('month', cs.datetime)
           ) AS profit_value
    FROM clinics c
    JOIN clinic_sales cs ON cs.cid = c.cid
    GROUP BY c.state, c.cid, month
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state, month ORDER BY profit_value ASC) AS rnk
    FROM clinic_profit
)
SELECT state, cid, month, profit_value
FROM ranked
WHERE rnk = 2
ORDER BY month, state;
