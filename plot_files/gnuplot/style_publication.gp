# ── Palette: Science/Nature muted ───────────────────────────────────
set linetype 1  lc rgb "#4477AA" lw 2.0 pt 7  ps 0.8   # filled circle
set linetype 2  lc rgb "#EE6677" lw 2.0 pt 9  ps 0.8   # filled triangle
set linetype 3  lc rgb "#228833" lw 2.0 pt 5  ps 0.8   # filled square
set linetype 4  lc rgb "#CCBB44" lw 2.0 pt 11 ps 0.8   # filled diamond
set linetype 5  lc rgb "#66CCEE" lw 2.0 pt 13 ps 0.8
set linetype 6  lc rgb "#AA3377" lw 2.0 pt 15 ps 0.8
set linetype cycle 6

# ── Border: 3-sided spine (left + bottom + top, no right) ───────────
# 1=bottom 2=left 4=top 8=right → 1+2+4 = 7
set border 7 lw 1.2 lc rgb "#444444"

# ── Grid: explicit lc/dt, not referencing a data linetype ───────────
set grid xtics ytics lc rgb "#BBBBBB" dt 2 lw 0.5
set grid mxtics mytics lc rgb "#DDDDDD" dt 3 lw 0.3

# ── Ticks ────────────────────────────────────────────────────────────
set xtics nomirror out scale 0.75
set ytics nomirror out scale 0.75
set mxtics 2
set mytics 2

# ── Legend ───────────────────────────────────────────────────────────
set key top right Right samplen 2 spacing 1.3 nobox \
    font ",11" textcolor rgb "#333333"

# ── Margins ──────────────────────────────────────────────────────────
set tmargin 2
set bmargin 4
set lmargin 9
set rmargin 3

# ── Fill style (errorbars, ribbons) ──────────────────────────────────
set style fill transparent solid 0.25 noborder
