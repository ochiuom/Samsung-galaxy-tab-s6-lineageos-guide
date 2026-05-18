# ── fitting_lorentzian.gp ─────────────────────────────────────────────
# Raman/PL peak fitting: single or multi-peak Lorentzian/Voigt/Fano
# Usage:
#   gnuplot fitting_lorentzian.gp
#   gnuplot -e "DATAFILE='raman.dat'; XCOL=1; YCOL=2" fitting_lorentzian.gp
#   gnuplot -e "MODE='fano'" fitting_lorentzian.gp

load "math.gp"

# ── Inputs ────────────────────────────────────────────────────────────
if (!exists("DATAFILE")) { DATAFILE = "data.dat" }
if (!exists("XCOL"))     { XCOL     = 1          }
if (!exists("YCOL"))     { YCOL     = 2          }
if (!exists("MODE"))     { MODE     = "lorentz"  }  # lorentz | pseudovoigt | fano | double
if (!exists("XMIN"))     { XMIN     = "*"        }
if (!exists("XMAX"))     { XMAX     = "*"        }

set xrange [XMIN:XMAX]

# ── Axes ──────────────────────────────────────────────────────────────
set xlabel "Raman shift (cm^{-1})"
set ylabel "Intensity (arb. units)"
set title  ""

# ── Fit tolerances ────────────────────────────────────────────────────
set fit quiet
set fit errorvariables          # gives A_err, x0_err etc after fit
set fit covarianceVariables     # covariance matrix available
FIT_LIMIT = 1e-9

# ════════════════════════════════════════════════════════════════════════
if (MODE eq "lorentz") {
# ── Single Lorentzian + linear background ────────────────────────────
# Initial guesses — adjust to your peak
    A1  = 1000.0
    x1  = 385.0     # E2g MoS2 ~383, A1g ~408; adjust
    g1  = 3.0       # HWHM in cm^-1
    m   = 0.0
    c   = 50.0

    fit L(x,A1,x1,g1) + BG(x,m,c) DATAFILE \
        u XCOL:YCOL via A1,x1,g1,m,c

    FWHM = L_fwhm(g1)
    print sprintf(">>> x0 = %.3f ± %.3f cm^-1", x1, x1_err)
    print sprintf(">>> FWHM = %.3f cm^-1", FWHM)
    print sprintf(">>> Area = %.2f", L_area(A1,g1))

    plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
         L(x,A1,x1,g1) + BG(x,m,c) w lines lt 2 lw 2.5 t "Lorentzian fit", \
         BG(x,m,c)                  w lines lt 7 lw 1.0 dt 2 t "Background"

# ════════════════════════════════════════════════════════════════════════
} else { if (MODE eq "pseudovoigt") {
# ── Pseudo-Voigt (Raman with instrument broadening) ───────────────────
    A1   = 1000.0
    x1   = 385.0
    f1   = 5.0      # FWHM (not HWHM — PV uses FWHM internally)
    eta1 = 0.5      # start at 50/50; let fit decide
    m    = 0.0
    c    = 50.0

    fit PV(x,A1,x1,f1,eta1) + BG(x,m,c) DATAFILE \
        u XCOL:YCOL via A1,x1,f1,eta1,m,c

    print sprintf(">>> x0   = %.3f ± %.3f cm^-1", x1, x1_err)
    print sprintf(">>> FWHM = %.3f cm^-1", f1)
    print sprintf(">>> eta  = %.3f (0=Gauss, 1=Lorentz)", eta1)

    plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
         PV(x,A1,x1,f1,eta1) + BG(x,m,c) w lines lt 2 lw 2.5 t "Pseudo-Voigt fit", \
         BG(x,m,c)                        w lines lt 7 lw 1.0 dt 2 t "Background"

# ════════════════════════════════════════════════════════════════════════
} else { if (MODE eq "fano") {
# ── Fano (A1g MoS2, graphene G-band under doping) ────────────────────
    A1   = 1000.0
    x1   = 408.0
    g1   = 3.0
    q1   = 5.0      # large q → nearly Lorentzian; try negative for asymmetry flip
    m    = 0.0
    c    = 50.0

    fit Fano(x,A1,x1,g1,q1) + BG(x,m,c) DATAFILE \
        u XCOL:YCOL via A1,x1,g1,q1,m,c

    print sprintf(">>> x0 = %.3f ± %.3f cm^-1", x1, x1_err)
    print sprintf(">>> q  = %.3f (asymmetry)", q1)
    print sprintf(">>> HWHM = %.3f cm^-1", g1)

    plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
         Fano(x,A1,x1,g1,q1) + BG(x,m,c) w lines lt 2 lw 2.5 t "Fano fit", \
         BG(x,m,c)                        w lines lt 7 lw 1.0 dt 2 t "Background"

# ════════════════════════════════════════════════════════════════════════
} else { if (MODE eq "double") {
# ── Two Lorentzians + background (e.g. E2g + A1g of MoS2) ────────────
    A1 = 1000.0 ; x1 = 383.0 ; g1 = 3.0
    A2 = 800.0  ; x2 = 408.0 ; g2 = 3.5
    m  = 0.0    ; c  = 50.0

    fit L2BG(x, A1,x1,g1, A2,x2,g2, m,c) DATAFILE \
        u XCOL:YCOL via A1,x1,g1,A2,x2,g2,m,c

    SEP = x2 - x1
    print sprintf(">>> Peak 1: x0 = %.3f ± %.3f cm^-1  FWHM = %.3f", x1, x1_err, L_fwhm(g1))
    print sprintf(">>> Peak 2: x0 = %.3f ± %.3f cm^-1  FWHM = %.3f", x2, x2_err, L_fwhm(g2))
    print sprintf(">>> Separation = %.3f cm^-1", SEP)

    plot DATAFILE u XCOL:YCOL w points lt 1 t "Data", \
         L2BG(x,A1,x1,g1,A2,x2,g2,m,c) w lines lt 2 lw 2.5 t "Total fit", \
         L(x,A1,x1,g1) + BG(x,m,c)     w lines lt 3 lw 1.5 dt 2 t "E_{2g}", \
         L(x,A2,x2,g2) + BG(x,m,c)     w lines lt 6 lw 1.5 dt 2 t "A_{1g}", \
         BG(x,m,c)                      w lines lt 7 lw 1.0 dt 3 t "Background"

}}}}
