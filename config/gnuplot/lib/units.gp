# ── units.gp ──────────────────────────────────────────────────────────
# Axis format strings and unit label constants
# Load via: load "units.gp"
# Then use: set xlabel XLABEL_RAMAN  or  set format y FMT_MEV

# ── X-axis label strings ──────────────────────────────────────────────
XLABEL_RAMAN    = "Raman shift (cm^{-1})"
XLABEL_ENERGY   = "Energy (eV)"
XLABEL_ENERGYMEV= "Energy (meV)"
XLABEL_WAVELEN  = "Wavelength (nm)"
XLABEL_WAVENLEN = "Wavenumber (cm^{-1})"
XLABEL_FIELD    = "Magnetic field (T)"
XLABEL_TEMP     = "Temperature (K)"
XLABEL_GATE     = "Gate voltage V_g (V)"
XLABEL_BIAS     = "Bias voltage V_{ds} (V)"
XLABEL_CURRENT  = "Current I (μA)"
XLABEL_FREQ     = "Frequency (GHz)"
XLABEL_TIME     = "Time (s)"
XLABEL_POSITION = "Position (μm)"
XLABEL_STRAIN   = "Applied strain (%)"
XLABEL_PRESSURE = "Pressure (GPa)"

# ── Y-axis label strings ──────────────────────────────────────────────
YLABEL_INTENSITY = "Intensity (arb. units)"
YLABEL_NORM      = "Normalized intensity (arb. units)"
YLABEL_RESISTANCE= "Resistance R (Ω)"
YLABEL_RESISTKOHM= "Resistance R (kΩ)"
YLABEL_CONDUCT   = "Conductance G (e^2/h)"
YLABEL_CURRENT   = "Current I (nA)"
YLABEL_CURRENTUA = "Current I (μA)"
YLABEL_STRESS    = "Stress (MPa)"
YLABEL_ABSORP    = "Absorbance (O.D.)"
YLABEL_COUNTS    = "Counts (s^{-1})"
YLABEL_PL        = "PL intensity (arb. units)"
YLABEL_DRDT      = "dR/dT (Ω K^{-1})"

# ── Colorbar labels ───────────────────────────────────────────────────
CBLABEL_INTENSITY = "Intensity (arb. units)"
CBLABEL_CONDUCT   = "Conductance (e^2/h)"
CBLABEL_RESISTANCE= "Resistance (Ω)"

# ── Axis format strings ───────────────────────────────────────────────
FMT_EXP   = "%.1e"          # scientific: 1.2e-03
FMT_POW   = "10^{%L}"       # log axis: 10^3
FMT_MEV   = "%.1f"          # meV values (typically 0–500)
FMT_KEL   = "%.0f"          # temperature in K
FMT_FLOAT = "%.2f"          # generic 2 decimal
FMT_INT   = "%.0f"          # integer ticks

# ── Physical constants (SI) ───────────────────────────────────────────
kB      = 8.617333e-5    # eV/K  Boltzmann
hbar    = 6.582119e-16   # eV·s  reduced Planck
e_C     = 1.602176e-19   # C     electron charge
c_cms   = 2.997924e10    # cm/s  speed of light
h_eVs   = 4.135667e-15   # eV·s  Planck

# ── Unit conversion factors ───────────────────────────────────────────
CM2MEV  = 0.12398        # cm^-1 → meV  (multiply wavenumber by this)
MEV2CM  = 8.0655         # meV → cm^-1
NM2EV   = 1239.84        # nm → eV  (divide wavelength by this)
EV2NM   = 1239.84        # eV → nm  (divide energy by this)
GPA2BAR = 10000.0        # GPa → bar
