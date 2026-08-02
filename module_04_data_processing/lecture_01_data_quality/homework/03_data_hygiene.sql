# 1. Удаляем записи с NULL в основных ключах

DELETE FROM silver.silver_countries
WHERE country_id IS NULL;

DELETE FROM silver.silver_cities
WHERE city_id IS NULL;

DELETE FROM silver.silver_categories
WHERE category_id IS NULL;

DELETE FROM silver.silver_products
WHERE product_id IS NULL;

DELETE FROM silver.silver_shops
WHERE shop_id IS NULL;

DELETE FROM silver.silver_employees
WHERE employee_id IS NULL;

DELETE FROM silver.silver_customers
WHERE customer_id IS NULL;

DELETE FROM silver.silver_sales
WHERE sales_id IS NULL
   OR employee_id IS NULL
   OR customer_id IS NULL
   OR product_id IS NULL;


# 2. Удаляем дубликаты по ID
# Оставляем только одну строку для каждого ID

DELETE FROM silver.silver_countries
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY country_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_countries
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_cities
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY city_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_cities
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_categories
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY category_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_categories
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_products
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY product_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_products
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_shops
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY shop_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_shops
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_employees
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY employee_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_employees
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_customers
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_customers
    ) duplicates
    WHERE row_number > 1
);

DELETE FROM silver.silver_sales
WHERE ctid IN (
    SELECT ctid
    FROM (
        SELECT
            ctid,
            ROW_NUMBER() OVER (
                PARTITION BY sales_id
                ORDER BY ctid
            ) AS row_number
        FROM silver.silver_sales
    ) duplicates
    WHERE row_number > 1
);


# 3. Удаляем сиротские записи в справочниках

DELETE FROM silver.silver_cities c
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_countries co
    WHERE co.country_id = c.country_id
);

DELETE FROM silver.silver_products p
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_categories ca
    WHERE ca.category_id = p.category_id
);

DELETE FROM silver.silver_shops sh
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_cities c
    WHERE c.city_id = sh.city_id
);

DELETE FROM silver.silver_customers cu
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_cities c
    WHERE c.city_id = cu.city_id
);

DELETE FROM silver.silver_employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_cities c
    WHERE c.city_id = e.city_id
)
OR NOT EXISTS (
    SELECT 1
    FROM silver.silver_shops sh
    WHERE sh.shop_id = e.shop_id
);


# 4. Удаляем сиротские продажи
# Продажа должна ссылаться на существующего employee, customer и product

DELETE FROM silver.silver_sales s
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_employees e
    WHERE e.employee_id = s.employee_id
)
OR NOT EXISTS (
    SELECT 1
    FROM silver.silver_customers cu
    WHERE cu.customer_id = s.customer_id
)
OR NOT EXISTS (
    SELECT 1
    FROM silver.silver_products p
    WHERE p.product_id = s.product_id
);


# 5. Удаляем сотрудников, которые не совершали продаж

DELETE FROM silver.silver_employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_sales s
    WHERE s.employee_id = e.employee_id
);


# 6. После удаления сотрудников снова удаляем продажи без существующего employee_id

DELETE FROM silver.silver_sales s
WHERE NOT EXISTS (
    SELECT 1
    FROM silver.silver_employees e
    WHERE e.employee_id = s.employee_id
);


# 7. Обогащаем sales полями shop_id и city_id
# Берем shop_id и city_id из таблицы employees

UPDATE silver.silver_sales s
SET
    shop_id = e.shop_id,
    city_id = e.city_id
FROM silver.silver_employees e
WHERE s.employee_id = e.employee_id;


# 8. Удаляем продажи, где enrichment не сработал

DELETE FROM silver.silver_sales
WHERE shop_id IS NULL
   OR city_id IS NULL;