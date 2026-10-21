function [T2, M0, numofTrunc] = calc_T2_AutoTrunc_sigma(te, signal_ric_noise)
%curve fitting with automatic trunction algorithm
%modified by Meiyan Feng
global global_sigma;
sigma = global_sigma;
numofTrunc = 0;
while((signal_ric_noise(end) < 3*sigma) && (size(te, 2) > 2))
   [te signal_ric_noise] = dataTrunc(te, signal_ric_noise,1);
   numofTrunc = numofTrunc + 1;
end

[T2,M0] = calc_T2(te,signal_ric_noise);


