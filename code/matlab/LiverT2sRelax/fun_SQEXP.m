function sig_SQEXP = fun_SQEXP(param, TE)

sigma = param (3); 
s0 = param(1); 
T2 = param(2);


sig_SQEXP = s0*s0*exp(-2*TE/T2) + 2*sigma*sigma;