# Dashboard specification

## Purpose

Present a compact, interactive view of **observed next-month default rates** in the historical UCI credit-card client dataset. The report is designed to explain the data, cohort definition, and limits of the analysis in under a minute.

Use descriptive wording throughout. Do not label any visual as a risk score, prediction, approval recommendation, or automated decision.

## Page: Credit default risk profile

### Header

- **Title:** Credit Default Risk Analysis
- **Subtitle:** Descriptive cohort analysis of observed next-month default in the public UCI credit-card client dataset.
- **Source line:** UCI Default of Credit Card Clients — Yeh (2009) · 30,000 historical records · 25 source fields
- **Interpretation note:** Historical public-data finding; not a predictive model or lending decision tool.

### KPI cards

Place these four cards at the top. Each card should use the documented DAX measures and retain the source context in a tooltip.

| Card | Measure or reference | Verified value for full dataset |
| --- | --- | ---: |
| Clients profiled | `[Client Count]` | 30,000 |
| Defaulted next month | `[Default Count]` | 6,636 |
| Observed next-month default rate | `[Observed Next-Month Default Rate]` | 22.12% |
| Unique client IDs | `[Unique Client Count]` | 30,000 |

### Main visual: repayment-status cohorts

- **Visual:** Clustered column chart.
- **X-axis:** `Recent Repayment Status`, sorted by `Recent Repayment Status Sort`.
- **Y-axis:** `[Observed Next-Month Default Rate]`, format as percent with two decimals.
- **Tooltip:** `[Client Count]`, `[Default Count]`, `[Observed Next-Month Default Rate]`.
- **Expected full-data values:**

| Cohort | Clients | Defaults | Observed rate |
| --- | ---: | ---: | ---: |
| No reported delay | 23,182 | 3,207 | 13.83% |
| 1 month delay | 3,688 | 1,252 | 33.95% |
| 2+ months delay | 3,130 | 2,177 | 69.55% |

### Supporting visual: credit-limit quartiles

- **Visual:** Horizontal bar chart.
- **Y-axis:** `Credit Limit Quartile (UCI)`, sorted by `Credit Limit Quartile Sort`.
- **X-axis:** `[Observed Next-Month Default Rate]`.
- **Tooltip:** `[Client Count]`, `[Default Count]`, `[Observed Next-Month Default Rate]`.
- **Expected full-data values:**

| Cohort | Clients | Defaults | Observed rate |
| --- | ---: | ---: | ---: |
| Lowest limit quartile | 7,676 | 2,440 | 31.79% |
| Lower-middle limit quartile | 7,614 | 1,882 | 24.72% |
| Upper-middle limit quartile | 7,643 | 1,326 | 17.35% |
| Highest limit quartile | 7,067 | 988 | 13.98% |

### Detail table

Add a matrix with rows for `Recent Repayment Status` and values for `[Client Count]`, `[Default Count]`, and `[Observed Next-Month Default Rate]`. This makes the numerator, denominator, and rate inspectable together.

### Slicers and interactions

- Add slicers for `SEX`, `EDUCATION`, `MARRIAGE`, and the credit-limit quartile field.
- Keep cross-highlighting enabled between the two cohort visuals and the detail table.
- Add a **Reset filters** button using a Power BI bookmark so a reviewer can return to the verified full-data view.
- Do not apply default filters in the published view; the initial page should show the documented full-dataset values.

## Formatting and accessibility

- Use a restrained palette: dark navy for labels, one blue for rate bars, and neutral gray for supporting elements.
- Show data labels on both cohort charts and use at least two decimal places for rates.
- Do not imply that a higher bar establishes causality.
- Use meaningful alt text, for example: “Observed next-month default rate by recent repayment status; highest in the 2+ months delay cohort in this historical dataset.”

## Footer disclaimer

> This report describes associations in a historical public dataset. It does not predict future default, establish causality, or support an automated lending decision. Practical use would require current data, validation, fairness assessment, regulatory review, and business-policy approval.
