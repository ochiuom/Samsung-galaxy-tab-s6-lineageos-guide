# ══════════════════════════════════════════════════════════════════════════════
# cavendish.gp — Cavendish torsion pendulum
#                Damped sinusoid fit + residuals panel
#
# Usage:
#   gnuplot cavendish.gp                         → cavendish.pdf (default)
#   gnuplot -e "MODE='png'" cavendish.gp         → cavendish.png
#   gnuplot -e "MODE='interactive'" cavendish.gp → wxt live window
#
# Outputs: cavendish.pdf (or .png)  +  cavendish_fit.dat
# ══════════════════════════════════════════════════════════════════════════════

if (!exists("DATAFILE")) { DATAFILE = "cavendish.data" }
if (!exists("OUT"))      { OUT      = "cavendish"      }
if (!exists("MODE"))     { MODE     = "pdf"            }

# ── Wong colour palette ────────────────────────────────────────────────────────
C_BLUE   = "#0072B2"
C_ORANGE = "#E69F00"
C_PINK   = "#CC79A7"
C_DKGREY = "#333333"
C_MDGREY = "#777777"
C_GRID   = "#dddddd"
FF = "Helvetica"

# ── Model: damped sinusoid ─────────────────────────────────────────────────────
theta(t) = theta0 + a * exp(-t/tau) * sin(2*pi*t/T + phi)
a=40.0; tau=500.0; phi=-0.5; T=10.0; theta0=5.0
set fit quiet
set fit errorvariables
FIT_LIMIT = 1e-12
fit theta(x) DATAFILE u 1:2:3 yerrors via a, tau, phi, T, theta0
CHI2_red = FIT_WSSR / FIT_NDF

# ── R² ────────────────────────────────────────────────────────────────────────
stats DATAFILE u 2 name "S" nooutput
SS_tot = S_sumsq - S_records * S_mean**2
set table $RES
    plot DATAFILE u 1:($2 - theta($1)) w table
unset table
stats $RES u 2 name "E" nooutput
Rsq = 1.0 - E_sumsq / SS_tot

# ── Console summary ───────────────────────────────────────────────────────────
print ""
print "==========================================="
print "  Cavendish Pendulum -- Fit Results"
print "==========================================="
print sprintf("  A      = %7.3f +/- %.3f  mrad", a,      a_err)
print sprintf("  tau    = %7.3f +/- %.3f  s",    tau,    tau_err)
print sprintf("  T      = %7.4f +/- %.4f  s",    T,      T_err)
print sprintf("  phi    = %7.4f +/- %.4f  rad",  phi,    phi_err)
print sprintf("  theta0 = %7.3f +/- %.3f  mrad", theta0, theta0_err)
print sprintf("  chi2/ndf = %.4f",                CHI2_red)
print sprintf("  R2       = %.6f",                Rsq)
print "==========================================="
print ""

# ── Write fitted values file ──────────────────────────────────────────────────
set table $ALLT
    plot DATAFILE u 1:2:3 w table
unset table

set print OUT."_fit.dat"
print "# t(s)    data(mrad)    err(mrad)    fit(mrad)    residual(mrad)"
do for [i=1:|$ALLT|] {
    _row = $ALLT[i]
    _t   = real(word(_row,1))
    _d   = real(word(_row,2))
    _e   = real(word(_row,3))
    _f   = theta(_t)
    _r   = _d - _f
    print sprintf("%.4f\t%.4f\t%.4f\t%.4f\t%.4f", _t, _d, _e, _f, _r)
}
unset print
print sprintf(">>> Saved: %s_fit.dat", OUT)

# ═════════════════════════════════════════════════════════════════════════════
# TERMINALS
# ═════════════════════════════════════════════════════════════════════════════
if (MODE eq "interactive") {
    set terminal wxt noraise enhanced font FF.",10" size 900,650 persist
} else { if (MODE eq "png") {
    set terminal pngcairo enhanced color font FF.",10" size 1600,1100
    set output OUT.".png"
} else {
    set terminal pdfcairo enhanced color font FF.",10" \
        size 12cm, 9cm linewidth 1.0
    set output OUT.".pdf"
}}

# ── Common styles ─────────────────────────────────────────────────────────────
set style line 1  lc rgb C_BLUE   pt 7  ps 0.50 lw 1.0
set style line 2  lc rgb C_ORANGE lw 2.0 lt 1
set style line 3  lc rgb C_PINK   pt 7  ps 0.50 lw 1.0
set style line 10 lc rgb C_MDGREY lw 0.8 lt 2 dt (6,3)

# ═════════════════════════════════════════════════════════════════════════════
# MULTIPLOT
# ═════════════════════════════════════════════════════════════════════════════
set multiplot layout 2,1 \
    margins 0.12, 0.97, 0.09, 0.97 \
    spacing 0, 0.02

# ─────────────────────────────────────────────────────────────────────────────
# TOP PANEL — data + fit
# ─────────────────────────────────────────────────────────────────────────────
set lmargin at screen 0.12
set rmargin at screen 0.97
set tmargin at screen 0.97
set bmargin at screen 0.42

unset xlabel
set ylabel "{/Helvetica-Oblique {/Symbol q}} (mrad)" font FF.",10" offset 2.0,0
set xrange [0:40]
set yrange [-80:70]
set xtics 5 nomirror out scale 0.6,0.3 format ""
set ytics 20 nomirror out scale 0.6,0.3
set mxtics 5
set mytics 2
set grid xtics ytics lt 0 lw 0.3 lc rgb C_GRID
set border 3 lw 0.8 lc rgb "#444444"
set key top right spacing 1.4 samplen 2.5 \
    box lw 0.5 lc rgb "#bbbbbb" font FF.",8.5"

set label 1 \
    sprintf("{/=8.5 {/Helvetica-Oblique A} = %.2f +/- %.2f mrad}\n" . \
            "{/=8.5 {/Symbol t} = %.1f +/- %.1f s}\n" . \
            "{/=8.5 {/Helvetica-Oblique T} = %.3f +/- %.3f s}\n" . \
            "{/=8.5 {/Symbol c}^{2}/ndf = %.3f}\n" . \
            "{/=8.5 {/Helvetica-Oblique R}^{2} = %.5f}", \
            a, a_err, tau, tau_err, T, T_err, CHI2_red, Rsq) \
    at graph 0.03, 0.28 left font FF tc rgb C_DKGREY front

plot \
    DATAFILE u 1:2:3 w yerrorbars ls 1 t "Data", \
    theta(x)         w lines      ls 2 t sprintf("Fit  ({/Helvetica-Oblique T} = %.3f s)", T)

# ─────────────────────────────────────────────────────────────────────────────
# BOTTOM PANEL — residuals
# ─────────────────────────────────────────────────────────────────────────────
set lmargin at screen 0.12
set rmargin at screen 0.97
set tmargin at screen 0.40
set bmargin at screen 0.09

set xlabel "Time (s)" font FF.",10" offset 0,0.3
set ylabel "Residuals (mrad)" font FF.",10" offset 2.0,0
set xrange [0:40]
set yrange [-25:25]
set xtics 5 nomirror out scale 0.6,0.3 format "%g"
set ytics 10 nomirror out scale 0.6,0.3
set mxtics 5
set mytics 2
set grid xtics ytics lt 0 lw 0.3 lc rgb C_GRID
set border 3 lw 0.8 lc rgb "#444444"
unset label 1
unset key

plot \
    0 w lines ls 10 notitle, \
    DATAFILE u 1:($2 - theta($1)):3 w yerrorbars ls 3 notitle

unset multiplot

# ── Close ─────────────────────────────────────────────────────────────────────
if (MODE ne "interactive") {
    unset output
    print sprintf(">>> Saved: %s.%s", OUT, (MODE eq "png" ? "png" : "pdf"))
}
