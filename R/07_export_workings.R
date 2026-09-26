# =============================================================================
# 07_export_workings.R — collect every R table into one Excel workbook
# Output: output/tables/R_Workings.xlsx (one sheet per table)
# Uses the 'writexl' package: no Java / no Excel needed, works on any computer.
# =============================================================================

if (!exists("reg_main")) source("R/04_regression.R")
if (!exists("desc_company")) source("R/02_descriptive_stats.R")

readme <- data.frame(
  Sheet = c("Ratios_Panel", "Desc_Company", "Desc_Year", "Desc_Pooled", "Desc_Period",
            "Correlation", "Corr_pvalues", "Reg_Main", "Reg_Fit", "Reg_VIF",
            "Reg_Diagnostics", "Reg_Robust_SE", "Reg_COVID", "Reg_FixedEffects", "Reg_Hausman"),
  Contents = c("100 firm-year ratio panel (same formulas as the Excel 'Ratios Panel')",
               "Table 3 — company-wise 10-year statistics",
               "Year-wise sector averages (data behind Figure 2)",
               "Pooled summary (mean, SD, quartiles) of every variable",
               "Pre-COVID / COVID / Post-COVID averages",
               "Table 4 — Pearson correlation matrix",
               "p-values for each correlation",
               "Tables 5 & 6 — pooled OLS for ROE and ROA",
               "R², adjusted R², F-statistic for each model",
               "Variance Inflation Factors (multicollinearity check; below 5 = fine)",
               "Breusch–Pagan, Shapiro–Wilk and Durbin–Watson tests",
               "Same OLS with robust (HC1) and firm-clustered standard errors",
               "ROE model with a COVID dummy (FY19-20, FY20-21)",
               "Two-way (company + year) fixed-effects panel model",
               "Hausman test: fixed vs random effects")
)

r4 <- function(df) mutate(as.data.frame(df), across(where(is.numeric), \(x) round(x, 4)))

sheets <- list(
  README           = readme,
  Ratios_Panel     = r4(mutate(panel, across(c(company, fy, period), as.character))),
  Desc_Company     = r4(desc_company),
  Desc_Year        = r4(desc_year),
  Desc_Pooled      = r4(desc_pooled),
  Desc_Period      = r4(mutate(desc_period, Period = as.character(Period))),
  Correlation      = r4(data.frame(Variable = rownames(cor_mat), cor_mat, check.names = FALSE)),
  Corr_pvalues     = data.frame(Variable = rownames(p_mat), signif(p_mat, 4), check.names = FALSE),
  Reg_Main         = r4(reg_main),
  Reg_Fit          = r4(reg_fit),
  Reg_VIF          = r4(vif_tab),
  Reg_Diagnostics  = diag_tab,
  Reg_Robust_SE    = r4(reg_robust),
  Reg_COVID        = r4(reg_covid),
  Reg_FixedEffects = r4(reg_fe),
  Reg_Hausman      = fe_note
)

writexl::write_xlsx(sheets, file.path(dir_tab, "R_Workings.xlsx"), format_headers = TRUE)
message("07_export_workings: output/tables/R_Workings.xlsx written.")
