# style_presentation.gp
# ── Beamer/semBlue-compatible presentation style ─────────────────────
# Assumes wxt or pdfcairo terminal set externally
# Fonts larger, lines thicker, markers bigger than publication style

# ── Palette: high-contrast, projector-safe ───────────────────────────
set linetype 1  lc rgb "#2166AC" lw 3.0 pt 7  ps 1.4   # strong blue
set linetype 2  lc rgb "#D6604D" lw 3.0 pt 9  ps 1.4   # strong red
set linetype 3  lc rgb "#1A9850" lw 3.0 pt 5  ps 1.4   # strong green
set linetype 4  lc rgb "#F4A582" lw 3.0 pt 11 ps 1.4   # salmon
set linetype 5  lc rgb "#4DAC26" lw 3.0 pt 13 ps 1.4   # lime
set linetype 6  lc rgb "#762A83" lw 3.0 pt 15 ps 1.4   # purple
set linetype cycle 6

# ── Border: clean 2-sided (left + bottom only, pure mpl axes style) ──
# 1=bottom 2=left → sum=3
set border 3 lw 2.0 lc rgb "#222222"

# ── Grid: subtle, doesn't compete with data ──────────────────────────
set grid xtics ytics lc rgb "#CCCCCC" dt 2 lw 0.8
unset grid  # presenters often prefer no grid; comment this to enable

# ── Ticks: larger scale for readability at distance ──────────────────
set xtics nomirror out scale 1.2 font ",14"
set ytics nomirror out scale 1.2 font ",14"
set mxtics 2
set mytics 2
set xlabel font ",15"
set ylabel font ",15"
set title  font ",16" textcolor rgb "#1A1A2E"

# ── Legend ───────────────────────────────────────────────────────────
set key top right Right samplen 3 spacing 1.5 nobox \
    font ",13" textcolor rgb "#222222"

# ── Margins: more breathing room ─────────────────────────────────────
set tmargin 3
set bmargin 5
set lmargin 11
set rmargin 4

# ── Fill ─────────────────────────────────────────────────────────────
set style fill transparent solid 0.35 noborder
