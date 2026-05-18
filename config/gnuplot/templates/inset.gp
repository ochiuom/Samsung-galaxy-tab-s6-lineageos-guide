# ── inset.gp ──────────────────────────────────────────────────────────
# Main plot with zoomed inset panel
# Inset position/size controlled via screen coordinates
#
# Usage:
#   gnuplot inset.gp
#   gnuplot -e "DATAFILE='raman.dat'; IX1=380; IX2=420" inset.gp

load "style_publication.gp"
load "units.gp"

if (!exists("DATAFILE")) { DATAFILE = "data.dat" }

# ── Inset zoom range (x) ──────────────────────────────────────────────
if (!exists("IX1")) { IX1 = 370.0 }    # inset xmin
if (!exists("IX2")) { IX2 = 430.0 }    # inset xmax
if (!exists("IY1")) { IY1 = "*"   }    # inset ymin (auto)
if (!exists("IY2")) { IY2 = "*"   }    # inset ymax (auto)

# ── Inset screen position (normalized 0–1) ────────────────────────────
# Adjust these to move/resize inset
INS_X1 = 0.52    # left edge
INS_X2 = 0.92    # right edge
INS_Y1 = 0.18    # bottom edge
INS_Y2 = 0.55    # top edge

set multiplot

# ════════════════════════════════════════════════════════════════════════
# ── Main panel ────────────────────────────────────────────────────────
set lmargin 9
set rmargin 3
set tmargin 2
set bmargin 4

set xlabel XLABEL_RAMAN
set ylabel YLABEL_INTENSITY
set xrange [*:*]
set yrange [*:*]
set key top right

# Optional: draw inset border box on main plot
set object 1 rectangle \
    from graph (INS_X1-0.02), graph (INS_Y1-0.02) \
    to   graph (INS_X2+0.02), graph (INS_Y2+0.02) \
    fc rgb "white" fs solid 1.0 border lc rgb "#888888" lw 0.8 front

plot DATAFILE u 1:2 w lines lt 1 lw 2.0 t "Data"

# ── Zoom indicator lines (connect main to inset) ──────────────────────
# set arrow 1 from IX1, graph 0 to screen INS_X1, screen INS_Y1 \
#     lt -1 lw 0.8 lc rgb "#AAAAAA" dt 3 nohead
# set arrow 2 from IX2, graph 0 to screen INS_X2, screen INS_Y1 \
#     lt -1 lw 0.8 lc rgb "#AAAAAA" dt 3 nohead

# ════════════════════════════════════════════════════════════════════════
# ── Inset panel ───────────────────────────────────────────────────────
set size     (INS_X2 - INS_X1), (INS_Y2 - INS_Y1)
set origin   INS_X1, INS_Y1

set xrange [IX1:IX2]
set yrange [IY1:IY2]

# Smaller font + tighter margins for inset
set xlabel "" font ",9"
set ylabel "" font ",9"
set xtics font ",9" scale 0.5
set ytics font ",9" scale 0.5
set key off
unset title

set lmargin 5
set rmargin 1
set tmargin 0.5
set bmargin 2.5

plot DATAFILE u 1:2 w lines lt 1 lw 1.5 notitle

unset multiplot
