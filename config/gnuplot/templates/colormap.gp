# ── colormap.gp ───────────────────────────────────────────────────────
# 2D intensity map: Raman shift vs gate voltage, T, position, etc.
# Data format: x  y  z  (whitespace separated, blank lines between x blocks)
# Generate from matrix with: awk script or Python np.savetxt

if (!exists("DATAFILE")) { DATAFILE = "map.dat"          }
if (!exists("CBMIN"))    { CBMIN    = "*"                }
if (!exists("CBMAX"))    { CBMAX    = "*"                }
if (!exists("PALETTE"))  { PALETTE  = "viridis"          }  # viridis|plasma|hot|gray

set xlabel "Raman shift (cm^{-1})"
set ylabel "Gate voltage (V)"
set cblabel "Intensity (arb. units)" rotate by -90 offset 2,0

# ── Palette selection ─────────────────────────────────────────────────
if (PALETTE eq "viridis") {
    # Perceptually uniform, colorblind-safe, good B&W conversion
    set palette defined (\
        0 "#440154", 0.13 "#3b528b", 0.25 "#21918c",\
        0.5 "#5ec962", 0.75 "#fde725", 1 "#fde725")
} else { if (PALETTE eq "plasma") {
    set palette defined (\
        0 "#0d0887", 0.25 "#7e03a8", 0.5 "#cc4778",\
        0.75 "#f89441", 1 "#f0f921")
} else { if (PALETTE eq "hot") {
    set palette rgbformulae 21,22,23
} else {
    set palette gray
}}}

set cbrange [CBMIN:CBMAX]
set pm3d map interpolate 2,2
set pm3d corners2color mean

# ── Colorbar tick formatting ───────────────────────────────────────────
set colorbox vertical user origin 0.88, 0.15 size 0.03, 0.70

# ── Margins: leave room for colorbar ──────────────────────────────────
set lmargin 9
set rmargin 12
set tmargin 2
set bmargin 4

splot DATAFILE u 1:2:3 w pm3d notitle
