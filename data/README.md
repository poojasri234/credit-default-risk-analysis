# Data source and handling

This repository does not distribute raw customer-level data.

1. Download the official UCI **Default of Credit Card Clients** dataset from <https://doi.org/10.24432/C55S3H>.
2. Save the official workbook locally and convert the `.xls` file to `.xlsx` if required by your environment.
3. Run `src/credit_risk_analysis.py` with the local workbook path.

The included `outputs/` files contain aggregate audit and cohort results only. They are provided to make the portfolio findings inspectable without exposing raw records.
