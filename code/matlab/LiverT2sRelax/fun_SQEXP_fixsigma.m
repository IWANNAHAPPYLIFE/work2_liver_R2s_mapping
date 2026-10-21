function sig_SQEXP = fun_SQEXP_fixsigma(param, TE)

global squaresigma;
s0 = param(1);
T2 = param(2);

sig_SQEXP = s0*s0*exp(-2*TE/T2) + squaresigma;
