# ── math.gp ──────────────────────────────────────────────────────────
# Common lineshape and physics functions for spectroscopy
# Load via: load "math.gp"  (available via GNUPLOT_LIB)

# ── Gaussian ──────────────────────────────────────────────────────────
# A: amplitude  x0: center  sig: sigma
G(x, A, x0, sig) = A * exp(-0.5 * ((x - x0) / sig)**2)
G_area(A, sig)   = A * sig * sqrt(2.0 * pi)

# ── Lorentzian ────────────────────────────────────────────────────────
# A: amplitude  x0: center  gam: HWHM
L(x, A, x0, gam) = A * gam**2 / ((x - x0)**2 + gam**2)
L_fwhm(gam)      = 2.0 * gam
L_area(A, gam)   = pi * A * gam

# ── Pseudo-Voigt (Thompson-Cox-Hastings approximation) ────────────────
# eta: mixing parameter (0=pure Gaussian, 1=pure Lorentzian)
# Use this when you don't want to deal with convolution integrals
# eta can be fixed or fitted; start with eta=0.5 for Raman
PV(x, A, x0, f, eta) = A * (eta * L(x,1,x0,f/2.0) + (1-eta) * G(x,1,x0,f/2.355))

# ── True Voigt (Faddeeva approximation, accurate to ~1e-4) ───────────
# Requires gL (Lorentzian HWHM) and gG (Gaussian sigma)
# Computationally heavier — use PV for most Raman work
# Uncomment if needed:
# V(x, A, x0, gL, gG) = ... # gnuplot has no complex erfc; use PV instead

# ── Fano lineshape ────────────────────────────────────────────────────
# q: Fano asymmetry parameter  gam: HWHM  x0: center  A: scale
# q→∞ recovers Lorentzian; q=0 gives pure dip
# Relevant: MoS2 A1g Fano interference with electronic continuum
Fano(x, A, x0, gam, q) = A * (1.0 + (x - x0) / (q * gam))**2 \
                            / (1.0 + ((x - x0) / gam)**2)

# ── Arrhenius ─────────────────────────────────────────────────────────
# Ea in eV, kB in eV/K
kB = 8.617333e-5
Arrhenius(T, A, Ea) = A * exp(-Ea / (kB * T))

# ── Bose-Einstein occupation ──────────────────────────────────────────
nBE(omega, T) = 1.0 / (exp(omega / (kB * T)) - 1.0)

# ── Linear background ─────────────────────────────────────────────────
BG(x, m, c) = m * x + c

# ── Multi-peak convenience wrappers ───────────────────────────────────
# Two Lorentzians + linear background (e.g. 2D + G Raman bands)
L2BG(x, A1,x1,g1, A2,x2,g2, m,c) = \
    L(x,A1,x1,g1) + L(x,A2,x2,g2) + BG(x,m,c)

# Three Lorentzians + background (e.g. D + G + 2D)
L3BG(x, A1,x1,g1, A2,x2,g2, A3,x3,g3, m,c) = \
    L(x,A1,x1,g1) + L(x,A2,x2,g2) + L(x,A3,x3,g3) + BG(x,m,c)
