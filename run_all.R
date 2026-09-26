# =============================================================================
# run_all.R — run the whole analysis in one go
# Open capital-structure-textiles-india.Rproj in RStudio, then click "Source" on
# this file (or press Ctrl+Shift+S). Everything is rebuilt into /output.
# =============================================================================

rm(list = ls())

source("R/00_setup.R")             # packages, colours, theme, folders
source("R/01_data_prep.R")         # Raw Data  -> 100-row Ratios Panel
source("R/02_descriptive_stats.R") # Table 3 + year-wise / period-wise stats
source("R/03_correlation.R")       # Table 4 + p-values
source("R/04_regression.R")        # Tables 5 & 6 + diagnostics, robust SE, COVID, FE
source("R/05_report_figures.R")    # Figures 1–3 exactly as in the report
source("R/06_additional_figures.R")# 13 additional figures (A01–A13)
source("R/07_export_workings.R")   # all tables -> output/tables/R_Workings.xlsx

message("\nDone. See output/figures/ and output/tables/.")
