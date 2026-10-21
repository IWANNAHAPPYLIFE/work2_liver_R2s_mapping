function Rs_error = calcRs_error(signal_noise,signal_fitted)
%% calculate the R2 error of estimation
aver_value = mean(signal_noise);

temp = signal_noise - aver_value;
sst = sum(sum(temp .^ 2));

temp = signal_noise - signal_fitted;
sse = sum(sum(temp .^ 2));

Rs_error =  1 - sse / sst;