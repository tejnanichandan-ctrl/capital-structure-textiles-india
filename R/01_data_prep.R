# =============================================================================
# 01_data_prep.R — build the 100-row Ratios Panel from the raw financials
# -----------------------------------------------------------------------------
# Input : data/raw_data.csv  (copy of the 'Raw Data' sheet in the Excel
#         workings; Rs. crore; FY ending March 2015 ... 2025; 10 companies)
# Output: object `panel` (100 firm-years, FY15-16 to FY24-25)
#         output/tables/ratios_panel.csv
#
# Formulas (identical to the Excel 'Ratios Panel' sheet):
#   Total Equity  = Equity Capital + Reserves & Surplus
#   D/E           = Borrowings / Total Equity
#   ROE           = Net Profit / Total Equity
#   ROA           = Net Profit / Total Assets
#   Size          = ln(Total Assets)
#   Sales Growth  = (Sales_t - Sales_t-1) / Sales_t-1
#   Tangibility   = Fixed Assets (incl. CWIP) / Total Assets
# FY2014-15 (March 2015) is used ONLY as the base year for sales growth.
# =============================================================================

if (!exists("theme_report")) source("R/00_setup.R")

raw <- read.csv("data/raw_data.csv", stringsAsFactors = FALSE)

# Company order used in all tables/charts (same as Table 1 of the report)
company_order <- c("KPR Mill", "Welspun Living", "Indo Count Industries",
                   "Vardhman Textiles", "Trident", "Arvind", "Nitin Spinners",
                   "Sutlej Textiles", "Gokaldas Exports", "Siyaram Silk Mills")

# "FY15-16" style label for the year ending March 2016, etc.
fy_label <- function(y) sprintf("FY%02d-%02d", (y - 1) %% 100, y %% 100)

panel_all <- raw |>
  arrange(company, fy_end) |>
  group_by(company) |>
  mutate(
    total_equity = equity_capital + reserves,
    de           = borrowings / total_equity,
    roe          = net_profit / total_equity,
    roa          = net_profit / total_assets,
    size         = log(total_assets),
    sales_growth = (sales - dplyr::lag(sales)) / dplyr::lag(sales),  # dplyr:: because plm also has lag()
    tangibility  = fixed_assets / total_assets
  ) |>
  ungroup()

panel <- panel_all |>
  filter(fy_end >= 2016, fy_end <= 2025) |>
  mutate(
    fy      = factor(fy_label(fy_end), levels = fy_label(2016:2025)),
    company = factor(company, levels = company_order),
    # Period flag for COVID analysis (report Section 3.6: FY19-20 & FY20-21)
    period  = factor(case_when(
      fy_end <= 2019 ~ "Pre-COVID (FY16–FY19)",
      fy_end <= 2021 ~ "COVID (FY20–FY21)",
      TRUE           ~ "Post-COVID (FY22–FY25)"),
      levels = c("Pre-COVID (FY16–FY19)", "COVID (FY20–FY21)", "Post-COVID (FY22–FY25)")),
    covid   = as.integer(fy_end %in% c(2020, 2021))
  ) |>
  arrange(company, fy_end) |>
  select(company, fy, fy_end, period, covid, sales, ebit, net_profit,
         total_equity, borrowings, total_assets, fixed_assets,
         de, roe, roa, size, sales_growth, tangibility, eps)

stopifnot(nrow(panel) == 100, !anyNA(panel$sales_growth))

write_tab(panel, file.path(dir_tab, "ratios_panel.csv"))
message("01_data_prep: panel built — ", nrow(panel), " firm-years, ",
        nlevels(panel$company), " companies.")
