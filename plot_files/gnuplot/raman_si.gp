# ── raman_si.gp ───────────────────────────────────────────────────────
# Silicon 520 cm-1 Raman peak: Lorentzian fit, publication output
# Usage (interactive):  gnuplot raman_si.gp
# Usage (export):       gnuplot -e "MODE='pdf'" raman_si.gp
#                       gnuplot -e "MODE='png'" raman_si.gp
#                       gnuplot -e "MODE='bw';  OUT='fig_si'" raman_si.gp

# ── Load libraries ────────────────────────────────────────────────────
load "style_publication.gp"
load "math.gp"
load "units.gp"
load "arrows.gp"

# ── Inputs ────────────────────────────────────────────────────────────
if (!exists("DATAFILE")) { DATAFILE = "raman_data.dat" }
if (!exists("OUT"))      { OUT      = "raman_si"       }
if (!exists("MODE"))     { MODE     = "interactive"    }
if (!exists("XMIN"))     { XMIN     = 490              }
if (!exists("XMAX"))     { XMAX     = 550              }

# ── Terminal selection ────────────────────────────────────────────────
if (MODE eq "interactive") {
    set terminal wxt noraise enhanced font "Sans,11" persist
} else { if (MODE eq "pdf") {
    set terminal pdfcairo transparent enhanced color \
        font "Helvetica,11" size 8cm,6cm
    set output OUT.".pdf"
} else { if (MODE eq "bw") {
    set terminal pdfcairo transparent enhanced monochrome \
        font "Helvetica,11" size 8cm,6cm
    set output OUT.".pdf"
    load "style_bw.gp"
} else { if (MODE eq "png") {
    set terminal pngcairo enhanced color \
        font "Helvetica,11" size 960,720 dpi 300
    set output OUT.".png"
}}}}

# ── Axes ──────────────────────────────────────────────────────────────
set xlabel XLABEL_RAMAN
set ylabel YLABEL_INTENSITY
set title  ""
set xrange [XMIN:XMAX]
set yrange [0:*]
set key top left

# ── Fit setup ─────────────────────────────────────────────────────────
set fit quiet
set fit errorvariables
set fit covariancevariables  # Matches the {{no}covariancevariables} in help
FIT_LIMIT = 1e-9

# Model: Lorentzian from math.gp + linear background
# L(x, A, x0, gam): A=amplitude  x0=center  gam=HWHM
f(x) = L(x, A1, x0, gam) + BG(x, m, c)

# Initial guesses
A1  = 230.0
x0  = 520.0
gam = 2.5
m   = 0.01
c   = 10.0

fit f(x) DATAFILE u 1:2 via A1, x0, gam, m, c

# ── Derived quantities ────────────────────────────────────────────────
FWHM = L_fwhm(gam)
AREA = L_area(A1, gam)

print ""
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print "  Fit Results: Si Raman 520 cm-1"
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print sprintf("  Peak position : %.4f ± %.4f cm^-1", x0,   x0_err)
print sprintf("  FWHM          : %.4f ± %.4f cm^-1", FWHM, 2*gam_err)
print sprintf("  Amplitude     : %.2f  ± %.2f",       A1,   A1_err)
print sprintf("  Area          : %.2f",                AREA)
print sprintf("  Background    : slope=%.5f  intercept=%.3f", m, c)
print sprintf("  FIT_STDFIT    : %.6f", FIT_STDFIT)

# Safely handle covariance output
if (exists("FIT_COV_x0_gam")) {
    print sprintf("  Covariance x0,gam : %.6f", FIT_COV_x0_gam)
} else {
    print "  Covariance x0,gam : Not calculated"
}
print "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
print ""

# ── Annotations ───────────────────────────────────────────────────────
# Peak position: dashed vertical marker (arrowstyle 3 from arrows.gp)
set arrow 1 from x0, 0 to x0, A1*0.92 arrowstyle 3

# Peak label above marker
set label 1 sprintf("%.2f cm^{-1}", x0) \
    at x0+1.0, A1*0.96 left font ",10" tc rgb "#222222"

# FWHM double-headed bracket at half-maximum
set arrow 2 from x0-gam, A1*0.5 to x0+gam, A1*0.5 arrowstyle 2
set label 2 sprintf("FWHM = %.2f cm^{-1}", FWHM) \
    at x0, A1*0.5+A1*0.07 center font ",9" tc rgb "#555555"

# Fit stats: bottom-right corner
set label 3 \
    sprintf("x_0 = %.3f ± %.3f cm^{-1}\nΓ   = %.3f ± %.3f cm^{-1}\nR²  ~ %.4f", \
    x0, x0_err, FWHM, 2*gam_err, 1.0 - FIT_STDFIT**2) \
    at graph 0.97, 0.22 right font ",9" tc rgb "#333333"

# ── Plot ──────────────────────────────────────────────────────────────
# Layer order: filled area → background → total fit → data points on top
plot DATAFILE u 1:2 \
         w points lt 1 ps 0.6 t "Data", \
     f(x) \
         w filledcurves y1=0 \
         lc rgb "#4477AA" fs transparent solid 0.15 noborder \
         t "Fit area", \
     BG(x, m, c) \
         w lines lt 7 lw 1.2 dt 3 \
         t "Background", \
     f(x) \
         w lines lt 2 lw 2.5 \
         t "Lorentzian fit"

# ── Cleanup ───────────────────────────────────────────────────────────
if (MODE ne "interactive") {
    unset output
    print ">>> Exported: ".OUT.(MODE eq "png" ? ".png" : ".pdf")
} else {
    pause -1 "  [interactive] press Enter to close"
}