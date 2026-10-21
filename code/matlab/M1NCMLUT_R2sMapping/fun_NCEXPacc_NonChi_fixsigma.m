function sig_NCEXP_NonChi = fun_NCEXPacc_NonChi_fixsigma(param, TE)
% plot rician noise corrected signal 
global Ncoils;
global global_sigma;
global pp_initial;
sigma = global_sigma;

s0 = param(1);
R2 = param(2);

s = s0*exp(-TE*R2);

temp1 = -0.5*((s/sigma).^2);%*Ncoils

temp2 = 1;
temp = 2*Ncoils - 1;
while (temp > 1)
    temp2 = temp2 * temp;
    temp = temp - 2;
end

temp3 = (2.^(Ncoils-1)) * factorial(Ncoils-1);

% the kummer function has some problem when z is much small for example -400;
%sig_NCEXP_NonChi = sqrt(0.5*pi) * sigma * temp2 * kummer(-0.5, Ncoils, temp1)/ tem
% sig_NCEXP_NonChi = sqrt(0.5*pi) * sigma * temp2 * hypergeom(-0.5, Ncoils, temp1)/ temp3;ppval(pp(5),-temp1)

sig_NCEXP_NonChi = sqrt(0.5*pi) * sigma * temp2 * real(ppval(pp_initial(log2(Ncoils)+1),-temp1))/ temp3;

% sig_NCEXP_NonChi = sqrt(0.5*pi) * sigma * temp2*ppval(pp_interval1_50,-temp1))/ temp3;
% sig_NCEXP_NonChi = sqrt(0.5*pi) * sigma * temp2 * ppval(pp_real(log2(Ncoils)+1),-temp1)/ temp3;
