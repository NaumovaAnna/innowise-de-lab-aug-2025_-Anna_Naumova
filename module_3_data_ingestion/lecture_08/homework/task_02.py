branches = [
    {"city": "Minsk", "revenue": 15000},
    {"city": "Warsaw", "revenue": 32000},
    {"city": "London", "revenue": 12000},
]


def audit_logger(func):
    """
    Декоратор для логирования запуска и завершения функции.
    """

    def wrapper(*args, **kwargs):
        print("[AUDIT] Запуск анализа...")

        result = func(*args, **kwargs)

        print("[AUDIT] Анализ завершен.")

        return result

    return wrapper


@audit_logger
def get_sorted_report(branches_data):
    """
    Сортирует список филиалов по выручке по убыванию.
    """
    sorted_branches = sorted(
        branches_data,
        key=lambda branch: branch["revenue"],
        reverse=True
    )

    return sorted_branches


sorted_report = get_sorted_report(branches)

print("Топ филиалов:")

for index, branch in enumerate(sorted_report, start=1):
    print(f"{index}. {branch['city']}: {branch['revenue']}")