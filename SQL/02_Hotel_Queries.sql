-- HOTEL MANAGEMENT SYSTEM QUERIES

------------------------------------------------
-- 1. For every user, get user_id and last booked room_no
------------------------------------------------
SELECT b.user_id, b.room_no
FROM bookings b
JOIN (
    SELECT user_id, MAX(booking_date) AS last_booking
    FROM bookings
    GROUP BY user_id
) t ON b.user_id = t.user_id AND b.booking_date = t.last_booking;



------------------------------------------------
-- 2. Booking_id and total billing amount for bookings created in Nov 2021
------------------------------------------------
SELECT bc.booking_id,
       SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON b.booking_id = bc.booking_id
WHERE b.booking_date >= '2021-11-01' AND b.booking_date < '2021-12-01'
GROUP BY bc.booking_id;



------------------------------------------------
-- 3. Bill_id and bill amount for bills in Oct 2021 with amount > 1000
------------------------------------------------
SELECT bc.bill_id,
       SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE bc.bill_date >= '2021-10-01' AND bc.bill_date < '2021-11-01'
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;



------------------------------------------------
-- 4. Most ordered and least ordered item of each month in 2021
------------------------------------------------
WITH monthly_item_totals AS (
    SELECT DATE_TRUNC('month', bill_date) AS month,
           item_id,
           SUM(item_quantity) AS total_qty
    FROM booking_commercials
    WHERE bill_date >= '2021-01-01' AND bill_date < '2022-01-01'
    GROUP BY month, item_id
),
ranked_items AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rnk_max,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS rnk_min
    FROM monthly_item_totals
)
SELECT month, item_id, total_qty,
       CASE 
           WHEN rnk_max = 1 THEN 'Most Ordered'
           WHEN rnk_min = 1 THEN 'Least Ordered'
       END AS item_category
FROM ranked_items
WHERE rnk_max = 1 OR rnk_min = 1
ORDER BY month;



------------------------------------------------
-- 5. Customers with second-highest bill value of each month in 2021
------------------------------------------------
WITH bills AS (
    SELECT DATE_TRUNC('month', bc.bill_date) AS month,
           b.user_id,
           SUM(bc.item_quantity * i.item_rate) AS bill_value
    FROM booking_commercials bc
    JOIN bookings b ON b.booking_id = bc.booking_id
    JOIN items i ON i.item_id = bc.item_id
    WHERE bc.bill_date >= '2021-01-01' AND bc.bill_date < '2022-01-01'
    GROUP BY month, b.user_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY bill_value DESC) AS bill_rank
    FROM bills
)
SELECT month, user_id, bill_value
FROM ranked
WHERE bill_rank = 2
ORDER BY month;
