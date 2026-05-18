# ── 1panel.gp ────────────────────────────────────────────────────────
# Single-panel publication figure template
# Usage (interactive):
#   gnuplot 1panel.gp
# Usage (export):
#   gnuplot -e "SCRIPT='1panel.gp'; OUT='fig1'" export.gp

# ── Data source ───────────────────────────────────────────────────────
# Override via: gnuplot -e "DATAFILE='mydata.dat'" 1panel.gp
if (!exists("DATAFILE")) { DATAFILE = "data.dat" }

# ── Axes ──────────────────────────────────────────────────────────────
set xlabel "x label (units)"
set ylabel "y label (units)"
set title  ""                   # usually blank in publications

set xrange [*:*]                # auto; replace with [0:10] etc
set yrange [*:*]

# ── Optional log scale (uncomment as needed) ──────────────────────────
# set logscale y
# set format y "10^{%L}"

# ── Plot ──────────────────────────────────────────────────────────────
# Column layout assumed: col1=x  col2=y  col3=yerr
# Swap in your actual columns; add more `\` lines for more datasets

plot DATAFILE \
     u 1:2:3 w yerrorbars lt 1 t "Dataset 1", \
     ""      u 1:2        w lines     lt 1 t ""

# ── Errorbar-only variant (no line): ──────────────────────────────────
# plot DATAFILE u 1:2:3 w yerrorbars lt 1 t "Data"

# ── Points-only variant: ──────────────────────────────────────────────
# plot DATAFILE u 1:2 w points lt 1 t "Data"
