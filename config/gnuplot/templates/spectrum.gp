# ── spectrum.gp ───────────────────────────────────────────────────────
load "style_publication.gp"

# max_val cannot be used as a bare variable from column data in gnuplot
# Correct approach: normalize externally, OR use gnuplot stats block

if (!exists("XMIN")) { XMIN = 200  }
if (!exists("XMAX")) { XMAX = 1000 }

set xlabel "Wavenumber (cm^{-1})"
set ylabel "Normalized Intensity (arb. units)"
set title  ""
set xrange [XMIN:XMAX]
unset ytics

# ── Per-file normalization via stats ──────────────────────────────────
stats "raman_300k.dat" u 2 nooutput ; max1 = STATS_max
stats "raman_100k.dat" u 2 nooutput ; max2 = STATS_max
stats "raman_10k.dat"  u 2 nooutput ; max3 = STATS_max

off1 = 1.2    # offset between spectra (>1 avoids overlap after norm)
off2 = 2.4

set key top right

plot "raman_300k.dat" u 1:($2/max1)        w lines lt 1 lw 2.0 t "300 K", \
     "raman_100k.dat" u 1:($2/max2 + off1) w lines lt 2 lw 2.0 t "100 K", \
     "raman_10k.dat"  u 1:($2/max3 + off2) w lines lt 3 lw 2.0 t "10 K"
