SELECT
	shop_id,
	address AS shop_adress,
	city_name,
	country_name
FROM 
	shops s 
INNER JOIN cities c ON s.city_id = c.city_id 
INNER JOIN countries c2 ON c.country_id = c2.country_id 
WHERE c2.country_name = 'Poland';