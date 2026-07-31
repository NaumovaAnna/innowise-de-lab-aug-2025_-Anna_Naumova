# Задание lecture_11: ETL pipeline для загрузки CSV в Bronze Layer

from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# 1. Настройки подключения к PostgreSQL
DB_USER = "admin"
DB_PASSWORD = "your_password"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "postgre"

# Папка, где лежит etl_pipeline.py и CSV-файлы
CSV_DIR = Path(__file__).parent


def create_db_engine() -> Engine:
    """
    Создает подключение к базе данных PostgreSQL.

    :return: SQLAlchemy Engine для работы с базой данных.
    """
    connection_string = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    try:
        engine = create_engine(connection_string)

        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        print("Подключение к базе данных успешно создано.")
        return engine

    except Exception as error:
        print("Ошибка подключения к базе данных:")
        print(error)
        raise


def create_bronze_tables(engine: Engine) -> None:
    """
    Создает схему bronze и таблицы Bronze Layer.

    Таблицы создаются с префиксом bronze_.
    В Bronze Layer данные загружаются без глубокой очистки.

    :param engine: SQLAlchemy Engine для подключения к базе данных.
    :return: None.
    """
    try:
        with engine.begin() as connection:
            connection.execute(text("CREATE SCHEMA IF NOT EXISTS bronze;"))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_countries (
                    country_id INTEGER PRIMARY KEY,
                    country_name VARCHAR(100),
                    country_code VARCHAR(10)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_cities (
                    city_id INTEGER PRIMARY KEY,
                    city_name VARCHAR(100),
                    zipcode VARCHAR(20),
                    country_id INTEGER,
                    CONSTRAINT fk_bronze_cities_country
                        FOREIGN KEY (country_id)
                        REFERENCES bronze.bronze_countries(country_id)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_categories (
                    category_id INTEGER PRIMARY KEY,
                    category_name VARCHAR(100)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_products (
                    product_id INTEGER PRIMARY KEY,
                    product_name VARCHAR(255),
                    price NUMERIC,
                    category_id INTEGER,
                    class VARCHAR(50),
                    modify_timestamp VARCHAR(100),
                    resistant VARCHAR(20),
                    is_allergic VARCHAR(20),
                    vitality_days INTEGER,
                    CONSTRAINT fk_bronze_products_category
                        FOREIGN KEY (category_id)
                        REFERENCES bronze.bronze_categories(category_id)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_shops (
                    shop_id INTEGER PRIMARY KEY,
                    city_id INTEGER,
                    address VARCHAR(255),
                    CONSTRAINT fk_bronze_shops_city
                        FOREIGN KEY (city_id)
                        REFERENCES bronze.bronze_cities(city_id)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_employees (
                    employee_id INTEGER PRIMARY KEY,
                    first_name VARCHAR(100),
                    middle_initial VARCHAR(10),
                    last_name VARCHAR(100),
                    birth_date VARCHAR(100),
                    gender VARCHAR(20),
                    city_id INTEGER,
                    shop_id INTEGER,
                    hire_date VARCHAR(100),
                    CONSTRAINT fk_bronze_employees_city
                        FOREIGN KEY (city_id)
                        REFERENCES bronze.bronze_cities(city_id),
                    CONSTRAINT fk_bronze_employees_shop
                        FOREIGN KEY (shop_id)
                        REFERENCES bronze.bronze_shops(shop_id)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_customers (
                    customer_id INTEGER PRIMARY KEY,
                    first_name VARCHAR(100),
                    middle_initial VARCHAR(10),
                    last_name VARCHAR(100),
                    city_id INTEGER,
                    address VARCHAR(255),
                    CONSTRAINT fk_bronze_customers_city
                        FOREIGN KEY (city_id)
                        REFERENCES bronze.bronze_cities(city_id)
                );
            """))

            connection.execute(text("""
                CREATE TABLE IF NOT EXISTS bronze.bronze_sales (
                    sales_id INTEGER PRIMARY KEY,
                    employee_id INTEGER,
                    customer_id INTEGER,
                    product_id INTEGER,
                    quantity INTEGER,
                    discount NUMERIC,
                    total_price NUMERIC,
                    sales_timestamp VARCHAR(100),
                    transaction_number VARCHAR(100),
                    CONSTRAINT fk_bronze_sales_employee
                        FOREIGN KEY (employee_id)
                        REFERENCES bronze.bronze_employees(employee_id),
                    CONSTRAINT fk_bronze_sales_customer
                        FOREIGN KEY (customer_id)
                        REFERENCES bronze.bronze_customers(customer_id),
                    CONSTRAINT fk_bronze_sales_product
                        FOREIGN KEY (product_id)
                        REFERENCES bronze.bronze_products(product_id)
                );
            """))

        print("Схема bronze и таблицы успешно созданы.")

    except Exception as error:
        print("Ошибка при создании схемы или таблиц Bronze Layer:")
        print(error)
        raise


def load_csv_to_table(
    engine: Engine,
    csv_file_name: str,
    table_name: str,
    chunksize: int | None = None,
) -> None:
    """
    Загружает данные из CSV-файла в таблицу PostgreSQL через pandas.to_sql().

    :param engine: SQLAlchemy Engine для подключения к базе данных.
    :param csv_file_name: Название CSV-файла.
    :param table_name: Название таблицы в схеме bronze.
    :param chunksize: Размер батча для массовой загрузки.
    :return: None.
    """
    csv_path = CSV_DIR / csv_file_name

    try:
        dataframe = pd.read_csv(csv_path, sep=";")

        dataframe.to_sql(
            name=table_name,
            con=engine,
            schema="bronze",
            if_exists="append",
            index=False,
            chunksize=chunksize,
        )

        print(f"Файл {csv_file_name} успешно загружен в bronze.{table_name}.")

    except FileNotFoundError:
        print(f"Файл не найден: {csv_path}")
        raise

    except Exception as error:
        print(f"Ошибка при загрузке файла {csv_file_name}:")
        print(error)
        raise


def run_etl_pipeline() -> None:
    """
    Запускает полный ETL-пайплайн:
    создает таблицы Bronze Layer и загружает CSV-файлы в PostgreSQL.

    :return: None.
    """
    engine = create_db_engine()

    create_bronze_tables(engine)

    load_csv_to_table(engine, "countries.csv", "bronze_countries")
    load_csv_to_table(engine, "cities.csv", "bronze_cities")
    load_csv_to_table(engine, "categories.csv", "bronze_categories")
    load_csv_to_table(engine, "products.csv", "bronze_products")
    load_csv_to_table(engine, "shops.csv", "bronze_shops")
    load_csv_to_table(engine, "employees.csv", "bronze_employees")
    load_csv_to_table(engine, "customers.csv", "bronze_customers")

    load_csv_to_table(
        engine=engine,
        csv_file_name="sales.csv",
        table_name="bronze_sales",
        chunksize=1000,
    )

    print("ETL-пайплайн успешно завершен.")


if __name__ == "__main__":
    run_etl_pipeline()