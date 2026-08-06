-- Проверка количества строк в Gold

SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM gold.dim_date
UNION ALL
SELECT 'dim_category', COUNT(*) FROM gold.dim_category
UNION ALL
SELECT 'dim_location', COUNT(*) FROM gold.dim_location
UNION ALL
SELECT 'dim_product', COUNT(*) FROM gold.dim_product
UNION ALL
SELECT 'dim_shop', COUNT(*) FROM gold.dim_shop
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM gold.dim_customer
UNION ALL
SELECT 'dim_employee', COUNT(*) FROM gold.dim_employee
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM gold.fact_sales;


-- Проверка дублей в fact_sales по business key

SELECT
    sales_id,
    COUNT(*) AS duplicates_count
FROM gold.fact_sales
GROUP BY sales_id
HAVING COUNT(*) > 1;


-- Проверка NULL в foreign keys fact_sales

SELECT COUNT(*) AS null_fk_count
FROM gold.fact_sales
WHERE date_key IS NULL
   OR product_key IS NULL
   OR category_key IS NULL
   OR customer_key IS NULL
   OR employee_key IS NULL
   OR shop_key IS NULL
   OR location_key IS NULL;


-- Проверка текущих версий SCD2 product

SELECT
    product_id,
    COUNT(*) AS current_versions_count
FROM gold.dim_product
WHERE is_current = true
GROUP BY product_id
HAVING COUNT(*) > 1;


-- Проверка mart views

SELECT 'mart_daily_anomaly' AS mart_name, COUNT(*) AS row_count FROM mart.mart_daily_anomaly
UNION ALL
SELECT 'mart_shop_daily', COUNT(*) FROM mart.mart_shop_daily
UNION ALL
SELECT 'mart_customer_behavior', COUNT(*) FROM mart.mart_customer_behavior
UNION ALL
SELECT 'mart_employee_performance', COUNT(*) FROM mart.mart_employee_performance
UNION ALL
SELECT 'mart_product_seasonality', COUNT(*) FROM mart.mart_product_seasonality;