function y = multi_lor(p, x)
  % p = [A1, x01, gamma1, A2, x02, gamma2, ..., offset]
  % Each peak: A * (gamma/2)^2 / ((x - x0)^2 + (gamma/2)^2)
  n_peaks = floor((length(p) - 1) / 3);
  y = zeros(size(x));
  for i = 1:n_peaks
    A     = p(3*i - 2);
    x0    = p(3*i - 1);
    gamma = p(3*i);
    y = y + A * (gamma/2)^2 ./ ((x - x0).^2 + (gamma/2)^2);
  end
  y = y + p(end);  % constant background offset
end