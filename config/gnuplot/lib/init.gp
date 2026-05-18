# ── init.gp ───────────────────────────────────────────────────────────
# Safe init: do not check GPVAL_TERMINAL here — undefined at startup
# Terminal detection handled per-script via MODE= variable
# This file loaded by ~/.gnuplot on every gnuplot launch

load "style_publication.gp"
print ">>> [gnuplot] Research Suite Loaded"
