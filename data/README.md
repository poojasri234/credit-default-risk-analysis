# Data source and handling

This repository does not distribute raw customer-level data. The published aggregate outputs were generated successfully after downloading the official UCI workbook locally and converting its `.xls` file to a local `.xlsx` input. The conversion preserved the source layout: the title remains in row 1 and the field headers remain in row 2, because the analysis reads the workbook with `header=1`.

1. Download the official UCI **Default of Credit Card Clients** dataset from <https://doi.org/10.24432/C55S3H>.
2. Save the official workbook locally and convert the `.xls` file to `.xlsx` if required by your environment, preserving the title row and header row.
3. Run `src/credit_risk_analysis.py` with the local workbook path.

The converted local workbook remains excluded by `.gitignore`. The included `outputs/` files contain aggregate audit and cohort results only. They are provided to make the portfolio findings inspectable without exposing raw records.
