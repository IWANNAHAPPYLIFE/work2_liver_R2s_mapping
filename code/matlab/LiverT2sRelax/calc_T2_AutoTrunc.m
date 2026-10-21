function [T2, M0, numofTrunc] = calc_T2_AutoTrunc(te, signal_ric_noise)
% curve fitting with automatic trunction algorithm
Rs_error = 0;
T2_last = 0;
numofTrunc = 0;
while(Rs_error<0.995 && size(te, 2) > 2)
    [Para(1), Para(2)]= calc_R2(te,signal_ric_noise); % R2
    signal_fitted_ric=Para(1)*exp(-te*Para(2)); % fitted signal
    Rs_error = calcRs_error(signal_ric_noise, signal_fitted_ric);
    if (Rs_error < 0.995 && size(te, 2) > 2)
        T2_last = 1/Para(2);
        M0 = Para(1);
        [te, signal_ric_noise] = dataTrunc(te, signal_ric_noise,1); % trunc the last one 
        numofTrunc = numofTrunc + 1;
    end
end

T2 = 1/Para(2);
M0 = Para(1);
if(T2_last > 0 && size(te, 2) > 2)
    while(abs(T2 - T2_last)/T2 > 0.025 && size(te, 2) > 2)
        [te, signal_ric_noise] = dataTrunc(te, signal_ric_noise,1);
        numofTrunc = numofTrunc + 1;
        [Para(1), Para(2)] = calc_R2(te,signal_ric_noise);               
        T2_last = T2;
        T2 = 1/Para(2);
        M0 = Para(1);
    end
end




