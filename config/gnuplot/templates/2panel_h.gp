# ── 2panel_h.gp ──────────────────────────────────────────────────────
# Two panels side by side (e.g. raw data | processed / two conditions)
# Export size hint: W=16cm H=6cm

if (!exists("FILE1")) { FILE1 = "data1.dat" }
if (!exists("FILE2")) { FILE2 = "data2.dat" }

set multiplot layout 1,2 \
    margins 0.10, 0.97, 0.15, 0.93 \
    spacing 0.08, 0.00

# ── Panel (a) ─────────────────────────────────────────────────────────
set xlabel "x label (units)"
set ylabel "y label (units)"
set label 1 "(a)" at graph -0.18, 1.02 font ",12" front

plot FILE1 u 1:2:3 w yerrorbars lt 1 t "Dataset 1", \
     ""    u 1:2   w lines       lt 1 t ""

# ── Panel (b) ─────────────────────────────────────────────────────────
unset ylabel               # shared y-axis label optional
set label 1 "(b)" at graph -0.12, 1.02 font ",12" front

plot FILE2 u 1:2:3 w yerrorbars lt 2 t "Dataset 2", \
     ""    u 1:2   w lines       lt 2 t ""

unset multiplot
