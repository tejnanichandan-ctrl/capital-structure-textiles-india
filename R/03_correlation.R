# =============================================================================
# 03_correlation.R — Pearson correlation matrix (Table 4) + p-values
# =============================================================================

if (!exists("panel")) source("R/01_data_prep.R")

cor_vars <- c(`D/E` = "de", ROE = "roe", ROA = "roa", EPS = "eps",
              `Size (ln TA)` = "size", `Sales Growth` = "sales_growth",
              Tangibility = "tangibility")

X <- as.data.frame(panel[, cor_vars]); names(X) <- names(cor_vars)

# ---- 1. Correlation coefficients (same as Excel CORREL) --------------------
cor_mat <- cor(X, method = "pearson")

# ---- 2. Significance: p-value of each pair (two-tailed t-test, n = 100) -----
p_mat <- outer(seq_along(X), seq_along(X), Vectorize(function(i, j) {
  if (i == j) return(NA_real_)
  cor.test(X[[i]], X[[j]])$p.value
}))
dimnames(p_mat) <- dimnames(cor_mat)

# Stars: *** p<0.001, ** p<0.01, * p<0.05
stars <- ifelse(is.na(p_mat), "", ifelse(p_mat < .001, "***", ifelse(p_mat < .01, "**", ifelse(p_mat < .05, "*", ""))))
cor_star <- matrix(paste0(sprintf("%.3f", cor_mat), stars), nrow(cor_mat), dimnames = dimnames(cor_mat))

# Critical |r| at 5% for n = 100 (useful for viva questions)
n <- nrow(X); t_crit <- qt(0.975, n - 2)
r_crit <- t_crit / sqrt(n - 2 + t_crit^2)

# ---- 3. Save & print -------------------------------------------------------
write_tab(data.frame(Variable = rownames(cor_mat), round(cor_mat, 4), check.names = FALSE),
          file.path(dir_tab, "correlation_matrix.csv"))
write_tab(data.frame(Variable = rownames(p_mat), signif(p_mat, 4), check.names = FALSE),
          file.path(dir_tab, "correlation_pvalues.csv"))
write_tab(data.frame(Variable = rownames(cor_star), cor_star, check.names = FALSE),
          file.path(dir_tab, "correlation_with_stars.csv"))

cat("\n==== Table 4: Pearson correlation matrix (n = 100) ====\n")
print(noquote(cor_star))
cat(sprintf("\n*** p<0.001  ** p<0.01  * p<0.05 | |r| above %.3f is significant at 5%% (n = %d)\n", r_crit, n))
