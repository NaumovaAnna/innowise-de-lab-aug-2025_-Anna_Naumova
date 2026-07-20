raw_log = "ORDER-2025-01-15|FRT-APPLE-PL|+111 (23) 456-78-90| мИнсК "

# 1. Разделение строки
order_id, product_code, raw_phone, raw_city = raw_log.split("|")

# 2. Разбор кода
category = product_code[:3]
region = product_code[-2:]

first_dash_position = product_code.find("-")
print(f"Позиция первого дефиса в коде товара: {first_dash_position}")

if product_code.startswith("FRT"):
    print("Код товара начинается с 'FRT'")
else:
    print("Код товара не начинается с 'FRT'")

# 3. Приведение к нужному формату
clean_phone = ""

for symbol in raw_phone:
    if symbol.isdigit():
        clean_phone += symbol

print(f"Длина номера телефона: {len(clean_phone)}")

# 4. Правильный вид названия города
city = raw_city.strip().lower().title()

# 5. Отчет
report = (
    f"Заказ: {order_id}\n"
    f"Категория: {category} | Регион: {region}\n"
    f"Телефон: {clean_phone}\n"
    f"Город: {city}"
)

print(report)
