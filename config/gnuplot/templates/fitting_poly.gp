# ── fitting_poly.gp ───────────────────────────────────────────────────
load "style_publication.gp"

if (!exists("DATAFILE")) { DATAFILE = "data.dat" }
if (!exists("XCOL"))     { XCOL = 1 }
if (!exists("YCOL"))     { YCOL = 2 }
if (!exists("ORDER"))    { ORDER = 2 }   # 2=quadratic 3=cubic

set xlabel "x (units)"
set ylabel "y (units)"
set title  ""

set fit quiet
set fit errorvariables

# ── Model selection ───────────────────────────────────────────────────
if (ORDER == 2) {
    g(x) = a2*x**2 + a1*x + a0
    a2 = 1.0 ; a1 = 1.0 ; a0 = 0.0
    fit g(x) DATAFILE u XCOL:YCOL via a2, a1, a0
    LABEL = sprintf("a_2=%.3g  a_1=%.3g  a_0=%.3g", a2, a1, a0)
} else {
    g(x) = a3*x**3 + a2*x**2 + a1*x + a0
    a3 = 0.1 ; a2 = 1.0 ; a1 = 1.0 ; a0 = 0.0
    fit g(x) DATAFILE u XCOL:YCOL via a3, a2, a1, a0
    LABEL = sprintf("a_3=%.3g  a_2=%.3g  a_1=%.3g  a_0=%.3g", a3, a2, a1, a0)
}

print ">>> ".LABEL
print sprintf(">>> FIT_STDFIT = %.4f", FIT_STDFIT)

set label 1 LABEL at graph 0.05, 0.90 font ",10" tc rgb "#333333"
set key bottom right

plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
     g(x)                 w lines  lt 2 lw 2.0 t sprintf("Degree-%d fit", ORDER)
