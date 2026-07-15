SELECT
	transaction_number,
	product_name,
	total_price,
	customer_id,
	sales_timestamp
FROM 
	sales s 
INNER JOIN products p ON s.product_id = p.product_id 
WHERE
	total_price > 1500
AND	p.class = 'A'
ORDER BY s.transaction_number 
LIMIT 10;
