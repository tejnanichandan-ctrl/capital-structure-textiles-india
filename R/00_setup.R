# =============================================================================
# 00_setup.R — packages, colours, chart theme and output folders
# Capital Structure Analysis — Textile & Apparel Sector, India (FY16–FY25)
# Prepared by: Chandan | Roll No. 5822 | Division D
# -----------------------------------------------------------------------------
# Every other script starts with source("R/00_setup.R"), so each one can be
# run on its own. Open the .Rproj file first so the working directory is the
# project folder.
# =============================================================================

# ---- 1. Packages (installed automatically the first time) -------------------
pkgs <- c("dplyr", "tidyr", "readr", "ggplot2", "scales", "ggrepel", "patchwork",
          "lmtest", "sandwich", "car", "plm", "writexl")

missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  message("Installing missing packages: ", paste(missing, collapse = ", "))
  install.packages(missing, repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages(invisible(lapply(pkgs, library, character.only = TRUE)))

# ---- 2. Output folders ------------------------------------------------------
dir_fig_report <- "output/figures/report"      # the 3 figures used in the report
dir_fig_add    <- "output/figures/additional"  # extra figures (A01 ... A13)
dir_tab        <- "output/tables"              # CSV tables + Excel workbook
for (d in c(dir_fig_report, dir_fig_add, dir_tab)) dir.create(d, recursive = TRUE, showWarnings = FALSE)

# ---- 3. Colours (same navy / red as the Word report) ------------------------
col_navy  <- "#1F4E79"   # D/E, main bars and points
col_red   <- "#C00000"   # ROE, trend lines
col_grey  <- "#8C8C8C"   # reference lines, sector average
col_covid <- "#F2E6D9"   # shading behind COVID years
col_pair  <- c("#2a78d6", "#eb6834", "#1baf7a")  # up to 3 groups (e.g. periods / models)

# ---- 4. One chart theme for every figure -----------------------------------
theme_report <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.title       = element_text(face = "bold", size = base_size + 2),
      plot.subtitle    = element_text(colour = "grey30"),
      plot.caption     = element_text(colour = "grey45", size = base_size - 2, hjust = 0),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "grey90", linewidth = 0.3),
      axis.title       = element_text(colour = "grey25"),
      legend.position  = "top",
      strip.text       = element_text(face = "bold"),
      plot.background  = element_rect(fill = "white", colour = NA)
    )
}
theme_set(theme_report())

src_caption <- "Source: Screener.in, standalone financials; author's calculations."

# Helper: save a ggplot at print quality (300 dpi PNG)
save_fig <- function(plot, file, width = 8, height = 4.5) {
  ggsave(file, plot, width = width, height = height, dpi = 300, bg = "white")
  message("  saved: ", file)
}

# Helper: write a CSV that opens cleanly in Excel (UTF-8 with BOM, so β and
# dashes display correctly on Windows)
write_tab <- function(df, file) readr::write_excel_csv(df, file, na = "")
