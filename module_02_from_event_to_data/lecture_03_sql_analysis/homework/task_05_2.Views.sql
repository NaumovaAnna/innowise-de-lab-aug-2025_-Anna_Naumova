CREATE VIEW FullStatShops AS
SELECT
    sh.shop_id,
    sh.shop_address,
    co.country_name AS country,
    COUNT(s.sales_id) AS total_sales_count,
    COALESCE(SUM(s.total_price), 0) AS total_sales_amount
FROM shops sh
INNER JOIN cities c
    ON sh.city_id = c.city_id
INNER JOIN countries co
    ON c.country_id = co.country_id
LEFT JOIN employees e
    ON sh.shop_id = e.shop_id
LEFT JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    sh.shop_id,
    sh.shop_address,
    co.country_name;