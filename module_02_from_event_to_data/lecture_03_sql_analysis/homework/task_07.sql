WITH shop_sales AS (
    SELECT
        e.shop_id,
        COUNT(s.sales_id)  AS total_sales_count,
        SUM(s.total_price) AS total_sales_amount
    FROM sales s
    JOIN employees e ON s.employee_id = e.employee_id
    GROUP BY e.shop_id
    HAVING COUNT(s.sales_id) >= 2
)
SELECT
    co.country_name AS country,
    sh.address      AS shop_address,
    ss.total_sales_count,
    ROUND(ss.total_sales_amount::numeric, 2) AS total_sales_amount,
    ROUND(SUM(ss.total_sales_amount) OVER (PARTITION BY co.country_id)::numeric, 2)
        AS country_total,
    ROUND((ss.total_sales_amount / SUM(ss.total_sales_amount) OVER (PARTITION BY co.country_id))::numeric, 4)
        AS country_sales_share,
    RANK() OVER (PARTITION BY co.country_id ORDER BY ss.total_sales_amount DESC)
        AS shop_rank_in_country,
    ROUND(SUM(ss.total_sales_amount) OVER (PARTITION BY co.country_id ORDER BY ss.total_sales_amount DESC)::numeric, 2)
        AS cumulative_country_revenue
FROM shops sh
JOIN shop_sales ss ON ss.shop_id = sh.shop_id
JOIN cities    ci ON sh.city_id = ci.city_id
JOIN countries co ON ci.country_id = co.country_id
ORDER BY country, shop_rank_in_country;