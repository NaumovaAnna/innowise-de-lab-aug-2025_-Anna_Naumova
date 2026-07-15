SELECT
	country_name,
	count(s.shop_id ) AS shops_count
FROM shops s 
INNER JOIN cities c ON s.city_id = c.city_id
INNER JOIN countries c2 ON c. country_id = c2. country_id
GROUP BY c2.country_name 
ORDER BY shops_count DESC
