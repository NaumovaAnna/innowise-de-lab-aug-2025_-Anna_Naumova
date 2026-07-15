SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    s.sales_id,
    s.total_price
FROM employees e
INNER JOIN sales s
    ON e.employee_id = s.employee_id
WHERE s.total_price > 1000
ORDER BY s.total_price DESC;