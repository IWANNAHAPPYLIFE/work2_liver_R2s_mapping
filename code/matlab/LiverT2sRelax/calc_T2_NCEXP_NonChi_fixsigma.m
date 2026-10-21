function [T2_NCEXP M0_NCEXP] = calc_T2_NCEXP_NonChi_fixsigma(te,signal_measured)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng 

maxsignal = max(signal_measured);
minsignal = min(signal_measured);

param0(1) = maxsignal;
param0(2) = 0.5*max(te);

lb=[maxsignal 0.1];
% lb=[];
ub=[10.0*maxsignal 2*max(te)];
% ub=[];%set no bounds

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
           'ScaleProblem','jacobian',...
     'TolFun',10^(-10),'TolX',10^(-10),...
  'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag]=lsqcurvefit(@fun_NCEXP_NonChi_fixsigma,param0,te,signal_measured,lb,ub,options);
exitflag

T2_NCEXP = param(2);
M0_NCEXP = param(1);

return