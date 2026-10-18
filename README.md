# Online Retail Sales and Customer Analysis

## Project overview 
This project analyses online retail transactions to understand sales performance, customer purchasing behaviour and revenue concentration. Python is used for data preparation, and MySQL is also used for analysis and RFM segmentation. Power BI is employed for interactive reporting. 

## Business Questions 
- How does completed-sales revenue vary across months and countries?
- Which Products and customers generate the most revenue?
- How concentrated is revenue among customers?
- How do customer groups differ in purchasing activity and spending?
- What do cancellation invoice patterns suggest for further investigation?

## Dataset
- https://archive.ics.uci.edu/dataset/352/online+retail

## Tools
- Python: data cleaning and exploratory analysis
- MySQL: validation, sales analysis and RFM segmentation
- Power BI: interactive Sales Overview and Customer Overview reports

## Data preparation
- Removed duplicate rows and converted columns to suitable data types.
- Classified transactions to distinguish completed sales from cancellations.
- Checked missing customer IDs and zero or negative prices.
- Calculated revenue using quantity and unit price.
- Retained transactions without customer IDs for overall sales analysis,
  but excluded them from customer-level RFM segmentation.
- Excluded postage codes DOT and POST, and manual entries M,
  from the StockCode revenue ranking only.

## SQL analysis
- Compared SQL results with Python calculation to check consistency.
- Used common table expressions (CTEs) to calculate customer-level RFM metrics: recency, frequency and monetary value.
- Calculated recency  (days since the last completed purchase), frequency (number of distinct completed orders) and monetary value
  (total completed-sales revenue per customer). 
- Assigned each metric a score from 1 to 4 using selected thresholds. More resent purchases. More recent purchases, more orders        and higher scores.

## RFM Segmentation

Each customer received scores from 1 to 4:
- Recency: fewer days since the last purchase → higher score.
- Frequency: more distinct completed orders → higher score.
- Monetary value: higher completed-sales spending → higher score.

Customers were assigned to the first matching rule below:

| Segment | Rule |
|---|---|
| Champions | R = 4, F = 4 and M = 4 |
| Potential loyalists | R ≥ 3 and F ≥ 3 |
| Recent repeat buyers | R ≥ 3 and F = 2 |
| Recent one-time buyers | R ≥ 3 and F = 1 |
| Lapsed high-spending frequent buyers | R = 1, F = 4 and M = 4 |
| At-risk repeat buyers | R = 1 and F ≥ 3 |
| Hibernating | R = 1 and F ≤ 2 |
| Other | Customers who did not match the preceding rules |

These segments use project-defined rules to describe past purchasing
behaviour; they do not predict future loyalty or churn.
 
 


## 
