# style_bw.gp
# ── Grayscale style for journals requiring B&W figures ───────────────
# All distinction via: dashtype + point type + shade of gray
# No color used anywhere — safe for any printer/journal

# ── Palette: grays + distinct dash/point combos ──────────────────────
#   Gray ladder: #000000 → #888888 (avoid anything lighter, prints poorly)
set linetype 1  lc rgb "#000000" lw 2.0 pt 7  ps 0.9 dt 1      # solid         filled circle
set linetype 2  lc rgb "#000000" lw 2.0 pt 6  ps 0.9 dt 2      # dashed        open circle
set linetype 3  lc rgb "#000000" lw 2.0 pt 5  ps 0.9 dt 3      # dotted        filled square
set linetype 4  lc rgb "#000000" lw 2.0 pt 4  ps 0.9 dt 4      # dash-dot      open square
set linetype 5  lc rgb "#444444" lw 2.0 pt 9  ps 0.9 dt 1      # solid gray    filled triangle
set linetype 6  lc rgb "#444444" lw 2.0 pt 8  ps 0.9 dt 2      # dashed gray   open triangle
set linetype 7  lc rgb "#888888" lw 2.0 pt 11 ps 0.9 dt 1      # light gray    filled diamond
set linetype 8  lc rgb "#888888" lw 2.0 pt 10 ps 0.9 dt 2      # light gray    open diamond
set linetype cycle 8

# ── Border: full box is conventional in many journals ────────────────
# Change to 3 or 7 if your journal prefers spine style
set border 15 lw 1.5 lc rgb "#000000"

# ── Grid: very light, only major ticks ───────────────────────────────
set grid xtics ytics lc rgb "#CCCCCC" dt 1 lw 0.4

# ── Ticks ────────────────────────────────────────────────────────────
set xtics nomirror out scale 0.75
set ytics nomirror out scale 0.75
set mxtics 2
set mytics 2

# ── Legend ───────────────────────────────────────────────────────────
# samplen long enough to show dash pattern clearly
set key top right Right samplen 4 spacing 1.3 nobox \
    font ",11" textcolor rgb "#000000"

# ── Margins ──────────────────────────────────────────────────────────
set tmargin 2
set bmargin 4
set lmargin 9
set rmargin 3

# ── Fill: use sparse crosshatch-like patterns via low solid value ─────
# gnuplot has no native hatch fill; use low alpha gray instead
set style fill transparent solid 0.15 noborder
