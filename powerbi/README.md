# Power BI build guide

This folder contains a documented Power BI build plan and DAX definitions. It **does not include a `.pbix` file** or raw customer-level data.

The dashboard is a descriptive portfolio case study. It is not a predictive credit model, a scorecard, or a lending-decision tool.

## 1. Get the data

1. Download the official **UCI Default of Credit Card Clients — Yeh (2009)** workbook from <https://doi.org/10.24432/C55S3H>.
2. If necessary, convert the source `.xls` workbook to `.xlsx` locally. Do not upload customer-level data to this repository.
3. In Power BI Desktop, choose **Get data → Excel workbook**, then select the `Data` worksheet.
4. In Power Query, skip the first title row and promote the next row to headers. The source fields must include `ID`, `LIMIT_BAL`, `PAY_0`, and `default payment next month`.
5. Rename the query to **Credit Clients** and set `ID`, `LIMIT_BAL`, `PAY_0`, and `default payment next month` to Whole number.

A compact Power Query pattern for the title/header step is:

```powerquery
let
    Source = Excel.Workbook(File.Contents("C:\\path\\to\\default_of_credit_card_clients.xlsx"), null, true),
    DataSheet = Source{[Item="Data", Kind="Sheet"]}[Data],
    SkipTitleRow = Table.Skip(DataSheet, 1),
    PromoteHeaders = Table.PromoteHeaders(SkipTitleRow, [PromoteAllScalars=true])
in
    PromoteHeaders
```

Use the current file path and verify the sheet name in Navigator before applying this pattern.

## 2. Check the import

Before creating visuals, confirm the imported source matches the verified public-data profile:

| Check | Expected result |
| --- | ---: |
| Rows | 30,000 |
| Unique `ID` values | 30,000 |
| Next-month default labels equal to 1 | 6,636 |
| Observed default rate | 22.12% |
| Missing values in the validated workbook | 0 |
| Exact duplicate rows in the validated workbook | 0 |

Use the Python analysis in `../src/credit_risk_analysis.py` or the SQL checks in `../sql/credit_risk_cohort_analysis.sql` as the reproducible source of truth for validation.

## 3. Add fields and measures

Open [measures.dax](measures.dax). Create the calculated columns first, then add the measures. The definitions assume the imported table is named **Credit Clients**. If you use a different table name, replace it consistently.

The documented credit-limit quartile field uses the verified UCI cut points from this particular historical workbook: 50,000, 140,000, and 240,000. Do not reuse those boundaries for a different source file.

## 4. Build the report

Follow [dashboard-spec.md](dashboard-spec.md) for the recommended page layout, visual fields, interaction behavior, and wording. Use [../dashboard/data.json](../dashboard/data.json) as the checked aggregate reference for the portfolio dashboard values.

## Data handling and interpretation

- Keep the downloaded workbook local; this repository intentionally contains aggregate outputs only.
- Label the headline measure **Observed next-month default rate**, not a predicted risk score.
- State that the findings are descriptive associations in historical public data. They do not establish causality or support an automated credit decision.
