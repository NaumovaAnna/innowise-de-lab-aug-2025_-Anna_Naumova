-- Создание Mart Layer

CREATE SCHEMA IF NOT EXISTS mart;


DROP VIEW IF EXISTS mart.mart_daily_anomaly;

CREATE VIEW mart.mart_daily_anomaly AS
WITH daily_revenue AS (
    SELECT
        fs.shop_key,
        fs.location_key,
        dd.full_date,
        SUM(fs.net_revenue) AS revenue
    FROM gold.fact_sales fs
    JOIN gold.dim_date dd
        ON fs.date_key = dd.date_key
    GROUP BY
        fs.shop_key,
        fs.location_key,
        dd.full_date
)
SELECT
    dr.shop_key,
    dr.location_key,
    loc.country_name,
    loc.city_name,
    sh.address AS shop_address,
    dr.full_date,
    dr.revenue,
    COALESCE((
        SELECT AVG(prev.revenue)
        FROM daily_revenue prev
        WHERE prev.shop_key = dr.shop_key
          AND prev.full_date >= dr.full_date - INTERVAL '30 days'
          AND prev.full_date < dr.full_date
    ), dr.revenue) AS expected_revenue,
    dr.revenue - COALESCE((
        SELECT AVG(prev.revenue)
        FROM daily_revenue prev
        WHERE prev.shop_key = dr.shop_key
          AND prev.full_date >= dr.full_date - INTERVAL '30 days'
          AND prev.full_date < dr.full_date
    ), dr.revenue) AS uplift
FROM daily_revenue dr
JOIN gold.dim_shop sh
    ON dr.shop_key = sh.shop_key
JOIN gold.dim_location loc
    ON dr.location_key = loc.location_key;


DROP VIEW IF EXISTS mart.mart_shop_daily;

CREATE VIEW mart.mart_shop_daily AS
WITH daily_shop AS (
    SELECT
        fs.shop_key,
        fs.location_key,
        dd.full_date,
        SUM(fs.net_revenue) AS daily_revenue,
        SUM(fs.profit) AS daily_profit,
        COUNT(*) AS sales_count
    FROM gold.fact_sales fs
    JOIN gold.dim_date dd
        ON fs.date_key = dd.date_key
    GROUP BY
        fs.shop_key,
        fs.location_key,
        dd.full_date
)
SELECT
    ds.shop_key,
    ds.location_key,
    loc.country_name,
    loc.city_name,
    sh.address AS shop_address,
    ds.full_date,
    ds.daily_revenue,
    ds.daily_profit,
    ds.sales_count,
    AVG(ds.daily_revenue) OVER (
        PARTITION BY ds.shop_key
    ) AS avg_daily_revenue
FROM daily_shop ds
JOIN gold.dim_shop sh
    ON ds.shop_key = sh.shop_key
JOIN gold.dim_location loc
    ON ds.location_key = loc.location_key;


DROP VIEW IF EXISTS mart.mart_customer_behavior;

CREATE VIEW mart.mart_customer_behavior AS
WITH customer_stats AS (
    SELECT
        fs.customer_key,
        dc.location_key,
        MAX(dd.full_date) AS last_purchase_date,
        COUNT(*) AS purchase_count,
        SUM(fs.net_revenue) AS total_revenue
    FROM gold.fact_sales fs
    JOIN gold.dim_customer dc
        ON fs.customer_key = dc.customer_key
    JOIN gold.dim_date dd
        ON fs.date_key = dd.date_key
    GROUP BY
        fs.customer_key,
        dc.location_key
),
max_date AS (
    SELECT MAX(full_date) AS max_full_date
    FROM gold.dim_date
)
SELECT
    cs.location_key,
    loc.country_name,
    loc.city_name,
    CASE
        WHEN cs.last_purchase_date >= md.max_full_date - INTERVAL '90 days'
            THEN 'Active'
        ELSE 'Inactive'
    END AS activity_status,
    CASE
        WHEN cs.total_revenue >= 10000 THEN 'VIP'
        WHEN cs.total_revenue >= 5000 THEN 'High Value'
        WHEN cs.total_revenue >= 1000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS revenue_segment,
    COUNT(*) AS customer_count,
    SUM(cs.total_revenue) AS total_revenue
FROM customer_stats cs
CROSS JOIN max_date md
LEFT JOIN gold.dim_location loc
    ON cs.location_key = loc.location_key
GROUP BY
    cs.location_key,
    loc.country_name,
    loc.city_name,
    activity_status,
    revenue_segment;


DROP VIEW IF EXISTS mart.mart_employee_performance;

CREATE VIEW mart.mart_employee_performance AS
WITH employee_stats AS (
    SELECT
        fs.employee_key,
        fs.shop_key,
        fs.location_key,
        de.full_name AS employee_name,
        COUNT(*) AS sales_count,
        SUM(fs.net_revenue) AS total_revenue,
        SUM(fs.profit) AS total_profit
    FROM gold.fact_sales fs
    JOIN gold.dim_employee de
        ON fs.employee_key = de.employee_key
    GROUP BY
        fs.employee_key,
        fs.shop_key,
        fs.location_key,
        de.full_name
),
ranked_employees AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY total_profit DESC
        ) AS profit_rank,
        NTILE(5) OVER (
            ORDER BY total_profit DESC
        ) AS performance_bucket
    FROM employee_stats
)
SELECT
    re.employee_key,
    re.employee_name,
    re.shop_key,
    re.location_key,
    loc.country_name,
    loc.city_name,
    re.sales_count,
    re.total_revenue,
    re.total_profit,
    re.profit_rank,
    CASE
        WHEN re.performance_bucket = 1 THEN 'Leader'
        WHEN re.performance_bucket = 5 THEN 'Outsider'
        ELSE 'Standard'
    END AS performance_group
FROM ranked_employees re
JOIN gold.dim_location loc
    ON re.location_key = loc.location_key;


DROP VIEW IF EXISTS mart.mart_product_seasonality;

CREATE VIEW mart.mart_product_seasonality AS
WITH monthly_product_sales AS (
    SELECT
        fs.location_key,
        dd.year_num,
        dd.month_num,
        dd.month_name,
        dp.product_key,
        dp.product_id,
        dp.product_name,
        dc.category_key,
        dc.category_name,
        SUM(fs.quantity) AS total_quantity,
        SUM(fs.net_revenue) AS total_revenue
    FROM gold.fact_sales fs
    JOIN gold.dim_date dd
        ON fs.date_key = dd.date_key
    JOIN gold.dim_product dp
        ON fs.product_key = dp.product_key
    JOIN gold.dim_category dc
        ON fs.category_key = dc.category_key
    GROUP BY
        fs.location_key,
        dd.year_num,
        dd.month_num,
        dd.month_name,
        dp.product_key,
        dp.product_id,
        dp.product_name,
        dc.category_key,
        dc.category_name
)
SELECT
    mps.location_key,
    loc.country_name,
    loc.city_name,
    mps.year_num,
    mps.month_num,
    mps.month_name,
    mps.category_key,
    mps.category_name,
    mps.product_key,
    mps.product_id,
    mps.product_name,
    mps.total_quantity,
    mps.total_revenue,
    RANK() OVER (
        PARTITION BY
            mps.location_key,
            mps.year_num,
            mps.month_num
        ORDER BY mps.total_revenue DESC
    ) AS product_rank_in_month
FROM monthly_product_sales mps
JOIN gold.dim_location loc
    ON mps.location_key = loc.location_key;