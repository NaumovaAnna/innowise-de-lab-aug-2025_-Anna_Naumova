UPDATE products p
SET class = 'A'
WHERE p.category_id IN (
    SELECT
        c.category_id
    FROM categories c
    INNER JOIN products p2
        ON c.category_id = p2.category_id
    INNER JOIN sales s
        ON p2.product_id = s.product_id
    GROUP BY
        c.category_id
    HAVING SUM(s.total_price) > 5000
);