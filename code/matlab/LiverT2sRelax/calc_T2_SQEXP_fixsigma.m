function [T2_SQEXP, M0_SQEXP] = calc_T2_SQEXP_fixsigma(te,signal_measured_square)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng 
maxsignal = sqrt(max(signal_measured_square));
minsignal = min(signal_measured_square);

param0(1) = maxsignal;
param0(2) = max(te)*0.5;


lb=[maxsignal 0.1];%
% lb=[];
ub=[max(10.0*maxsignal, 100) 3*max(te)];%
% ub=[];%set no bounds

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
     'TolFun',10^(-10),'TolX',10^(-10),...
  'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag]=lsqcurvefit(@fun_SQEXP_fixsigma,param0,te,signal_measured_square,lb,ub,options);
exitflag

T2_SQEXP = param(2);
M0_SQEXP = param(1);

return