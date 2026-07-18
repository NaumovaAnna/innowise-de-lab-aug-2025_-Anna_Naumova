daily_logs = [
    [500, 0, 1200],      # Касса 1
    [300, -999, 800],    # Касса 2
    [1500, 200],         # Касса 3
]

total_revenue = 0

for cashbox_number, transactions in enumerate(daily_logs, start=1):
    print(f"-- Обработка Кассы №{cashbox_number} --")

    for transaction in transactions:
        if transaction == -999:
            print("Аварийная остановка кассы!")
            break

        if transaction == 0:
            print("Пропуск сбоя")
            continue

        if transaction > 0:
            total_revenue += transaction
            print(f"Добавлено: {transaction}")

print("Итоговая выручка магазина:", total_revenue)