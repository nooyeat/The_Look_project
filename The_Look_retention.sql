WITH valid_orders AS (
    SELECT *
    FROM order_segment
    WHERE status NOT IN ('cancelled', 'returned')
),
first_months AS (
    SELECT 
        user_id,
        DATE_FORMAT(MIN(created_at), '%Y-%m-01') AS first_month
    FROM valid_orders
    GROUP BY user_id
),
order_months AS (
    SELECT 
        v.user_id,
        DATE_FORMAT(v.created_at, '%Y-%m-01') AS order_month,
        fm.first_month,
        PERIOD_DIFF(DATE_FORMAT(v.created_at, '%Y%m'), DATE_FORMAT(fm.first_month, '%Y%m')) AS month_diff
    FROM valid_orders v
    JOIN first_months fm ON v.user_id = fm.user_id
),
filtered AS (
    SELECT *
    FROM order_months
    WHERE first_month BETWEEN '2024-04-01' AND '2025-03-01'
      AND month_diff BETWEEN 0 AND 11
),
retention_counts AS (
    SELECT 
        first_month,
        COUNT(DISTINCT CASE WHEN month_diff = 0 THEN user_id END) AS MONTH_0,
        COUNT(DISTINCT CASE WHEN month_diff = 1 THEN user_id END) AS M1,
        COUNT(DISTINCT CASE WHEN month_diff = 2 THEN user_id END) AS M2,
        COUNT(DISTINCT CASE WHEN month_diff = 3 THEN user_id END) AS M3,
        COUNT(DISTINCT CASE WHEN month_diff = 4 THEN user_id END) AS M4,
        COUNT(DISTINCT CASE WHEN month_diff = 5 THEN user_id END) AS M5,
        COUNT(DISTINCT CASE WHEN month_diff = 6 THEN user_id END) AS M6,
        COUNT(DISTINCT CASE WHEN month_diff = 7 THEN user_id END) AS M7,
        COUNT(DISTINCT CASE WHEN month_diff = 8 THEN user_id END) AS M8,
        COUNT(DISTINCT CASE WHEN month_diff = 9 THEN user_id END) AS M9,
        COUNT(DISTINCT CASE WHEN month_diff = 10 THEN user_id END) AS M10,
        COUNT(DISTINCT CASE WHEN month_diff = 11 THEN user_id END) AS M11,
        COUNT(DISTINCT CASE WHEN month_diff = 12 THEN user_id END) AS M12
    FROM filtered
    GROUP BY first_month
)
SELECT 
    first_month,
    MONTH_0,
    ROUND(M1 * 100.0 / MONTH_0, 1) AS MONTH_1,
    ROUND(M2 * 100.0 / MONTH_0, 1) AS MONTH_2,
    ROUND(M3 * 100.0 / MONTH_0, 1) AS MONTH_3,
    ROUND(M4 * 100.0 / MONTH_0, 1) AS MONTH_4,
    ROUND(M5 * 100.0 / MONTH_0, 1) AS MONTH_5,
    ROUND(M6 * 100.0 / MONTH_0, 1) AS MONTH_6,
    ROUND(M7 * 100.0 / MONTH_0, 1) AS MONTH_7,
    ROUND(M8 * 100.0 / MONTH_0, 1) AS MONTH_8,
    ROUND(M9 * 100.0 / MONTH_0, 1) AS MONTH_9,
    ROUND(M10 * 100.0 / MONTH_0, 1) AS MONTH_10,
    ROUND(M11 * 100.0 / MONTH_0, 1) AS MONTH_11,
    ROUND(M12 * 100.0 / MONTH_0, 1) AS MONTH_12
FROM retention_counts
ORDER BY first_month;
