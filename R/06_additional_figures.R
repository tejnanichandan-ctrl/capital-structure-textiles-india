# =============================================================================
# 06_additional_figures.R — extra graphs that strengthen the report
# -----------------------------------------------------------------------------
#  A01  Sector trend as two aligned panels (improved Figure 2, no dual axis)
#  A02  D/E trend for each company (small multiples vs. sector mean)
#  A03  Heatmap of D/E — company × year
#  A04  Box plot: spread of D/E within each company
#  A05  Scatter: D/E vs ROA (the stronger r = −0.51 link)
#  A06  Correlation heatmap (Table 4 as a picture)
#  A07  Company map: mean D/E vs mean ROE, bubble = firm size
#  A08  Determinant: Firm size vs D/E
#  A09  Determinant: Sales growth vs ROE
#  A10  Regression coefficient plot with 95% confidence intervals
#  A11  Regression diagnostics (residuals vs fitted, normal Q–Q)
#  A12  Sector capital mix — debt vs equity share of capital employed
#  A13  Pre-COVID / COVID / Post-COVID comparison of D/E, ROE, ROA
# =============================================================================

if (!exists("m_roe"))   source("R/04_regression.R")
if (!exists("cor_mat")) source("R/03_correlation.R")

out <- function(name) file.path(dir_fig_add, name)
covid_band <- list(scale_x_discrete(), annotate("rect", xmin = 4.5, xmax = 6.5, ymin = -Inf, ymax = Inf,
                       fill = col_covid, alpha = 0.7))

# ---- A01: improved Figure 2 — two panels sharing the year axis -------------
trend <- panel |>
  group_by(fy) |>
  summarise(mean_de = mean(de), mean_roe = mean(roe) * 100, .groups = "drop")

p_de <- ggplot(trend, aes(fy, mean_de, group = 1)) +
  covid_band +
  geom_line(colour = col_navy, linewidth = 0.9) +
  geom_point(colour = col_navy, size = 2.4) +
  geom_text(data = trend[c(1, 10), ], aes(label = sprintf("%.2f", mean_de)),
            vjust = -1, size = 3.2, colour = "grey20") +
  annotate("text", x = 5.5, y = max(trend$mean_de) * 1.05, label = "COVID years",
           size = 3, colour = "grey40") +
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, .12))) +
  labs(y = "Mean D/E ratio", x = NULL) +
  theme(axis.text.x = element_blank())

p_roe <- ggplot(trend, aes(fy, mean_roe, group = 1)) +
  covid_band +
  geom_line(colour = col_red, linewidth = 0.9) +
  geom_point(colour = col_red, size = 2.4, shape = 15) +
  geom_text(data = trend[c(1, 7, 10), ], aes(label = sprintf("%.1f%%", mean_roe)),
            vjust = -1, size = 3.2, colour = "grey20") +
  scale_y_continuous(limits = c(0, NA), expand = expansion(mult = c(0, .15))) +
  labs(y = "Mean ROE (%)", x = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

a01 <- (p_de / p_roe) +
  plot_annotation(title = "Sector Trend: Leverage Fell Steadily While ROE Swung With the Cycle",
                  subtitle = "Pooled mean of 10 textile companies, FY15-16 to FY24-25 (standalone)",
                  caption = src_caption, theme = theme_report())
save_fig(a01, out("A01_sector_trend_two_panel.png"), 8, 6)

# ---- A02: D/E trend for each company (small multiples) ---------------------
sector_mean <- panel |> group_by(fy) |> summarise(de = mean(de), .groups = "drop")

a02 <- ggplot(panel, aes(fy, de, group = company)) +
  geom_line(data = sector_mean, aes(fy, de, group = 1), inherit.aes = FALSE,
            colour = col_grey, linetype = "dashed", linewidth = 0.5) +
  geom_line(colour = col_navy, linewidth = 0.8) +
  geom_point(colour = col_navy, size = 1.3) +
  facet_wrap(~ company, ncol = 5) +
  scale_x_discrete(breaks = c("FY15-16", "FY19-20", "FY24-25"),
                   labels = c("FY16", "FY20", "FY25")) +
  labs(title = "Debt-Equity Ratio by Company, FY16–FY25",
       subtitle = "Blue = company; grey dashed = sector mean",
       x = NULL, y = "D/E ratio", caption = src_caption) +
  theme(panel.spacing = unit(0.8, "lines"))
save_fig(a02, out("A02_DE_trend_by_company.png"), 11, 5)

# ---- A03: Heatmap of D/E (company × year) ----------------------------------
a03 <- ggplot(panel, aes(fy, factor(company, levels = rev(levels(company))), fill = de)) +
  geom_tile(colour = "white", linewidth = 0.8) +
  geom_text(aes(label = sprintf("%.2f", de), colour = de > 2), size = 2.9, show.legend = FALSE) +
  scale_fill_gradient(low = "#EAF1F8", high = col_navy, name = "D/E") +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = "grey15")) +
  labs(title = "Debt-Equity Ratio Heatmap — Company × Year",
       subtitle = "Darker = more debt per rupee of equity",
       x = NULL, y = NULL, caption = src_caption) +
  theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "right")
save_fig(a03, out("A03_DE_heatmap.png"), 9.5, 5.2)

# ---- A04: Box plot of D/E by company ---------------------------------------
a04 <- ggplot(panel, aes(x = de, y = reorder(company, de, median))) +
  geom_boxplot(fill = "#DCE7F2", colour = col_navy, outlier.colour = col_red, width = 0.6) +
  geom_jitter(height = 0.12, width = 0, colour = col_navy, alpha = 0.45, size = 1.4) +
  labs(title = "Spread of D/E Within Each Company (10 years each)",
       subtitle = "Box = middle 50% of years; line = median; red dots = outlier years",
       x = "Debt-Equity Ratio", y = NULL, caption = src_caption) +
  theme(panel.grid.major.y = element_blank())
save_fig(a04, out("A04_DE_boxplot_by_company.png"), 8, 5)

# ---- A05: D/E vs ROA scatter -----------------------------------------------
a05 <- ggplot(panel, aes(de, roa * 100)) +
  geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_point(colour = col_navy, alpha = 0.65, size = 2.4) +
  geom_smooth(method = "lm", formula = y ~ x, colour = col_red, fill = "#F4CCCC",
              linewidth = 0.8) +
  labs(title = "D/E Ratio vs. ROA (100 firm-years)",
       subtitle = sprintf("Pearson r = %.2f — a stronger negative link than with ROE; shaded = 95%% CI",
                          cor(panel$de, panel$roa)),
       x = "Debt-Equity Ratio", y = "Return on Assets (%)", caption = src_caption)
save_fig(a05, out("A05_scatter_DE_vs_ROA.png"), 7, 5.2)

# ---- A06: Correlation heatmap ----------------------------------------------
cor_long <- as.data.frame(as.table(cor_mat)) |>
  setNames(c("Var1", "Var2", "r")) |>
  mutate(Var1 = factor(Var1, levels = rownames(cor_mat)),
         Var2 = factor(Var2, levels = rev(rownames(cor_mat))),
         p    = as.vector(p_mat),
         lab  = paste0(sprintf("%.2f", r),
                       ifelse(is.na(p), "", ifelse(p < .001, "***", ifelse(p < .01, "**", ifelse(p < .05, "*", ""))))))

a06 <- ggplot(cor_long, aes(Var1, Var2, fill = r)) +
  geom_tile(colour = "white", linewidth = 0.8) +
  geom_text(aes(label = lab), size = 3, colour = ifelse(abs(cor_long$r) > .6, "white", "grey15")) +
  scale_fill_gradient2(low = col_red, mid = "#F2F2F2", high = col_navy, midpoint = 0,
                       limits = c(-1, 1), name = "r") +
  labs(title = "Correlation Matrix (Pooled, n = 100)",
       subtitle = "Blue = positive, red = negative; *** p<0.001 ** p<0.01 * p<0.05",
       x = NULL, y = NULL, caption = src_caption) +
  theme(panel.grid = element_blank(), axis.text.x = element_text(angle = 35, hjust = 1),
        legend.position = "right")
save_fig(a06, out("A06_correlation_heatmap.png"), 8, 6)

# ---- A07: Company map — mean D/E vs mean ROE, bubble = size ----------------
firm_avg <- panel |>
  group_by(company) |>
  summarise(de = mean(de), roe = mean(roe) * 100, ta = mean(total_assets), .groups = "drop")

a07 <- ggplot(firm_avg, aes(de, roe)) +
  geom_vline(xintercept = mean(panel$de), colour = col_grey, linetype = "dashed", linewidth = 0.4) +
  geom_hline(yintercept = mean(panel$roe) * 100, colour = col_grey, linetype = "dashed", linewidth = 0.4) +
  geom_point(aes(size = ta), colour = col_navy, alpha = 0.7) +
  ggrepel::geom_text_repel(aes(label = company), size = 3.2, colour = "grey15",
                           box.padding = 0.6, seed = 1) +
  annotate("text", x = min(firm_avg$de), y = max(firm_avg$roe) + 1.5, hjust = 0,
           label = "Low debt, high ROE", colour = "grey40", size = 3, fontface = "italic") +
  annotate("text", x = max(firm_avg$de), y = min(firm_avg$roe) - 1.5, hjust = 1,
           label = "High debt, low ROE", colour = "grey40", size = 3, fontface = "italic") +
  scale_size_continuous(range = c(3, 13), name = "Avg. total assets (Rs cr)",
                        labels = scales::label_comma()) +
  labs(title = "Company Map: Leverage vs. Profitability (10-year averages)",
       subtitle = "Dashed lines = pooled sample means",
       x = "Mean Debt-Equity Ratio", y = "Mean ROE (%)", caption = src_caption) +
  theme(legend.position = "bottom")
save_fig(a07, out("A07_company_map_DE_vs_ROE.png"), 8, 6)

# ---- A08: Determinant — Size vs D/E ----------------------------------------
a08 <- ggplot(panel, aes(size, de)) +
  geom_point(colour = col_navy, alpha = 0.65, size = 2.4) +
  geom_smooth(method = "lm", formula = y ~ x, colour = col_red, fill = "#F4CCCC", linewidth = 0.8) +
  labs(title = "Determinant: Firm Size vs. Debt-Equity Ratio",
       subtitle = sprintf("r = %.2f — larger firms carry LESS debt (supports Pecking Order)",
                          cor(panel$size, panel$de)),
       x = "Firm size = ln(Total Assets)", y = "Debt-Equity Ratio", caption = src_caption)
save_fig(a08, out("A08_size_vs_DE.png"), 7, 5.2)

# ---- A09: Determinant — Sales growth vs ROE --------------------------------
a09 <- ggplot(panel, aes(sales_growth * 100, roe * 100)) +
  geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_vline(xintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_point(colour = col_navy, alpha = 0.65, size = 2.4) +
  geom_smooth(method = "lm", formula = y ~ x, colour = col_red, fill = "#F4CCCC", linewidth = 0.8) +
  labs(title = "Sales Growth vs. ROE",
       subtitle = sprintf("r = %.2f — growth is the strongest positive driver of ROE",
                          cor(panel$sales_growth, panel$roe)),
       x = "Sales growth (% YoY)", y = "Return on Equity (%)", caption = src_caption)
save_fig(a09, out("A09_sales_growth_vs_ROE.png"), 7, 5.2)

# ---- A10: Coefficient plot (ROE vs ROA models) -----------------------------
coef_df <- bind_rows(
  data.frame(model = "ROE model (Table 5)", term = names(coef(m_roe)), est = coef(m_roe),
             lo = confint(m_roe)[, 1], hi = confint(m_roe)[, 2]),
  data.frame(model = "ROA model (Table 6)", term = names(coef(m_roa)), est = coef(m_roa),
             lo = confint(m_roa)[, 1], hi = confint(m_roa)[, 2])
) |>
  filter(term != "(Intercept)") |>
  mutate(term = factor(term, levels = rev(c("de", "size", "sales_growth", "tangibility")),
                       labels = rev(c("D/E ratio", "Size (ln TA)", "Sales growth", "Tangibility"))),
         sig = ifelse(lo > 0 | hi < 0, "Significant at 5%", "Not significant"))

a10 <- ggplot(coef_df, aes(est, term, colour = model)) +
  geom_vline(xintercept = 0, colour = "grey50", linewidth = 0.4) +
  geom_errorbarh(aes(xmin = lo, xmax = hi), height = 0.2, linewidth = 0.7,
                 position = position_dodge(width = 0.5)) +
  geom_point(aes(shape = sig), size = 3, position = position_dodge(width = 0.5)) +
  scale_colour_manual(values = c(col_red, col_navy), name = NULL) +
  scale_shape_manual(values = c(`Significant at 5%` = 16, `Not significant` = 1), name = NULL) +
  labs(title = "Regression Coefficients with 95% Confidence Intervals",
       subtitle = "A bar that crosses zero = not statistically significant",
       x = "Estimated coefficient (effect on ROE / ROA as a decimal)", y = NULL,
       caption = src_caption) +
  guides(colour = guide_legend(order = 1), shape = guide_legend(order = 2))
save_fig(a10, out("A10_regression_coefficients.png"), 8, 4.8)

# ---- A11: Regression diagnostics (ROE model) -------------------------------
diag_df <- data.frame(fitted = fitted(m_roe), resid = resid(m_roe),
                      std_resid = rstandard(m_roe), company = panel$company, fy = panel$fy)
diag_df$label <- ifelse(abs(diag_df$std_resid) > 2.5, paste(diag_df$company, diag_df$fy), NA)

d1 <- ggplot(diag_df, aes(fitted * 100, resid * 100)) +
  geom_hline(yintercept = 0, colour = col_red, linetype = "dashed") +
  geom_point(colour = col_navy, alpha = 0.65, size = 2) +
  ggrepel::geom_text_repel(aes(label = label), size = 2.8, na.rm = TRUE, seed = 1) +
  labs(title = "Residuals vs. Fitted", x = "Fitted ROE (%)", y = "Residual (% points)")

d2 <- ggplot(diag_df, aes(sample = std_resid)) +
  stat_qq(colour = col_navy, alpha = 0.65, size = 2) +
  stat_qq_line(colour = col_red, linetype = "dashed") +
  labs(title = "Normal Q–Q Plot", x = "Theoretical quantiles", y = "Standardised residuals")

a11 <- (d1 | d2) + plot_annotation(
  title = "Regression Diagnostics — ROE Model (Table 5)",
  subtitle = "Labelled points = unusual firm-years (|standardised residual| > 2.5)",
  caption = src_caption, theme = theme_report())
save_fig(a11, out("A11_regression_diagnostics.png"), 10, 4.8)

# ---- A12: Sector capital mix — debt vs equity ------------------------------
mix <- panel |>
  group_by(fy) |>
  summarise(Debt = sum(borrowings), Equity = sum(total_equity), .groups = "drop") |>
  tidyr::pivot_longer(c(Debt, Equity), names_to = "source", values_to = "amt") |>
  group_by(fy) |> mutate(share = amt / sum(amt)) |> ungroup() |>
  mutate(source = factor(source, levels = c("Equity", "Debt")))

a12 <- ggplot(mix, aes(fy, share, fill = source)) +
  geom_col(width = 0.72, colour = "white", linewidth = 0.4) +
  geom_text(data = subset(mix, source == "Debt"), aes(label = percent(share, 1)),
            position = position_stack(vjust = 0.5), colour = "white", size = 3) +
  scale_fill_manual(values = c(Debt = col_red, Equity = col_navy), name = NULL,
                    breaks = c("Debt", "Equity")) +
  scale_y_continuous(labels = percent, expand = c(0, 0)) +
  labs(title = "Sector Capital Mix: Share of Debt in Capital Employed",
       subtitle = "Aggregate borrowings ÷ (borrowings + equity) across all 10 companies",
       x = NULL, y = "Share of total capital", caption = src_caption) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), panel.grid.major.x = element_blank())
save_fig(a12, out("A12_sector_capital_mix.png"), 8, 4.8)

# ---- A13: Pre-COVID / COVID / Post-COVID comparison ------------------------
per <- panel |>
  group_by(period) |>
  summarise(`Mean D/E (x)` = mean(de), `Mean ROE (%)` = mean(roe) * 100,
            `Mean ROA (%)` = mean(roa) * 100, .groups = "drop") |>
  tidyr::pivot_longer(-period, names_to = "metric", values_to = "value") |>
  mutate(metric = factor(metric, levels = c("Mean D/E (x)", "Mean ROE (%)", "Mean ROA (%)")))

a13 <- ggplot(per, aes(period, value, fill = period)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = ifelse(metric == "Mean D/E (x)", sprintf("%.2f", value), sprintf("%.1f", value))),
            vjust = -0.4, size = 3.2, colour = "grey15") +
  facet_wrap(~ metric, scales = "free_y") +
  scale_fill_manual(values = col_pair, name = NULL) +
  scale_y_continuous(expand = expansion(mult = c(0, .15))) +
  labs(title = "Before, During and After COVID-19",
       subtitle = "Pooled means; COVID = FY19-20 & FY20-21",
       x = NULL, y = NULL, caption = src_caption) +
  theme(axis.text.x = element_blank(), panel.grid.major.x = element_blank())
save_fig(a13, out("A13_covid_period_comparison.png"), 9, 4.5)

message("06_additional_figures: 13 additional figures saved.")
