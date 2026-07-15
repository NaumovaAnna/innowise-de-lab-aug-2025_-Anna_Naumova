CREATE OR REPLACE FUNCTION AvgSalesPerEmployee(p_employee_id INT)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    avg_sales NUMERIC;
BEGIN
    SELECT AVG(s.total_price)
    INTO avg_sales
    FROM sales s
    WHERE s.employee_id = p_employee_id;

    RETURN avg_sales;
END;
$$;