INSERT INTO gold.dim_date (
    date_key,
    full_date,
    day_of_week,
    week_num,
    month_num,
    month_name,
    quarter_num,
    year_num
)
SELECT
    TO_CHAR(date_value, 'YYYYMMDD')::INTEGER AS date_key,
    date_value AS full_date,
    TO_CHAR(date_value, 'FMDay') AS day_of_week,
    EXTRACT(WEEK FROM date_value)::INTEGER AS week_num,
    EXTRACT(MONTH FROM date_value)::INTEGER AS month_num,
    TO_CHAR(date_value, 'FMMonth') AS month_name,
    EXTRACT(QUARTER FROM date_value)::INTEGER AS quarter_num,
    EXTRACT(YEAR FROM date_value)::INTEGER AS year_num
FROM (
    SELECT GENERATE_SERIES(
        MIN(sales_timestamp)::DATE,
        MAX(sales_timestamp)::DATE,
        INTERVAL '1 day'
    )::DATE AS date_value
    FROM silver.silver_sales
) dates
ON CONFLICT (date_key) DO UPDATE
SET
    full_date = EXCLUDED.full_date,
    day_of_week = EXCLUDED.day_of_week,
    week_num = EXCLUDED.week_num,
    month_num = EXCLUDED.month_num,
    month_name = EXCLUDED.month_name,
    quarter_num = EXCLUDED.quarter_num,
    year_num = EXCLUDED.year_num;


-- 2. dim_category

INSERT INTO gold.dim_category (
    category_id,
    category_name
)
SELECT DISTINCT
    category_id,
    category_name
FROM silver.silver_categories
WHERE category_id IS NOT NULL
ON CONFLICT (category_id) DO UPDATE
SET category_name = EXCLUDED.category_name;


-- 3. dim_location

INSERT INTO gold.dim_location (
    city_id,
    city_name,
    zipcode,
    country_id,
    country_name,
    country_code
)
SELECT DISTINCT
    c.city_id,
    c.city_name,
    c.zipcode,
    co.country_id,
    co.country_name,
    co.country_code
FROM silver.silver_cities c
JOIN silver.silver_countries co
    ON c.country_id = co.country_id
WHERE c.city_id IS NOT NULL
ON CONFLICT (city_id) DO UPDATE
SET
    city_name = EXCLUDED.city_name,
    zipcode = EXCLUDED.zipcode,
    country_id = EXCLUDED.country_id,
    country_name = EXCLUDED.country_name,
    country_code = EXCLUDED.country_code;


-- 4. dim_product SCD Type 2

WITH source_products AS (
    SELECT DISTINCT
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        p.price,
        p.class,
        p.resistant,
        p.is_allergic,
        p.vitality_days,
        MD5(
            CONCAT_WS(
                '|',
                p.product_name,
                p.category_id,
                c.category_name,
                p.price,
                p.class,
                p.resistant,
                p.is_allergic,
                p.vitality_days
            )
        ) AS attribute_hash,
        COALESCE(p.modify_timestamp::DATE, CURRENT_DATE) AS valid_from_dt
    FROM silver.silver_products p
    LEFT JOIN silver.silver_categories c
        ON p.category_id = c.category_id
    WHERE p.product_id IS NOT NULL
)
UPDATE gold.dim_product target
SET
    valid_to_dt = CURRENT_DATE - 1,
    is_current = false
FROM source_products source
WHERE target.product_id = source.product_id
  AND target.is_current = true
  AND target.attribute_hash <> source.attribute_hash;


WITH source_products AS (
    SELECT DISTINCT
        p.product_id,
        p.product_name,
        p.category_id,
        c.category_name,
        p.price,
        p.class,
        p.resistant,
        p.is_allergic,
        p.vitality_days,
        MD5(
            CONCAT_WS(
                '|',
                p.product_name,
                p.category_id,
                c.category_name,
                p.price,
                p.class,
                p.resistant,
                p.is_allergic,
                p.vitality_days
            )
        ) AS attribute_hash,
        COALESCE(p.modify_timestamp::DATE, CURRENT_DATE) AS valid_from_dt
    FROM silver.silver_products p
    LEFT JOIN silver.silver_categories c
        ON p.category_id = c.category_id
    WHERE p.product_id IS NOT NULL
)
INSERT INTO gold.dim_product (
    product_id,
    product_name,
    category_id,
    category_name,
    price,
    class,
    resistant,
    is_allergic,
    vitality_days,
    attribute_hash,
    valid_from_dt,
    valid_to_dt,
    is_current
)
SELECT
    source.product_id,
    source.product_name,
    source.category_id,
    source.category_name,
    source.price,
    source.class,
    source.resistant,
    source.is_allergic,
    source.vitality_days,
    source.attribute_hash,
    source.valid_from_dt,
    DATE '9999-12-31',
    true
FROM source_products source
WHERE NOT EXISTS (
    SELECT 1
    FROM gold.dim_product target
    WHERE target.product_id = source.product_id
      AND target.attribute_hash = source.attribute_hash
      AND target.is_current = true
);


-- 5. dim_shop

INSERT INTO gold.dim_shop (
    shop_id,
    location_key,
    city_id,
    address
)
SELECT DISTINCT
    sh.shop_id,
    loc.location_key,
    sh.city_id,
    sh.address
FROM silver.silver_shops sh
JOIN gold.dim_location loc
    ON sh.city_id = loc.city_id
WHERE sh.shop_id IS NOT NULL
ON CONFLICT (shop_id) DO UPDATE
SET
    location_key = EXCLUDED.location_key,
    city_id = EXCLUDED.city_id,
    address = EXCLUDED.address;


-- 6. dim_customer

INSERT INTO gold.dim_customer (
    customer_id,
    location_key,
    first_name,
    middle_initial,
    last_name,
    full_name,
    address
)
SELECT DISTINCT
    cu.customer_id,
    loc.location_key,
    cu.first_name,
    cu.middle_initial,
    cu.last_name,
    CONCAT_WS(' ', cu.first_name, cu.middle_initial, cu.last_name) AS full_name,
    cu.address
FROM silver.silver_customers cu
LEFT JOIN gold.dim_location loc
    ON cu.city_id = loc.city_id
WHERE cu.customer_id IS NOT NULL
ON CONFLICT (customer_id) DO UPDATE
SET
    location_key = EXCLUDED.location_key,
    first_name = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name = EXCLUDED.last_name,
    full_name = EXCLUDED.full_name,
    address = EXCLUDED.address;


-- 7. dim_employee

INSERT INTO gold.dim_employee (
    employee_id,
    shop_key,
    location_key,
    first_name,
    middle_initial,
    last_name,
    full_name,
    birth_date,
    gender,
    hire_date
)
SELECT DISTINCT
    e.employee_id,
    sh.shop_key,
    loc.location_key,
    e.first_name,
    e.middle_initial,
    e.last_name,
    CONCAT_WS(' ', e.first_name, e.middle_initial, e.last_name) AS full_name,
    e.birth_date,
    e.gender,
    e.hire_date
FROM silver.silver_employees e
JOIN gold.dim_shop sh
    ON e.shop_id = sh.shop_id
JOIN gold.dim_location loc
    ON e.city_id = loc.city_id
WHERE e.employee_id IS NOT NULL
ON CONFLICT (employee_id) DO UPDATE
SET
    shop_key = EXCLUDED.shop_key,
    location_key = EXCLUDED.location_key,
    first_name = EXCLUDED.first_name,
    middle_initial = EXCLUDED.middle_initial,
    last_name = EXCLUDED.last_name,
    full_name = EXCLUDED.full_name,
    birth_date = EXCLUDED.birth_date,
    gender = EXCLUDED.gender,
    hire_date = EXCLUDED.hire_date;
