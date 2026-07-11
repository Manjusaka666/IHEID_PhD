# Figures and LaTeX macros for "Narrative Contagion at the Sovereign Default
# Boundary". Reads output/results.json; writes output/fig_*.pdf and
# output/quant_numbers.tex.

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
shade_zone <- function(zlo, zhi, ylim) {
  rect(zlo, ylim[1] - abs(ylim[1]), zhi, ylim[2] * 1.2,
       col = grDevices::adjustcolor(col_orange, 0.12), border = NA)
}

h <- r$hump
zb <- r$zones$`1.0`                      # base susceptible zone [lo, hi]
ord <- order(h$theta); th <- h$theta[ord]
dsdn10 <- h$dsdn_bp[ord] / 10            # bp per 10 pp of belief
sp <- h$spread_bp[ord]

# ------------------------------------------------------------------ fig_hump
pdfopen("fig_hump.pdf", w = 9, h = 4.3)
par(mfrow = c(1, 2))
ylim <- c(0, max(dsdn10) * 1.06)
plot(NA, xlim = c(-0.05, 0.25), ylim = ylim,
     xlab = expression("fundamentals  " * theta),
     ylab = "bp per 10 pp of belief",
     main = "(a) price relevance of the story")
shade_zone(zb[1], zb[2], ylim)
lines(th, dsdn10, lwd = 2.4, col = col_blue)
abline(v = 0, col = col_gray, lty = 3)
pts <- c(0.01, r$calibration$th_zone, 0.15)
idx <- sapply(pts, function(p) which.min(abs(th - p)))
points(th[idx], dsdn10[idx], pch = 16, col = col_red)
text(th[idx], dsdn10[idx] + 12, c("distressed", "zone", "safe"), cex = 0.75)
text(mean(zb), max(dsdn10) * 0.55, "susceptible\nzone", cex = 0.8, col = col_orange)

ylim2 <- c(0.5, 4000)
plot(NA, xlim = c(-0.05, 0.25), ylim = ylim2, log = "y",
     xlab = expression("fundamentals  " * theta),
     ylab = "spread (bp, log scale)",
     main = "(b) the zone in spread space")
rect(zb[1], 0.1, zb[2], 8000, col = grDevices::adjustcolor(col_orange, 0.12), border = NA)
lines(th, pmax(sp, 0.5), lwd = 2.4, col = col_blue)
abline(v = 0, col = col_gray, lty = 3)
dev.off()

# ------------------------------------------------------------------ fig_zone
zf <- r$zone_fig; tz <- zf$theta[ord]
pdfopen("fig_zone.pdf", w = 6.6, h = 4.5)
plot(NA, xlim = c(-0.05, 0.15), ylim = c(0, 4.3),
     xlab = expression("fundamentals  " * theta),
     ylab = expression("narrative reproduction number  " * R[0](theta)),
     main = "amplification opens the zone")
shade_zone(zb[1], zb[2], c(0, 4.3))
lines(tz, zf$R0_0.25[ord], lwd = 2.2, col = col_gray, lty = 5)
lines(tz, zf$`R0_1.0`[ord], lwd = 2.4, col = col_blue)
lines(tz, zf$R0_1.5[ord],  lwd = 2.2, col = col_red, lty = 2)
abline(h = 1, col = col_gray, lty = 3)
text(0.135, 1.12, expression(R[0] == 1), cex = 0.8, col = col_gray)
legend("topright", bty = "n", lwd = 2.2, lty = c(5, 1, 2),
       col = c(col_gray, col_blue, col_red), cex = 0.9,
       legend = c("A = 0.25 (pre-amplification)", "A = 1 (baseline)", "A = 1.5"))
dev.off()

# -------------------------------------------------------------- fig_outbreak
p <- r$paths; mo <- seq_len(length(p$zone$n))
pdfopen("fig_outbreak.pdf", w = 9.6, h = 3.6)
par(mfrow = c(1, 3), mar = c(4, 4, 2.2, 0.8))
plot(NA, xlim = c(1, 48), ylim = range(c(p$zone$a, p$zone$n)), xlab = "month",
     ylab = "share", main = "(a) awareness and belief")
lines(mo, p$zone$a, lwd = 2.4, col = col_blue)
lines(mo, p$zone$n, lwd = 2.4, col = col_orange)
legend("topleft", bty = "n", lwd = 2.4, col = c(col_blue, col_orange),
       legend = c(expression("aware  " * a[t]), expression("believing  " * n[t])),
       cex = 0.9)
plot(NA, xlim = c(1, 48), ylim = c(1, 4200), log = "y", xlab = "month",
     ylab = "spread (bp, log scale)", main = "(b) pricing the story")
lines(mo, pmax(p$safe$s, 1), lwd = 2.2, col = col_green)
lines(mo, pmax(p$safe$s0, 1), lwd = 1.6, col = col_green, lty = 5)
lines(mo, p$zone$s, lwd = 2.4, col = col_orange)
lines(mo, p$zone$s0, lwd = 1.6, col = col_orange, lty = 5)
lines(mo, p$distressed$s, lwd = 2.2, col = col_red)
lines(mo, p$distressed$s0, lwd = 1.6, col = col_red, lty = 5)
legend("bottomright", bty = "n", lwd = c(2.2, 1.6), lty = c(1, 5), col = col_gray,
       legend = c("with narrative", "counterfactual n = 0"), cex = 0.95)
plot(NA, xlim = c(1, 48), ylim = c(-0.02, 0.17), xlab = "month",
     ylab = expression("fundamentals  " * theta[t]), main = "(c) the real damage")
abline(h = 0, col = col_gray, lty = 3)
lines(mo, p$safe$th, lwd = 2.2, col = col_green)
lines(mo, p$zone$th, lwd = 2.4, col = col_orange)
lines(mo, p$zone$th0, lwd = 1.6, col = col_orange, lty = 5)
lines(mo, p$distressed$th, lwd = 2.2, col = col_red)
lines(mo, p$distressed$th0, lwd = 1.6, col = col_red, lty = 5)
dev.off()

# ---------------------------------------------------------------- fig_crisis
m <- r$mc
pdfopen("fig_crisis.pdf", w = 9, h = 4.3)
par(mfrow = c(1, 2))
plot(NA, xlim = c(0, 0.20), ylim = c(0, 1),
     xlab = expression("initial fundamentals  " * theta[0]),
     ylab = "P(default within 24 months)", main = "(a) hazard with and without the story")
shade_zone(zb[1], zb[2], c(0, 1))
lines(m$th0, m$nonarr, lwd = 2.4, col = col_blue)
lines(m$th0, m$narr, lwd = 2.4, col = col_orange)
legend("topright", bty = "n", lwd = 2.4, col = c(col_orange, col_blue), cex = 0.9,
       legend = c("narrative seeded (n = 0.02)", "no narrative"))
wn <- 100 * (m$narr - m$nonarr); wt <- 100 * (m$transp - m$nonarr)
wc <- 100 * (m$cap - m$nonarr_cap)
plot(NA, xlim = c(0, 0.20), ylim = range(c(wn, wt, wc)) * 1.1,
     xlab = expression("initial fundamentals  " * theta[0]),
     ylab = "narrative wedge (pp)", main = "(b) the wedge and its policies")
shade_zone(zb[1], zb[2], c(-1, 7))
abline(h = 0, col = col_gray, lty = 3)
lines(m$th0, wn, lwd = 2.4, col = col_orange)
lines(m$th0, wt, lwd = 2.2, col = col_green, lty = 2)
lines(m$th0, wc, lwd = 2.2, col = col_red, lty = 4)
legend("topright", bty = "n", lwd = 2.2, lty = c(1, 2, 4),
       col = c(col_orange, col_green, col_red), cex = 0.9,
       legend = c("baseline", expression("transparency  " * (gamma %*% 1.5)),
                  "spread cap 400 bp"))
dev.off()

# ---------------------------------------------------------------- fig_timing
tm <- r$timing
pdfopen("fig_timing.pdf", w = 6.6, h = 4.5)
plot(NA, xlim = c(1, 13), ylim = c(0.42, 0.75),
     xlab = "month in which the policy arrives",
     ylab = "P(default within 24 months)", main = "the price of waiting")
abline(h = tm$never, col = col_gray, lty = 3)
abline(h = tm$nonarr, col = col_blue, lty = 3)
text(3.4, tm$never - 0.012, "no intervention", cex = 0.8, col = col_gray)
text(11, tm$nonarr + 0.012, "no narrative", cex = 0.8, col = col_blue)
lines(tm$k, tm$cap_k, lwd = 2.4, col = col_red, type = "b", pch = 16)
lines(tm$k, tm$cut_k, lwd = 2.2, col = col_green, type = "b", pch = 17, lty = 2)
legend("bottomright", bty = "n", lwd = 2.2, lty = c(1, 2), pch = c(16, 17),
       col = c(col_red, col_green), cex = 0.9,
       legend = c("spread cap from month k", "one-shot deletion of 75% of n at k"))
dev.off()

# ------------------------------------------------------------------- fig_phase
ph <- r$phase
ga <- r$global_audit
pth <- ph$theta
pn <- ph$n
dth <- as.matrix(ph$dtheta)
dn <- as.matrix(ph$dn)
pdfopen("fig_phase.pdf", w = 6.8, h = 4.8)
plot(NA, xlim = range(pth), ylim = range(pn),
     xlab = expression("fundamentals  " * theta),
     ylab = expression("believing wealth share  " * n),
     main = "deterministic phase field")
contour(pth, pn, dth, levels = 0, add = TRUE, drawlabels = FALSE,
        lwd = 2.2, col = col_blue)
contour(pth, pn, dn, levels = 0, add = TRUE, drawlabels = FALSE,
        lwd = 2.2, lty = 2, col = col_orange)
for (i in seq(1, length(pth), by = 2)) {
  for (j in seq(1, length(pn), by = 2)) {
    vx <- dth[i, j]
    vy <- dn[i, j]
    norm <- sqrt((vx / 0.01)^2 + (vy / 0.05)^2)
    if (is.finite(norm) && norm > 0) {
      arrows(pth[i], pn[j], pth[i] + 0.006 * vx / (0.01 * norm),
             pn[j] + 0.03 * vy / (0.05 * norm), length = 0.05,
             col = grDevices::adjustcolor(col_gray, 0.65))
    }
  }
}
lines(p$zone$th, p$zone$n, lwd = 2.5, col = col_red)
valid_boundary <- is.finite(ga$seed_boundary) & ga$seed_boundary > 0
lines(ga$seed_theta[valid_boundary], ga$seed_boundary[valid_boundary],
      lwd = 2.3, lty = 4, col = "black")
for (row in seq_len(nrow(ga$equilibria))) {
  points(ga$equilibria$theta[row], ga$equilibria$belief[row],
         pch = ifelse(ga$equilibria$stable[row], 16, 1), cex = 1.1)
}
legend("topright", bty = "n", lwd = c(2.2, 2.2, 2.5, 2.3),
       lty = c(1, 2, 1, 4), col = c(col_blue, col_orange, col_red, "black"),
       legend = c(expression(dot(theta) == 0), expression(dot(n) == 0),
                  "seeded path", "continued seed boundary"), cex = 0.80)
dev.off()

# -------------------------------------------------------------------- macros
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d)
cal <- r$calibration
ga <- r$global_audit
z25 <- r$zones$`0.25`; z15 <- r$zones$`1.5`
sp_at <- function(x) approx(th, sp, xout = x)$y
pz <- r$paths$zone
positive_index <- which(ga$equilibria$belief > 0)[1]
stable_index <- which(ga$equilibria$stable)[1]
lower_index <- which(ga$equilibria$belief == 0 & !ga$equilibria$stable)[1]
positive_eigen <- unlist(ga$equilibria$eigen_real[[positive_index]])
stable_eigen <- unlist(ga$equilibria$eigen_real[[stable_index]])
zone_audit <- ga$zone_seed_audit
seed_horizon_diff <- max(abs(c(zone_audit$horizon_120, zone_audit$horizon_360) -
                               zone_audit$horizon_240), na.rm = TRUE)
seed_step_diff <- max(abs(c(zone_audit$substeps_8, zone_audit$substeps_32) -
                          zone_audit$substeps_16), na.rm = TRUE)

lines_out <- c(
  sprintf("\\newcommand{\\GainMax}{%s}", fmt(cal$gainmax, 2)),
  sprintf("\\newcommand{\\MultPeak}{%s}", fmt(cal$multpeak, 1)),
  sprintf("\\newcommand{\\ShiftVal}{%s}", fmt(cal$shift, 2)),
  sprintf("\\newcommand{\\RelPeakTen}{%s}", fmt(cal$dsdn10_peak_bp, 0)),
  sprintf("\\newcommand{\\RelZoneTen}{%s}", fmt(cal$dsdn10_zone_bp, 0)),
  sprintf("\\newcommand{\\RelSafeTen}{%s}", fmt(cal$dsdn10_safe_bp, 1)),
  sprintf("\\newcommand{\\ZoneLo}{%s}", fmt(zb[1], 3)),
  sprintf("\\newcommand{\\ZoneHi}{%s}", fmt(zb[2], 3)),
  sprintf("\\newcommand{\\ZoneSpreadLo}{%s}", fmt(sp_at(zb[2]), 0)),
  sprintf("\\newcommand{\\ZoneSpreadHi}{%s}", fmt(sp_at(zb[1]), 0)),
  sprintf("\\newcommand{\\ZoneWidthPre}{%s}", fmt(z25[2] - z25[1], 3)),
  sprintf("\\newcommand{\\ZoneHiAmp}{%s}", fmt(z15[2], 3)),
  sprintf("\\newcommand{\\SZoneBase}{%s}", fmt(cal$s_zone_bp, 0)),
  sprintf("\\newcommand{\\PeakN}{%s}", fmt(100 * r$peak_n, 0)),
  sprintf("\\newcommand{\\PeakExcess}{%s}", fmt(r$peak_excess_bp, 0)),
  sprintf("\\newcommand{\\ZoneDefMonth}{%s}", fmt(ga$zone_default_month, 0)),
  sprintf("\\newcommand{\\WedgePeak}{%s}", fmt(100 * m$wedge_peak, 1)),
  sprintf("\\newcommand{\\WedgeArg}{%s}", fmt(m$wedge_argmax, 2)),
  sprintf("\\newcommand{\\WedgeSafe}{%s}", fmt(100 * m$wedge_safe, 2)),
  sprintf("\\newcommand{\\WedgeTransp}{%s}", fmt(100 * m$wedge_transp, 1)),
  sprintf("\\newcommand{\\WedgeCap}{%s}", fmt(100 * m$wedge_cap, 1)),
  sprintf("\\newcommand{\\FundReliefCap}{%s}", fmt(100 * m$fund_relief_cap, 1)),
  sprintf("\\newcommand{\\PNoNarr}{%s}", fmt(100 * tm$nonarr, 1)),
  sprintf("\\newcommand{\\PNever}{%s}", fmt(100 * tm$never, 1)),
  sprintf("\\newcommand{\\PCapEarly}{%s}", fmt(100 * tm$cap_k[1], 1)),
  sprintf("\\newcommand{\\PCapLate}{%s}", fmt(100 * tm$cap_k[length(tm$cap_k)], 1)),
  sprintf("\\newcommand{\\DelayCost}{%s}", fmt(100 * (tm$cap_k[length(tm$cap_k)] - tm$cap_k[1]), 0)),
  sprintf("\\newcommand{\\CutSaveMax}{%s}", fmt(100 * (tm$never - min(tm$cut_k)), 1)),
  sprintf("\\newcommand{\\RhoVal}{%s}", fmt(cal$rho, 2)),
  sprintf("\\newcommand{\\SigVal}{%s}", fmt(cal$sig, 2)),
  sprintf("\\newcommand{\\XiVal}{%s}", fmt(cal$xi, 2)),
  sprintf("\\newcommand{\\ChiVal}{%s}", fmt(cal$chi, 2)),
  sprintf("\\newcommand{\\GamAVal}{%s}", fmt(cal$gamma_a, 2)),
  sprintf("\\newcommand{\\GamNVal}{%s}", fmt(cal$gamma_n, 2)),
  sprintf("\\newcommand{\\AcceptVal}{%s}", fmt(cal$acceptance, 2)),
  sprintf("\\newcommand{\\RZeroPeak}{%s}", fmt(cal$r0peak, 0)),
  sprintf("\\newcommand{\\SeedVal}{%s}", fmt(cal$n0, 2)),
  sprintf("\\newcommand{\\AwareSeedVal}{%s}", fmt(cal$a0, 2)),
  sprintf("\\newcommand{\\SeedThresholdPct}{%s}",
          fmt(100 * zone_audit$horizon_240, 2)),
  sprintf("\\newcommand{\\SeedHorizonDiff}{%s}", fmt(100 * seed_horizon_diff, 3)),
  sprintf("\\newcommand{\\SeedStepDiff}{%s}", fmt(100 * seed_step_diff, 3)),
  sprintf("\\newcommand{\\EquilibriumCount}{%s}", nrow(ga$equilibria)),
  sprintf("\\newcommand{\\LowerRoot}{%s}",
          fmt(ga$equilibria$theta[lower_index], 4)),
  sprintf("\\newcommand{\\SaddleTheta}{%s}",
          fmt(ga$equilibria$theta[positive_index], 4)),
  sprintf("\\newcommand{\\SaddleAwarePct}{%s}",
          fmt(100 * ga$equilibria$awareness[positive_index], 1)),
  sprintf("\\newcommand{\\SaddleBeliefPct}{%s}",
          fmt(100 * ga$equilibria$belief[positive_index], 1)),
  sprintf("\\newcommand{\\StableTheta}{%s}",
          fmt(ga$equilibria$theta[stable_index], 4)),
  sprintf("\\newcommand{\\SaddleEigen}{%s}", fmt(max(positive_eigen), 4)),
  sprintf("\\newcommand{\\StableEigen}{%s}", fmt(max(stable_eigen), 4))
  ,sprintf("\\newcommand{\\HumpMargin}{%s}", fmt(cal$hump_margin, 3))
  ,sprintf("\\newcommand{\\SigMonth}{%s}", fmt(cal$sigm, 4))
  ,sprintf("\\newcommand{\\ChiMonth}{%s}", fmt(cal$chim, 4))
)
writeLines(lines_out, file.path(out, "quant_numbers.tex"))
cat("wrote", length(lines_out), "macros and 6 figures\n")
