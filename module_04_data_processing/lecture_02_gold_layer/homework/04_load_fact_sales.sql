WITH source_sales AS (
    SELECT
        s.sales_id,
        s.transaction_number,
        TO_CHAR(s.sales_timestamp::DATE, 'YYYYMMDD')::INTEGER AS date_key,
        dp.product_key,
        dc.category_key,
        dcu.customer_key,
        de.employee_key,
        dsh.shop_key,
        dloc.location_key,
        s.sales_timestamp,
        s.quantity,
        dp.price AS unit_price,
        ROUND((s.quantity * dp.price)::NUMERIC, 2) AS gross_revenue,
        COALESCE(s.discount, 0) AS discount_rate,
        ROUND(s.total_price::NUMERIC, 2) AS net_revenue
    FROM silver.silver_sales s
    JOIN gold.dim_date dd
        ON dd.full_date = s.sales_timestamp::DATE
    JOIN gold.dim_product dp
        ON dp.product_id = s.product_id
       AND dp.is_current = true
    JOIN gold.dim_category dc
        ON dc.category_id = dp.category_id
    JOIN gold.dim_customer dcu
        ON dcu.customer_id = s.customer_id
    JOIN gold.dim_employee de
        ON de.employee_id = s.employee_id
    JOIN gold.dim_shop dsh
        ON dsh.shop_id = s.shop_id
    JOIN gold.dim_location dloc
        ON dloc.city_id = s.city_id
)
INSERT INTO gold.fact_sales (
    sales_id,
    transaction_number,
    date_key,
    product_key,
    category_key,
    customer_key,
    employee_key,
    shop_key,
    location_key,
    sales_timestamp,
    quantity,
    unit_price,
    gross_revenue,
    discount_rate,
    discount_amount,
    net_revenue,
    profit,
    margin_percent
)
SELECT
    sales_id,
    transaction_number,
    date_key,
    product_key,
    category_key,
    customer_key,
    employee_key,
    shop_key,
    location_key,
    sales_timestamp,
    quantity,
    unit_price,
    gross_revenue,
    discount_rate,
    GREATEST(gross_revenue - net_revenue, 0) AS discount_amount,
    net_revenue,
    ROUND((net_revenue * 0.20)::NUMERIC, 2) AS profit,
    CASE
        WHEN net_revenue > 0
            THEN ROUND(((net_revenue * 0.20) / net_revenue * 100)::NUMERIC, 2)
        ELSE 0
    END AS margin_percent
FROM source_sales
ON CONFLICT (sales_id) DO NOTHING;