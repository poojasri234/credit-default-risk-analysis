# Credit Default Risk Analysis

[Open the live dashboard](https://poojasri234.github.io/credit-default-risk-analysis/)

**Tools:** Python/pandas · SQL/SQLite · Excel source-data handling · interactive HTML dashboard · Power BI report specification and DAX measures

A descriptive risk-monitoring case study using the public [UCI Default of Credit Card Clients dataset](https://doi.org/10.24432/C55S3H). It identifies observed differences in next-month default rates across repayment-status and credit-limit cohorts; it is not a predictive credit model.

**Reproducibility note:** the official UCI workbook is not redistributed here. The published aggregate outputs were generated after downloading the source locally and converting its `.xls` workbook to a local `.xlsx` file while preserving the first title row and second header row required by the analysis. That local input is ignored by Git; see [data handling notes](data/README.md).

## Business question

In this historical public dataset, which repayment-status and credit-limit cohorts show higher observed next-month default rates and therefore warrant deeper monitoring?

## Approach

1. Validated **30,000** unique client IDs, **25** source fields, zero missing values, and zero exact duplicate records.
2. Defined observed next-month default rate as records labelled `default payment next month = 1` divided by all clients in each cohort.
3. Grouped the recent repayment-status field into no reported delay, one-month delay, and two-or-more-months delay.
4. Created descriptive credit-limit quartiles using the validated workbook.
5. Independently reconciled cohort counts and rates with [SQLite `GROUP BY` queries](sql/credit_risk_cohort_analysis.sql) before publishing aggregate results.

## Findings

| Cohort | Clients | Defaults | Observed next-month default rate |
| --- | ---: | ---: | ---: |
| All clients | 30,000 | 6,636 | 22.12% |
| No reported delay | 23,182 | 3,207 | 13.83% |
| One-month delay | 3,688 | 1,252 | 33.95% |
| Two-or-more-month delay | 3,130 | 2,177 | 69.55% |
| Lowest credit-limit quartile | 7,676 | 2,440 | 31.79% |
| Highest credit-limit quartile | 7,067 | 988 | 13.98% |

The two-or-more-month-delay cohort is **10.4%** of clients but accounts for **32.8%** of observed default labels. This supports descriptive monitoring, not a lending rule.

## Recommendation

Use repayment-status cohorts as a descriptive portfolio-monitoring view and investigate whether the pattern remains after considering other documented attributes.

For a real organisation, any outreach, collections-support, or risk-review pilot must be policy-approved, human-reviewed, tested on current data, and assessed for fairness. Do not use these historical cohorts as an automated lending or credit-limit decision rule.

## Potential business value — illustrative only

The dataset has no exposure at default, loss given default, collection cost, or evidence that an intervention works, so it cannot support a monetary benefit claim.

As a sizing example only, a **one-percentage-point absolute reduction** in next-month defaults within a comparable future cohort of **3,130** clients would mean about **31 fewer default-labelled accounts**. Financial value would require current exposure, loss, intervention-cost, and causal-effect data.

## Limitations

- This is a historical public dataset of Taiwan credit-card clients, not employer data.
- The analysis describes associations; it does not establish causality, predict future default, or train a credit model.
- Quartile cut points are specific to this workbook and are not policy thresholds.
- No fairness assessment, model validation, regulatory review, expected-loss calculation, or business-policy approval has been performed.

## SQL and dashboard evidence

- [`sql/credit_risk_cohort_analysis.sql`](sql/credit_risk_cohort_analysis.sql) — data-quality checks, repayment cohorts, quartiles, and reconciliation.
- [`src/credit_risk_analysis.py`](src/credit_risk_analysis.py) — reproducible analysis and validation.
- [`powerbi/`](powerbi/) — DAX measures and report specification. A completed `.pbix` file is not included.
- [`outputs/credit_risk_summary.json`](outputs/credit_risk_summary.json) and [`outputs/data_audit.json`](outputs/data_audit.json) — aggregate-only results and audit.

## 3-minute interview walkthrough

- **0:00–0:25:** Frame this as a descriptive credit-risk monitoring case study, not a predictive model.
- **0:25–0:50:** Describe the 30,000 unique IDs, 25 fields, zero missing values, and zero duplicate rows.
- **0:50–1:20:** Define observed default rate and explain the repayment-status cohorts.
- **1:20–1:50:** State the key finding: 69.55% in the 2+ month delay cohort versus 13.83% in the no-delay cohort.
- **1:50–2:20:** Show the independent SQLite reconciliation and dashboard data.
- **2:20–3:00:** Recommend monitoring and further validated testing, then explain that current data, exposure, loss, fairness review, and policy approval are needed before any practical decision.

## Reproduce

```bash
python -m pip install -r requirements.txt
python src/credit_risk_analysis.py \
  --input /path/to/default_of_credit_card_clients.xlsx \
  --output outputs/credit_risk_summary.json \
  --audit-output outputs/data_audit.json
```

See [data/README.md](data/README.md) for source download and conversion guidance.
