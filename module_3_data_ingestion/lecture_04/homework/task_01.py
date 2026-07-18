products = ["Яблоки", "Хлеб", "Молоко", "Печенье", "Сок", "Кефир"]

for i in range (0, len(products), 2) :
    item = products [i]
    name_length = len(item)

    print(f"Индекс {i} : Проверен товар {item} (Длина названия: {name_length} символов)")

    if item == "Бананы":
        print("Проверка прервана: найдены Бананы")
        break
else :
    print(f"---Выборочная проверка успешно завершена---")