# Figures and LaTeX macros for "Official Distrust, Investor Composition, and
# Sovereign Rollover Crises". Reads output/results.json; writes
# output/fig_*.pdf and output/quant_numbers.tex.

library(jsonlite)

root <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), ".."))
out <- file.path(root, "output")
r <- fromJSON(file.path(out, "results.json"))

col_blue <- "#1268b3"; col_orange <- "#d55e00"; col_green <- "#009e73"
col_gray <- "#666666"; col_red <- "#c0392b"

pdfopen <- function(f, w = 9, h = 4.4) {
  pdf(file.path(out, f), width = w, height = h, pointsize = 10)
  par(mar = c(4, 4, 2.2, 1), mgp = c(2.4, 0.7, 0), las = 1)
}

# -------------------------------------------------------------- fig_frontier
fr <- r$frontier
pdfopen("fig_frontier.pdf", w = 9, h = 4.4)
par(mfrow = c(1, 2))
plot(NA, xlim = c(0, 1), ylim = c(0.5, 0.72),
     xlab = expression("high-run-propensity weight  " * mu),
     ylab = expression("crisis threshold  " * theta^"*"),
     main = "(a) the fragility frontier (stress)")
lines(fr$mu, fr$t_stress_0.04, lwd = 2.2, col = col_blue)
lines(fr$mu, fr$t_stress_0.08, lwd = 2.2, col = col_orange)
lines(fr$mu, fr$t_stress_0.12, lwd = 2.2, col = col_red)
legend("topleft", bty = "n", lwd = 2.2, col = c(col_blue, col_orange, col_red),
       legend = c(expression(delta == 0.04), expression(delta == 0.08),
                  expression(delta == 0.12)), cex = 0.9)
plot(NA, xlim = c(0, 1), ylim = c(150, 1100),
     xlab = expression("high-run-propensity weight  " * mu),
     ylab = "spread (bp)", main = "(b) spreads along the frontier")
lines(fr$mu, fr$s_stress_0.04, lwd = 2.2, col = col_blue)
lines(fr$mu, fr$s_stress_0.08, lwd = 2.2, col = col_orange)
lines(fr$mu, fr$s_stress_0.12, lwd = 2.2, col = col_red)
dev.off()

# ---------------------------------------------------------- fig_transparency
tr <- r$transparency
ygrid <- tr$y; mgrid <- tr$mu
dt <- if (is.matrix(tr$dtda)) tr$dtda else do.call(rbind, tr$dtda)   # rows = y, cols = mu
pdfopen("fig_transparency.pdf", w = 6.4, h = 4.8)
image(ygrid, mgrid, sign(dt), col = c(grDevices::adjustcolor(col_green, 0.25),
                                      grDevices::adjustcolor(col_red, 0.30)),
      xlab = expression("official news level  " * y),
      ylab = expression("high-run-propensity weight  " * mu),
      main = "when does official precision stabilize?", useRaster = TRUE)
contour(ygrid, mgrid, dt, levels = 0, add = TRUE, lwd = 2.2, drawlabels = FALSE)
text(0.86, 0.5, expression("precision raises  " * theta^"*"), cex = 0.85, col = col_red)
text(1.19, 0.5, expression("precision lowers  " * theta^"*"), cex = 0.85, col = col_green)
points(c(r$calibration$y_stress, r$calibration$y_calm), c(0.4, 0.4), pch = 16)
text(r$calibration$y_stress, 0.44, "stress", cex = 0.75)
text(r$calibration$y_calm, 0.44, "calm", cex = 0.75)
dev.off()

# -------------------------------------------------------------- fig_ambnoise
dr <- r$directional
pdfopen("fig_ambnoise.pdf", w = 6.4, h = 4.6)
plot(dr$y, dr$d_amb, type = "l", lwd = 2.4, col = col_orange,
     ylim = range(c(dr$d_amb, dr$d_noise)),
     xlab = expression("official news level  " * y),
     ylab = expression(Delta * theta^"*"),
     main = "ambiguity is directional; noise is contextual")
lines(dr$y, dr$d_noise, lwd = 2.4, col = col_blue, lty = 5)
abline(h = 0, col = col_gray, lty = 3)
legend("topright", bty = "n", lwd = 2.4, lty = c(1, 5),
       col = c(col_orange, col_blue), cex = 0.9,
       legend = c(expression("distrust  " * (delta == 0.08)),
                  expression("equal-sd extra noise")))
dev.off()

# -------------------------------------------------------------------- fig_qt
qt <- r$qt
tt <- seq_len(qt$T)
pdfopen("fig_qt.pdf", w = 6.8, h = 4.6)
plot(tt, qt$s_qt, type = "s", lwd = 2.4, col = col_orange,
     ylim = c(0, max(qt$s_qt) * 1.15),
     xlab = "year", ylab = "spread (bp)",
     main = "the state-contingent price of QT")
lines(tt, qt$s_noqt, type = "s", lwd = 2.4, col = col_blue)
abline(v = qt$t_shock, col = col_gray, lty = 3)
text(qt$t_shock, max(qt$s_qt) * 1.08, "fundamentals shock", cex = 0.8, col = col_gray, adj = -0.05)
legend("topleft", bty = "n", lwd = 2.4, col = c(col_orange, col_blue), cex = 0.9,
       legend = c(expression("QT:  " * mu * "  0.35" %->% "0.65"),
                  expression("no QT:  " * mu == 0.35)))
dev.off()

# -------------------------------------------------------------------- macros
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d)
cal <- r$calibration; b <- r$base; cr <- r$credibility; cc <- r$cac; qt <- r$qt

lines_out <- c(
  sprintf("\\newcommand{\\PbarPct}{%s}", fmt(cal$pbar * 100, 1)),
  sprintf("\\newcommand{\\RatioVal}{%s}", fmt(cal$ratio, 2)),
  sprintf("\\newcommand{\\UniqBound}{%s}", fmt(cal$unique_bound, 2)),
  sprintf("\\newcommand{\\CutoffPrem}{%s}", fmt(cal$cutoff_premium, 3)),
  sprintf("\\newcommand{\\ShiftVal}{%s}", fmt(cal$shift, 2)),
  sprintf("\\newcommand{\\TCalm}{%s}", fmt(b$calm$t_amb, 3)),
  sprintf("\\newcommand{\\TCalmBay}{%s}", fmt(b$calm$t_bay, 3)),
  sprintf("\\newcommand{\\TStress}{%s}", fmt(b$stress$t_amb, 3)),
  sprintf("\\newcommand{\\PCalmPct}{%s}", fmt(b$calm$P_amb * 100, 1)),
  sprintf("\\newcommand{\\PStressPct}{%s}", fmt(b$stress$P_amb * 100, 1)),
  sprintf("\\newcommand{\\SCalm}{%s}", fmt(b$calm$s_amb, 0)),
  sprintf("\\newcommand{\\SStress}{%s}", fmt(b$stress$s_amb, 0)),
  sprintf("\\newcommand{\\PremCalm}{%s}", fmt(b$calm$premium_bp, 0)),
  sprintf("\\newcommand{\\PremStress}{%s}", fmt(b$stress$premium_bp, 0)),
  sprintf("\\newcommand{\\PremRatio}{%s}", fmt(b$stress$premium_bp / b$calm$premium_bp, 1)),
  sprintf("\\newcommand{\\MultCalm}{%s}", fmt(b$calm$mult, 1)),
  sprintf("\\newcommand{\\YDagger}{%s}", fmt(r$transparency_ydagger, 2)),
  sprintf("\\newcommand{\\HalfDeltaBp}{%s}", fmt(abs(cr$half_delta_spread_bp), 0)),
  sprintf("\\newcommand{\\DtDdelta}{%s}", fmt(cr$dt_ddelta_stress, 2)),
  sprintf("\\newcommand{\\QTPreQt}{%s}", fmt(qt$s_preshock_qt, 0)),
  sprintf("\\newcommand{\\QTPreNo}{%s}", fmt(qt$s_preshock_noqt, 0)),
  sprintf("\\newcommand{\\QTEndQt}{%s}", fmt(qt$s_end_qt, 0)),
  sprintf("\\newcommand{\\QTEndNo}{%s}", fmt(qt$s_end_noqt, 0)),
  sprintf("\\newcommand{\\QTPremCalm}{%s}", fmt(qt$s_preshock_qt - qt$s_preshock_noqt, 0)),
  sprintf("\\newcommand{\\QTPremShock}{%s}", fmt(qt$s_end_qt - qt$s_end_noqt, 0)),
  sprintf("\\newcommand{\\CACSBase}{%s}", fmt(cc$base$s_amb, 0)),
  sprintf("\\newcommand{\\CACSNew}{%s}", fmt(cc$cac$s_amb, 0)),
  sprintf("\\newcommand{\\CACTBase}{%s}", fmt(cc$base$t_amb, 3)),
  sprintf("\\newcommand{\\CACTNew}{%s}", fmt(cc$cac$t_amb, 3)),
  sprintf("\\newcommand{\\SigX}{%s}", fmt(cal$sigx, 2)),
  sprintf("\\newcommand{\\SigY}{%s}", fmt(cal$sigy, 2)),
  sprintf("\\newcommand{\\DelF}{%s}", fmt(cal$delF, 2)),
  sprintf("\\newcommand{\\MuBase}{%s}", fmt(cal$mu0, 2))
)
writeLines(lines_out, file.path(out, "quant_numbers.tex"))
cat("wrote", length(lines_out), "macros and 4 figures\n")
