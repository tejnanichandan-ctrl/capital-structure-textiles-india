# Analysis Notes

This page explains every statistical result in the repository in two layers: first the **technical reading** (academic depth), then **in plain words**. It works as viva preparation and as an appendix to the written report.

All numbers are reproduced by `run_all.R`. The source tables are in [`output/tables/`](../output/tables/).

---

## 1. Descriptive statistics (Table 3) — `02_descriptive_stats.R`

**Technical:** pooled mean D/E is 0.75 (SD 0.60, range 0.06–3.63). Year-wise mean D/E falls almost without a break, from 1.10 to 0.40. Aggregate D/E (total debt ÷ total equity) falls from 1.03 to 0.29.

**In plain words:** the average textile company had about as much debt as equity in FY16 and less than half that by FY25. Some firms (Nitin Spinners, Gokaldas) always borrowed much more than others (KPR Mill, Vardhman).

## 2. Correlation (Table 4) — `03_correlation.R`

**Technical:** with n = 100, any |r| above 0.197 is significant at 5%. D/E is negatively correlated with ROE (−0.36), ROA (−0.51), EPS (−0.39) and size (−0.40), all at p < 0.001. Sales growth is positively correlated with ROE (0.41) and ROA (0.40). The correlations among the regressors are all below |0.41|, so multicollinearity is unlikely.

**In plain words:** firm-years with more debt earned less. Bigger firms had less debt, and fast-growing firms earned more.

## 3. Pooled OLS regression (Tables 5 & 6) — `04_regression.R`

**Technical:** in the ROE model, β₁(D/E) = −0.0772 (t = −4.93, p < 0.001), β₂(Size) = −0.0311 (p = 0.014), β₃(Growth) = +0.1964 (p < 0.001) and β₄(Tangibility) = +0.0835 (p = 0.153). R² = 0.335, adj. R² = 0.307, F(4, 95) = 11.99. The ROA model shows the same signs with a higher R² (0.456).

**In plain words:** a one-unit increase in D/E (for example, from 0.5 to 1.5) goes with about 7.7 percentage points lower ROE, even after allowing for size, growth and asset mix. The four variables together explain about one-third of the differences in ROE.

---

## 4. Robustness checks (beyond the assignment brief)

**1. Multicollinearity (VIF): every value is between 1.0 and 1.35.**
*Technical:* all VIFs are far below the usual cut-off of 5, so the regressors are close to independent and the coefficient estimates are stable.
*Plain words:* the four explanatory variables don't overlap, so each one's effect can be measured separately.

**2. Heteroskedasticity (Breusch–Pagan): present in the ROE model (p = 0.006), not in the ROA model (p = 0.34).**
*Technical:* the spread of the ROE residuals changes with the regressors, so ordinary standard errors can be misleading. The models were re-estimated with robust (HC1) and firm-clustered standard errors.
*Plain words:* the D/E result survives the tougher test. It stays significant with robust errors (p = 0.003) and clustered errors (p = 0.002). Size is less secure: with firm-clustered errors its p-value rises to 0.06, so it is significant only at 10%.

**3. COVID dummy (FY19-20 and FY20-21): coefficient −0.005, p = 0.83, not significant.**
*Technical:* once D/E, size, growth and tangibility are controlled for, the COVID years show no separate effect on ROE. The drop is already captured by the fall in sales growth. D/E stays at −0.077 (p < 0.001).
*Plain words:* COVID hurt profits by cutting sales, not through any extra effect of its own. This answers Limitation 3 in Section 6.1.

**4. Panel models: two-way fixed effects and the Hausman test.**
*Technical:* with company and year fixed effects, D/E = −0.112 (p < 0.001) and sales growth = +0.183 (p = 0.002), while size becomes insignificant. The Hausman test (χ² = 1.32, p = 0.86) prefers random effects, which means pooled or random-effects estimates are consistent.
*Plain words:* even when each company is compared only with itself over time, more debt goes with lower ROE. This is the model suggested in Scope for Further Research (Section 6.2).

**5. Residual normality (Shapiro–Wilk) and autocorrelation (Durbin–Watson): both flag issues.**
*Technical:* these problems are typical of a 100-observation firm panel with a few extreme loss years (Gokaldas FY16-17 and FY17-18, Sutlej FY23-24). With n = 100, the t-tests are still approximately valid. The clustered standard errors in point 2 correct for the within-firm correlation.
*Plain words:* a few very bad years distort the pattern slightly, but the main conclusion does not change.

---

## 5. Bottom line
The negative leverage–profitability relationship holds under every test run here: plain OLS, robust and clustered standard errors, a COVID control, and within-firm fixed effects. The size effect is weaker; it is significant under plain OLS but only marginal (p ≈ 0.06) with firm-clustered errors. Tangibility is never significant. Taken together, this evidence supports **Pecking Order Theory**.
