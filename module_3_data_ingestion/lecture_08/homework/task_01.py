# Глобальный лимит для мелких закупок
SMALL_BATCH_LIMIT = 500


def calculate_batch(weight, price, discount=0.0):
    """
    Рассчитывает итоговую стоимость партии товара
    и проверяет, превышает ли она лимит.

    :param weight: Вес партии в кг.
    :param price: Цена за кг.
    :param discount: Скидка. По умолчанию 0.0.
    :return: Итоговая сумма и статус превышения лимита.
    """
    final_sum = weight * price * (1 - discount)
    is_limit_exceeded = final_sum > SMALL_BATCH_LIMIT

    return final_sum, is_limit_exceeded


carrots_sum, carrots_limit_exceeded = calculate_batch(100, 4)
apples_sum, apples_limit_exceeded = calculate_batch(50, 20, 0.1)

print(
    f"Партия 1 (Морковь): Сумма {carrots_sum}. "
    f"Превышение лимита: {carrots_limit_exceeded}"
)

print(
    f"Партия 2 (Яблоки): Сумма {apples_sum}. "
    f"Превышение лимита: {apples_limit_exceeded}"
)