CREATE DATABASE IF NOT EXISTS online_retail_project
	CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;
    
USE online_retail_project;

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INTEGER AUTO_INCREMENT PRIMARY KEY,
    Invoive_no VARCHAR(20) NOT NULL,
    Stock_code VARCHAR(20) NOT NULL,
    Desc_pro VARCHAR(30) NULL,
    Quantity INT NOT NULL,
    Invoice_date DATETIME NOT NULL,
    Unit_price DECIMAL(12,2) NOT NULL,
    Customer_id VARCHAR(20) NULL,
    Country VARCHAR(100) NOT NULL,
    Transaction_status VARCHAR(50) NOT NULL,
    Revenue DECIMAL(14,2) NOT NULL,
    Yearmonth CHAR(7) NOT NULL,
    Week_day VARCHAR(10) NOT NULL,
    Hour TINYINT UNSIGNED NOT NULL,
    Transaction_date DATE NOT NULL
    );
    
SHOW TABLES;
DESCRIBE transactions;
SELECT COUNT(*) FROM transactions;

-- MODIFY ERROR
ALTER TABLE transactions MODIFY COLUMN Desc_pro VARCHAR(500) NULL;
ALTER TABLE transactions RENAME COLUMN Invoive_no TO Invoice_no; 

SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = ON;
 
LOAD DATA LOCAL INFILE
'D:/Project/online+retail/processed/clean_transactions.csv'
INTO TABLE transactions
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    Invoice_no,
    Stock_code,
    @Desc_pro,
    Quantity,
    Invoice_date,
    Unit_price,
    @Customer_id,
    Country,
    Transaction_status,
    Revenue,
    Yearmonth,
    Week_day,
    Hour,
    Transaction_date
)
SET
    Desc_pro = NULLIF(@Desc_pro, ''),
    Customer_id = NULLIF(@Customer_id, '');
  
SELECT COUNT(*) AS imported_rows
FROM transactions;

-- CHECK WHETHER IMPORTED REVENUE IS CORRECT 
SELECT Quantity, Unit_price, Revenue, ROUND(Quantity * Unit_price) AS expected_revenue 
FROM transactions LIMIT 20;

-- COUNT ANY REVENUE MISMATCHES
SELECT COUNT(*) AS revenue_mismatches FROM transactions 
WHERE Revenue <> ROUND(Quantity * Unit_price, 2);

-- CHECK THE IMPORTED ROW COUNT AND SAMPLE ROWS
SELECT COUNT(*) AS imported_row FROM transactions; 
SELECT * FROM transactions LIMIT 10; 

-- CHECK THE UNIQUE INVOICE, CUSTOMER, AND COUNTRY
SELECT COUNT(DISTINCT Invoice_no) AS unique_invoice FROM transactions; 
SELECT COUNT(DISTINCT Customer_id) AS unique_customer FROM transactions;
SELECT COUNT(DISTINCT Country) AS unique_country FROM transactions;

-- CHECK THE MAXIMUM AND MINIMUM INVOICE DATE
SELECT MIN(Invoice_date) AS earliest_date FROM transactions;
SELECT MAX(Invoice_date) AS latest_date FROM transactions;
 
 -- CHECK THE MISSING VALUES 
SELECT 
     SUM(Desc_pro IS NULL ) AS missing_descriptions,
     SUM(Customer_id IS NULL) AS missing_customer_ids
FROM transactions;

-- CHECK EMPTY STRING
SELECT 
    SUM(Desc_pro = ' ') AS empty_descriptions,
    SUM(Customer_id = ' ') AS empty_customer_ids
FROM transactions;

-- CHECK TRANSACTION STATUSES
SELECT Transaction_status, COUNT(*) AS row_count FROM transactions GROUP BY Transaction_status ORDER BY row_count DESC;

/* 
The clean_transactions.csv file was imported into MySQL table.

The MySQL and Python results matched for:
- total row count
- date range
- number of unique invoice, customers, and country
- each number of transcation statues
*/

-- UNIQUE INVOICE NUMBER
SELECT COUNT(DISTINCT Invoice_no) FROM transactions;
-- NUMBER OF UNIQUE ORDERS IN EACH TRANSACTION STATUS 
SELECT Transaction_status, COUNT(DISTINCT Invoice_no) AS unique_orders
FROM transactions
GROUP BY Transaction_status;

-- CHECK COMPLETED SALES REVENUE 
SELECT ROUND(SUM(Revenue),2) AS completed_revenue FROM transactions WHERE Transaction_status = 'Completed Sales';

-- CHECK CANCELLED SALES REVENUE
SELECT ROUND(SUM(Revenue),2) AS cancelled_revenue FROM transactions WHERE Transaction_status = 'Cancelled';

-- CHECK PRICE ADJUSTMENT REVENUE
SELECT ROUND(SUM(Revenue),2) AS cancelled_revenue FROM transactions WHERE Transaction_status= 'Price Adjustment';

-- AVERAGE ORDER VALUE for COMPLETED ORDER
SELECT ROUND(AVG(order_revenue), 2) AS average_order_value
FROM (
    SELECT
        Invoice_no,
        SUM(Revenue) AS order_revenue
    FROM transactions
    WHERE Transaction_status = 'Completed Sales'
    GROUP BY Invoice_no
) AS order_totals;

/*
- Unique Inove: 25900
- Unique Customer: 4372
- Unique Country: 38

- Earliest_date: 2010-12-01 08:26:00
- Latest_date: 2011-12-09 12:50:00

- Missing descriptions: 1454
- Missing customer ids: 135037

- Completed sales: 524878
- Cancelled: 9251
- Price Adjustment: 2512

- Total unique Invoice_no: 25900
- Unique completed sales order: 19960
- Unique cancelled order: 3836
- Unique price adjustment order:2157
- Some invoices contain both completed-sales and price-adjustment rows, so these category counts should not be added together.

- Sum of completed revenue: 10642110.80
- Sum of cancelled revenue: -893979.73
- Sum of price adjustment revenue: -22124.12

- Average_order_value (completed sales): 533.17
 
*/

-- CALCULATE MONTHLY REVENUE and ORDERS
SELECT
	DISTINCT Yearmonth, 
    ROUND(SUM(Revenue), 2)AS Monthly_revenue
FROM transactions
WHERE Transaction_status = 'Completed Sales'
GROUP BY Yearmonth
ORDER BY Yearmonth ASC;

SELECT
	DISTINCT Yearmonth, 
    COUNT(DISTINCT Invoice_no) AS Monthly_order
FROM transactions
WHERE Transaction_status='Completed Sales'
GROUP BY Yearmonth
ORDER BY Yearmonth ASC;

-- COMBINE BOTH RESULTS
SELECT 
    Yearmonth,
    ROUND(SUM(Revenue), 2) AS Monthly_revenue,
    COUNT(DISTINCT Invoice_no) AS Monthly_order
FROM transactions
WHERE Transaction_status = 'Completed Sales'
GROUP BY Yearmonth
ORDER BY Yearmonth ASC;

SELECT
	DISTINCT Yearmonth, 
    COUNT(DISTINCT Invoice_no) AS Monthly_order
FROM transactions
WHERE Transaction_status='Cancelled'
GROUP BY Yearmonth
ORDER BY Yearmonth ASC;

SELECT
	DISTINCT Yearmonth, 
    COUNT(DISTINCT Invoice_no) AS Monthly_order
FROM transactions
WHERE Transaction_status='Price Adjustment'
GROUP BY Yearmonth
ORDER BY Yearmonth ASC;

-- ORDERS BY WEEKDAY
SELECT
	DISTINCT Week_day, 
    COUNT(DISTINCT Invoice_no) AS Weekday_order
FROM transactions
WHERE Transaction_status='Completed Sales'
GROUP BY Week_day
ORDER BY FIELD(
    Week_day,
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
);

SELECT COUNT(*) AS saturday_rows
FROM transactions
WHERE Week_day = 'Saturday'
  AND Transaction_status = 'Completed Sales';
  
SELECT COUNT(*) AS saturday_rows
FROM transactions
WHERE Week_day = 'Saturday'; -- there are no orders in saturday



-- ORDERS BY HOUR
SELECT
	DISTINCT Hour, 
    COUNT(DISTINCT Invoice_no) AS Hour_order
FROM transactions
WHERE Transaction_status='Completed Sales'
GROUP BY Hour
ORDER BY Hour ASC;



-- TOP 10 PRODUCT BY REVENUE
SELECT 
    Stock_code AS Product_code, 
    SUM(Revenue) AS Product_revenue
FROM transactions 
WHERE Transaction_status = 'Completed Sales'
GROUP BY Stock_code
ORDER BY Product_revenue DESC
LIMIT 10;

-- TOP 10 PRODUCT BY QUANTITY
SELECT 
    Stock_code AS Product_code, 
	SUM(Quantity) AS Total_quantity_sold
FROM transactions 
WHERE Transaction_status = 'Completed Sales'
GROUP BY Stock_code
ORDER BY Total_quantity_sold DESC
LIMIT 10;

-- REVENUE BY COUNTRY
SELECT 
	Country,
    SUM(Revenue) AS total_revenue
FROM transactions
GROUP BY Country
ORDER BY total_revenue DESC; 

-- CUSTOMER COUNT BY COUNTRY
SELECT
    Country,
    COUNT(DISTINCT Customer_id) AS Unique_customers
FROM transactions
WHERE Customer_id IS NOT NULL
GROUP BY Country
ORDER BY Unique_customers DESC;



