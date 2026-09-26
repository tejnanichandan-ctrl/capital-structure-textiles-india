# =============================================================================
# 02_descriptive_stats.R — company-wise, year-wise and pooled statistics
# Reproduces Table 3 of the report (plus extra columns) and the year-wise
# averages behind Figure 2.
# =============================================================================

if (!exists("panel")) source("R/01_data_prep.R")

# ---- 1. Company-wise (10-year averages) — Table 3 --------------------------
desc_company <- panel |>
  group_by(Company = company) |>
  summarise(
    `Mean D/E`          = mean(de),
    `SD D/E`            = sd(de),
    `Min D/E`           = min(de),
    `Max D/E`           = max(de),
    `Mean ROE`          = mean(roe),
    `Mean ROA`          = mean(roa),
    `Mean EPS (Rs.)`    = mean(eps),
    `Mean Sales Growth` = mean(sales_growth),
    `Mean Tangibility`  = mean(tangibility),
    `Mean Size (ln TA)` = mean(size),
    .groups = "drop"
  )

pooled_row <- panel |>
  summarise(
    Company = "Pooled (all 100 obs.)",
    `Mean D/E` = mean(de), `SD D/E` = sd(de), `Min D/E` = min(de), `Max D/E` = max(de),
    `Mean ROE` = mean(roe), `Mean ROA` = mean(roa), `Mean EPS (Rs.)` = mean(eps),
    `Mean Sales Growth` = mean(sales_growth), `Mean Tangibility` = mean(tangibility),
    `Mean Size (ln TA)` = mean(size)
  )

desc_company <- bind_rows(mutate(desc_company, Company = as.character(Company)), pooled_row)

# ---- 2. Year-wise (sector averages) — data behind Figure 2 -----------------
desc_year <- panel |>
  group_by(Year = fy) |>
  summarise(
    `Mean D/E`          = mean(de),
    `Median D/E`        = median(de),
    `SD D/E`            = sd(de),
    `Mean ROE`          = mean(roe),
    `Mean ROA`          = mean(roa),
    `Mean Sales Growth` = mean(sales_growth),
    `Total Debt (Rs cr)`   = sum(borrowings),
    `Total Equity (Rs cr)` = sum(total_equity),
    .groups = "drop"
  ) |>
  mutate(`Aggregate D/E` = `Total Debt (Rs cr)` / `Total Equity (Rs cr)`)

# ---- 3. Pooled summary of every variable -----------------------------------
vars <- c(`D/E` = "de", ROE = "roe", ROA = "roa", `Size (ln TA)` = "size",
          `Sales Growth` = "sales_growth", Tangibility = "tangibility", `EPS (Rs.)` = "eps")

desc_pooled <- do.call(rbind, lapply(names(vars), function(v) {
  x <- panel[[vars[[v]]]]
  data.frame(Variable = v, N = length(x), Mean = mean(x), SD = sd(x),
             Min = min(x), Q1 = unname(quantile(x, .25)), Median = median(x),
             Q3 = unname(quantile(x, .75)), Max = max(x), check.names = FALSE)
}))

# ---- 4. Period-wise (Pre-COVID / COVID / Post-COVID) -----------------------
desc_period <- panel |>
  group_by(Period = period) |>
  summarise(`Firm-years` = n(), `Mean D/E` = mean(de), `Mean ROE` = mean(roe),
            `Mean ROA` = mean(roa), `Mean Sales Growth` = mean(sales_growth),
            .groups = "drop")

# ---- 5. Save & print -------------------------------------------------------
write_tab(desc_company, file.path(dir_tab, "desc_by_company.csv"))
write_tab(desc_year, file.path(dir_tab, "desc_by_year.csv"))
write_tab(desc_pooled, file.path(dir_tab, "desc_pooled.csv"))
write_tab(desc_period, file.path(dir_tab, "desc_by_period.csv"))

cat("\n==== Table 3: Descriptive statistics by company ====\n")
print(desc_company |> mutate(across(where(is.numeric), \(x) round(x, 3))), n = Inf, width = Inf)
cat("\n==== Year-wise sector averages (Figure 2 data) ====\n")
print(desc_year |> mutate(across(where(is.numeric), \(x) round(x, 3))), n = Inf, width = Inf)
