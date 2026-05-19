% Raman multi-peak Lorentzian fitting: Bulk_300K.dat
% Octave — requires optim + signal packages

clear; clc; close all;
pkg load optim;
pkg load signal;

% ── 1. Load data ──────────────────────────────────────────────────────────
d = load('Bulk_300K.dat');
x = d(:,1);
y = d(:,2);

% ── 2. ALS baseline ───────────────────────────────────────────────────────
function bg = als_baseline(y, lambda, p, niter)
  n  = numel(y);
  D  = diff(speye(n), 2);
  H  = lambda .* (D' * D);
  w  = ones(n, 1);
  for k = 1:niter
    W  = spdiags(w, 0, n, n);
    bg = (W + H) \ (w .* y);
    w  = p .* (y > bg) + (1 - p) .* (y <= bg);
  end
end

lambda_als = 1e8;
p_als      = 0.001;
bg = als_baseline(y, lambda_als, p_als, 20);
ys = y - bg;

% ── 3. Multi-Lorentzian model ─────────────────────────────────────────────
function val = multi_lor(p, xi)
  n   = numel(p) / 3;
  val = zeros(size(xi));
  for i = 1:n
    amp = p(3*i-2);  cen = p(3*i-1);  wid = p(3*i);
    val += amp .* (wid/2).^2 ./ ((xi - cen).^2 + (wid/2).^2);
  end
end

% ── 4. Initial guesses ────────────────────────────────────────────────────
p0 = [
  4478.5,   73.8,  12.3;
  3316.0,  242.4,  14.6;
  2851.8,  284.4,  24.6;
  2847.0,  337.3,  30.5;
  1873.2,  389.1,  28.2;
   634.1,  621.6,  12.3;
   721.6,  668.0,  23.5;
   701.1,  724.2,  37.6;
    78.0, 1032.0,  23.5;
    30.5, 1307.2,  15.0;
    44.5, 1607.1,  28.3;
];
p0_vec  = reshape(p0', 1, []);
n_peaks = size(p0, 1);

lb = repmat([0,   -Inf, 0.5], 1, n_peaks);
ub = repmat([Inf,  Inf, 150], 1, n_peaks);

% ── 5. Fit ────────────────────────────────────────────────────────────────
fit_mask = (x >= 50) & (x <= 1700);
xf = x(fit_mask);
yf = ys(fit_mask);

opts = optimset('MaxIter', 10000, 'TolFun', 1e-12, 'TolX', 1e-12, 'Display', 'off');
[popt,resnorm,res,~,~,~,J] = lsqcurvefit(@multi_lor, p0_vec, xf, yf, lb, ub, opts);
pcov = full(inv(J'*J)) * (resnorm/numel(xf));
perr = sqrt(diag(pcov))';

fprintf('Resnorm: %.4g\n\n', resnorm);

% ── 6. Results table ──────────────────────────────────────────────────────
fprintf('%3s  %14s  %12s  %10s\n', '#', 'Center (cm-1)', 'FWHM (cm-1)', 'Amplitude');
for i = 1:n_peaks
  fprintf('%3d  %14.3f  %12.3f  %10.2f\n', i, popt(3*i-1), popt(3*i), popt(3*i-2));
end

fprintf('\n');
fprintf('%3s  %14s  %6s  %14s  %6s  %14s  %6s  %14s  %6s\n', ...
        '#','Center','+-','FWHM','+-','Amp','+-','Int_Area','+-');
for i = 1:n_peaks
  amp   = popt(3*i-2); cen = popt(3*i-1); wid = popt(3*i);
  da    = perr(3*i-2); dc  = perr(3*i-1); dw  = perr(3*i);
  area  = pi * amp * wid / 2;
  darea = pi/2 * sqrt((wid*da).^2 + (amp*dw).^2);
  fprintf('%3d  %14.4f  %6.4f  %14.4f  %6.4f  %14.2f  %6.2f  %14.2f  %6.2f\n', ...
          i, cen, dc, wid, dw, amp, da, area, darea);
end


fid = fopen('fit_results.dat', 'w');
fprintf(fid, '%3s  %14s  %6s  %14s  %6s  %14s  %6s  %14s  %6s\n', '#','Center','+-','FWHM','+-','Amp','+-','Int_Area','+-');
for i = 1:n_peaks
  amp=popt(3*i-2); cen=popt(3*i-1); wid=popt(3*i);
  da=perr(3*i-2); dc=perr(3*i-1); dw=perr(3*i);
  area=pi*amp*wid/2; darea=pi/2*sqrt((wid*da).^2+(amp*dw).^2);
  fprintf(fid, '%3d  %14.4f  %6.4f  %14.4f  %6.4f  %14.2f  %6.2f  %14.2f  %6.2f\n', i,cen,dc,wid,dw,amp,da,area,darea);
end
fclose(fid);

% ── 7. Reconstruct ────────────────────────────────────────────────────────
x_fine   = linspace(min(x), max(x), 5000)';
fit_sub  = multi_lor(popt, x);
fit_fine = multi_lor(popt, x_fine);
residual = ys - fit_sub;

peaks_fine = zeros(numel(x_fine), n_peaks);
for i = 1:n_peaks
  amp = popt(3*i-2);  cen = popt(3*i-1);  wid = popt(3*i);
  peaks_fine(:,i) = amp .* (wid/2).^2 ./ ((x_fine - cen).^2 + (wid/2).^2);
end

% ── 8. Colours ────────────────────────────────────────────────────────────
c_data = [0.00, 0.45, 0.70];
c_bg   = [0.50, 0.50, 0.50];
c_fit  = [0.00, 0.00, 0.00];
c_res  = [0.84, 0.37, 0.00];

peak_colors = [
  0.00, 0.62, 0.45;
  0.80, 0.47, 0.65;
  0.84, 0.37, 0.00;
  0.94, 0.89, 0.26;
  0.00, 0.45, 0.70;
  0.34, 0.71, 0.91;
  0.90, 0.62, 0.00;
  0.00, 0.62, 0.45;
  0.80, 0.47, 0.65;
  0.84, 0.37, 0.00;
  0.34, 0.71, 0.91;
];

% ── 9. Style helper ───────────────────────────────────────────────────────
function pub_ax(ax)
  set(ax, 'FontSize',   12, ...
          'FontName',   'Helvetica', ...
          'LineWidth',  1.2, ...
          'TickDir',    'in', ...
          'TickLength', [0.012 0.012], ...
          'XMinorTick', 'on', ...
          'YMinorTick', 'on', ...
          'Box',        'on', ...
          'XGrid',      'off', ...
          'YGrid',      'off');
end

% ── 10. Figure 1: raw + ALS baseline ─────────────────────────────────────
fig1 = figure('Color', 'white', 'Units', 'centimeters', 'Position', [2 2 18 9]);
set(fig1, 'PaperUnits', 'centimeters', 'PaperSize', [18 9], 'PaperPosition', [0 0 18 9]);

axes('Position', [0.11 0.14 0.86 0.80]);
plot(x, y, 'o', 'MarkerSize', 2.0, 'MarkerEdgeColor', c_data, ...
     'MarkerFaceColor', c_data + 0.5*(1-c_data), 'DisplayName', 'Raw data');
hold on;
plot(x, bg, '-', 'Color', c_bg, 'LineWidth', 2.0, 'DisplayName', 'ALS baseline');
pub_ax(gca);
xlim([40 1800]); ylim([0 max(y)*1.10]);
xlabel('Raman Shift (cm^{-1})',  'FontSize', 13, 'FontName', 'Helvetica');
ylabel('Intensity (arb. units)', 'FontSize', 13, 'FontName', 'Helvetica');
title('(a)  Raw spectrum + ALS baseline', 'FontSize', 12, 'FontName', 'Helvetica', 'FontWeight', 'normal');
legend('Location', 'northeast', 'FontSize', 11, 'Box', 'off');
text(0.02, 0.94, sprintf('\\lambda = %.0e,   p = %.3f', lambda_als, p_als), ...
     'Units', 'normalized', 'FontSize', 9, 'FontName', 'Helvetica', 'Color', [0.4 0.4 0.4]);

print(fig1, 'fig1_background.pdf', '-dpdf', '-fillpage');
fprintf('Saved fig1_background.pdf\n');

% ── 11. Figure 2: fit + residual ──────────────────────────────────────────
fig2 = figure('Color', 'white', 'Units', 'centimeters', 'Position', [2 2 18 16]);
set(fig2, 'PaperUnits', 'centimeters', 'PaperSize', [18 16], 'PaperPosition', [0 0 18 16]);

ax1 = axes('Position', [0.11 0.22 0.86 0.73]);
hold on;

%for i = 1:n_peaks
%  col = peak_colors(i,:);
%  fill([x_fine; flipud(x_fine)], [peaks_fine(:,i); zeros(numel(x_fine),1)], ...
%       col, 'FaceAlpha', 0.20, 'EdgeColor', col, 'LineWidth', 1.4, ...
%       'HandleVisibility', 'off');
%end

for i = 1:n_peaks
  col = peak_colors(i,:);
  plot(x_fine, peaks_fine(:,i), '-', ...
       'Color',            col, ...
       'LineWidth',        1.2, ...
       'HandleVisibility', 'off');
end

plot(x, ys, 'o', 'MarkerSize', 2.0, 'MarkerEdgeColor', c_data, ...
     'MarkerFaceColor', c_data + 0.5*(1-c_data), 'DisplayName', 'Data (BG subtracted)');
plot(x_fine, fit_fine, '-', 'Color', c_fit, 'LineWidth', 2.0, 'DisplayName', 'Total fit');

ymax_main = max(ys) * 1.12;
for i = 1:n_peaks
  cen = popt(3*i-1);
  if cen >= 40 && cen <= 1800
    plot([cen cen], [ymax_main*0.90 ymax_main*0.98], '-', ...
         'Color', [0.4 0.4 0.4], 'LineWidth', 0.9, 'HandleVisibility', 'off');
  end
end

pub_ax(ax1);
set(ax1, 'XTickLabel', {});
xlim([30 1800]); ylim([0 ymax_main]);
xticks(30:170:1800);
ylabel('Intensity (arb. units)', 'FontSize', 9, 'FontName', 'Helvetica');
set(get(gca, 'YLabel'), 'Units', 'normalized', 'Position', [-0.08, 0.5, 0]);
title('(b)  Raman spectrum  |  Multi-Lorentzian fit', ...
      'FontSize', 9, 'FontName', 'Helvetica', 'FontWeight', 'normal');
%legend('Location', 'southeast', 'FontSize', 11, 'Box', 'off');
%legend('Position', [0.65 0.40 0.15 0.08], 'FontSize', 11, 'Box', 'off');

txt = '';
for i = 1:n_peaks
  txt = [txt sprintf('Peak %2d   %7.2f cm-1   FWHM %5.2f cm-1\n', ...
         i, popt(3*i-1), popt(3*i))];
end
text(0.98, 0.75, txt, 'Units', 'normalized', ...
     'FontSize', 9.5, 'FontName', 'Helvetica', ...
     'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
     'BackgroundColor', [0.97 0.97 0.97], ...
     'EdgeColor', [0.70 0.70 0.70], ...
     'Parent', ax1);

ax2 = axes('Position', [0.11 0.07 0.86 0.13]);
hold on;
plot(x, residual, 'o', 'MarkerSize', 1.6, 'MarkerEdgeColor', c_res, ...
     'MarkerFaceColor', c_res + 0.5*(1-c_res), 'HandleVisibility', 'off');
plot([30 1800], [0 0], '-', 'Color', [0.3 0.3 0.3], 'LineWidth', 1.0, ...
     'HandleVisibility', 'off');
pub_ax(ax2);
xlim([30 1800]);
xticks(30:170:1800);
rlim = max(abs(residual(fit_mask))) * 1.4;
ylim([-rlim rlim]);
xlabel('Raman Shift (cm^{-1})', 'FontSize', 13, 'FontName', 'Helvetica');
ylabel('Residual',              'FontSize', 10, 'FontName', 'Helvetica');

print(fig2, 'fig2_fit.pdf', '-dpdf', '-fillpage');
fprintf('Saved fig2_fit.pdf\n');
