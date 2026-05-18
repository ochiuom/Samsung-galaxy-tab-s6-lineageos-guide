#include "TH1F.h"
#include "TF1.h"
#include "TMath.h"
#include "TCanvas.h"
#include "TLegend.h"
#include "TStyle.h"

// --- 1. DEFINE MATH FUNCTIONS FIRST ---
// This ensures the compiler knows what they are when we call them later.

Double_t background(Double_t *x, Double_t *par) {
   return par[0] + par[1]*x[0] + par[2]*x[0]*x[0];
}

Double_t lorentzianPeak(Double_t *x, Double_t *par) {
   return (0.5*par[0]*par[1]/TMath::Pi()) / TMath::Max(1.e-10,
   (x[0]-par[2])*(x[0]-par[2])+ .25*par[1]*par[1]);
}

Double_t fitFunction(Double_t *x, Double_t *par) {
   return background(x, par) + lorentzianPeak(x, &par[3]);
}

// --- 2. NOW DEFINE THE MAIN MACRO ---

void FittingDemo() {
   // Set Publication Styles
   gStyle->SetOptStat(0);
   gStyle->SetOptFit(1); // Keep it for now to verify chi-square

   const int nBins = 60;
   Double_t data[nBins] = { 6, 1,10,12, 6,13,23,22,15,21,
   23,26,36,25,27,35,40,44,66,81,
   75,57,48,45,46,41,35,36,53,32,
   40,37,38,31,36,44,42,37,32,32,
   43,44,35,33,33,39,29,41,32,44,
   26,39,29,35,32,21,21,15,25,15};

   TH1F *histo = new TH1F("histo", "Research Quality Fit;Energy [GeV];Events / 0.05 GeV", 60, 0, 3);
   for(int i=0; i < nBins; i++) {
      histo->SetBinContent(i+1, data[i]);
      histo->SetBinError(i+1, TMath::Sqrt(data[i]));
   }

   // Style the histogram
   histo->SetMarkerStyle(20);
   histo->SetMarkerSize(1.0);
   histo->SetLineWidth(2);

   // Create the global fit function
   TF1 *fitFcn = new TF1("fitFcn", fitFunction, 0, 3, 6);
   fitFcn->SetLineColor(kRed);
   fitFcn->SetLineWidth(3);
   fitFcn->SetNpx(1000); // Super smooth line

   // Set initial parameters
   fitFcn->SetParameters(10, 2, 0.1, 40, 0.4, 1.0);
   fitFcn->SetParNames("Bkg_Const", "Bkg_Slope", "Bkg_Quad", "Peak_Area", "Peak_Width", "Peak_Mean");

   TCanvas *c1 = new TCanvas("c1", "c1", 900, 700);
   histo->Draw("E1");
   histo->Fit("fitFcn", "R");

   // Draw Background Component
   TF1 *backOnly = new TF1("backOnly", background, 0, 3, 3);
   backOnly->SetParameters(fitFcn->GetParameters());
   backOnly->SetLineColor(kBlue);
   backOnly->SetLineStyle(2);
   backOnly->Draw("same");

   // Draw Peak Component (Shaded)
   TF1 *peakOnly = new TF1("peakOnly", lorentzianPeak, 0, 3, 3);
   peakOnly->SetParameters(&fitFcn->GetParameters()[3]);
   peakOnly->SetLineColor(kGreen+2);
   peakOnly->SetFillColorAlpha(kGreen+2, 0.3); // Transparent green fill
   peakOnly->SetFillStyle(1001);
   peakOnly->Draw("same");

   // Add Legend
   TLegend *leg = new TLegend(0.6, 0.6, 0.88, 0.88);
   leg->SetBorderSize(0);
   leg->AddEntry(histo, "Data", "lep");
   leg->AddEntry(fitFcn, "Global Fit", "l");
   leg->AddEntry(backOnly, "Background", "l");
   leg->AddEntry(peakOnly, "Lorentzian Signal", "f");
   leg->Draw();

   c1->SaveAs("Publication_Fit.pdf");
}
