prices = [100, -50, 300, 40, 800]

# 2. Удаляем ошибочное отрицательное значение
prices.remove(-50)

# 3. Добавляем новую цену в конец списка
prices.append(150)

# 4. Сортируем список по возрастанию
prices.sort()

# 5. Создаем новый список цен с НДС 20%
tax_prices = [price * 1.2 for price in prices if price > 100]

# 6. Выводим результаты
print("Базовый прайс (очищенный):", prices)
print("Цены с НДС (>100):", tax_prices)
print("Общая выручка:", sum(tax_prices))
print("Минимум:", min(tax_prices))
print("Максимум:", max(tax_prices))