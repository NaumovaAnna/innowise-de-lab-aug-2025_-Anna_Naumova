UPDATE products p
SET price = price * 1.10
FROM categories c
WHERE c.category_id = p.category_id
  AND c.category_name = 'Fruits';