BEGIN;

WITH new_employee AS (
    INSERT INTO employees (
        employee_id,
        first_name,
        middle_initial,
        last_name,
        birth_date,
        gender,
        city_id,
        shop_id,
        hire_date
    )
    SELECT
        (SELECT MAX(employee_id) + 1 FROM employees),
        'Test',
        'A',
        'Employee',
        DATE '2000-01-01',
        'M',
        sh.city_id,
        sh.shop_id,
        CURRENT_DATE
    FROM shops sh
    LIMIT 1
    RETURNING employee_id
)
INSERT INTO sales (
    sales_id,
    employee_id,
    customer_id,
    product_id,
    quantity,
    discount,
    total_price,
    sales_timestamp,
    transaction_number
)
SELECT
    (SELECT MAX(sales_id) + 1 FROM sales),
    ne.employee_id,
    (SELECT customer_id FROM customers LIMIT 1),
    (SELECT product_id FROM products LIMIT 1),
    1,
    0,
    100,
    CURRENT_TIMESTAMP,
    'NEW-EMPLOYEE-SALE-001'
FROM new_employee ne;

COMMIT;