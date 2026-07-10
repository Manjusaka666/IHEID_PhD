# Sanctions Risk and Dollar Convenience: figures and number macros.
# Reads output/results.json (from solve_model.jl) and writes journal-style
# PDF figures plus output/quant_numbers.tex.
# Run from code/:  Rscript make_figures.R

suppressMessages(library(jsonlite))

out_dir <- file.path(dirname(sub("--file=", "", grep("--file=", commandArgs(FALSE), value = TRUE))), "..", "output")
r <- fromJSON(file.path(out_dir, "results.json"), simplifyVector = TRUE)

col_base <- "#0072B2"; col_lo <- "#8C8C8C"; col_hi <- "#D55E00"
col_re <- "#000000"; col_good <- "#009E73"; col_gray <- "#8C8C8C"

pdf_one <- function(file, w = 6.4, h = 4.4) {
  pdf(file.path(out_dir, file), width = w, height = h, pointsize = 10)
  par(mar = c(4.2, 4.4, 1.4, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
}

## ---- Figure 1: transition of N and the convenience yield ------------------
p10 <- r$paths$`m_1.0`; p15 <- r$paths$`m_1.5`; p25 <- r$paths$`m_2.5`
yrs <- 0:(length(p15$N) - 1)
pdf(file.path(out_dir, "fig_transition.pdf"), width = 9.2, height = 3.8, pointsize = 10)
par(mfrow = c(1, 2), mar = c(4.2, 4.4, 2.0, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
plot(yrs, p15$N * 100, type = "l", lwd = 2, col = col_base,
     xlab = "years since reassessment", ylab = "dollar share of reserves (percent)",
     main = "(a) network size", ylim = range(c(p10$N, p25$N)) * 100)
lines(yrs, p10$N * 100, lwd = 2, col = col_lo, lty = 2)
lines(yrs, p25$N * 100, lwd = 2, col = col_hi, lty = 4)
legend("topright", bty = "n", lwd = 2, lty = c(2, 1, 4),
       col = c(col_lo, col_base, col_hi),
       legend = c("multiplier 1.0", "multiplier 1.5 (baseline)", "multiplier 2.5"))
plot(yrs, p15$cy * 1e4, type = "l", lwd = 2, col = col_base,
     xlab = "years since reassessment", ylab = "convenience yield (bp)",
     main = "(b) convenience yield", ylim = range(c(p10$cy, p25$cy)) * 1e4)
lines(yrs, p10$cy * 1e4, lwd = 2, col = col_lo, lty = 2)
lines(yrs, p25$cy * 1e4, lwd = 2, col = col_hi, lty = 4)
invisible(dev.off())

## ---- Figure 2: the network fingerprint (exposed vs aligned) ---------------
pdf_one("fig_spillover.pdf")
plot(yrs, p15$aE * 100, type = "l", lwd = 2, col = col_hi,
     xlab = "years since reassessment", ylab = "dollar share (percent)",
     ylim = range(c(p15$aE, p15$aA)) * 100)
lines(yrs, p15$aA * 100, lwd = 2, col = col_base)
lines(yrs, p10$aA * 100, lwd = 2, col = col_gray, lty = 3)
legend("topright", bty = "n", lwd = 2, lty = c(1, 1, 3),
       col = c(col_hi, col_base, col_gray),
       legend = c("exposed countries", "aligned countries",
                  "aligned, no network externality"))
invisible(dev.off())

## ---- Figure 3: the sanctions-use frontier ---------------------------------
lf <- r$frontier
pdf(file.path(out_dir, "fig_frontier.pdf"), width = 9.2, height = 3.8, pointsize = 10)
par(mfrow = c(1, 2), mar = c(4.2, 4.4, 2.0, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
plot(lf$p, lf$v_weaponize, type = "l", lwd = 2, col = col_hi,
     xlab = "breadth of use  p", ylab = "hegemon flow value (bn USD / yr)",
     main = "(a) sanctions-use frontier", ylim = range(c(lf$v_weaponize, lf$v_restraint)))
lines(lf$p, lf$v_restraint, lwd = 2, col = col_base, lty = 2)
abline(v = r$calibration$p_single, col = col_gray, lty = 3)
text(r$calibration$p_single + 0.008, max(lf$v_weaponize) - 1, "single use", adj = 0, cex = 0.8, col = col_gray)
legend("bottomleft", bty = "n", lwd = 2, lty = c(1, 2), col = c(col_hi, col_base),
       legend = c(expression(paste("weaponization  (", bar(s) == 1, ")")),
                  expression(paste("restraint  (", bar(s) == 0, ")"))))
plot(lf$p, lf$s_R, type = "l", lwd = 2, col = col_base,
     xlab = "breadth of use  p", ylab = expression(paste("Ramsey intensity  ", s[R])),
     main = "(b) optimal rule by breadth", ylim = c(0, 1))
abline(h = 1, col = col_hi, lty = 2)
text(0.35, 0.96, "discretion", col = col_hi, cex = 0.85)
invisible(dev.off())

## ---- Figure 4: the weaponization bias --------------------------------------
gams <- c(50, 100, 200, 400, 800)
sR_g <- sapply(gams, function(g) r$policy[[paste0("gam_", g)]]$s_R)
pvs  <- sapply(gams, function(g) r$policy[[paste0("gam_", g)]]$commit_pv_bn)
ms <- c(1.0, 1.25, 1.5, 2.0, 2.5, 3.0)
ms_keys <- c("m_1.0", "m_1.25", "m_1.5", "m_2.0", "m_2.5", "m_3.0")
sR_m <- sapply(ms_keys, function(k) r$p5[[k]]$s_R)
pdf(file.path(out_dir, "fig_bias.pdf"), width = 9.2, height = 3.8, pointsize = 10)
par(mfrow = c(1, 2), mar = c(4.2, 4.4, 2.0, 0.8), mgp = c(2.6, 0.8, 0), las = 1)
plot(gams, sR_g, type = "b", pch = 19, lwd = 2, col = col_base, log = "x",
     xlab = "geopolitical stakes  (bn USD per crisis)", ylab = "sanction intensity",
     main = "(a) rule vs. discretion, by stakes", ylim = c(0, 1.05))
abline(h = 1, col = col_hi, lty = 2)
text(90, 1.03, "discretion", col = col_hi, cex = 0.85)
plot(ms, sR_m, type = "b", pch = 19, lwd = 2, col = col_base,
     xlab = "network multiplier  m", ylab = "sanction intensity",
     main = "(b) Ramsey intensity by network elasticity", ylim = c(0, 1.05))
abline(h = 1, col = col_hi, lty = 2)
invisible(dev.off())

## ---- quant_numbers.tex ------------------------------------------------------
fmt <- function(x, d = 1) formatC(x, format = "f", digits = d, big.mark = ",")
fmt0 <- function(x) formatC(round(x), format = "d", big.mark = ",")
cal <- r$calibration
ssx <- r$ss
mm <- r$multiplier
pol <- r$policy$gam_200
lines_out <- c(
  sprintf("\\newcommand{\\KappaBP}{%s}", fmt(cal$kappa * 1e4, 0)),
  sprintf("\\newcommand{\\LZeroBP}{%s}", fmt(cal$l0 * 1e4, 0)),
  sprintf("\\newcommand{\\LOneBP}{%s}", fmt(cal$l1 * 1e4, 0)),
  sprintf("\\newcommand{\\NuVal}{%s}", fmt(cal$nu, 3)),
  sprintf("\\newcommand{\\LamN}{%s}", fmt(cal$lamN, 2)),
  sprintf("\\newcommand{\\HalfLifeD}{%s}", fmt(log(0.5) / log(cal$lamD), 1)),
  sprintf("\\newcommand{\\PiHatBP}{%s}", fmt(cal$pihat_single * 1e4, 1)),
  sprintf("\\newcommand{\\NPre}{%s}", fmt(ssx$pre$N * 100, 0)),
  sprintf("\\newcommand{\\CYPre}{%s}", fmt(ssx$pre$cy * 1e4, 0)),
  sprintf("\\newcommand{\\PrivPre}{%s}", fmt(ssx$pre$priv, 1)),
  sprintf("\\newcommand{\\NPostSingle}{%s}", fmt(ssx$post_single$N * 100, 1)),
  sprintf("\\newcommand{\\CYPostSingle}{%s}", fmt(ssx$post_single$cy * 1e4, 1)),
  sprintf("\\newcommand{\\PrivPostSingle}{%s}", fmt(ssx$post_single$priv, 1)),
  sprintf("\\newcommand{\\AEPostSingle}{%s}", fmt(ssx$post_single$aE * 100, 1)),
  sprintf("\\newcommand{\\AAPostSingle}{%s}", fmt(ssx$post_single$aA * 100, 1)),
  sprintf("\\newcommand{\\DNSinglePP}{%s}", fmt(abs(mm$`m_1.5`$dN_pp), 1)),
  sprintf("\\newcommand{\\DCYSingleBP}{%s}", fmt(abs(mm$`m_1.5`$dcy_bp), 1)),
  sprintf("\\newcommand{\\DPrivSingleBN}{%s}", fmt(abs(mm$`m_1.5`$dpriv_bn), 1)),
  sprintf("\\newcommand{\\DAEPP}{%s}", fmt(abs(mm$`m_1.5`$daE_pp), 1)),
  sprintf("\\newcommand{\\DAAPP}{%s}", fmt(abs(mm$`m_1.5`$daA_pp), 1)),
  sprintf("\\newcommand{\\DNLowPP}{%s}", fmt(abs(mm$`m_1.0`$dN_pp), 1)),
  sprintf("\\newcommand{\\DNHighPP}{%s}", fmt(abs(mm$`m_2.5`$dN_pp), 1)),
  sprintf("\\newcommand{\\DPrivHighBN}{%s}", fmt(abs(mm$`m_2.5`$dpriv_bn), 1)),
  sprintf("\\newcommand{\\NPostRoutine}{%s}", fmt(ssx$post_routine$N * 100, 1)),
  sprintf("\\newcommand{\\CYPostRoutine}{%s}", fmt(ssx$post_routine$cy * 1e4, 0)),
  sprintf("\\newcommand{\\PrivPostRoutine}{%s}", fmt(ssx$post_routine$priv, 1)),
  sprintf("\\newcommand{\\DPrivRoutineBN}{%s}", fmt(ssx$pre$priv - ssx$post_routine$priv, 1)),
  sprintf("\\newcommand{\\PRoutine}{%s}", fmt(ssx$p_routine * 100, 0)),
  sprintf("\\newcommand{\\DNSoftPP}{%s}", fmt((ssx$pre$N - ssx$post_soft$N) * 100, 1)),
  sprintf("\\newcommand{\\SRBase}{%s}", fmt(pol$s_R, 2)),
  sprintf("\\newcommand{\\BiasBase}{%s}", fmt(pol$bias, 2)),
  sprintf("\\newcommand{\\CommitFlowBase}{%s}", fmt(pol$commit_flow_bn, 1)),
  sprintf("\\newcommand{\\CommitPVBase}{%s}", fmt0(pol$commit_pv_bn)),
  sprintf("\\newcommand{\\SRGamFifty}{%s}", fmt(r$policy$gam_50$s_R, 2)),
  sprintf("\\newcommand{\\CommitPVGamFifty}{%s}", fmt0(r$policy$gam_50$commit_pv_bn)),
  sprintf("\\newcommand{\\SRGamEightH}{%s}", fmt(r$policy$gam_800$s_R, 2)),
  sprintf("\\newcommand{\\SRMOne}{%s}", fmt(r$p5$`m_1.0`$s_R, 2)),
  sprintf("\\newcommand{\\SRMThree}{%s}", fmt(r$p5$`m_3.0`$s_R, 2)),
  sprintf("\\newcommand{\\DNOutsidePP}{%s}", fmt(abs(r$outside$dN_pp), 1)),
  sprintf("\\newcommand{\\DPrivOutsideBN}{%s}", fmt(abs(r$outside$dpriv_bn), 1)),
  sprintf("\\newcommand{\\HalfLife}{%s}", fmt(r$calibration$half_life, 0)),
  sprintf("\\newcommand{\\GammaBase}{%s}", fmt0(r$calibration$gamma)),
  sprintf("\\newcommand{\\WReserves}{%s}", fmt0(r$calibration$W / 1000))
)
gt <- r$geopolitical_thresholds$`zeta_0.5_chi_1.0`
lines_out <- c(lines_out,
  sprintf("\\newcommand{\\ZetaH}{%s}", fmt(r$calibration$zeta_h, 2)),
  sprintf("\\newcommand{\\GammaThresholdSingle}{%s}", fmt(gt$gamma_at_p_0.02, 1)),
  sprintf("\\newcommand{\\GammaThresholdTen}{%s}", fmt(gt$gamma_at_p_0.10, 1)),
  sprintf("\\newcommand{\\GammaThresholdRoutine}{%s}", fmt(gt$gamma_at_p_0.25, 1)))
# break-even breadth: weaponization value = restraint value
dv <- lf$v_weaponize - lf$v_restraint
i <- which(dv <= 0)[1]
pbe <- lf$p[i - 1] + (lf$p[i] - lf$p[i - 1]) * dv[i - 1] / (dv[i - 1] - dv[i])
lines_out <- c(lines_out,
  sprintf("\\newcommand{\\PBreakEven}{%s}", fmt(pbe * 100, 1)))
writeLines(lines_out, file.path(out_dir, "quant_numbers.tex"))
cat("wrote", length(lines_out), "macros and 4 figures\n")
