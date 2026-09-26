# Data

## `raw_data.csv`
Standalone financial statement figures for the 10 sample companies, FY ending March 2015 to March 2025 (11 years × 10 firms = 110 rows). All amounts are in **Rs crore**, except EPS, which is in Rs.

| Column | Meaning | Screener.in field |
|---|---|---|
| `company` | Company name | — |
| `basis` | Always `Standalone` | — |
| `fy_end` | Financial year ending March of this year (2016 = FY2015-16) | — |
| `sales` | Net sales / revenue | Sales |
| `ebit` | Operating profit | Operating Profit |
| `net_profit` | Profit after tax | Net Profit |
| `equity_capital` | Paid-up share capital | Equity Capital |
| `reserves` | Reserves & surplus | Reserves |
| `borrowings` | Long-term + short-term borrowings | Borrowings |
| `total_assets` | Balance-sheet total | Total Assets |
| `fixed_assets` | Net block + capital work-in-progress | Fixed Assets + CWIP |
| `eps` | Earnings per share, split-adjusted | EPS |
| `other_assets` | Other assets (inventory, receivables, cash, loans & advances, other) | Other Assets |
| `other_liabilities` | Other liabilities (trade payables, provisions, other; excludes borrowings) | Other Liabilities |

FY2014-15 rows are used **only** as the base year for FY2015-16 sales growth. The analysis panel covers FY2015-16 to FY2024-25 (100 firm-years).

## `5822_Chandan_CapitalStructure_Workings.xlsx`
The final (submitted) Excel workings, with live formulas. The sheets are: Cover & Notes, Raw Data, one sheet per company, Ratios Panel, Descriptive Stats, Correlation Matrix, Regression Output (live LINEST), ET Wealth Link, Theory Formulas and Formulas Used. The R analysis reproduces the descriptive statistics, correlations and regressions; the liquidity proxy is computed in the workbook only.

## Source and terms of use
The data come from [Screener.in](https://www.screener.in), which standardises financial statements filed with the BSE and NSE. A spot-check against CMIE Prowess found differences only at the second decimal place. The data are included for academic, non-commercial use only.
