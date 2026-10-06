-- Credit Default Risk: SQLite validation and descriptive cohort queries
--
-- Source: UCI Default of Credit Card Clients — Yeh (2009)
-- https://doi.org/10.24432/C55S3H
--
-- Expected table: credit_clients
-- Expected columns retain the official workbook names, including:
--   "ID", "LIMIT_BAL", "PAY_0", and "default payment next month"
--
-- The raw workbook is intentionally not included in this repository. Follow
-- data/README.md to download it from UCI, then import it into SQLite.
--
-- These queries calculate descriptive cohort rates only. They are not a
-- prediction model and must not be used to make a credit decision.

-- ============================================================================
-- 1. Portfolio-level validation
-- ============================================================================
SELECT
  COUNT(*) AS record_count,
  COUNT(DISTINCT "ID") AS unique_client_ids,
  COUNT(*) - COUNT(DISTINCT "ID") AS repeated_client_id_count,
  SUM(CASE WHEN "LIMIT_BAL" IS NULL THEN 1 ELSE 0 END) AS missing_limit_bal,
  SUM(CASE WHEN "PAY_0" IS NULL THEN 1 ELSE 0 END) AS missing_pay_0,
  SUM(CASE WHEN "default payment next month" IS NULL THEN 1 ELSE 0 END) AS missing_default_label,
  SUM(CASE WHEN "default payment next month" = 1 THEN 1 ELSE 0 END) AS defaults,
  ROUND(100.0 * SUM(CASE WHEN "default payment next month" = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS overall_default_rate_percent
FROM credit_clients;

-- Exact duplicate check across all 25 official source fields.
-- The validated UCI workbook returns zero extra exact copies.
WITH exact_rows AS (
  SELECT
    "ID", "LIMIT_BAL", "SEX", "EDUCATION", "MARRIAGE", "AGE",
    "PAY_0", "PAY_2", "PAY_3", "PAY_4", "PAY_5", "PAY_6",
    "BILL_AMT1", "BILL_AMT2", "BILL_AMT3", "BILL_AMT4", "BILL_AMT5", "BILL_AMT6",
    "PAY_AMT1", "PAY_AMT2", "PAY_AMT3", "PAY_AMT4", "PAY_AMT5", "PAY_AMT6",
    "default payment next month",
    COUNT(*) AS copies
  FROM credit_clients
  GROUP BY
    "ID", "LIMIT_BAL", "SEX", "EDUCATION", "MARRIAGE", "AGE",
    "PAY_0", "PAY_2", "PAY_3", "PAY_4", "PAY_5", "PAY_6",
    "BILL_AMT1", "BILL_AMT2", "BILL_AMT3", "BILL_AMT4", "BILL_AMT5", "BILL_AMT6",
    "PAY_AMT1", "PAY_AMT2", "PAY_AMT3", "PAY_AMT4", "PAY_AMT5", "PAY_AMT6",
    "default payment next month"
)
SELECT
  COALESCE(SUM(copies - 1), 0) AS extra_exact_duplicate_rows,
  COALESCE(SUM(CASE WHEN copies > 1 THEN 1 ELSE 0 END), 0) AS duplicate_value_groups
FROM exact_rows;

-- Confirm the next-month default label is binary in the validated workbook.
SELECT
  "default payment next month" AS default_label,
  COUNT(*) AS clients
FROM credit_clients
GROUP BY "default payment next month"
ORDER BY default_label;

-- ============================================================================
-- 2. Repayment-status cohort view (reconciles with outputs/data_audit.json)
-- ============================================================================
WITH repayment_cohorts AS (
  SELECT
    CASE
      WHEN "PAY_0" >= 2 THEN '2+ months delay'
      WHEN "PAY_0" = 1 THEN '1 month delay'
      ELSE 'No reported delay'
    END AS cohort,
    "default payment next month" AS default_flag
  FROM credit_clients
)
SELECT
  cohort,
  COUNT(*) AS customers,
  SUM(default_flag) AS defaults,
  ROUND(100.0 * SUM(default_flag) / COUNT(*), 2) AS observed_default_rate_percent
FROM repayment_cohorts
GROUP BY cohort
ORDER BY CASE cohort
  WHEN 'No reported delay' THEN 1
  WHEN '1 month delay' THEN 2
  WHEN '2+ months delay' THEN 3
END;

-- A reconciliation check: each client must belong to exactly one status cohort.
WITH repayment_cohorts AS (
  SELECT
    CASE
      WHEN "PAY_0" >= 2 THEN '2+ months delay'
      WHEN "PAY_0" = 1 THEN '1 month delay'
      ELSE 'No reported delay'
    END AS cohort,
    "default payment next month" AS default_flag
  FROM credit_clients
), cohort_totals AS (
  SELECT COUNT(*) AS customers, SUM(default_flag) AS defaults
  FROM repayment_cohorts
)
SELECT
  customers AS cohort_customer_total,
  defaults AS cohort_default_total,
  (SELECT COUNT(*) FROM credit_clients) AS source_customer_total,
  (SELECT SUM("default payment next month") FROM credit_clients) AS source_default_total,
  CASE WHEN customers = (SELECT COUNT(*) FROM credit_clients)
         AND defaults = (SELECT SUM("default payment next month") FROM credit_clients)
       THEN 'PASS' ELSE 'CHECK' END AS reconciliation_status
FROM cohort_totals;

-- ============================================================================
-- 3. Credit-limit quartile cohorts (reconciles with the validated Python output)
-- ============================================================================
-- The Python workflow used pd.qcut on this exact UCI workbook. Its documented
-- data-driven boundaries are 50,000, 140,000, and 240,000. Keeping those
-- fixed boundaries here reproduces the published aggregate quartiles, including
-- tied values at each boundary. Do not reuse these cut points for another data set.
WITH limit_cohorts AS (
  SELECT
    CASE
      WHEN "LIMIT_BAL" <= 50000 THEN 'Lowest limit quartile'
      WHEN "LIMIT_BAL" <= 140000 THEN 'Lower-middle limit quartile'
      WHEN "LIMIT_BAL" <= 240000 THEN 'Upper-middle limit quartile'
      ELSE 'Highest limit quartile'
    END AS cohort,
    "default payment next month" AS default_flag
  FROM credit_clients
)
SELECT
  cohort,
  COUNT(*) AS customers,
  SUM(default_flag) AS defaults,
  ROUND(100.0 * SUM(default_flag) / COUNT(*), 2) AS observed_default_rate_percent
FROM limit_cohorts
GROUP BY cohort
ORDER BY CASE cohort
  WHEN 'Lowest limit quartile' THEN 1
  WHEN 'Lower-middle limit quartile' THEN 2
  WHEN 'Upper-middle limit quartile' THEN 3
  WHEN 'Highest limit quartile' THEN 4
END;

-- Optional exploratory alternative for a new data set (SQLite 3.25+):
-- NTILE creates four nearly equal-sized rank buckets. It will not necessarily
-- reproduce the tied-value qcut cohorts above, so keep it separate from the
-- published findings.
WITH ranked_clients AS (
  SELECT
    "ID",
    "default payment next month" AS default_flag,
    NTILE(4) OVER (ORDER BY "LIMIT_BAL", "ID") AS quartile_number
  FROM credit_clients
)
SELECT
  'Rank quartile ' || quartile_number AS cohort,
  COUNT(*) AS customers,
  SUM(default_flag) AS defaults,
  ROUND(100.0 * SUM(default_flag) / COUNT(*), 2) AS observed_default_rate_percent
FROM ranked_clients
GROUP BY quartile_number
ORDER BY quartile_number;
