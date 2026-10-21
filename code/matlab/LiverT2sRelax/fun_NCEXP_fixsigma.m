function sig_NCEXP = fun_NCEXP_fixsigma(param, TE)
% plot rician noise corrected signal 

global sigma;
sigma = sigma;

s0 = param(1);
T2 = param(2);

s = s0*exp(-TE/T2);

alpha = (0.5*s/sigma).^2;

tempw = (1+2*alpha).*besseli(0,alpha,1) + 2*alpha.*besseli(1,alpha,1);

sig_NCEXP = sqrt(0.5*pi*sigma*sigma) .* tempw;