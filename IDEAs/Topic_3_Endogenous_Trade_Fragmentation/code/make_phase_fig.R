# Phase diagram of the fold-driving (theta, chi) plane for the fragmentation
# paper. Reads output/phase_grid.csv (written by
# code/phase_diagram.jl); writes output/fig_phase.pdf.
#
# Standalone companion to make_figures.R: base R only (no ggplot2), matching that
# script's palette, fonts (pointsize 10), and pdf/par conventions.
#
# theta = deterred share (share of escalations deterred by an intact sector);
# chi   = capacity-scale elasticity (premium compression as friendly capacity
#         scales). Cells are classified: 0 monotone (no fold), 1 fold ahead
#         (post-2022 hazard delta = 0.10 below the upper fold), 2 past the fold.

root <- normalizePath(file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), ".."))
out <- file.path(root, "output")
d <- read.csv(file.path(out, "phase_grid.csv"))

# shared palette (identical to make_figures.R)
col_blue <- "#1268b3"; col_orange <- "#d55e00"; col_green <- "#009e73"
col_gray <- "#666666"; col_red <- "#c0392b"

# three class shades, read as a rising-danger sequence
fill_mono <- grDevices::adjustcolor(col_green,  0.22)   # safely monotone
fill_fold <- grDevices::adjustcolor(col_orange, 0.45)   # fold ahead of 0.10
fill_past <- grDevices::adjustcolor(col_red,    0.70)   # 0.10 already past the fold

# reshape long -> matrix z[theta, chi]
thetas <- sort(unique(round(d$theta, 2)))
chis   <- sort(unique(round(d$chi, 2)))
z <- matrix(NA_integer_, length(thetas), length(chis))
for (k in seq_len(nrow(d))) {
  i <- match(round(d$theta[k], 2), thetas)
  j <- match(round(d$chi[k], 2), chis)
  z[i, j] <- d$class[k]
}

dth <- diff(thetas)[1]; dch <- diff(chis)[1]

pdf(file.path(out, "fig_phase.pdf"), width = 6.4, height = 5.4, pointsize = 10)
par(mar = c(4, 4.2, 2.6, 1), mgp = c(2.5, 0.7, 0), las = 1)

plot(NA, xlim = range(thetas) + c(-dth, dth) / 2,
     ylim = range(chis) + c(-dch, dch) / 2, xaxs = "i", yaxs = "i",
     xlab = expression("deterred share  " * theta),
     ylab = expression("capacity-scale elasticity  " * chi),
     main = "Where the fold lives in the deterrence-capacity plane")

# filled cells
palette3 <- c(fill_mono, fill_fold, fill_past)
for (i in seq_along(thetas)) for (j in seq_along(chis)) {
  rect(thetas[i] - dth / 2, chis[j] - dch / 2,
       thetas[i] + dth / 2, chis[j] + dch / 2,
       col = palette3[z[i, j] + 1], border = NA)
}

# faint cell grid for legibility
abline(v = thetas[-length(thetas)] + dth / 2, col = "#ffffff", lwd = 0.4)
abline(h = chis[-length(chis)] + dch / 2, col = "#ffffff", lwd = 0.4)

# class boundaries: crisp segments along shared edges of differing cells
for (i in seq_along(thetas)) for (j in seq_along(chis)) {
  if (i < length(thetas) && z[i + 1, j] != z[i, j])
    segments(thetas[i] + dth / 2, chis[j] - dch / 2,
             thetas[i] + dth / 2, chis[j] + dch / 2, lwd = 1.8, col = col_gray)
  if (j < length(chis) && z[i, j + 1] != z[i, j])
    segments(thetas[i] - dth / 2, chis[j] + dch / 2,
             thetas[i] + dth / 2, chis[j] + dch / 2, lwd = 1.8, col = col_gray)
}
box()

# post-2022 baseline calibration (theta = 0.6, chi = 0.4)
points(0.6, 0.4, pch = 21, bg = "white", col = "black", cex = 1.5, lwd = 1.8)
points(0.6, 0.4, pch = 20, col = "black", cex = 0.7)
text(0.6, 0.4, labels = "baseline\n(0.6, 0.4)", pos = 4, offset = 0.6,
     cex = 0.78, font = 2)

# the 16 sensitivity-table cells (Table 3): theta in {.4,.5,.6,.7} x chi in {0,.2,.4,.6}
sth <- c(0.4, 0.5, 0.6, 0.7); sch <- c(0.0, 0.2, 0.4, 0.6)
gr <- expand.grid(th = sth, ch = sch)
points(gr$th, gr$ch, pch = 3, col = col_gray, cex = 0.55, lwd = 0.9)
# the single past-fold table cell the paper flags (theta = 0.4, chi = 0.6)
points(0.4, 0.6, pch = 1, col = col_red, cex = 1.7, lwd = 1.8)

legend("bottomleft", inset = 0.015, bg = "white", box.col = col_gray, cex = 0.78,
       fill = c(fill_mono, fill_fold, fill_past), border = NA,
       legend = c("monotone (no fold)",
                  expression("fold ahead  " * (delta[post] < delta[hi]^"*")),
                  expression("past the fold  " * (delta[post] >= delta[hi]^"*"))))
legend("bottomright", inset = 0.015, bg = "white", box.col = col_gray, cex = 0.72,
       pch = c(21, 3, 1), pt.cex = c(1.3, 0.6, 1.4), pt.lwd = c(1.6, 0.9, 1.6),
       col = c("black", col_gray, col_red), pt.bg = c("white", NA, NA),
       legend = c("baseline calibration", "Table 3 cells",
                  expression("Table 3 past-fold cell")))

dev.off()
cat("wrote fig_phase.pdf\n")
