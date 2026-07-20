product = " фермерский ТВОРОГ "
price = 4.567
qty = 3
csv_row = "milk,bread,cheese"
review = "Это лучший ТВОРОГ в городе!"

file_path = r"C:\EcoMarket\data\2025\january\sales.csv"

# 1. Нормализация названия товара
clean_product = product.strip().lower().title()

# 2. Формирование чека для клиента
total = price * qty

receipt = (
    f"Чек \"EcoMarket\"\n"
    f"\tТовар: {clean_product}\n"
    f"\tКол-во: {qty}\n"
    f"\tИтого: {total:.2f} руб."
)

print(receipt)

# 3. Подготовка строки из CSV
csv_items = csv_row.split(",")
formatted_csv = " | ".join(csv_items)

print(formatted_csv)

# 4. Проверка отзыва клиента
if "творог" in review.lower():
    print("Отзыв относится к категории: Dairy")

# 5. Вывод пути к файлу
print(file_path)


