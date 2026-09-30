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

-- CHECK COMPLETED SALES REVENUE 
SELECT ROUND(SUM(Revenue),2) AS completed_revenue FROM transactions WHERE Transaction_status = 'Completed Sales';

/* 
The clean_transactions.csv file was imported into MySQL table.

The MySQL and Python results matched for:
- total row count
- date range
- number of unique invoice, customers, and country
- each number of transcation statues
*/

