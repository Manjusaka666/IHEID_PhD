# Diagnostic Sovereign Risk: figures and number macros for the paper.
# Reads output/results.json and output/results_gov.json (produced by the
# Julia solvers) and writes journal-style PDF figures plus
# output/quant_numbers.tex, the single source of every model-generated
# number cited in the text.
#
# Run from the code/ directory:  Rscript make_figures.R

suppressMessages(library(jsonlite))

out_dir <- file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), "..", "output")
r <- fromJSON(file.path(out_dir, "results.json"), simplifyVector = TRUE)
g <- fromJSON(file.path(out_dir, "results_gov.json"), simplifyVector = TRUE)

# palette: colorblind-safe, prints legibly in grayscale
col_re   <- "#000000"   # rational benchmark: black
col_diag <- "#0072B2"   # diagnostic: blue
col_bad  <- "#D55E00"   # bad news: vermillion
col_good <- "#009E73"   # good news: green
col_gray <- "#8C8C8C"

pdf_one <- function(file, w = 6.2, h = 4.4) {
  pdf(file.path(out_dir, file), width = w, height = h, pointsize = 10)
  par(mar = c(4.2, 4.4, 1.2, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
}

## ---- Figure 1: price schedules ------------------------------------------
fp <- r$fig_price
pdf_one("fig_price.pdf")
b <- fp$b
plot(b, fp$q_re, type = "l", lwd = 2, col = col_re, lty = 2,
     xlab = expression(paste("debt choice ", b*minute, "  (units of mean quarterly output)")),
     ylab = expression(paste("bond price  ", q(b*minute, x, h))),
     xlim = c(0, 0.14), ylim = c(0, 1), xaxs = "i", yaxs = "i")
lines(b, fp$q_good,    lwd = 2, col = col_good)
lines(b, fp$q_neutral, lwd = 2, col = col_gray)
lines(b, fp$q_bad,     lwd = 2, col = col_bad)
legend("bottomleft", bty = "n", lwd = 2,
       col = c(col_re, col_good, col_gray, col_bad),
       lty = c(2, 1, 1, 1),
       legend = c(expression(paste("rational (", theta == 0, "), any history")),
                  expression(paste("diagnostic, good news (", nu > 0, ")")),
                  expression(paste("diagnostic, no news (", nu == 0, ")")),
                  expression(paste("diagnostic, bad news (", nu < 0, ")"))))
invisible(dev.off())

## ---- Figure 2: default sets ---------------------------------------------
fd <- r$fig_defaultset
pdf_one("fig_defaultset.pdf")
y <- fd$y
keep <- !(is.na(fd$b_re) & is.na(fd$b_good) & is.na(fd$b_bad))
xr <- range(y[keep])
plot(y, fd$b_re, type = "l", lwd = 2, col = col_re, lty = 2,
     xlab = "income  y", ylab = expression(paste("default boundary  ", underline(b)(y))),
     xlim = xr,
     ylim = c(0, max(unlist(fd[c("b_re", "b_good", "b_bad")]), na.rm = TRUE) * 1.05),
     xaxs = "i", yaxs = "i")
lines(y, fd$b_good, lwd = 2, col = col_good)
lines(y, fd$b_bad,  lwd = 2, col = col_bad)
legend("topleft", bty = "n", lwd = 2,
       col = c(col_re, col_good, col_bad), lty = c(2, 1, 1),
       legend = c(expression(paste("rational (", theta == 0, ")")),
                  expression(paste("diagnostic, after good news")),
                  expression(paste("diagnostic, after bad news"))))
invisible(dev.off())

## ---- Figure 3: boom-reversal event study --------------------------------
be0 <- r$boom_events$`theta_0.0`
be5 <- r$boom_events$`theta_0.5`
win <- be0$win
pdf(file.path(out_dir, "fig_boom.pdf"), width = 9.5, height = 3.4, pointsize = 10)
par(mfrow = c(1, 3), mar = c(4.2, 4.2, 2.2, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
sp0 <- unlist(lapply(be0$spread_mean, function(z) ifelse(is.null(z), NA, z))) * 1e4
sp5 <- unlist(lapply(be5$spread_mean, function(z) ifelse(is.null(z), NA, z))) * 1e4
plot(win, sp5, type = "b", pch = 19, lwd = 2, col = col_diag,
     xlab = "quarters since boom reversal", ylab = "mean spread (bp, winsorized)",
     main = "(a) spread", ylim = range(c(sp0, sp5), na.rm = TRUE))
lines(win, sp0, type = "b", pch = 1, lwd = 2, col = col_re, lty = 2)
abline(v = 0, col = col_gray, lty = 3)
plot(win, be5$debt, type = "b", pch = 19, lwd = 2, col = col_diag,
     xlab = "quarters since boom reversal", ylab = "mean debt (face value)",
     main = "(b) debt", ylim = range(c(be0$debt, be5$debt)))
lines(win, be0$debt, type = "b", pch = 1, lwd = 2, col = col_re, lty = 2)
abline(v = 0, col = col_gray, lty = 3)
plot(win, be5$default_haz * 100, type = "b", pch = 19, lwd = 2, col = col_diag,
     xlab = "quarters since boom reversal", ylab = "default hazard (percent)",
     main = "(c) default hazard", ylim = c(0, max(be5$default_haz) * 105))
lines(win, be0$default_haz * 100, type = "b", pch = 1, lwd = 2, col = col_re, lty = 2)
abline(v = 0, col = col_gray, lty = 3)
legend("topright", bty = "n", lwd = 2, pch = c(19, 1), lty = c(1, 2),
       col = c(col_diag, col_re),
       legend = c(expression(theta == 0.5), expression(theta == 0)))
invisible(dev.off())

## ---- Figure 4: fiscal rules, the 2x2 ------------------------------------
pdf_one("fig_rule.pdf", w = 6.6, h = 4.6)
cells <- list(
  list(key = "A_rat_rat",   col = col_re,   lty = 2, pch = 1,
       lab = "rational gov., rational market"),
  list(key = "B_rat_diag",  col = col_gray, lty = 2, pch = 0,
       lab = "rational gov., diagnostic market"),
  list(key = "C_diag_diag", col = col_diag, lty = 1, pch = 19,
       lab = "diagnostic gov., diagnostic market"),
  list(key = "D_diag_rat",  col = col_bad,  lty = 1, pch = 17,
       lab = "diagnostic gov., rational market"))
ce_all <- lapply(cells, function(cc) g[[cc$key]]$rule$ce_pct * 100)  # bp of consumption
bc <- g$A_rat_rat$rule$ceiling
plot(NULL, xlim = range(bc), ylim = range(unlist(ce_all)) * 1.08,
     xlab = expression(paste("debt ceiling  ", bar(b), "  (units of mean quarterly output)")),
     ylab = "welfare gain (bp of permanent consumption)")
abline(h = 0, col = col_gray, lty = 3)
for (i in seq_along(cells)) {
  cc <- cells[[i]]
  lines(bc, ce_all[[i]], type = "b", lwd = 2, col = cc$col, lty = cc$lty, pch = cc$pch)
}
legend("bottomright", bty = "n", lwd = 2,
       col = sapply(cells, `[[`, "col"), lty = sapply(cells, `[[`, "lty"),
       pch = sapply(cells, `[[`, "pch"), cex = 0.85,
       legend = sapply(cells, `[[`, "lab"))
invisible(dev.off())

## ---- quant_numbers.tex ----------------------------------------------------
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d, big.mark = ",")
fmt0 <- function(x) formatC(round(x), format = "d", big.mark = ",")
m0 <- r$`theta_0.0`; m5 <- r$`theta_0.5`; m1 <- r$`theta_1.0`
lines_out <- c(
  sprintf("\\newcommand{\\SprMedRE}{%s}",   fmt(m0$median_spread * 100, 1)),
  sprintf("\\newcommand{\\SprMedDiag}{%s}", fmt(m5$median_spread * 100, 1)),
  sprintf("\\newcommand{\\SprMedOne}{%s}",  fmt(m1$median_spread * 100, 1)),
  sprintf("\\newcommand{\\SprMeanRE}{%s}",   fmt(m0$mean_spread * 100, 1)),
  sprintf("\\newcommand{\\SprMeanDiag}{%s}", fmt(m5$mean_spread * 100, 1)),
  sprintf("\\newcommand{\\SprSdRE}{%s}",   fmt(m0$sd_spread * 100, 1)),
  sprintf("\\newcommand{\\SprSdDiag}{%s}", fmt(m5$sd_spread * 100, 1)),
  sprintf("\\newcommand{\\SprSdOne}{%s}",  fmt(m1$sd_spread * 100, 1)),
  sprintf("\\newcommand{\\SprSdRatio}{%s}", fmt(m5$sd_spread / m0$sd_spread, 1)),
  sprintf("\\newcommand{\\CorrSprYRE}{%s}",   fmt(m0$corr_spread_y, 2)),
  sprintf("\\newcommand{\\CorrSprYDiag}{%s}", fmt(m5$corr_spread_y, 2)),
  sprintf("\\newcommand{\\CorrSprYOne}{%s}",  fmt(m1$corr_spread_y, 2)),
  sprintf("\\newcommand{\\FracAccessOne}{%s}", fmt(m1$frac_access * 100, 1)),
  sprintf("\\newcommand{\\DebtYRE}{%s}",   fmt(m0$mean_debt_y * 100, 1)),
  sprintf("\\newcommand{\\DebtYDiag}{%s}", fmt(m5$mean_debt_y * 100, 1)),
  sprintf("\\newcommand{\\DebtYOne}{%s}",  fmt(m1$mean_debt_y * 100, 1)),
  sprintf("\\newcommand{\\DefFreqRE}{%s}",   fmt(m0$defaults_per_100y, 1)),
  sprintf("\\newcommand{\\DefFreqDiag}{%s}", fmt(m5$defaults_per_100y, 1)),
  sprintf("\\newcommand{\\DefFreqOne}{%s}",  fmt(m1$defaults_per_100y, 1)),
  sprintf("\\newcommand{\\NewsBpRE}{%s}",      fmt(abs(m0$bp_per_1sd_news), 1)),
  sprintf("\\newcommand{\\NewsBpRELin}{%s}",   fmt0(m0$bp_per_1sd_news_linear)),
  sprintf("\\newcommand{\\NewsBpRELinAbs}{%s}", fmt0(abs(m0$bp_per_1sd_news_linear))),
  sprintf("\\newcommand{\\NewsBpDiagLin}{%s}", fmt0(m5$bp_per_1sd_news_linear)),
  sprintf("\\newcommand{\\NewsBpDiag}{%s}",    fmt0(m5$bp_per_1sd_news)),
  sprintf("\\newcommand{\\NewsBpDiagAbs}{%s}", fmt0(abs(m5$bp_per_1sd_news))),
  sprintf("\\newcommand{\\NewsBpOneAbs}{%s}",  fmt0(abs(m1$bp_per_1sd_news))),
  sprintf("\\newcommand{\\AsymPosDiag}{%s}", fmt0(abs(m5$reg_pos_bp))),
  sprintf("\\newcommand{\\AsymNegDiag}{%s}", fmt0(abs(m5$reg_neg_bp))),
  sprintf("\\newcommand{\\FracAccessRE}{%s}",   fmt(m0$frac_access * 100, 1)),
  sprintf("\\newcommand{\\FracAccessDiag}{%s}", fmt(m5$frac_access * 100, 1)),
  sprintf("\\newcommand{\\SdNews}{%s}", fmt(m5$sd_news * 100, 1))
)
# CG mapping values
cgb <- function(th, rho = 0.945) -th * (1 + th) / ((1 + th)^2 + th^2 * rho^2)
lines_out <- c(lines_out,
  sprintf("\\newcommand{\\CGbetaQuarter}{%s}", fmt(cgb(0.25), 2)),
  sprintf("\\newcommand{\\CGbetaHalf}{%s}",    fmt(cgb(0.5), 2)),
  sprintf("\\newcommand{\\CGbetaOne}{%s}",     fmt(cgb(1.0), 2)))

# event study numbers
haz5 <- be5$default_haz; haz0 <- be0$default_haz
k0 <- which(win == 0)
lines_out <- c(lines_out,
  sprintf("\\newcommand{\\HazPeakDiag}{%s}", fmt(haz5[k0] * 100, 1)),
  sprintf("\\newcommand{\\HazPeakRE}{%s}",   fmt(haz0[k0] * 100, 1)),
  sprintf("\\newcommand{\\EventsN}{%s}",     fmt0(be0$n_events)),
  sprintf("\\newcommand{\\BoomDebtRiseDiag}{%s}",
          fmt0(100 * (be5$debt[k0] / be5$debt[1] - 1))),
  sprintf("\\newcommand{\\BoomDebtRiseRE}{%s}",
          fmt0(100 * (be0$debt[k0] / be0$debt[1] - 1))))

# 2x2 rule experiment: best ceiling per cell
best <- function(key) {
  rl <- g[[key]]$rule
  i <- which.max(rl$ce_pct)
  list(ce_bp = rl$ce_pct[i] * 100, ceil = rl$ceiling[i],
       worst_bp = min(rl$ce_pct) * 100,
       def0 = g[[key]]$moments$defaults_per_100y,
       defopt = rl$defaults_per_100y[i],
       debt = g[[key]]$moments$mean_debt_y * 100)
}
A <- best("A_rat_rat"); B <- best("B_rat_diag")
C <- best("C_diag_diag"); D <- best("D_diag_rat")
lines_out <- c(lines_out,
  sprintf("\\newcommand{\\CEbestA}{%s}", fmt(A$ce_bp, 1)),
  sprintf("\\newcommand{\\CEbestB}{%s}", fmt(B$ce_bp, 1)),
  sprintf("\\newcommand{\\CEbestC}{%s}", fmt(C$ce_bp, 1)),
  sprintf("\\newcommand{\\CEbestD}{%s}", fmt(D$ce_bp, 1)),
  sprintf("\\newcommand{\\CEworstA}{%s}", fmt(A$worst_bp, 1)),
  sprintf("\\newcommand{\\CEworstB}{%s}", fmt(B$worst_bp, 1)),
  sprintf("\\newcommand{\\CeilOptC}{%s}", fmt(C$ceil, 2)),
  sprintf("\\newcommand{\\CeilOptD}{%s}", fmt(D$ceil, 2)),
  sprintf("\\newcommand{\\DebtYCellD}{%s}", fmt(D$debt, 1)),
  sprintf("\\newcommand{\\DefFreqCellC}{%s}", fmt(C$def0, 1)),
  sprintf("\\newcommand{\\DefFreqCellCopt}{%s}", fmt(C$defopt, 1)),
  sprintf("\\newcommand{\\DefFreqCellD}{%s}", fmt(D$def0, 1)),
  sprintf("\\newcommand{\\NewsBpCellD}{%s}", fmt(abs(g$D_diag_rat$moments$bp_per_1sd_news), 1)),
  sprintf("\\newcommand{\\NewsBpCellC}{%s}", fmt0(abs(g$C_diag_diag$moments$bp_per_1sd_news))))

writeLines(lines_out, file.path(out_dir, "quant_numbers.tex"))
cat("wrote", length(lines_out), "macros and 4 figures to", normalizePath(out_dir), "\n")
