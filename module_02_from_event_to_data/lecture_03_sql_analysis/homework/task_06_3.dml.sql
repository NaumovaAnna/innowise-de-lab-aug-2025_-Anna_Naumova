UPDATE products
SET modify_timestamp = NOW()
WHERE modify_timestamp IS NULL;