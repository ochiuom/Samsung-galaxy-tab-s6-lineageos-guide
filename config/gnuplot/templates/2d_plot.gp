# ── 2d_plot.gp ────────────────────────────────────────────────────────
load "style_publication.gp"

set xlabel "Applied Strain (%)"
set ylabel "Stress (MPa)"
set title  ""

# ── Optional dual y-axis (uncomment) ──────────────────────────────────
# set y2label "Poisson Ratio"
# set y2tics
# set link y2 via y*0.1 inverse y/0.1

# ── Optional log scale ────────────────────────────────────────────────
# set logscale y
# set format y "10^{%L}"

set key top left

# col layout: x  y  yerr  y2  y2err
plot "data.dat" u 1:2:3 w yerrorbars lt 1 t "Experimental", \
     "data.dat" u 1:2   w lines      lt 1 lw 1.5 notitle, \
     "data.dat" u 1:4   w lines      lt 2 lw 2.0 t "Theory"
