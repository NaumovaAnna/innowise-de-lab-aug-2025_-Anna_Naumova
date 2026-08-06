-- 1. Выручка по месяцам

SELECT
    dd.year_num,
    dd.month_num,
    dd.month_name,
    SUM(fs.net_revenue) AS monthly_revenue,
    SUM(fs.profit) AS monthly_profit
FROM gold.fact_sales fs
JOIN gold.dim_date dd
    ON fs.date_key = dd.date_key
GROUP BY
    dd.year_num,
    dd.month_num,
    dd.month_name
ORDER BY
    dd.year_num,
    dd.month_num;


-- 2. Топ-10 клиентов по выручке

SELECT
    dc.customer_id,
    dc.full_name,
    SUM(fs.net_revenue) AS total_revenue,
    COUNT(*) AS sales_count
FROM gold.fact_sales fs
JOIN gold.dim_customer dc
    ON fs.customer_key = dc.customer_key
GROUP BY
    dc.customer_id,
    dc.full_name
ORDER BY
    total_revenue DESC
LIMIT 10;


-- 3. Анализ продаж по сотрудникам

SELECT
    de.employee_id,
    de.full_name AS employee_name,
    COUNT(*) AS sales_count,
    SUM(fs.net_revenue) AS total_revenue,
    SUM(fs.profit) AS total_profit
FROM gold.fact_sales fs
JOIN gold.dim_employee de
    ON fs.employee_key = de.employee_key
GROUP BY
    de.employee_id,
    de.full_name
ORDER BY
    total_profit DESC;


-- 4. Самые продаваемые товары

SELECT
    dp.product_id,
    dp.product_name,
    dc.category_name,
    SUM(fs.quantity) AS total_quantity,
    SUM(fs.net_revenue) AS total_revenue
FROM gold.fact_sales fs
JOIN gold.dim_product dp
    ON fs.product_key = dp.product_key
JOIN gold.dim_category dc
    ON fs.category_key = dc.category_key
GROUP BY
    dp.product_id,
    dp.product_name,
    dc.category_name
ORDER BY
    total_quantity DESC
LIMIT 10;


-- 5. Средний чек и маржинальность по магазинам

SELECT
    sh.shop_id,
    loc.country_name,
    loc.city_name,
    sh.address,
    COUNT(*) AS sales_count,
    SUM(fs.net_revenue) AS total_revenue,
    ROUND(AVG(fs.net_revenue), 2) AS average_check,
    SUM(fs.profit) AS total_profit,
    ROUND(AVG(fs.margin_percent), 2) AS avg_margin_percent
FROM gold.fact_sales fs
JOIN gold.dim_shop sh
    ON fs.shop_key = sh.shop_key
JOIN gold.dim_location loc
    ON fs.location_key = loc.location_key
GROUP BY
    sh.shop_id,
    loc.country_name,
    loc.city_name,
    sh.address
ORDER BY
    total_revenue DESC;