# ── fitting_linear.gp ─────────────────────────────────────────────────
load "style_publication.gp"

if (!exists("DATAFILE")) { DATAFILE = "data.dat" }
if (!exists("XCOL"))     { XCOL = 1 }
if (!exists("YCOL"))     { YCOL = 2 }

set xlabel "x (units)"
set ylabel "y (units)"
set title  ""

# ── Fit ───────────────────────────────────────────────────────────────
set fit quiet
set fit errorvariables

f(x) = m*x + b
m = 1.0 ; b = 0.0

fit f(x) DATAFILE u XCOL:YCOL via m, b

# ── R² (manual) ───────────────────────────────────────────────────────
# gnuplot has no built-in R²; use FIT_STDFIT as proxy (lower=better)
# For true R²: compute in awk/python, pass as variable

print sprintf(">>> m = %.4f ± %.4f", m, m_err)
print sprintf(">>> b = %.4f ± %.4f", b, b_err)
print sprintf(">>> FIT_STDFIT = %.4f", FIT_STDFIT)

set label 1 sprintf("y = %.3fx + %.3f", m, b) \
    at graph 0.05, 0.90 font ",11" tc rgb "#333333"

set key bottom right

plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
     f(x)                 w lines  lt 2 lw 2.0 dt 2 t "Linear fit"
