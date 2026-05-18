# ── errorband.gp ──────────────────────────────────────────────────────
# Shaded confidence/error band around a curve
# Requires gnuplot >= 5.2 for `filledcurves`
#
# Data format: col1=x  col2=y  col3=ylo  col4=yhi
#   ylo/yhi can be: mean±std, 95% CI, min/max envelope
#   Generate with Python: np.percentile or scipy.stats.sem
#
# Usage:
#   gnuplot errorband.gp
#   gnuplot -e "DATAFILE='fit_ci.dat'; BAND='ci95'" errorband.gp

load "style_publication.gp"
load "units.gp"

if (!exists("DATAFILE")) { DATAFILE = "data.dat" }
if (!exists("BAND"))     { BAND     = "std"      }  # std | ci95 | minmax

set xlabel "x (units)"
set ylabel "y (units)"
set title  ""
set key top left

# ── Band color: match lt 1 blue with alpha ────────────────────────────
BAND_COLOR = "#4477AA"
BAND_ALPHA = "40"           # hex alpha: 40≈25%, 80≈50%
FILL_COLOR = BAND_COLOR.BAND_ALPHA

# ── Plot: filled band first (behind), then mean line, then points ──────
plot DATAFILE u 1:3:4 w filledcurves \
         lc rgb FILL_COLOR fs transparent solid 0.25 noborder \
         t sprintf("%s band", BAND), \
     DATAFILE u 1:2   w lines  lt 1 lw 2.0 t "Mean", \
     DATAFILE u 1:2   w points lt 1 ps 0.6 notitle

# ── Variant: yerrorlines (classic, no fill) ───────────────────────────
# plot DATAFILE u 1:2:3:4 w yerrorlines lt 1 lw 1.5 t "Data ± σ"

# ── Variant: multiple bands (e.g. 1σ + 2σ) ───────────────────────────
# FILL1 = "#4477AA30"   # 1σ darker
# FILL2 = "#4477AA18"   # 2σ lighter
# plot DATAFILE u 1:3:4   w filledcurves lc rgb FILL1 ... t "1σ", \
#      DATAFILE u 1:5:6   w filledcurves lc rgb FILL2 ... t "2σ", \
#      DATAFILE u 1:2     w lines lt 1 lw 2.0 t "Mean"
