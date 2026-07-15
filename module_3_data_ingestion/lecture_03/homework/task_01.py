# 1. Инициализирование входных переменных
raw_sku = "CARROT-001"
raw_regions = ("Minsk", "Warsaw", "Berlin", "Warsaw")
raw_weight_str = "2.5"
raw_stock_str = "150"

# 2. Явное преобразование типов
weight_kg = float(raw_weight_str)
stock_quantity = int(raw_stock_str)

# 3. Преобразование коллекций
sku_as_list = list(raw_sku)
regions_list = list(raw_regions)
unique_regions = set(regions_list)
regions_tuple = tuple(unique_regions)

# 4. Пустые коллекции двумя способами
empty_list_1 = []
empty_list_2 = list()

empty_dict_1 = {}
empty_dict_2 = dict()

empty_tuple_1 = ()
empty_tuple_2 = tuple()

empty_set = set()

# 5. Проверка на “пустоту” коллекций через bool()
print("Empty list:", bool(empty_list_1))
print("Empty dict:", bool(empty_dict_1))
print("Empty tuple:", bool(empty_tuple_1))
print("Empty set:", bool(empty_set))

non_empty_list = [raw_sku]
non_empty_dict = {"sku": raw_sku}
non_empty_tuple = (raw_sku,)
non_empty_set = {raw_sku}

#6. Выведение в консоль значения и типы
print("Non-empty list:", bool(non_empty_list))
print("Non-empty dict:", bool(non_empty_dict))
print("Non-empty tuple:", bool(non_empty_tuple))
print("Non-empty set:", bool(non_empty_set))
print("weight_kg:", weight_kg, type(weight_kg))
print("stock_quantity:", stock_quantity, type(stock_quantity))
print("sku_as_list:", sku_as_list, type(sku_as_list))
print("regions_list:", regions_list, type(regions_list))
print("unique_regions:", unique_regions, type(unique_regions))
print("regions_tuple:", regions_tuple, type(regions_tuple))
