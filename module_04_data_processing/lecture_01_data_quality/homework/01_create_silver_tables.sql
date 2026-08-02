DROP SCHEMA IF EXISTS silver CASCADE;

CREATE SCHEMA IF NOT EXISTS silver;


CREATE TABLE silver.silver_countries (
    country_id INTEGER,
    country_name VARCHAR(100),
    country_code VARCHAR(10)
);


CREATE TABLE silver.silver_cities (
    city_id INTEGER,
    city_name VARCHAR(100),
    zipcode VARCHAR(20),
    country_id INTEGER
);


CREATE TABLE silver.silver_categories (
    category_id INTEGER,
    category_name VARCHAR(100)
);


CREATE TABLE silver.silver_products (
    product_id INTEGER,
    product_name VARCHAR(255),
    price NUMERIC(10, 2),
    category_id INTEGER,
    class VARCHAR(50),
    modify_timestamp TIMESTAMP,
    resistant BOOLEAN,
    is_allergic BOOLEAN,
    vitality_days INTEGER
);


CREATE TABLE silver.silver_shops (
    shop_id INTEGER,
    city_id INTEGER,
    address VARCHAR(255)
);


CREATE TABLE silver.silver_employees (
    employee_id INTEGER,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(20),
    city_id INTEGER,
    shop_id INTEGER,
    hire_date DATE
);


CREATE TABLE silver.silver_customers (
    customer_id INTEGER,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    city_id INTEGER,
    address VARCHAR(255)
);


CREATE TABLE silver.silver_sales (
    sales_id INTEGER,
    employee_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    discount NUMERIC(10, 2),
    total_price NUMERIC(10, 2),
    sales_timestamp TIMESTAMP,
    transaction_number VARCHAR(100),

    shop_id INTEGER,
    city_id INTEGER
);