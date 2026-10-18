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
 
## Power BI Dashboard

### Sales Overview
Shows sales KPIs, monthly revenue, country revenue and the Top 10
StockCodes, with a Country slicer.


### Customer Overview
Shows customer counts and revenue by RFM segment, and the Top 10
customers by completed-sales revenue, with segment and Country slicers.


## Key Findings

- The UK generated approximately 84.6% of total completed-sales revenue.
- Completed-sales revenue increased from approximately £1.06 million
  in September 2011 to £1.50 million in November 2011.
- The top 10% of identified customers generated approximately 61.45%
  of completed-sales revenue from identified customers.
- Champions represented approximately 10.5% of segmented customers
  and generated 48.9% of segmented completed-sales revenue.
- Overall cancellation invoice share was 16.12%.

## Overall
### Recommendations 
- Prioritise the UK, which generated approximately 84.6% of completed-sales revenue. Asses selected established overseas markets for further investment by reviewing revenue, demand and cancellation records.
- Review demand and cancellation records before increasing investment in low-volume markets. Assess profitability and fulfilment costs before deciding to stop serving a market.
- Prioritise retention of high-spending customers and Champions. Monitor changes in their purchasing activity and investigate ways to encourage repeat purchasing among Potential loyalists.
- Use the observed September–November sales increase to inform stock and staffing reviews, while checking whether the pattern continues in other years.

### Limitations

- Transactions without customer IDs were included in overall sales analysis but excluded from RFM segmentation and customer revenue concentration analysis.
- Revenue measures completed sales, not profit. Product costs, marketing costs and fulfilment costs were unavailable.
- Cancellation invoice share measures cancellation invoices as a proportion of completed and cancellation invoices. It does not show the percentage of original orders that were cancelled.
- High cancellation shares in countries with very few invoices should be interpreted cautiously.
- RFM segments describe historical purchasing behaviour. They do not prove future loyalty or predict customer churn.
- December 2011 contains only part of the month, so it should not be compared directly with complete months.
- The available period is insufficient to establish a recurring annual seasonal pattern.
