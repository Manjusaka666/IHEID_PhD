# Figures and LaTeX number macros for "Endogenous Trade Fragmentation".
# Reads output/results.json (written by solve_model.jl); writes output/fig_*.pdf,
# output/quant_numbers.tex, output/sens_table.tex.

library(jsonlite)

root <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), ".."))
out <- file.path(root, "output")
r <- fromJSON(file.path(out, "results.json"))

col_blue <- "#1268b3"; col_orange <- "#d55e00"; col_green <- "#009e73"
col_gray <- "#666666"; col_red <- "#c0392b"

pdfopen <- function(f, w = 9, h = 4) {
  pdf(file.path(out, f), width = w, height = h, pointsize = 10)
  par(mar = c(4, 4, 2.2, 1), mgp = c(2.4, 0.7, 0), las = 1)
}

# ---------------------------------------------------------------- fig_scurve
sc <- r$scurve
pdfopen("fig_scurve.pdf", w = 6.2, h = 5)
plot(sc$F, sc$pre, type = "l", lwd = 2.2, col = col_blue, xlim = c(0, 1),
     ylim = c(0, 1), xlab = expression("sector fragmentation  " * F[c]),
     ylab = expression("best response  " * f[c](F[c])),
     main = "friend-shoring best response, critical sector")
lines(sc$F, sc$post, lwd = 2.2, col = col_green)
lines(sc$F, sc$fold, lwd = 2.2, col = col_orange)
abline(0, 1, col = col_gray, lty = 2)
legend("topleft", bty = "n", lwd = 2.2, col = c(col_blue, col_green, col_orange, col_gray),
       lty = c(1, 1, 1, 2), cex = 0.9,
       legend = c(expression("pre-2022  " * (delta == 0.04)),
                  expression("post-2022  " * (delta == 0.10)),
                  expression("at the fold  " * (delta == delta^"*")),
                  "45-degree line"))
dev.off()

# ----------------------------------------------------------- fig_bifurcation
bf <- r$bifurcation
pdfopen("fig_bifurcation.pdf", w = 9, h = 4.6)
par(mfrow = c(1, 2))
plot(NA, xlim = c(0.02, 0.26), ylim = c(0, 1),
     xlab = expression("dispute hazard  " * delta * "  (per year)"),
     ylab = expression("critical-sector fragmentation  " * F[c]),
     main = "(a) equilibria and the fold")
rect(bf$band_lo, -0.05, bf$band_hi, 1.05, col = grDevices::adjustcolor(col_orange, 0.12), border = NA)
lines(bf$delta, bf$low, lwd = 2.4, col = col_blue)
lines(bf$delta, bf$high, lwd = 2.4, col = col_blue)
lines(bf$delta, bf$mid, lwd = 1.6, col = col_red, lty = 2)
abline(v = r$calibration$delta_pre, col = col_gray, lty = 3)
abline(v = r$calibration$delta_post, col = col_gray, lty = 3)
text(r$calibration$delta_pre, 0.97, "pre-2022", cex = 0.75, col = col_gray, adj = -0.05)
text(r$calibration$delta_post, 0.90, "post-2022", cex = 0.75, col = col_gray, adj = -0.05)
text(0.5 * (bf$band_lo + bf$band_hi), 0.55, "hysteresis\nband", cex = 0.75, col = col_orange)
legend("bottomright", bty = "n", lwd = c(2.4, 1.6), lty = c(1, 2),
       col = c(col_blue, col_red), cex = 0.85,
       legend = c("stable equilibria", "unstable"))

cs <- r$cascade
plot(cs$delta, cs$f_crit, type = "l", lwd = 2.4, col = col_orange,
     xlim = c(0.02, 0.26), ylim = c(0, 1),
     xlab = expression("dispute hazard  " * delta * "  (per year)"),
     ylab = "fragmented share of sector trade",
     main = "(b) the cascade is sectorally concentrated")
lines(cs$delta, cs$f_mid, lwd = 2.2, col = col_green)
lines(cs$delta, cs$f_flex, lwd = 2.2, col = col_blue)
lines(cs$delta, cs$F_agg, lwd = 2.0, col = col_gray, lty = 5)
legend("topleft", bty = "n", lwd = 2.2, col = c(col_orange, col_green, col_blue, col_gray),
       lty = c(1, 1, 1, 5), cex = 0.85,
       legend = c(expression("critical  " * (sigma == 2)),
                  expression("middle  " * (sigma == 4)),
                  expression("flexible  " * (sigma == 8)),
                  "aggregate F"))
dev.off()

# ------------------------------------------------------------ fig_hysteresis
hy <- r$hysteresis
tt <- seq_len(hy$T) - 1
pdfopen("fig_hysteresis.pdf", w = 6.8, h = 4.6)
plot(NA, xlim = c(0, hy$T - 1), ylim = c(0, 1),
     xlab = "years", ylab = expression("critical-sector fragmentation  " * F[c]),
     main = "a temporary confrontation, a permanent network")
rect(hy$spike_on - 1, -0.05, hy$spike_off - 1, 1.05,
     col = grDevices::adjustcolor(col_red, 0.10), border = NA)
lines(tt, hy$Fc_ctrl, lwd = 2.4, col = col_blue)
lines(tt, hy$Fc_spike, lwd = 2.4, col = col_orange)
text(0.5 * (hy$spike_on + hy$spike_off) - 1, 0.03,
     sprintf("confrontation\n(delta = %.2f)", hy$d_spike), cex = 0.75, col = col_red)
legend("topleft", bty = "n", lwd = 2.4, col = c(col_orange, col_blue), cex = 0.9,
       legend = c(sprintf("12-year confrontation, then delta = %.3f", hy$d_mid),
                  sprintf("no confrontation, same terminal delta = %.3f", hy$d_mid)))
dev.off()

# ---------------------------------------------------------------- fig_policy
po <- r$policy
pdfopen("fig_policy.pdf", w = 9, h = 4.3)
par(mfrow = c(1, 2))
labs <- c("baseline", "friend-shoring\nsubsidy (25%)", "stockpile\n(-1/3 loss)")
keys <- c("baseline", "subsidy", "stockpile")
lo <- sapply(keys, function(k) po[[k]]$band_lo)
hi <- sapply(keys, function(k) po[[k]]$band_hi)
plot(NA, xlim = c(0.5, 3.5), ylim = c(0.06, 0.22), xaxt = "n",
     xlab = "", ylab = expression("fold location  " * delta^"*"),
     main = "(a) where the tipping region sits")
axis(1, at = 1:3, labels = labs, cex.axis = 0.8, padj = 0.4)
for (i in 1:3) {
  segments(i, lo[i], i, hi[i], lwd = 6, col = col_orange)
  points(i, lo[i], pch = 16, col = col_orange); points(i, hi[i], pch = 16, col = col_orange)
}
abline(h = r$calibration$delta_post, col = col_gray, lty = 2)
text(3.4, r$calibration$delta_post, "post-2022", cex = 0.75, col = col_gray, adj = c(1, -0.4))

pic <- sapply(keys, function(k) po[[k]]$pic) * 100
bp <- barplot(pic, names.arg = labs, col = c(col_gray, col_red, col_green),
              ylab = "equilibrium disruption hazard (% / yr)", cex.names = 0.8,
              main = "(b) the hazard each policy delivers", ylim = c(0, 11))
text(bp, pic + 0.4, sprintf("%.1f", pic), cex = 0.85)
dev.off()

# ----------------------------------------------------------------- fig_wedge
wd <- r$wedge
pdfopen("fig_wedge.pdf", w = 6.2, h = 4.4)
plot(wd$delta, wd$tau * 100, type = "b", pch = 16, lwd = 2.2, col = col_blue,
     xlab = expression("dispute hazard  " * delta), ylab = "corrective wedge (% ad valorem)",
     main = "defend the bridge, then burn it")
abline(h = 0, col = col_gray, lty = 2)
rect(bf$band_lo, -100, bf$band_hi, 100, col = grDevices::adjustcolor(col_orange, 0.12), border = NA)
text(wd$delta[2], 2.2, "subsidize staying", cex = 0.8, col = col_gray)
text(wd$delta[6], -3.2, "subsidize switching", cex = 0.8, col = col_gray)
dev.off()

# -------------------------------------------------------------------- macros
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d)
fmt_sci_tex <- function(x, d = 1) {
  exponent <- floor(log10(abs(x)))
  sprintf(paste0("%.", d, "f\\times10^{%d}"), x / 10^exponent, exponent)
}
cal <- r$calibration; ss <- r$ss; wf <- r$welfare; ds <- r$distance
mu <- r$multiplier

lines_out <- c(
  sprintf("\\newcommand{\\LamCrit}{%s}",  fmt(cal$lam0[1], 2)),
  sprintf("\\newcommand{\\LamMid}{%s}",   fmt(cal$lam0[2] * 100, 0)),
  sprintf("\\newcommand{\\LamFlex}{%s}",  fmt(cal$lam0[3] * 100, 1)),
  sprintf("\\newcommand{\\DeltaPrePct}{%s}",  fmt(cal$delta_pre * 100, 0)),
  sprintf("\\newcommand{\\DeltaPostPct}{%s}", fmt(cal$delta_post * 100, 0)),
  sprintf("\\newcommand{\\FcPrePct}{%s}",  fmt(ss$pre$Fm[1] * 100, 1)),
  sprintf("\\newcommand{\\FcPostPct}{%s}", fmt(ss$post$Fm[1] * 100, 1)),
  sprintf("\\newcommand{\\FAggPrePct}{%s}",  fmt(ss$pre$F * 100, 1)),
  sprintf("\\newcommand{\\FAggPostPct}{%s}", fmt(ss$post$F * 100, 1)),
  sprintf("\\newcommand{\\PicPrePct}{%s}",  fmt(ss$pre$pic0 * 100, 1)),
  sprintf("\\newcommand{\\PicPostPct}{%s}", fmt(ss$post$pic * 100, 1)),
  sprintf("\\newcommand{\\FoldLoPct}{%s}", fmt(ds$fold_lo * 100, 1)),
  sprintf("\\newcommand{\\FoldHiPct}{%s}", fmt(ds$fold_hi * 100, 1)),
  sprintf("\\newcommand{\\ConsumedPct}{%s}", fmt(ds$consumed * 100, 0)),
  sprintf("\\newcommand{\\MCrit}{%s}", fmt(mu$M_crit, 2)),
  sprintf("\\newcommand{\\MAgg}{%s}", fmt(mu$M_agg, 2)),
  sprintf("\\newcommand{\\SpectralRadius}{%s}", fmt(mu$spectral_radius, 3)),
  sprintf("\\newcommand{\\MOwnCrit}{%s}", fmt(mu$own_channel_sector[1] / mu$direct_sector[1], 2)),
  sprintf("\\newcommand{\\CrossAmplificationSharePct}{%s}",
          fmt(mu$cross_spillover_sector[1] /
              (mu$total_sector[1] - mu$direct_sector[1]) * 100, 1)),
  sprintf("\\newcommand{\\DirectCritResponse}{%s}", fmt(mu$direct_sector[1], 3)),
  sprintf("\\newcommand{\\TotalCritResponse}{%s}", fmt(mu$total_sector[1], 3)),
  sprintf("\\newcommand{\\DirectMidResponse}{%s}", fmt_sci_tex(mu$direct_sector[2], 1)),
  sprintf("\\newcommand{\\TotalMidResponse}{%s}", fmt_sci_tex(mu$total_sector[2], 1)),
  sprintf("\\newcommand{\\DMidPct}{%s}", fmt(r$hysteresis$d_mid * 100, 1)),
  sprintf("\\newcommand{\\DSpikePct}{%s}", fmt(r$hysteresis$d_spike * 100, 1)),
  sprintf("\\newcommand{\\HystCtrlEndPct}{%s}", fmt(tail(r$hysteresis$Fc_ctrl, 1) * 100, 0)),
  sprintf("\\newcommand{\\HystSpikeEndPct}{%s}", fmt(tail(r$hysteresis$Fc_spike, 1) * 100, 0)),
  sprintf("\\newcommand{\\PFCtrlEndPct}{%s}", fmt(tail(r$hysteresis$Fc_ctrl_perfect_foresight, 1) * 100, 0)),
  sprintf("\\newcommand{\\PFSpikeEndPct}{%s}", fmt(tail(r$hysteresis$Fc_spike_perfect_foresight, 1) * 100, 0)),
  sprintf("\\newcommand{\\PFMaxCtrlPP}{%s}", fmt(r$hysteresis$max_path_difference_ctrl * 100, 1)),
  sprintf("\\newcommand{\\PFMaxSpikePP}{%s}", fmt(r$hysteresis$max_path_difference_spike * 100, 1)),
  sprintf("\\newcommand{\\PFResidual}{%s}", fmt_sci_tex(max(
    r$hysteresis$perfect_foresight_residual_ctrl,
    r$hysteresis$perfect_foresight_residual_spike), 1)),
  sprintf("\\newcommand{\\RootGridDifference}{%s}",
          ifelse(r$bifurcation$max_root_difference == 0, "0",
                 fmt_sci_tex(r$bifurcation$max_root_difference, 1))),
  sprintf("\\newcommand{\\FoldMaxResidual}{%s}", fmt_sci_tex(max(
    abs(r$bifurcation$fold_lower$residual),
    abs(r$bifurcation$fold_lower$slope_residual),
    abs(r$bifurcation$fold_upper$residual),
    abs(r$bifurcation$fold_upper$slope_residual)), 1)),
  sprintf("\\newcommand{\\LamCritModeratePct}{%s}",
          fmt(r$loss_sensitivity$critical_inventory_025_substitution_025 * 100, 0)),
  sprintf("\\newcommand{\\LamCritStrongPct}{%s}",
          fmt(r$loss_sensitivity$critical_inventory_05_substitution_05 * 100, 1)),
  sprintf("\\newcommand{\\FLoPct}{%s}", fmt(wf$F_lo * 100, 0)),
  sprintf("\\newcommand{\\FHiPct}{%s}", fmt(wf$F_hi * 100, 0)),
  sprintf("\\newcommand{\\PicLoPct}{%s}", fmt(wf$pic_lo * 100, 1)),
  sprintf("\\newcommand{\\PicHiPct}{%s}", fmt(wf$pic_hi * 100, 1)),
  sprintf("\\newcommand{\\TrapCostPct}{%s}", fmt(wf$trap_cost_sector * 100, 1)),
  sprintf("\\newcommand{\\TrapGDPBp}{%s}", fmt(wf$trap_cost_gdp_pct * 100, 1)),
  sprintf("\\newcommand{\\SubsBandLoPct}{%s}", fmt(po$subsidy$band_lo * 100, 1)),
  sprintf("\\newcommand{\\SubsBandHiPct}{%s}", fmt(po$subsidy$band_hi * 100, 1)),
  sprintf("\\newcommand{\\SubsFcPct}{%s}", fmt(po$subsidy$Fc * 100, 0)),
  sprintf("\\newcommand{\\SubsPicPct}{%s}", fmt(po$subsidy$pic * 100, 1)),
  sprintf("\\newcommand{\\StockBandLoPct}{%s}", fmt(po$stockpile$band_lo * 100, 1)),
  sprintf("\\newcommand{\\StockBandHiPct}{%s}", fmt(po$stockpile$band_hi * 100, 1)),
  sprintf("\\newcommand{\\StockFcPct}{%s}", fmt(po$stockpile$Fc * 100, 1)),
  sprintf("\\newcommand{\\StockPicPct}{%s}", fmt(po$stockpile$pic * 100, 1)),
  sprintf("\\newcommand{\\WedgeAtPostPct}{%s}", fmt(wd$tau[wd$delta == 0.10] * 100, 1)),
  sprintf("\\newcommand{\\WedgeAtTwentyPct}{%s}", fmt(wd$tau[wd$delta == 0.20] * 100, 1)),
  sprintf("\\newcommand{\\WedgeAtTwentyFourPct}{%s}", fmt(abs(wd$tau[wd$delta == 0.24]) * 100, 1)),
  sprintf("\\newcommand{\\TransFcTenPct}{%s}", fmt(r$transition$Fc[10] * 100, 1)),
  sprintf("\\newcommand{\\CascMidQuarterPct}{%s}", fmt(cs$f_mid[which(cs$delta >= 0.25)[1]] * 100, 0)),
  sprintf("\\newcommand{\\DiDPredictedPP}{%s}", fmt((ss$post$Fm[1] - ss$pre$Fm[1]) * 100 -
                                                    (ss$post$Fm[3] - ss$pre$Fm[3]) * 100, 1)),
  sprintf("\\newcommand{\\PicRiseBp}{%s}", fmt((ss$post$pic - cal$delta_post * (1 - cal$theta * (1 - ss$pre$Fm[1]))) * 1e4, 0))
)
writeLines(lines_out, file.path(out, "quant_numbers.tex"))

# sensitivity table: fold band by theta x chi
sens <- r$sensitivity
ths <- c(0.4, 0.5, 0.6, 0.7); chs <- c(0.0, 0.2, 0.4, 0.6)
rows <- c("\\begin{tabular}{lcccc}", "\\toprule",
          paste0(" & ", paste(sprintf("$\\chi = %.1f$", chs), collapse = " & "), " \\\\"),
          "\\midrule")
for (th in ths) {
  cells <- sapply(chs, function(ch) {
    v <- sens[[sprintf("th%.1f_chi%.1f", th, ch)]]
    if (is.null(v$band_lo) || is.na(v$band_lo)) "none" else
      sprintf("%.3f--%.3f", v$band_lo, v$band_hi)
  })
  rows <- c(rows, paste0(sprintf("$\\theta = %.1f$ & ", th),
                         paste(cells, collapse = " & "), " \\\\"))
}
rows <- c(rows, "\\bottomrule", "\\end{tabular}")
writeLines(rows, file.path(out, "sens_table.tex"))

cat("wrote", length(lines_out), "macros, sensitivity table, and 5 figures\n")
