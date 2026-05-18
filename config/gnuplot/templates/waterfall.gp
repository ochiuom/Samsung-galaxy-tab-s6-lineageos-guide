# ── waterfall.gp ──────────────────────────────────────────────────────
# Stacked/offset spectra — temperature series, gate series, position map
# Each spectrum is a separate data block (blank-line separated in file)
# OR separate files passed as a space-separated string
#
# Usage:
#   gnuplot -e "DATAFILE='spectra.dat'; NSPEC=8; OFFSET=200" waterfall.gp
#   gnuplot -e "DATAFILE='spectra.dat'; NSPEC=5; OFFSET=500; COLOR=1" waterfall.gp
#
# Data format (single file, blank-line blocks):
#   x1 y1
#   x2 y2
#   ...
#   <blank line>
#   x1 y1   ← next spectrum
#   ...

if (!exists("DATAFILE")) { DATAFILE = "spectra.dat" }
if (!exists("NSPEC"))    { NSPEC    = 5             }  # number of spectra
if (!exists("OFFSET"))   { OFFSET   = 300.0         }  # y offset per spectrum
if (!exists("XCOL"))     { XCOL     = 1             }
if (!exists("YCOL"))     { YCOL     = 2             }
if (!exists("COLOR"))    { COLOR    = 0             }  # 0=monochrome stack, 1=colored

set xlabel "Raman shift (cm^{-1})"
set ylabel "Intensity + offset (arb. units)"
set title  ""
unset ytics                     # y-axis values meaningless after offset
set ytics format ""

# ── Label positions (right side, one per spectrum) ────────────────────
# Uncomment and customise if you have parameter labels (T=4K etc)
# array LABELS[NSPEC] = ["4 K","50 K","100 K","200 K","300 K"]

set key off

# ── Plot loop ─────────────────────────────────────────────────────────
# gnuplot index selects blank-line-separated blocks (0-indexed)

if (COLOR == 0) {
    # Monochrome: all same color, good for B&W journals
    plot for [i=0:NSPEC-1] DATAFILE \
         index i \
         u XCOL:(column(YCOL) + i*OFFSET) \
         w lines lt 1 lc rgb "#222222" lw 1.5 notitle

} else {
    # Colored: cycles through linetype palette
    plot for [i=0:NSPEC-1] DATAFILE \
         index i \
         u XCOL:(column(YCOL) + i*OFFSET) \
         w lines lt (i+1) lw 1.5 notitle
}

# ── Optional: add spectrum labels on right margin ─────────────────────
# Requires knowing your xrange max — set XMAX and uncomment:
# set xrange [*:XMAX]
# do for [i=0:NSPEC-1] {
#     set label i+10 LABELS[i+1] at XMAX, i*OFFSET font ",10" left
# }
# replot
