# =============================================================================
# 05_report_figures.R — the 3 figures that appear in the Word report
# -----------------------------------------------------------------------------
# Figure 1: Average Debt-Equity Ratio by Company (horizontal bar)
# Figure 2: Sector trend — Mean D/E vs Mean ROE (dual axis, as in the report)
# Figure 3: D/E vs ROE scatter, 100 firm-years, with linear trend line
# Saved to output/figures/report/ as 300-dpi PNGs, ready to paste into Word.
# =============================================================================

if (!exists("panel")) source("R/01_data_prep.R")

# ---- Figure 1: Average D/E by company --------------------------------------
fig1_data <- panel |>
  group_by(company) |>
  summarise(mean_de = mean(de), .groups = "drop") |>
  mutate(company = reorder(company, mean_de))

fig1 <- ggplot(fig1_data, aes(x = mean_de, y = company)) +
  geom_col(fill = col_navy, width = 0.75) +
  geom_text(aes(label = sprintf("%.2f", mean_de)), hjust = -0.2, size = 3.4, colour = "grey15") +
  scale_x_continuous(expand = expansion(mult = c(0, 0.08))) +
  labs(title = "Average Debt-Equity Ratio by Company",
       x = "Mean Debt-Equity Ratio (FY16–FY25, Standalone)", y = NULL,
       caption = src_caption) +
  theme(panel.grid.major.y = element_blank())

save_fig(fig1, file.path(dir_fig_report, "Figure1_avg_DE_by_company.png"), 8, 4.5)

# ---- Figure 2: Sector trend, mean D/E vs mean ROE (dual axis) --------------
# NOTE: this reproduces the report's dual-axis chart. Dual axes let the reader
# be misled by the choice of scale, so an improved two-panel version is given
# in 06_additional_figures.R (A01) — consider using that one in the report.
fig2_data <- panel |>
  group_by(fy) |>
  summarise(mean_de = mean(de), mean_roe = mean(roe) * 100, .groups = "drop")

# Map ROE (%) onto the D/E axis with a linear rescale
de_rng  <- range(fig2_data$mean_de); roe_rng <- range(fig2_data$mean_roe)
k       <- diff(de_rng) / diff(roe_rng)
to_de   <- function(r) de_rng[1] + (r - roe_rng[1]) * k
to_roe  <- function(d) roe_rng[1] + (d - de_rng[1]) / k

fig2 <- ggplot(fig2_data, aes(x = fy, group = 1)) +
  geom_line(aes(y = mean_de), colour = col_navy, linewidth = 0.9) +
  geom_point(aes(y = mean_de), colour = col_navy, size = 2.6) +
  geom_line(aes(y = to_de(mean_roe)), colour = col_red, linewidth = 0.9) +
  geom_point(aes(y = to_de(mean_roe)), colour = col_red, size = 2.6, shape = 15) +
  scale_y_continuous(name = "Mean D/E Ratio",
                     sec.axis = sec_axis(~ to_roe(.), name = "Mean ROE (%)")) +
  labs(title = "Sector Trend: Debt-Equity Ratio vs. Return on Equity (Standalone)",
       x = NULL, caption = src_caption) +
  theme(axis.title.y.left  = element_text(colour = col_navy),
        axis.title.y.right = element_text(colour = col_red),
        axis.text.x = element_text(angle = 45, hjust = 1))

save_fig(fig2, file.path(dir_fig_report, "Figure2_sector_trend_DE_ROE.png"), 8, 4.5)

# ---- Figure 3: D/E vs ROE scatter with linear trend ------------------------
fig3 <- ggplot(panel, aes(x = de, y = roe * 100)) +
  geom_hline(yintercept = 0, colour = "grey70", linewidth = 0.3) +
  geom_point(colour = col_navy, alpha = 0.65, size = 2.4) +
  geom_smooth(method = "lm", formula = y ~ x, se = FALSE,
              colour = col_red, linetype = "dashed", linewidth = 0.8) +
  labs(title = "D/E Ratio vs. ROE (100 firm-year observations, Standalone)",
       subtitle = sprintf("Pearson r = %.2f; dashed line = linear trend",
                          cor(panel$de, panel$roe)),
       x = "Debt-Equity Ratio", y = "Return on Equity (%)", caption = src_caption)

save_fig(fig3, file.path(dir_fig_report, "Figure3_scatter_DE_vs_ROE.png"), 7, 5.2)

message("05_report_figures: 3 report figures saved.")
