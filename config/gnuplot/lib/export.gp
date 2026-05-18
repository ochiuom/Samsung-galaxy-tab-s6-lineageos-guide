# ── export.gp ────────────────────────────────────────────────────────
# Usage:
#   gnuplot -e "SCRIPT='myplot.gp'; OUT='fig1'" export.gp
#   gnuplot -e "SCRIPT='myplot.gp'; OUT='fig1'; MODE='bw'" export.gp
#   gnuplot -e "SCRIPT='myplot.gp'; OUT='fig1'; MODE='presentation'" export.gp
#
# Produces: OUT.pdf + OUT.png
# Requires: GNUPLOT_LIB set (handled by home.sessionVariables)

# ── Defaults ──────────────────────────────────────────────────────────
if (!exists("OUT"))    { OUT    = "output"      }
if (!exists("MODE"))   { MODE   = "publication" }
if (!exists("W"))      { W      = "8"           }   # cm, pdf width
if (!exists("H"))      { H      = "6"           }   # cm, pdf height
if (!exists("WPNG"))   { WPNG   = "960"         }   # px, png width
if (!exists("HPNG"))   { HPNG   = "720"         }   # px, png height
if (!exists("DPI"))    { DPI    = "300"         }

# ── Style selection ───────────────────────────────────────────────────
if (MODE eq "bw") {
    STYLE = "style_bw.gp"
    MONO  = "monochrome"
} else { if (MODE eq "presentation") {
    STYLE = "style_presentation.gp"
    MONO  = "color"
} else {
    STYLE = "style_publication.gp"
    MONO  = "color"
}}

# ── PDF export ────────────────────────────────────────────────────────
set terminal pdfcairo enhanced @MONO font "Helvetica,11" \
    size @W."cm", @H."cm"
set output OUT.".pdf"
load STYLE
load SCRIPT
unset output

# ── PNG export ────────────────────────────────────────────────────────
set terminal pngcairo enhanced @MONO font "Helvetica,11" \
    size @WPNG, @HPNG dpi @DPI
set output OUT.".png"
load STYLE
load SCRIPT
unset output

print ">>> Exported: ".OUT.".pdf + ".OUT.".png  [mode=".MODE."]"
