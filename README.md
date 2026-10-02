# Credit Default Risk Analysis

A descriptive risk-analysis case study using the public UCI **Default of Credit Card Clients** dataset. The analysis profiles repayment-status and credit-limit cohorts to show where observed next-month default rates differ.

## Business question

Which cohorts show higher **observed** next-month default rates, and which signals deserve further review?

## Tools

Python · pandas · SQLite · Excel

## Dataset

- **Source:** [UCI Default of Credit Card Clients — Yeh (2009)](https://doi.org/10.24432/C55S3H)
- **Scope:** 30,000 historical credit-card client records and 25 source fields
- **License:** CC BY 4.0
- **Data handling:** raw customer-level data is not redistributed. Download the official source workbook separately and follow the instructions in [data/README.md](data/README.md).

## Data quality checks

| Check | Result |
| --- | ---: |
| Records profiled | 30,000 |
| Source fields | 25 |
| Unique client IDs | 30,000 |
| Missing values | 0 |
| Exact duplicate rows | 0 |

## Key findings

| Cohort | Observed next-month default rate |
| --- | ---: |
| All clients | 22.12% (6,636 / 30,000) |
| No reported recent delay (`PAY_0 ≤ 0`) | 13.83% (3,207 / 23,182) |
| 1-month delay (`PAY_0 = 1`) | 33.95% |
| 2+ months delay (`PAY_0 ≥ 2`) | 69.55% (2,177 / 3,130) |
| Lowest credit-limit quartile | 31.79% |
| Highest credit-limit quartile | 13.98% |

The repayment-status findings were calculated with pandas and independently reconciled using SQLite `GROUP BY` queries.

## Reproduce

1. Install the dependencies:

   ```bash
   python -m pip install -r requirements.txt
   ```

2. Download and convert the official UCI `.xls` workbook to `.xlsx` as described in [data/README.md](data/README.md).

3. Run the analysis:

   ```bash
   python src/credit_risk_analysis.py \
     --input /path/to/default_of_credit_card_clients.xlsx \
     --output outputs/credit_risk_summary.json \
     --audit-output outputs/data_audit.json
   ```

## Repository structure

```text
src/credit_risk_analysis.py       Reproducible analysis and validation checks
data/README.md                    Source and data-handling instructions
outputs/credit_risk_summary.json  Aggregate portfolio summary
outputs/data_audit.json           Aggregate audit and cohort results
```

## Important limitations

This is a historical public-dataset analysis. Results describe associations in labeled data; they do not establish causality, predict future default, or support an automated lending decision. A real credit use case would require current data, documented feature timing, validation, fairness assessment, regulatory review, and business-policy approval.
