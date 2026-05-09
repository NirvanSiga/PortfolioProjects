-- Appending all monthly sales tables together
-- Handles both date formats in OrderDate: 'YYYY-MM-DD' and 'MM/DD/YYYY'

CREATE OR REPLACE TABLE `rfm2403.sales.sales_2025` AS

SELECT
  * REPLACE (
    COALESCE(
      SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)),
      SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))
    ) AS OrderDate
  )
FROM `rfm2403.sales.sales202501`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202502`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202503`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202504`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202505`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202506`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202507`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202508`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202509`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202510`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202511`

UNION ALL SELECT * REPLACE (COALESCE(SAFE.PARSE_DATE('%Y-%m-%d', CAST(OrderDate AS STRING)), SAFE.PARSE_DATE('%m/%d/%Y', CAST(OrderDate AS STRING))) AS OrderDate)
FROM `rfm2403.sales.sales202512`;


--calculate recency, frequency, monetary, r, f, m ranks
--combine views with CTEs
CREATE OR REPLACE VIEW `rfm2403.sales.rfm_metrics`
AS
WITH current_date AS (
  SELECT DATE ('2026-03-24') AS analysis_date
),
rfm AS (
  SELECT 
    CustomerID,
    MAX(OrderID) AS last_order_date,
    date_diff((SELECT analysis_date FROM current_date), MAX(OrderDate), DAY) AS recency,
    COUNT (*) AS frequency,
    SUM(OrderValue) AS monetary
  FROM `rfm2403.sales.sales_2025`
  GROUP BY CustomerID
)

SELECT 
  rfm.*,
  ROW_NUMBER() OVER(ORDER BY recency ASC) AS r_rank,
  ROW_NUMBER() OVER(ORDER BY frequency DESC) AS f_rank,
  ROW_NUMBER() OVER(ORDER BY monetary DESC) AS m_rank
FROM rfm;


--Assigning scores from 1(lowest) through 10(highest)
CREATE OR REPLACE VIEW `rfm2403.sales.rfm_scores`
AS
SELECT
  *, 
  NTILE(10) OVER(ORDER BY r_rank DESC) AS r_score,
  NTILE(10) OVER(ORDER BY f_rank DESC) AS f_score,
  NTILE(10) OVER(ORDER BY m_rank DESC) AS m_score, 
FROM `rfm2403.sales.rfm_metrics`;



--Total scores
CREATE OR REPLACE VIEW `rfm2403.sales.rfm_total_scores`
AS
SELECT 
  CustomerID,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  (r_score + f_score + m_score) AS rfm_total_score
FROM `rfm2403.sales.rfm_scores`
ORDER BY rfm_total_score DESC;


--BI ready rfm table
CREATE OR REPLACE TABLE `rfm2403.sales.rfm_segments_final`
AS
SELECT
  CustomerId,
  recency,
  frequency,
  monetary,
  r_score,
  f_score,
  m_score,
  rfm_total_score,
  CASE
    WHEN rfm_total_score >= 28 THEN 'Champion'
    WHEN rfm_total_score >= 24 THEN 'Loyal VIP'
   WHEN rfm_total_score >= 20 THEN 'Potential VIP'
   WHEN rfm_total_score >= 16 THEN 'Very Promising'
   WHEN rfm_total_score >= 12 THEN 'Engaged'
   WHEN rfm_total_score >= 8 THEN 'Requires Attention'
   WHEN rfm_total_score >= 4 THEN 'At Risk'
  ELSE 'Lost/Inactive'
  END AS rfm_segment
FROM `rfm2403.sales.rfm_total_scores`
ORDER BY rfm_total_score DESC;















