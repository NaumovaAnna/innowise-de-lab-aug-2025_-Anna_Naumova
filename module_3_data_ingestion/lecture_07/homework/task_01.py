# Task 01

center_coords = (40.7128, -74.0060)
# center_coords[0] = 41.0000

print(f"Coordinates of the location of the central warehouse: {center_coords[0]} , {center_coords[1]}")

print(len(center_coords))
print(type(center_coords))

# Task 02

product = {
	"id": 105,
	"name": "Organic Buckwheat",
	"price": 3.50,
	"stock": 100
}

product["price"] = 4.2
product["category"] = "Grains"

discount_rate  = product.get("discount", 0)

print(product)
print(discount_rate)

# Task 03

suppliers_log = [
	"FreshFarm Inc",
	"GreenFields Ltd",
	"AgroWorld Co",
	"FreshFarm Inc",
	"GreenFields Ltd"
]

unique_suppliers = set(suppliers_log)
unique_suppliers.add("GreenFields Ltd")

is_freshfarm_present = "FreshFarm Inc" in unique_suppliers

print(is_freshfarm_present)
print(unique_suppliers)
print(len(unique_suppliers))

# Task 04

usd_prices = {
    "Banana": 1.2,
    "Mango": 2.5,
    "Avocado": 2.0,
}

eur_prices = {product: price * 0.9 for product, price in usd_prices.items()}

print(eur_prices)

# Task 05

import json
api_response_json = """ 
{ 
	"store": "StoreHub", 
	"orders": [ 
		{"id": 1, "total": 50}, 
		{"id": 2, "total": 200}, 
		{"id": 3, "total": 150} 
		]
 } 
"""

import json
api_response = json.loads(api_response_json)
orders = api_response["orders"]
high_value_orders = [order for order in orders if order["total"]>100]
api_response["high_value_orders"] = high_value_orders
updated_json = json.dumps(api_response, indent=4)

print(updated_json)
