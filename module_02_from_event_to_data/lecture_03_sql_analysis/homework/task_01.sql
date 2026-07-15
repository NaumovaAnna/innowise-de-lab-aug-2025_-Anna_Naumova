SELECT 
    s.sales_id,
    p.product_name,
    s2.address AS shop_address
FROM sales s
INNER JOIN products p on s.product_id = p.product_id 
INNER join employees e on e.employee_id = s.employee_id 
INNER join shops s2 on e.shop_id = s2.shop_id 
ORDER BY S.sales_id 
limit 10;