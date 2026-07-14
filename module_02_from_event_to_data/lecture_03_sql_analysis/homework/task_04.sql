SELECT 
product_name,
SUM(s.total_price ) total_revenue,
AVG (s.total_price) avg_sale
FROM sales s 
INNER JOIN products p ON s.product_id = p.product_id 
GROUP BY p.product_name
HAVING SUM(total_price) > 400000
ORDER BY SUM(total_price) DESC 
LIMIT 10;