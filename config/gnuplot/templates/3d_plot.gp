# ── 3d_plot.gp ────────────────────────────────────────────────────────
load "style_publication.gp"

# colormap.gp is a template (produces output) — do NOT load as lib
# Palette defined inline here
set palette defined (\
    0 "#440154", 0.25 "#3b528b", 0.5 "#21918c",\
    0.75 "#5ec962", 1 "#fde725")

set xlabel "X-Coordinate (Å)"
set ylabel "Y-Coordinate (Å)"
set zlabel "Energy (eV)" rotate by 90 offset -1,0

set title ""

set xyplane at 0
set view 60, 30, 1.0, 1.0
set hidden3d
set pm3d depthorder
set pm3d interpolate 2,2
set colorbox vertical

# ── Contour overlay (uncomment for publication) ────────────────────────
# set contour surface
# set cntrparam levels 10
# unset clabel

splot "grid_data.dat" u 1:2:3 w pm3d notitle
