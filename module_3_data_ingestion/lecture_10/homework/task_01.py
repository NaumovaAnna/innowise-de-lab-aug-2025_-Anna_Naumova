class Product:
    def __init__(self, name: str, price: float):
        self.name = name
        self.__price = price

    def set_price(self, new_price: float):
        if new_price > 0:
            self.__price = new_price
        else:
            print("Ошибка безопасности: Цена должна быть положительной!")

    def get_price(self):
        return self.__price

    def calculate_cost(self):
        return self.get_price()

    def get_display_info(self):
        return f"Товар: {self.name} | Цена: {self.get_price()} руб."


class WeighableProduct(Product):
    def __init__(self, name: str, price: float, weight: float):
        super().__init__(name, price)
        self.weight = weight

    def calculate_cost(self):
        return self.get_price() * self.weight

    def get_display_info(self):
        return f"Весовой товар: {self.name} | Вес: {self.weight} кг | Итого: {self.calculate_cost()} руб."


class PackagedProduct(Product):
    def __init__(self, name: str, price: float, quantity: int):
        super().__init__(name, price)
        self.quantity = quantity

    def calculate_cost(self):
        return self.get_price() * self.quantity

    def get_display_info(self):
        return f"Упаковка: {self.name} | Количество: {self.quantity} шт. | Итого: {self.calculate_cost()} руб."


# --- СИМУЛЯЦИЯ РАБОТЫ КАССЫ ---

# 1. Создаем корзину и наполняем её данными
cart = []
cart.append(Product("Молоко", 100))
cart.append(WeighableProduct("Яблоки", 50.0, 2.5))
cart.append(PackagedProduct("Яйца", 12, 10))

# 2. Попытка взлома системы (вызов метода set_price(-200) для молока)
cart[0].set_price(-200)

# 3. Печать чека в цикле
print("\n--- Чек EcoMarket ---")
total_sum = 0.0

for item in cart:
    print(item.get_display_info())
    total_sum += item.calculate_cost()

# 4. Вывод подвала чека с итоговой суммой
print("-" * 30)
print(f"ИТОГО К ОПЛАТЕ: {total_sum} руб.")
