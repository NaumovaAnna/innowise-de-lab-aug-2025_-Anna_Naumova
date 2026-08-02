# 1. Primary Keys

ALTER TABLE silver.silver_countries
ADD CONSTRAINT pk_silver_countries
PRIMARY KEY (country_id);

ALTER TABLE silver.silver_cities
ADD CONSTRAINT pk_silver_cities
PRIMARY KEY (city_id);

ALTER TABLE silver.silver_categories
ADD CONSTRAINT pk_silver_categories
PRIMARY KEY (category_id);

ALTER TABLE silver.silver_products
ADD CONSTRAINT pk_silver_products
PRIMARY KEY (product_id);

ALTER TABLE silver.silver_shops
ADD CONSTRAINT pk_silver_shops
PRIMARY KEY (shop_id);

ALTER TABLE silver.silver_employees
ADD CONSTRAINT pk_silver_employees
PRIMARY KEY (employee_id);

ALTER TABLE silver.silver_customers
ADD CONSTRAINT pk_silver_customers
PRIMARY KEY (customer_id);

ALTER TABLE silver.silver_sales
ADD CONSTRAINT pk_silver_sales
PRIMARY KEY (sales_id);


# 2. Foreign Keys для справочников

ALTER TABLE silver.silver_cities
ADD CONSTRAINT fk_silver_cities_country
FOREIGN KEY (country_id)
REFERENCES silver.silver_countries(country_id);

ALTER TABLE silver.silver_products
ADD CONSTRAINT fk_silver_products_category
FOREIGN KEY (category_id)
REFERENCES silver.silver_categories(category_id);

ALTER TABLE silver.silver_shops
ADD CONSTRAINT fk_silver_shops_city
FOREIGN KEY (city_id)
REFERENCES silver.silver_cities(city_id);

ALTER TABLE silver.silver_customers
ADD CONSTRAINT fk_silver_customers_city
FOREIGN KEY (city_id)
REFERENCES silver.silver_cities(city_id);

ALTER TABLE silver.silver_employees
ADD CONSTRAINT fk_silver_employees_city
FOREIGN KEY (city_id)
REFERENCES silver.silver_cities(city_id);

ALTER TABLE silver.silver_employees
ADD CONSTRAINT fk_silver_employees_shop
FOREIGN KEY (shop_id)
REFERENCES silver.silver_shops(shop_id);


# 3. Foreign Keys для таблицы продаж

ALTER TABLE silver.silver_sales
ADD CONSTRAINT fk_silver_sales_employee
FOREIGN KEY (employee_id)
REFERENCES silver.silver_employees(employee_id);

ALTER TABLE silver.silver_sales
ADD CONSTRAINT fk_silver_sales_customer
FOREIGN KEY (customer_id)
REFERENCES silver.silver_customers(customer_id);

ALTER TABLE silver.silver_sales
ADD CONSTRAINT fk_silver_sales_product
FOREIGN KEY (product_id)
REFERENCES silver.silver_products(product_id);

ALTER TABLE silver.silver_sales
ADD CONSTRAINT fk_silver_sales_shop
FOREIGN KEY (shop_id)
REFERENCES silver.silver_shops(shop_id);

ALTER TABLE silver.silver_sales
ADD CONSTRAINT fk_silver_sales_city
FOREIGN KEY (city_id)
REFERENCES silver.silver_cities(city_id);


# 4. Business CHECK constraint

ALTER TABLE silver.silver_employees
ADD CONSTRAINT chk_silver_employees_hire_after_birth
CHECK (hire_date > birth_date);