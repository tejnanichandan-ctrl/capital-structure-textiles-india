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

FY2014-15 rows are used **only** as the base year for FY2015-16 sales growth. The analysis panel covers FY2015-16 to FY2024-25 (100 firm-years).

## `Chandan_CapitalStructure_Workings.xlsx`
The original Excel workings, with live formulas. The sheets are: Raw Data, one sheet per company, Ratios Panel, Descriptive Stats, Correlation Matrix, Regression Output and Formulas Used. The R analysis reproduces every number in this workbook.

## Source and terms of use
The data come from [Screener.in](https://www.screener.in), which standardises financial statements filed with the BSE and NSE. A spot-check against CMIE Prowess found differences only at the second decimal place. The data are included for academic, non-commercial use only.
