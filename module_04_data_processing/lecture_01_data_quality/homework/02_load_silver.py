# Задание: загрузка данных из Bronze Layer в Silver Layer
# Читаем данные из bronze-таблиц, очищаем их и загружаем в silver-таблицы.

from datetime import datetime

import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# Настройки подключения к PostgreSQL
DB_USER = "admin"
DB_PASSWORD = "admin123"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "postgre"


def create_db_engine() -> Engine:
    """
    Создает подключение к базе данных PostgreSQL.

    :return: SQLAlchemy Engine для работы с PostgreSQL.
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


def validate_and_fix_date(date_value):
    """
    Проверяет дату и исправляет некорректные значения.

    Логика:
    - если дата нормальная, возвращаем эту дату;
    - если дата пустая, возвращаем 1900-01-01;
    - если дата невозможная, например 2023-99-99, возвращаем 1900-01-01;
    - если дата записана через слэш, например 25/12/2023, тоже пробуем разобрать.

    :param date_value: Значение даты из Bronze Layer.
    :return: Исправленная дата.
    """
    technical_default_date = pd.Timestamp("1900-01-01").date()

    if pd.isna(date_value):
        return technical_default_date

    date_text = str(date_value).strip()

    if date_text == "":
        return technical_default_date

    possible_formats = [
        "%Y-%m-%d",
        "%d/%m/%Y",
        "%Y/%m/%d",
        "%d-%m-%Y",
    ]

    for date_format in possible_formats:
        try:
            fixed_date = datetime.strptime(date_text, date_format).date()
            return fixed_date

        except ValueError:
            continue

    return technical_default_date


def validate_and_fix_timestamp(timestamp_value):
    """
    Проверяет timestamp и исправляет формат времени.

    Логика:
    - если timestamp пустой, возвращаем NaT, потом строка будет удалена;
    - если есть только дата, добавляем время 00:00:00;
    - если timestamp невозможный, возвращаем NaT.

    :param timestamp_value: Значение timestamp из Bronze Layer.
    :return: Исправленный timestamp или NaT.
    """
    if pd.isna(timestamp_value):
        return pd.NaT

    timestamp_text = str(timestamp_value).strip()

    if timestamp_text == "":
        return pd.NaT

    possible_formats = [
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d %H:%M",
        "%Y-%m-%d",
        "%d/%m/%Y %H:%M:%S",
        "%d/%m/%Y %H:%M",
        "%d/%m/%Y",
        "%Y/%m/%d %H:%M:%S",
        "%Y/%m/%d %H:%M",
        "%Y/%m/%d",
    ]

    for timestamp_format in possible_formats:
        try:
            fixed_timestamp = datetime.strptime(
                timestamp_text,
                timestamp_format,
            )

            return pd.Timestamp(fixed_timestamp)

        except ValueError:
            continue

    return pd.NaT


def convert_to_boolean(value):
    """
    Преобразует строковые значения в boolean.

    Например:
    Yes / True / 1 -> True
    No / False / 0 -> False

    :param value: Значение из Bronze Layer.
    :return: True, False или None.
    """
    if pd.isna(value):
        return None

    value = str(value).strip().lower()

    if value in ["yes", "true", "1", "y"]:
        return True

    if value in ["no", "false", "0", "n"]:
        return False

    return None


def load_dataframe_to_silver(
    dataframe: pd.DataFrame,
    engine: Engine,
    table_name: str,
) -> None:
    """
    Загружает DataFrame в таблицу Silver Layer.

    :param dataframe: DataFrame с очищенными данными.
    :param engine: SQLAlchemy Engine для подключения к базе данных.
    :param table_name: Название таблицы в схеме silver.
    :return: None.
    """
    try:
        dataframe.to_sql(
            name=table_name,
            con=engine,
            schema="silver",
            if_exists="append",
            index=False,
        )

        print(f"Данные успешно загружены в silver.{table_name}")

    except Exception as error:
        print(f"Ошибка при загрузке данных в silver.{table_name}:")
        print(error)
        raise


def run_silver_loading() -> None:
    """
    Запускает процесс загрузки данных из Bronze Layer в Silver Layer.

    :return: None.
    """
    engine = create_db_engine()

    # 1. Читаем данные из Bronze Layer
    countries = pd.read_sql("SELECT * FROM bronze.bronze_countries", engine)
    cities = pd.read_sql("SELECT * FROM bronze.bronze_cities", engine)
    categories = pd.read_sql("SELECT * FROM bronze.bronze_categories", engine)
    products = pd.read_sql("SELECT * FROM bronze.bronze_products", engine)
    shops = pd.read_sql("SELECT * FROM bronze.bronze_shops", engine)
    employees = pd.read_sql("SELECT * FROM bronze.bronze_employees", engine)
    customers = pd.read_sql("SELECT * FROM bronze.bronze_customers", engine)
    sales = pd.read_sql("SELECT * FROM bronze.bronze_sales", engine)

    print("Данные успешно прочитаны из Bronze Layer.")

    # 2. Обработка products

    products["price"] = pd.to_numeric(
        products["price"],
        errors="coerce",
    ).round(2)

    products["resistant"] = products["resistant"].apply(convert_to_boolean)
    products["is_allergic"] = products["is_allergic"].apply(convert_to_boolean)

    products["modify_timestamp"] = products["modify_timestamp"].apply(
        validate_and_fix_timestamp
    )

    products["modify_timestamp"] = products["modify_timestamp"].fillna(
        pd.Timestamp("1900-01-01 00:00:00")
    )

    # 3. Обработка employees

    employees["birth_date"] = employees["birth_date"].apply(validate_and_fix_date)
    employees["hire_date"] = employees["hire_date"].apply(validate_and_fix_date)

    # 4. Обработка sales

    sales["sales_timestamp"] = sales["sales_timestamp"].apply(
        validate_and_fix_timestamp
    )

    # Если даты нет совсем или она неправильная — удаляем строку
    sales = sales.dropna(subset=["sales_timestamp"])

    sales["discount"] = pd.to_numeric(
        sales["discount"],
        errors="coerce",
    ).round(2)

    sales["total_price"] = pd.to_numeric(
        sales["total_price"],
        errors="coerce",
    ).round(2)

    # 5. Добавляем поля для обогащения данных.
    # Потом они будут заполнены в SQL-файле 03_data_hygiene.sql

    sales["shop_id"] = None
    sales["city_id"] = None

    # 6. Загружаем данные в Silver Layer

    load_dataframe_to_silver(countries, engine, "silver_countries")
    load_dataframe_to_silver(cities, engine, "silver_cities")
    load_dataframe_to_silver(categories, engine, "silver_categories")
    load_dataframe_to_silver(products, engine, "silver_products")
    load_dataframe_to_silver(shops, engine, "silver_shops")
    load_dataframe_to_silver(employees, engine, "silver_employees")
    load_dataframe_to_silver(customers, engine, "silver_customers")
    load_dataframe_to_silver(sales, engine, "silver_sales")

    print("Загрузка данных в Silver Layer успешно завершена.")


if __name__ == "__main__":
    run_silver_loading()