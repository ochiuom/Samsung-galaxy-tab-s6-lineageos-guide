import ROOT
import math

# 1. Logic Functions
def background_logic(x, par):
    return par[0] + par[1]*x[0] + par[2]*x[0]*x[0]

def lorentzian_logic(x, par):
    # par: [Area, Width, Mean]
    denom = (x[0]-par[2])*(x[0]-par[2]) + 0.25*par[1]*par[1]
    return (0.5*par[0]*par[1]/math.pi) / max(1.e-10, denom)

def fit_logic(x, par):
    # par[0-2] = background, par[3-5] = lorentzian
    return background_logic(x, par) + lorentzian_logic(x, [par[3], par[4], par[5]])

def FittingDemo():
    # Style
    ROOT.gStyle.SetOptStat(0)
    ROOT.gStyle.SetOptFit(1)

    data = [6, 1, 10, 12, 6, 13, 23, 22, 15, 21,
            23, 26, 36, 25, 27, 35, 40, 44, 66, 81,
            75, 57, 48, 45, 46, 41, 35, 36, 53, 32,
            40, 37, 38, 31, 36, 44, 42, 37, 32, 32,
            43, 44, 35, 33, 33, 39, 29, 41, 32, 44,
            26, 39, 29, 35, 32, 21, 21, 15, 25, 15]

    histo = ROOT.TH1F("histo", "Research Quality Fit;Energy [GeV];Events / 0.05 GeV", 60, 0, 3)
    for i, val in enumerate(data):
        histo.SetBinContent(i+1, val)
        histo.SetBinError(i+1, math.sqrt(val))

    histo.SetMarkerStyle(20)
    histo.SetMarkerSize(1.0)
    histo.SetLineWidth(2)

    # Global Fit
    fitFcn = ROOT.TF1("fitFcn", fit_logic, 0, 3, 6)
    fitFcn.SetParameters(10, 2, 0.1, 40, 0.4, 1.0)
    fitFcn.SetLineColor(ROOT.kRed)
    fitFcn.SetLineWidth(3)
    fitFcn.SetNpx(1000)

    c1 = ROOT.TCanvas("c1", "c1", 900, 700)
    histo.Draw("E1")
    histo.Fit(fitFcn, "R")

    # --- THE FIX: KEEP THE COMPONENTS ALIVE ---
    # We assign them to the 'c1' object or global variables so Python doesn't kill them
    
    # 1. Background Component
    c1.backOnly = ROOT.TF1("backOnly", background_logic, 0, 3, 3)
    c1.backOnly.SetParameters(fitFcn.GetParameters())
    c1.backOnly.SetLineColor(ROOT.kBlue)
    c1.backOnly.SetLineStyle(2)
    c1.backOnly.Draw("same")

    # 2. Peak Component (Shaded)
    c1.peakOnly = ROOT.TF1("peakOnly", lorentzian_logic, 0, 3, 3)
    # Peak parameters start at index 3 of the fit parameters
    pars = fitFcn.GetParameters()
    c1.peakOnly.SetParameters(pars[3], pars[4], pars[5])
    c1.peakOnly.SetLineColor(ROOT.kGreen+2)
    c1.peakOnly.SetFillColorAlpha(ROOT.kGreen+2, 0.3)
    c1.peakOnly.SetFillStyle(1001)
    c1.peakOnly.Draw("same")

    # Legend
    leg = ROOT.TLegend(0.6, 0.6, 0.88, 0.88)
    leg.SetBorderSize(0)
    leg.AddEntry(histo, "Data", "lep")
    leg.AddEntry(fitFcn, "Global Fit", "l")
    leg.AddEntry(c1.backOnly, "Background", "l")
    leg.AddEntry(c1.peakOnly, "Lorentzian Signal", "f")
    leg.Draw()
    
    # Force drawing and save
    c1.Update()
    c1.SaveAs("Publication_Fit_Python.pdf")
    
    # Keep the window from closing immediately
    print("Fit Complete. Check Publication_Fit_Python.pdf")
    ROOT.gApplication.Run() 

if __name__ == "__main__":
    FittingDemo()