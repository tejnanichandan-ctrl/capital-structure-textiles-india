# =============================================================================
# 04_regression.R — pooled OLS (Tables 5 & 6) + extra robustness workings
# -----------------------------------------------------------------------------
# Main model (assignment brief):
#   ROE = b0 + b1(D/E) + b2(Size) + b3(Growth) + b4(Tangibility) + e
# Robustness in the report: same model with ROA.
#
# Extra workings added here (not in the Word report, useful for viva / Scope
# for Further Research, Section 6.2):
#   (a) VIF — multicollinearity check
#   (b) Breusch–Pagan test — heteroskedasticity
#   (c) Robust (HC1) and firm-clustered standard errors
#   (d) COVID dummy model (FY19-20 & FY20-21)
#   (e) Panel fixed-effects model (company + year effects)
#   (f) Normality of residuals (Shapiro–Wilk)
# =============================================================================

if (!exists("panel")) source("R/01_data_prep.R")

# Tidy a coefficient table into the same layout as Table 5/6 of the report
coef_table <- function(ct, model_name) {
  ct <- as.matrix(ct[, 1:4, drop = FALSE])
  data.frame(
    Model       = model_name,
    Variable    = rownames(ct),
    Coefficient = ct[, 1],
    `Std. Error`  = ct[, 2],
    `t-Statistic` = ct[, 3],
    `p-value`     = ct[, 4],
    `Sig. at 5%?` = ifelse(ct[, 4] < .01, "Yes**", ifelse(ct[, 4] < .05, "Yes*", "No")),
    check.names = FALSE, row.names = NULL
  )
}
nice_names <- c("(Intercept)" = "Intercept (β0)", de = "D/E Ratio (β1)",
                size = "Size — ln(Total Assets) (β2)", sales_growth = "Sales Growth (β3)",
                tangibility = "Tangibility (β4)", covid = "COVID dummy (FY20–FY21)")
rename_vars <- function(df) { df$Variable <- ifelse(df$Variable %in% names(nice_names), nice_names[df$Variable], df$Variable); df }

fit_stats <- function(m, name) {
  s <- summary(m); f <- s$fstatistic
  data.frame(Model = name, n = nobs(m), R2 = s$r.squared, `Adj. R2` = s$adj.r.squared,
             F = unname(f[1]), df1 = unname(f[2]), df2 = unname(f[3]),
             `F p-value` = unname(pf(f[1], f[2], f[3], lower.tail = FALSE)), check.names = FALSE)
}

# ---- 1. Main models (Table 5 = ROE, Table 6 = ROA) -------------------------
m_roe <- lm(roe ~ de + size + sales_growth + tangibility, data = panel)
m_roa <- lm(roa ~ de + size + sales_growth + tangibility, data = panel)

reg_main <- rbind(
  rename_vars(coef_table(coef(summary(m_roe)), "ROE (Table 5)")),
  rename_vars(coef_table(coef(summary(m_roa)), "ROA (Table 6)"))
)
reg_fit <- rbind(fit_stats(m_roe, "ROE (Table 5)"), fit_stats(m_roa, "ROA (Table 6)"))

# ---- 2. Diagnostics --------------------------------------------------------
vif_tab <- data.frame(Variable = nice_names[names(car::vif(m_roe))],
                      VIF = unname(car::vif(m_roe)))

diag_tab <- data.frame(
  Test  = c("Breusch–Pagan (heteroskedasticity) — ROE model",
            "Breusch–Pagan (heteroskedasticity) — ROA model",
            "Shapiro–Wilk (normality of residuals) — ROE model",
            "Shapiro–Wilk (normality of residuals) — ROA model",
            "Durbin–Watson (autocorrelation) — ROE model",
            "Durbin–Watson (autocorrelation) — ROA model"),
  Statistic = c(bptest(m_roe)$statistic, bptest(m_roa)$statistic,
                shapiro.test(resid(m_roe))$statistic, shapiro.test(resid(m_roa))$statistic,
                dwtest(m_roe)$statistic, dwtest(m_roa)$statistic),
  `p-value` = c(bptest(m_roe)$p.value, bptest(m_roa)$p.value,
                shapiro.test(resid(m_roe))$p.value, shapiro.test(resid(m_roa))$p.value,
                dwtest(m_roe)$p.value, dwtest(m_roa)$p.value),
  check.names = FALSE
)
diag_tab$Reading <- ifelse(diag_tab$`p-value` < .05, "Assumption violated at 5%", "No violation at 5%")

# ---- 3. Robust standard errors (same coefficients, safer p-values) ---------
reg_robust <- rbind(
  rename_vars(coef_table(coeftest(m_roe, vcov = vcovHC(m_roe, type = "HC1")), "ROE — robust HC1 SE")),
  rename_vars(coef_table(coeftest(m_roe, vcov = vcovCL(m_roe, cluster = ~company)), "ROE — firm-clustered SE")),
  rename_vars(coef_table(coeftest(m_roa, vcov = vcovHC(m_roa, type = "HC1")), "ROA — robust HC1 SE")),
  rename_vars(coef_table(coeftest(m_roa, vcov = vcovCL(m_roa, cluster = ~company)), "ROA — firm-clustered SE"))
)

# ---- 4. COVID dummy model --------------------------------------------------
m_roe_covid <- lm(roe ~ de + size + sales_growth + tangibility + covid, data = panel)
reg_covid   <- rename_vars(coef_table(coef(summary(m_roe_covid)), "ROE + COVID dummy"))
reg_fit     <- rbind(reg_fit, fit_stats(m_roe_covid, "ROE + COVID dummy"))

# ---- 5. Panel fixed effects (company & year) -------------------------------
pdat  <- pdata.frame(as.data.frame(panel), index = c("company", "fy"))
m_fe  <- plm(roe ~ de + size + sales_growth + tangibility, data = pdat,
             model = "within", effect = "twoways")
m_re  <- plm(roe ~ de + size + sales_growth + tangibility, data = pdat,
             model = "random", effect = "individual")
m_fe1 <- plm(roe ~ de + size + sales_growth + tangibility, data = pdat,
             model = "within", effect = "individual")
haus  <- phtest(m_fe1, m_re)

reg_fe <- rename_vars(coef_table(coeftest(m_fe, vcov = vcovHC(m_fe, cluster = "group")),
                                 "ROE — two-way fixed effects (clustered SE)"))
fe_note <- data.frame(
  Item  = c("Two-way FE within R²", "Hausman test (FE vs RE) chi-sq", "Hausman p-value", "Preferred model"),
  Value = c(sprintf("%.3f", summary(m_fe)$r.squared["rsq"]),
            sprintf("%.3f", haus$statistic), sprintf("%.4f", haus$p.value),
            ifelse(haus$p.value < .05, "Fixed effects (p < 0.05)", "Random effects (p ≥ 0.05)"))
)

# ---- 6. Save & print -------------------------------------------------------
write_tab(reg_main,   file.path(dir_tab, "regression_main_ROE_ROA.csv"))
write_tab(reg_fit,    file.path(dir_tab, "regression_fit_statistics.csv"))
write_tab(vif_tab,    file.path(dir_tab, "regression_VIF.csv"))
write_tab(diag_tab,   file.path(dir_tab, "regression_diagnostics.csv"))
write_tab(reg_robust, file.path(dir_tab, "regression_robust_SE.csv"))
write_tab(reg_covid,  file.path(dir_tab, "regression_COVID_dummy.csv"))
write_tab(reg_fe,     file.path(dir_tab, "regression_fixed_effects.csv"))
write_tab(fe_note,    file.path(dir_tab, "regression_FE_vs_RE_hausman.csv"))

# Full R console output, for the appendix
sink(file.path(dir_tab, "regression_full_output.txt"))
cat("==== Table 5: ROE model ====\n");        print(summary(m_roe))
cat("\n==== Table 6: ROA model ====\n");      print(summary(m_roa))
cat("\n==== VIF (ROE model) ====\n");         print(car::vif(m_roe))
cat("\n==== Breusch–Pagan ====\n");           print(bptest(m_roe)); print(bptest(m_roa))
cat("\n==== Robust HC1 (ROE) ====\n");        print(coeftest(m_roe, vcov = vcovHC(m_roe, type = "HC1")))
cat("\n==== ROE + COVID dummy ====\n");       print(summary(m_roe_covid))
cat("\n==== Two-way fixed effects ====\n");   print(summary(m_fe))
cat("\n==== Hausman test ====\n");            print(haus)
sink()

cat("\n==== Table 5 & 6: Pooled OLS ====\n")
print(reg_main |> mutate(across(where(is.numeric), \(x) round(x, 4))), row.names = FALSE)
cat("\n"); print(reg_fit |> mutate(across(where(is.numeric), \(x) round(x, 3))), row.names = FALSE)
