def calculate_purchase(product_name, weight, price):
    """
    Рассчитывает итоговую стоимость партии товара.

    :param product_name: Название товара.
    :param weight: Вес партии.
    :param price: Цена за кг.
    """
    try:
        numeric_weight = float(weight)

        total_cost = numeric_weight * price
        technical_index = 100 / numeric_weight

        print(f"Товар: {product_name}. Итоговая стоимость: {total_cost}$")

    except TypeError as error:
        print(f"Тип ошибки: {type(error)}")
        print(f"Сообщение: {error}")

    except ValueError as error:
        print(f"Тип ошибки: {type(error)}")
        print(f"Сообщение: {error}")

    except ZeroDivisionError as error:
        print(f"Тип ошибки: {type(error)}")
        print(f"Сообщение: {error}")

    finally:
        print("--- Проверка партии завершена ---")
        print()


calculate_purchase("Томаты", 100, 2.5)
calculate_purchase("Огурцы", "пятьдесят", 1.8)
calculate_purchase("Перец", 0, 4)
calculate_purchase("Зелень", [10], 5)