USE online_retail_project;

DESCRIBE transactions; 
SELECT COUNT(*) FROM transactions;

-- CREATE CUSTOMER LEVEL ORDERS AND SPENDING 
SELECT 
    DISTINCT Customer_id,
    COUNT(DISTINCT Invoice_no) AS total_orders,
    SUM(REVENUE) AS total_spendig
FROM transactions
WHERE Customer_id IS NOT NULL AND Transaction_status = 'Completed Sales'
GROUP BY Customer_id;


-- FIND CUSTOMERS WHOSE TOTAL SPENDING IS HIGHER THAN THE AVERAGE TOTAL SPENDING PER CUSTOMER
WITH customer_summary AS(
   SELECT 
       DISTINCT Customer_id,
       COUNT(DISTINCT Invoice_no) AS total_orders,
       SUM(REVENUE) AS total_spending
   FROM transactions
   WHERE Customer_id IS NOT NULL AND Transaction_status = 'Completed Sales'
   GROUP BY Customer_id
)
SELECT 
    Customer_id,
    total_spending
FROM customer_summary
WHERE total_spending > (
	SELECT 
		AVG(total_spending) AS avg_spending
	FROM customer_summary
)
ORDER BY total_spending DESC;

-- Revenue change
WITH monthly_summary AS (
    SELECT
        DATE_FORMAT(Invoice_date, '%Y-%m') AS month_label,
        SUM(Revenue) AS monthly_revenue
    FROM transactions
    WHERE Transaction_status = 'Completed Sales'
    GROUP BY DATE_FORMAT(Invoice_date, '%Y-%m')
)
SELECT
    month_label,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY month_label
    ) AS previous_month_revenue,
    monthly_revenue - LAG(monthly_revenue) OVER (
        ORDER BY month_label
    ) AS revenue_change
FROM monthly_summary
ORDER BY month_label;