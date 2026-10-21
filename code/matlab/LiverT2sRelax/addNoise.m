function [Sn] = addNoise(S, sigma, Ncoils)
Sn = zeros(size(S));
temp = S ./ sqrt(Ncoils);

for N = 1 : Ncoils
   real = temp +  normrnd(0, sigma, size(S));
   imag = normrnd(0, sigma, size(S));
   Sn = Sn + real.^2 + imag.^2;
end

Sn = sqrt(Sn);

end