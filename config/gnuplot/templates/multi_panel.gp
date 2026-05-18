# ── multi_panel.gp ────────────────────────────────────────────────────
load "style_publication.gp"

if (!exists("FILE1")) { FILE1 = "raman.dat" }
if (!exists("FILE2")) { FILE2 = "pl.dat"    }

set multiplot layout 1,2 \
    margins 0.10, 0.97, 0.15, 0.93 \
    spacing 0.10, 0.00

# ── Panel (a): Raman ──────────────────────────────────────────────────
set xlabel "Raman shift (cm^{-1})"
set ylabel "Intensity (arb. units)"
set label 1 "(a)" at graph -0.20, 1.03 font ",12" front norotate

plot FILE1 u 1:2 w lines lt 1 lw 2.0 t "Raman"

# ── Panel (b): PL ─────────────────────────────────────────────────────
unset ylabel
set xlabel "Energy (eV)"
set label 1 "(b)" at graph -0.12, 1.03 font ",12" front norotate

plot FILE2 u 1:2 w lines lt 2 lw 2.0 t "PL"

unset multiplot
