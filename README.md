# Credit Default Risk Analysis

[View the live dashboard](https://poojasri234.github.io/credit-default-risk-analysis/)

This descriptive monitoring project uses the public [UCI Default of Credit Card Clients dataset](https://doi.org/10.24432/C55S3H). It compares observed next-month default rates across repayment-status and credit-limit cohorts; it is not a predictive credit model.

## Data setup

UCI distributes the source as an `.xls` workbook. I downloaded it locally and converted it to `.xlsx`, preserving the title row and the second-row headers needed by the analysis. The local source file is ignored by Git; [data notes](data/README.md) document the process.

## Question

Which repayment-status and credit-limit cohorts show higher observed next-month default rates and should be monitored more closely?

## Method

- Validated **30,000** unique client IDs, **25** source fields, zero missing values, and zero exact duplicate records.
- Calculated observed default rate as `default payment next month = 1 ÷ all clients in each cohort`.
- Grouped recent repayment status into no reported delay, one-month delay, and two-or-more-months delay.
- Created descriptive credit-limit quartiles.
- Reconciled the cohort counts and rates with [SQLite](sql/credit_risk_cohort_analysis.sql) before publishing aggregate results.

## Results

| Cohort | Clients | Defaults | Observed next-month default rate |
| --- | ---: | ---: | ---: |
| All clients | 30,000 | 6,636 | 22.12% |
| No reported delay | 23,182 | 3,207 | 13.83% |
| One-month delay | 3,688 | 1,252 | 33.95% |
| Two-or-more-month delay | 3,130 | 2,177 | 69.55% |
| Lowest credit-limit quartile | 7,676 | 2,440 | 31.79% |
| Highest credit-limit quartile | 7,067 | 988 | 13.98% |

The two-or-more-month-delay group represents **10.4%** of clients but **32.8%** of recorded defaults. That makes it a useful cohort for descriptive monitoring, not an automated lending rule.

## Recommended next step

Use the cohorts as a monitoring view and validate the pattern with current operational data and other relevant attributes. Any outreach, collections-support, or risk-review pilot would need policy approval, human review, fairness assessment, and a controlled evaluation.

For scale only, a one-percentage-point reduction in a comparable future cohort of 3,130 clients would equal about **31 fewer default-labelled accounts**. This is neither a forecast nor a financial benefit estimate; exposure, loss, cost, and causal-effect data are missing.

## Notes on the data

- The dataset covers historical Taiwan credit-card clients, not employer data.
- The analysis describes associations; it does not establish causality or predict future default.
- The quartiles are descriptive cut points, not policy thresholds.
- No fairness review, expected-loss calculation, or business-policy approval has been performed.

## Project files

- [SQL cohort analysis](sql/credit_risk_cohort_analysis.sql)
- [Python analysis](src/credit_risk_analysis.py)
- [Power BI measures and report plan](powerbi/)
- [Aggregate results](outputs/credit_risk_summary.json) and [data audit](outputs/data_audit.json)

## Run it

```bash
python -m pip install -r requirements.txt
python src/credit_risk_analysis.py \
  --input /path/to/default_of_credit_card_clients.xlsx \
  --output outputs/credit_risk_summary.json \
  --audit-output outputs/data_audit.json
```
