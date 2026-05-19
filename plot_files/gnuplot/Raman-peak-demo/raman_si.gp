# ══════════════════════════════════════════════════════════════════════════════
# raman_si.gp  —  Si 520 cm⁻¹ Raman peak · Lorentzian fit
# Self-contained (no external library files needed).
#
# Usage:
#   gnuplot raman_si.gp                          →  raman_si.pdf  (default)
#   gnuplot -e "MODE='png'" raman_si.gp          →  raman_si.png
#   gnuplot -e "MODE='interactive'" raman_si.gp  →  wxt window
# ══════════════════════════════════════════════════════════════════════════════

# ── I/O defaults ──────────────────────────────────────────────────────────────
if (!exists("DATAFILE")) { DATAFILE = "raman_data.dat" }
if (!exists("OUT"))      { OUT      = "raman_si"       }
if (!exists("MODE"))     { MODE     = "pdf"            }
if (!exists("XMIN"))     { XMIN     = 492              }
if (!exists("XMAX"))     { XMAX     = 548              }

# ── Wong colour palette (colour-blind safe) ────────────────────────────────────
C_BLUE   = "#0072B2"
C_ORANGE = "#E69F00"
C_GREY   = "#999999"
C_FILL   = "#56B4E9"
C_DKGREY = "#333333"
C_MDGREY = "#777777"

FF = "Helvetica"
FS = 10

# ── Terminal ──────────────────────────────────────────────────────────────────
if (MODE eq "interactive") {
    set terminal wxt noraise enhanced font FF.",".FS persist
} else { if (MODE eq "png") {
    set terminal pngcairo enhanced color font FF.",".FS size 1200,900 dpi 300
    set output OUT.".png"
} else {
    set terminal pdfcairo transparent enhanced color font FF.",".FS size 8.5cm,6.5cm linewidth 1.0
    set output OUT.".pdf"
}}

# ── Margins ───────────────────────────────────────────────────────────────────
set lmargin at screen 0.14
set rmargin at screen 0.96
set bmargin at screen 0.13
set tmargin at screen 0.97

# ── Axes ──────────────────────────────────────────────────────────────────────
set xlabel "Raman shift (cm^{-1})" font FF.",".FS offset 0,0.4
set ylabel "Intensity (arb. units)" font FF.",".FS offset 1.8,0

set xrange [XMIN:XMAX]
set yrange [0:280]
set xtics 10 nomirror out scale 0.6,0.3
set ytics 50 nomirror out scale 0.6,0.3
set mxtics 5
set mytics 5
set grid xtics ytics lt 0 lw 0.3 lc rgb "#dddddd"
set border 3 lw 0.8 lc rgb "#444444"

# ── Legend ────────────────────────────────────────────────────────────────────
set key top right width -1 height 0.4 spacing 1.4 samplen 2.5 box lw 0.5 lc rgb "#bbbbbb" font FF.",9"

# ── Line/point styles ─────────────────────────────────────────────────────────
set style line 1  lc rgb C_BLUE   pt 7  ps 0.55 lw 1.0
set style line 2  lc rgb C_ORANGE lw 2.0 lt 1
set style line 3  lc rgb C_GREY   lw 1.1 lt 2 dt (6,3)
set style line 10 lc rgb C_DKGREY lw 0.8 lt 2 dt (4,3)
set style line 11 lc rgb C_MDGREY lw 1.0 lt 1

# ── Fit model ─────────────────────────────────────────────────────────────────
L(x, A, xc, g) = A * g**2 / ((x - xc)**2 + g**2)
f(x) = L(x, A1, x0, gam) + c
A1=230.0; x0=520.0; gam=3.0; c=12.0
set fit quiet
set fit errorvariables
FIT_LIMIT = 1e-10
fit f(x) DATAFILE u 1:2 via A1,x0,gam,c

# ── Derived quantities ────────────────────────────────────────────────────────
FWHM     = 2.0 * abs(gam)
FWHM_err = 2.0 * gam_err
AREA     = pi * A1 * abs(gam)

# Proper R²
stats DATAFILE u 2 name "S" nooutput
ymean  = S_mean
SS_tot = S_sumsq - S_records * S_mean**2

set table $RES
    plot DATAFILE u 1:($2 - f($1)) w table
unset table
stats $RES u 2 name "E" nooutput
SS_res = E_sumsq
Rsq = 1.0 - SS_res / SS_tot

# ── Console summary ───────────────────────────────────────────────────────────
print ""
print "==================================="
print "  Si 520 cm-1 Raman / Lorentzian"
print "==================================="
print sprintf("  x0   = %.4f +/- %.4f cm-1", x0,   x0_err)
print sprintf("  FWHM = %.4f +/- %.4f cm-1", FWHM, FWHM_err)
print sprintf("  A    = %.2f  +/- %.2f",      A1,   A1_err)
print sprintf("  BG   = %.3f (const.)",        c)
print sprintf("  Area = %.2f  (arb.)",          AREA)
print sprintf("  R2   = %.6f",                  Rsq)
print "==================================="
print ""

# ── Annotations ───────────────────────────────────────────────────────────────
set arrow 1 from x0, c to x0, A1+c nohead ls 10 front

set label 1 sprintf("{/=8.5 %.2f cm^{-1}}", x0) \
    at x0+0.6, A1+c+11 left font FF tc rgb C_DKGREY front

HM = c + A1*0.5
set arrow 2 from x0-abs(gam), HM to x0+abs(gam), HM \
    heads size 0.5,20 ls 11 front

set label 2 sprintf("{/=8 FWHM = %.2f cm^{-1}}", FWHM) \
    at x0, HM+11 center font FF tc rgb C_MDGREY front

set label 3 \
    sprintf("{/=8.5 {/Helvetica-Oblique x}_{0} = %.3f +/- %.3f cm^{-1}}\n{/=8.5 {/Symbol G} = %.3f +/- %.3f cm^{-1}}\n{/=8.5 {/Helvetica-Oblique R}^{2} = %.5f}", \
    x0, x0_err, FWHM, FWHM_err, Rsq) \
    at graph 0.97, 0.24 right font FF tc rgb C_DKGREY front

# ── Plot ──────────────────────────────────────────────────────────────────────
set style fill transparent solid 0.18 noborder

plot \
    f(x)         w filledcurves y1=0 lc rgb C_FILL t "", \
    c            w lines ls 3 t "Background", \
    f(x)         w lines ls 2 t "Lorentzian fit", \
    DATAFILE u 1:2 w points ls 1 t "Data"

# ── Close output ──────────────────────────────────────────────────────────────
if (MODE ne "interactive") {
    unset output
    print sprintf(">>> Saved: %s.%s", OUT, (MODE eq "png" ? "png" : "pdf"))
} else {
    pause -1 "  [interactive] press Enter to close"
}
