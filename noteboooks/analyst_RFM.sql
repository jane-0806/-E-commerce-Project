USE online_retail_project;

-- CREATE RFM CUSTOMER TABLE
SELECT 
    MIN(Invoice_date) AS first_completed_sale,
    MAX(Invoice_date) AS last_completed_sale
FROM transactions
WHERE Transaction_status = 'Completed Sales';

SET @analysis_date = (
    SELECT DATE_ADD(DATE(MAX(Invoice_date)), INTERVAL 1 DAY)
    FROM transactions
    WHERE Transaction_status= 'Completed Sales'
); 

SELECT @analysis_date;

SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id;

-- CALCUALTE FREQUENCY CUMULATIVE PROPORTION
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
    Customer_id,
    frequency,
    CUME_DIST() OVER(ORDER BY frequency) AS cumulative_proportion
    FROM rfm_customer
    ORDER BY frequency, Customer_id;
    
-- FIND 25%, 50% AND 75% BOUNDARIES
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
),
frequency_distribution AS (
    SELECT 
    Customer_id,
    frequency,
    CUME_DIST() OVER(ORDER BY frequency) AS cumulative_proportion
    FROM rfm_customer
)
SELECT 
    MIN(CASE WHEN cumulative_proportion >= 0.25 THEN frequency END) AS frequency_25,
    MIN(CASE WHEN cumulative_proportion >= 0.50 THEN frequency END) AS frequency_50,
    MIN(CASE WHEN cumulative_proportion >= 0.75 THEN frequency END) AS frequency_75
FROM frequency_distribution;


-- TRUN THESE BOUNDARIES INTO F_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
	Customer_id,
    frequency,
CASE 
  WHEN frequency <= 1 THEN 1
  WHEN frequency <= 2 THEN 2
  WHEN frequency <= 5 THEN 3
  ELSE 4 
END AS F_score
FROM rfm_customer;

-- COUNT CUSTOMER NUMBER OF EACH F_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), frequency_score AS (
SELECT 
	Customer_id,
    frequency,
CASE 
  WHEN frequency <= 1 THEN 1
  WHEN frequency <= 2 THEN 2
  WHEN frequency <= 5 THEN 3
  ELSE 4 
END AS F_score
FROM rfm_customer
)
SELECT 
    F_score,
    COUNT(DISTINCT Customer_id) AS customer_count
FROM frequency_score
GROUP BY F_score
ORDER BY F_score;

-- CALCUALTE RECENCY CUMULATIVE PROPORTION
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
    Customer_id, 
    recency_date,
    CUME_DIST() OVER(ORDER BY recency_date) AS recency_cumul_proportion
FROM rfm_customer
ORDER BY recency_date, Customer_id;

-- BOUNDARIES 
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), recency_distribution AS (
	 SELECT 
    Customer_id, 
    recency_date,
    CUME_DIST() OVER(ORDER BY recency_date) AS recency_cumul_proportion
FROM rfm_customer
ORDER BY recency_date, Customer_id
)
SELECT 
    MIN(CASE WHEN recency_cumul_proportion >= 0.25 THEN recency_date END) AS recency_25,
    MIN(CASE WHEN recency_cumul_proportion >= 0.50 THEN recency_date END) AS recency_50,
    MIN(CASE WHEN recency_cumul_proportion >= 0.75 THEN recency_date END) AS recency_75
FROM recency_distribution;

-- R_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN recency_date <= 18 THEN 4
        WHEN recency_date <= 51 THEN 3
        WHEN recency_date <= 143 THEN 2
	    ELSE 1
	 END AS R_score
FROM rfm_customer;

-- COUNT CUSTOMER FOR EACH R_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), recency_score AS (
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN recency_date <= 18 THEN 4
        WHEN recency_date <= 51 THEN 3
        WHEN recency_date <= 143 THEN 2
	    ELSE 1
	 END AS R_score
FROM rfm_customer
) 
SELECT 
    R_score,
    COUNT(Customer_id) AS customer_number
FROM recency_score
GROUP BY R_score
ORDER BY R_score;


-- CALCUALTE MONETARY CUMULATIVE PROPORTION
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
    Customer_id,
    monetary,
    CUME_DIST()OVER(ORDER BY monetary) AS monetary_cumul_proportion
FROM rfm_customer
ORDER BY monetary, Customer_id;

-- BOUNDARIES 
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), monetary_distribution AS (
     SELECT 
         Customer_id,
         monetary,
         CUME_DIST()OVER(ORDER BY monetary) AS monetary_cumul_proportion
    FROM rfm_customer
	ORDER BY monetary, Customer_id
)
SELECT 
    MIN(CASE WHEN monetary_cumul_proportion >= 0.25 THEN monetary END) AS monetary_25,
    MIN(CASE WHEN monetary_cumul_proportion >= 0.50 THEN monetary END) AS monetary_50,
    MIN(CASE WHEN monetary_cumul_proportion >= 0.75 THEN monetary END) AS monetary_75
FROM monetary_distribution;


-- M_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
)
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN monetary <= 306.46 THEN 1
        WHEN monetary <= 668.56 THEN 2
        WHEN monetary <= 1660.88 THEN 3
	    ELSE 4
	 END AS M_score
FROM rfm_customer;


-- COUNT CUSTOMER FOR EACH M_SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), monetary_score AS (
	SELECT 
        Customer_id,
        recency_date,
        CASE 
		  WHEN monetary <= 306.46 THEN 1
          WHEN monetary <= 668.56 THEN 2
          WHEN monetary <= 1660.88 THEN 3
	    ELSE 4
	    END AS M_score
FROM rfm_customer
)
SELECT 
    M_score,
    COUNT(Customer_id) AS customer_number
FROM monetary_score
GROUP BY M_score
ORDER BY M_score;


-- COMBINE R, F, AND M SCORE
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), recency_score AS (
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN recency_date <= 18 THEN 4
        WHEN recency_date <= 51 THEN 3
        WHEN recency_date <= 143 THEN 2
	    ELSE 1
	 END AS R_score
FROM rfm_customer
), frequency_score AS (
      SELECT 
	     Customer_id,
		 frequency,
         CASE 
            WHEN frequency <= 1 THEN 1
            WHEN frequency <= 2 THEN 2
            WHEN frequency <= 5 THEN 3
            ELSE 4 
         END AS F_score
      FROM rfm_customer
), monetary_score AS (
	SELECT 
        Customer_id,
        recency_date,
        CASE 
		  WHEN monetary <= 306.46 THEN 1
          WHEN monetary <= 668.56 THEN 2
          WHEN monetary <= 1660.88 THEN 3
	    ELSE 4
	    END AS M_score
FROM rfm_customer
)
SELECT
    r.Customer_id,
    r.recency_date,
    r.frequency,
    r.monetary,
    rs.R_score,
    fs.F_score,
    ms.M_score
FROM rfm_customer AS r
JOIN recency_score AS rs
    ON r.Customer_id = rs.Customer_id
JOIN frequency_score AS fs
    ON r.Customer_id = fs.Customer_id
JOIN monetary_score AS ms
    ON r.Customer_id = ms.Customer_id;
    
-- R: fewer days → higher score
-- F: more orders → higher score
-- M: more spending → higher score

-- set the rules
-- R=F=M=4 : Champions
-- R>=3 F>= 3: potential loalists
-- R>=3 F=2 : recent repeat buyer
-- R>=3 F=1: recent one time buyer
-- R=1 F=4 M=4: disappeared high-spending frequent buyers
-- R=1 F>=3: At risk repeated buyers 
-- R=1 F<=2: Hibernating
-- otherwise: Other


WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), recency_score AS (
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN recency_date <= 18 THEN 4
        WHEN recency_date <= 51 THEN 3
        WHEN recency_date <= 143 THEN 2
	    ELSE 1
	 END AS R_score
FROM rfm_customer
), frequency_score AS (
      SELECT 
	     Customer_id,
		 frequency,
         CASE 
            WHEN frequency <= 1 THEN 1
            WHEN frequency <= 2 THEN 2
            WHEN frequency <= 5 THEN 3
            ELSE 4 
         END AS F_score
      FROM rfm_customer
), monetary_score AS (
	SELECT 
        Customer_id,
        recency_date,
        CASE 
		  WHEN monetary <= 306.46 THEN 1
          WHEN monetary <= 668.56 THEN 2
          WHEN monetary <= 1660.88 THEN 3
	    ELSE 4
	    END AS M_score
FROM rfm_customer
), combined_scores AS (
    SELECT
        r.Customer_id,
        r.recency_date,
        r.frequency,
        r.monetary,
        rs.R_score,
        fs.F_score,
        ms.M_score
    FROM rfm_customer AS r
    JOIN recency_score AS rs
        ON r.Customer_id = rs.Customer_id
    JOIN frequency_score AS fs
        ON r.Customer_id = fs.Customer_id
    JOIN monetary_score AS ms
        ON r.Customer_id = ms.Customer_id
)
SELECT
    Customer_id,
    recency_date,
    frequency,
    monetary,
    R_score,
    F_score,
    M_score,
    CASE
      WHEN R_score=4 AND F_score=4 AND M_score=4 THEN 'Champions'
      WHEN R_score>=3 AND F_score=3 THEN 'Potential loyalists'
      WHEN R_score>=3 AND F_score=2 THEN 'Recent repeat buyers'
      WHEN R_score>=3 AND F_score=1 THEN 'Recent one-time buyers'
      WHEN R_score=1 AND F_score=4 AND M_score=4 THEN 'Lapsed high-spending frequent buyers'
      WHEN R_score=1 AND F_score>=3 THEN 'At-risk repeat buyers'
      WHEN R_score=1 AND F_score<=2 THEN 'Hibernating'	
      ELSE 'Other'
	END AS segment
FROM combined_scores;

-- segment selection
WITH rfm_customer AS(
    SELECT 
     Customer_id,
     MAX(Invoice_date) AS last_purchase,
     DATEDIFF(
		 @analysis_date,
         MAX(Invoice_date)) AS recency_date,
         COUNT(DISTINCT Invoice_no) AS frequency,
         SUM(Revenue) AS monetary
FROM transactions
WHERE Transaction_status = 'Completed Sales'AND Customer_id IS NOT NULL
GROUP BY Customer_id
), recency_score AS (
SELECT 
     Customer_id,
     recency_date,
     CASE 
        WHEN recency_date <= 18 THEN 4
        WHEN recency_date <= 51 THEN 3
        WHEN recency_date <= 143 THEN 2
	    ELSE 1
	 END AS R_score
FROM rfm_customer
), frequency_score AS (
      SELECT 
	     Customer_id,
		 frequency,
         CASE 
            WHEN frequency <= 1 THEN 1
            WHEN frequency <= 2 THEN 2
            WHEN frequency <= 5 THEN 3
            ELSE 4 
         END AS F_score
      FROM rfm_customer
), monetary_score AS (
	SELECT 
        Customer_id,
        recency_date,
        CASE 
		  WHEN monetary <= 306.46 THEN 1
          WHEN monetary <= 668.56 THEN 2
          WHEN monetary <= 1660.88 THEN 3
	    ELSE 4
	    END AS M_score
FROM rfm_customer
), combined_scores AS (
    SELECT
        r.Customer_id,
        r.recency_date,
        r.frequency,
        r.monetary,
        rs.R_score,
        fs.F_score,
        ms.M_score
    FROM rfm_customer AS r
    JOIN recency_score AS rs
        ON r.Customer_id = rs.Customer_id
    JOIN frequency_score AS fs
        ON r.Customer_id = fs.Customer_id
    JOIN monetary_score AS ms
        ON r.Customer_id = ms.Customer_id
), segmented_customers AS (
    SELECT
        Customer_id,
        recency_date,
        frequency,
        monetary,
        R_score,
        F_score,
        M_score,
        CASE
            WHEN R_score = 4 AND F_score = 4 AND M_score = 4
                THEN 'Champions'
            WHEN R_score >= 3 AND F_score >= 3
                THEN 'Potential loyalists'
            WHEN R_score >= 3 AND F_score = 2
                THEN 'Recent repeat buyers'
            WHEN R_score >= 3 AND F_score = 1
                THEN 'Recent one-time buyers'
            WHEN R_score = 1 AND F_score = 4 AND M_score = 4
                THEN 'Lapsed high-spending frequent buyers'
            WHEN R_score = 1 AND F_score >= 3
                THEN 'At-risk repeat buyers'
            WHEN R_score = 1 AND F_score <= 2
                THEN 'Hibernating'
            ELSE 'Other'
        END AS segment
    FROM combined_scores
)
SELECT 
    segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(monetary),2) AS total_monetary,
    ROUND(AVG(monetary), 2) AS average_monetary,
    ROUND(AVG(frequency),2) AS average_frequency,
    ROUND(AVG(recency_date), 2) AS average_recency_days
FROM segmented_customers
GROUP BY segment
ORDER BY total_monetary DESC;

-- Calculate how much revenue comes from the top 10 percent of customers

WITH customer_spending AS (
    SELECT
        Customer_id,
        SUM(Revenue) AS monetary
    FROM transactions
    WHERE Transaction_status = 'Completed Sales'
      AND Customer_id IS NOT NULL
    GROUP BY Customer_id
),
ranked_customers AS (
    SELECT
        Customer_id,
        monetary,
        ROW_NUMBER() OVER (
            ORDER BY monetary DESC, Customer_id
        ) AS spending_position,
        COUNT(*) OVER () AS total_customers
    FROM customer_spending
),
revenue_totals AS (
    SELECT
        COUNT(*) AS customer_count,
        CEIL(COUNT(*) * 0.10) AS top10_customer_count,
        SUM(
            CASE
                WHEN spending_position <= CEIL(total_customers * 0.10) THEN monetary
                ELSE 0
            END
        ) AS top10_customer_revenue,
        SUM(monetary) AS all_customer_revenue
    FROM ranked_customers
)
SELECT
    customer_count,
    top10_customer_count,
    ROUND(top10_customer_revenue, 2) AS top10_customer_revenue,
    ROUND(all_customer_revenue, 2) AS all_customer_revenue,
    ROUND(
        top10_customer_revenue
        / NULLIF(all_customer_revenue, 0) * 100,
        2
    ) AS top10_customer_revenue_pct
FROM revenue_totals;

-- top10% customer revenue has 61.46% in total revenue, which means the only top 10 customers contributed arbound 2/3 of total revenue 
-- So i can say revenue is concentrated among a relatively small group 