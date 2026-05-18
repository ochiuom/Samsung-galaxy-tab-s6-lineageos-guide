# ── transport.gp ──────────────────────────────────────────────────────
# R vs T with dR/dT on dual y-axis
# Also supports R vs B (magnetotransport)
#
# Usage:
#   gnuplot transport.gp
#   gnuplot -e "MODE='RvsB'" transport.gp
#   gnuplot -e "DATAFILE='hall.dat'; MODE='RvsB'" transport.gp
#
# Data format (R vs T): col1=T(K)  col2=R(Ω)
# Data format (R vs B): col1=B(T)  col2=Rxx(Ω)  col3=Rxy(Ω)  [optional]

load "style_publication.gp"
load "units.gp"

if (!exists("DATAFILE")) { DATAFILE = "transport.dat" }
if (!exists("MODE"))     { MODE     = "RvsT"          }

# ════════════════════════════════════════════════════════════════════════
if (MODE eq "RvsT") {

    set xlabel XLABEL_TEMP
    set ylabel YLABEL_RESISTANCE
    set y2label YLABEL_DRDT
    set y2tics
    set ytics nomirror

    set title ""
    set key top right

    # ── Numerical dR/dT via finite difference ─────────────────────────
    # gnuplot can't differentiate inline cleanly for noisy data
    # Best practice: pre-compute in awk/python and add as col3
    # If col3 exists (smoothed dR/dT):

    set style line 10 lc rgb "#CCCCCC" lw 0.5 dt 1   # y2 axis helper

    plot DATAFILE u 1:2     w lines  lt 1 lw 2.0 axes x1y1 t "R(T)", \
         DATAFILE u 1:3     w lines  lt 2 lw 1.5 axes x1y2 t "dR/dT" \
             lc rgb "#EE6677" dt 2

    # ── Single-column variant (no dR/dT column): uncomment ────────────
    # plot DATAFILE u 1:2 w lines lt 1 lw 2.0 t "R(T)"

# ════════════════════════════════════════════════════════════════════════
} else { if (MODE eq "RvsB") {

    set xlabel XLABEL_FIELD
    set ylabel YLABEL_RESISTANCE
    set title  ""
    set key top left

    # ── Symmetrize: Rxx=(R(+B)+R(-B))/2, Rxy=(R(+B)-R(-B))/2 ─────────
    # Pre-process in Python; load symmetrized file here
    # col1=B  col2=Rxx  col3=Rxy (Hall)

    set y2label "Hall resistance R_{xy} (Ω)"
    set y2tics
    set ytics nomirror

    plot DATAFILE u 1:2 w lines lt 1 lw 2.0 axes x1y1 t "R_{xx}", \
         DATAFILE u 1:3 w lines lt 2 lw 1.5 axes x1y2 t "R_{xy}" \
             lc rgb "#EE6677"

}}
