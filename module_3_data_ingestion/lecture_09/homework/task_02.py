from typing import Optional, Union

Number = Union[int, float]


def calculate_total_delivery_cost(
    product_name: str,
    weights: list[Number] | tuple[Number, ...],
    prices: list[Number] | tuple[Number, ...],
    discount: Optional[float] = None,
    currency_rate: Number = 1,
    *extra_costs: float,
) -> dict[str, float]:
    """
    Рассчитывает итоговую стоимость партии товара.

    :param product_name: Название товара.
    :param weights: Коллекция с весами партий.
    :param prices: Коллекция с ценами за кг.
    :param discount: Скидка. Может быть None.
    :param currency_rate: Курс пересчета валюты. По умолчанию 1.
    :param extra_costs: Дополнительные расходы.
    :return: Словарь, где ключ — название товара, значение — итоговая стоимость.
    """
    if len(weights) != len(prices):
        raise ValueError("Количество весов и цен должно совпадать")

    total_sum: float = 0.0

    for index in range(len(weights)):
        total_sum += weights[index] * prices[index]

    if discount is not None:
        discount_sum: float = total_sum * (1 - discount)
    else:
        discount_sum = total_sum

    extra_sum: float = sum(extra_costs)

    final_sum: float = (discount_sum + extra_sum) * currency_rate

    return {product_name: final_sum}


vegetable_result = calculate_total_delivery_cost(
    "Овощная партия",
    [100, 50],
    [4, 6],
    0.1,
    1,
    20,
    15,
)

fruit_result = calculate_total_delivery_cost(
    "Фруктовая партия",
    (30, 20, 10),
    (15, 12, 18),
    None,
    1.2,
    25,
)

print(
    f"Товар: Овощная партия, итоговая стоимость: "
    f"{vegetable_result['Овощная партия']}"
)

print(
    f"Товар: Фруктовая партия, итоговая стоимость: "
    f"{fruit_result['Фруктовая партия']}"
)