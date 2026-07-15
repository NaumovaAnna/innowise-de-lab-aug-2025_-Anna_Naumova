SELECT
    monthly_with_previous.sale_month,
    monthly_with_previous.monthly_revenue,
    monthly_with_previous.previous_month_revenue,
    monthly_with_previous.monthly_revenue - monthly_with_previous.previous_month_revenue AS revenue_diff_vs_previous
FROM (
    SELECT
        monthly_sales.sale_month,
        monthly_sales.monthly_revenue,
        COALESCE(
            LAG(monthly_sales.monthly_revenue) OVER (
                ORDER BY monthly_sales.sale_month
            ),
            0
        ) AS previous_month_revenue
    FROM (
        SELECT
            DATE_TRUNC('month', s.sales_timestamp::timestamp) AS sale_month,
            SUM(s.total_price) AS monthly_revenue
        FROM sales s
        INNER JOIN employees e
            ON s.employee_id = e.employee_id
        INNER JOIN shops sh
            ON e.shop_id = sh.shop_id
        INNER JOIN cities c
            ON sh.city_id = c.city_id
        INNER JOIN countries co
            ON c.country_id = co.country_id
        WHERE co.country_name = 'Germany'
          AND s.sales_timestamp <> ''
        GROUP BY DATE_TRUNC('month', s.sales_timestamp::timestamp)
    ) AS monthly_sales
) AS monthly_with_previous
ORDER BY monthly_with_previous.sale_month
LIMIT 24;