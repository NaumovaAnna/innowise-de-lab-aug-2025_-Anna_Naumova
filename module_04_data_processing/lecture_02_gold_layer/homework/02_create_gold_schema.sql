CREATE SCHEMA IF NOT EXISTS gold;


CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key INTEGER PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    day_of_week VARCHAR(20) NOT NULL,
    week_num INTEGER NOT NULL,
    month_num INTEGER NOT NULL CHECK (month_num BETWEEN 1 AND 12),
    month_name VARCHAR(20) NOT NULL,
    quarter_num INTEGER NOT NULL CHECK (quarter_num BETWEEN 1 AND 4),
    year_num INTEGER NOT NULL
);


CREATE TABLE IF NOT EXISTS gold.dim_category (
    category_key BIGSERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL UNIQUE,
    category_name VARCHAR(100) NOT NULL
);


CREATE TABLE IF NOT EXISTS gold.dim_location (
    location_key BIGSERIAL PRIMARY KEY,
    city_id INTEGER NOT NULL UNIQUE,
    city_name VARCHAR(100) NOT NULL,
    zipcode VARCHAR(20),
    country_id INTEGER NOT NULL,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(10)
);


CREATE TABLE IF NOT EXISTS gold.dim_product (
    product_key BIGSERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    category_id INTEGER,
    category_name VARCHAR(100),
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    class VARCHAR(50),
    resistant BOOLEAN,
    is_allergic BOOLEAN,
    vitality_days INTEGER,
    attribute_hash TEXT NOT NULL,
    valid_from_dt DATE NOT NULL,
    valid_to_dt DATE NOT NULL,
    is_current BOOLEAN NOT NULL
);


CREATE TABLE IF NOT EXISTS gold.dim_shop (
    shop_key BIGSERIAL PRIMARY KEY,
    shop_id INTEGER NOT NULL UNIQUE,
    location_key BIGINT NOT NULL,
    city_id INTEGER NOT NULL,
    address VARCHAR(255) NOT NULL,
    CONSTRAINT fk_dim_shop_location
        FOREIGN KEY (location_key)
        REFERENCES gold.dim_location(location_key)
);


CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL UNIQUE,
    location_key BIGINT,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    address VARCHAR(255),
    CONSTRAINT fk_dim_customer_location
        FOREIGN KEY (location_key)
        REFERENCES gold.dim_location(location_key)
);


CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employee_key BIGSERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL UNIQUE,
    shop_key BIGINT NOT NULL,
    location_key BIGINT NOT NULL,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    birth_date DATE,
    gender VARCHAR(20),
    hire_date DATE,
    CONSTRAINT fk_dim_employee_shop
        FOREIGN KEY (shop_key)
        REFERENCES gold.dim_shop(shop_key),
    CONSTRAINT fk_dim_employee_location
        FOREIGN KEY (location_key)
        REFERENCES gold.dim_location(location_key),
    CONSTRAINT chk_dim_employee_hire_after_birth
        CHECK (hire_date > birth_date)
);


CREATE TABLE IF NOT EXISTS gold.fact_sales (
    sales_key BIGSERIAL PRIMARY KEY,
    sales_id INTEGER NOT NULL UNIQUE,
    transaction_number VARCHAR(100),

    date_key INTEGER NOT NULL,
    product_key BIGINT NOT NULL,
    category_key BIGINT NOT NULL,
    customer_key BIGINT NOT NULL,
    employee_key BIGINT NOT NULL,
    shop_key BIGINT NOT NULL,
    location_key BIGINT NOT NULL,

    sales_timestamp TIMESTAMP NOT NULL,

    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC(10, 2) NOT NULL CHECK (unit_price >= 0),
    gross_revenue NUMERIC(14, 2) NOT NULL CHECK (gross_revenue >= 0),
    discount_rate NUMERIC(10, 4),
    discount_amount NUMERIC(14, 2) NOT NULL CHECK (discount_amount >= 0),
    net_revenue NUMERIC(14, 2) NOT NULL CHECK (net_revenue >= 0),
    profit NUMERIC(14, 2) NOT NULL,
    margin_percent NUMERIC(7, 2),

    CONSTRAINT fk_fact_sales_date
        FOREIGN KEY (date_key)
        REFERENCES gold.dim_date(date_key),

    CONSTRAINT fk_fact_sales_product
        FOREIGN KEY (product_key)
        REFERENCES gold.dim_product(product_key),

    CONSTRAINT fk_fact_sales_category
        FOREIGN KEY (category_key)
        REFERENCES gold.dim_category(category_key),

    CONSTRAINT fk_fact_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES gold.dim_customer(customer_key),

    CONSTRAINT fk_fact_sales_employee
        FOREIGN KEY (employee_key)
        REFERENCES gold.dim_employee(employee_key),

    CONSTRAINT fk_fact_sales_shop
        FOREIGN KEY (shop_key)
        REFERENCES gold.dim_shop(shop_key),

    CONSTRAINT fk_fact_sales_location
        FOREIGN KEY (location_key)
        REFERENCES gold.dim_location(location_key)
);


CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_product_current
ON gold.dim_product(product_id)
WHERE is_current = true;


CREATE INDEX IF NOT EXISTS ix_fact_sales_date_key
ON gold.fact_sales(date_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_product_key
ON gold.fact_sales(product_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_category_key
ON gold.fact_sales(category_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_customer_key
ON gold.fact_sales(customer_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_employee_key
ON gold.fact_sales(employee_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_shop_key
ON gold.fact_sales(shop_key);

CREATE INDEX IF NOT EXISTS ix_fact_sales_location_key
ON gold.fact_sales(location_key);