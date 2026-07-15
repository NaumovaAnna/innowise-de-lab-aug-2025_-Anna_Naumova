SELECT 
first_name,
last_name,
address,
total_price AS max_amount
FROM sales s 
INNER JOIN employees e ON s.employee_id = e.employee_id
INNER JOIN shops sh ON e.shop_id = sh.shop_id
WHERE s.total_price = (
    SELECT MAX(total_price)
    FROM sales);
