# ── arrows.gp ─────────────────────────────────────────────────────────
# Annotation macros: peak labels, transition arrows, brackets
# Load via: load "arrows.gp"
# Requires: label/arrow counters managed by caller (see usage below)
#
# Usage:
#   load "arrows.gp"
#   call "peak_label"    x y "E_{2g}" "above"
#   call "arrow_lr"      x1 y1 x2 y2
#   call "bracket"       x1 x2 y "Δ = 25 cm^{-1}"

# ── Internal counters (increment before each call if using multiples) ──
if (!exists("_LBL"))  { _LBL  = 1 }
if (!exists("_ARR"))  { _ARR  = 1 }

# ── Peak label: vertical tick + text ──────────────────────────────────
# Args: $1=x  $2=y  $3="text"  $4="above"|"below"
# Example: call "peak_label" 383.0 1200 "E_{2g}" "above"
peak_label(px, py, txt, pos) = 1   # dummy — gnuplot call syntax below

# gnuplot `call` passes args as $0..$9 strings
# Save as peak_label.gp and call separately, OR use inline set label:

# ── Inline macro: copy-paste block for peak annotation ────────────────
# Replace PX, PY, TXT each time

# Above peak (most common for Raman)
# set arrow _ARR from PX, PY to PX, PY*1.08 lt -1 lw 1.0 lc rgb "#444444" \
#     head filled size screen 0.008,20
# set label _LBL "TXT" at PX, PY*1.12 center font ",10" tc rgb "#222222"
# _ARR = _ARR + 1 ; _LBL = _LBL + 1

# ── Convenience: named shorthand functions ────────────────────────────

# Horizontal double-headed arrow (peak separation, FWHM bracket)
# call: set_harrow(x1, x2, y, label, lbl_id, arr_id)
# Usage pattern (inline, since gnuplot has no true macros):
#
# set arrow 10 from 383, 800 to 408, 800 lt -1 lw 1.5 \
#     lc rgb "#333333" heads filled size screen 0.010,20
# set label 10 "Δ = 25 cm^{-1}" at 395.5, 850 center font ",10"

# ── Transition arrow: oblique, for band diagrams / energy levels ───────
# set arrow N from X1,Y1 to X2,Y2 lt -1 lw 1.5 lc rgb "#2166AC" \
#     head filled size screen 0.012,25

# ── Vertical dashed marker line (mode position, phase transition T) ────
# set arrow N from XV,YBOT to XV,YTOP lt -1 lw 1.0 lc rgb "#888888" \
#     dt 2 nohead

# ── Region shading via filled rectangle object ────────────────────────
# set object N rectangle from X1,YBOT to X2,YTOP \
#     fc rgb "#AACCEE" fillstyle transparent solid 0.15 noborder behind

# ── Ready-to-use named arrow styles (set once, reference by index) ─────
# Call after loading style_*.gp:

set style arrow 1 lt -1 lw 1.5 lc rgb "#333333" \
    head filled size screen 0.010,20          # standard annotation
set style arrow 2 lt -1 lw 1.5 lc rgb "#333333" \
    heads filled size screen 0.010,20         # double-headed (separation)
set style arrow 3 lt -1 lw 1.0 lc rgb "#888888" \
    dt 2 nohead                               # dashed marker line
set style arrow 4 lt -1 lw 2.0 lc rgb "#2166AC" \
    head filled size screen 0.014,25          # transition / emphasis

# ── Usage with named styles ───────────────────────────────────────────
# set arrow 1 from 383,1100 to 408,1100 arrowstyle 2   # separation bracket
# set arrow 2 from 385,0    to 385,1300 arrowstyle 3   # mode marker
# set label 1 "E_{2g}" at 383,1150 right font ",10"
# set label 2 "A_{1g}" at 408,1150 left  font ",10"
# set label 3 "Δ=25 cm^{-1}" at 395.5,1180 center font ",10"
