function [T2_NCEXP, M0_NCEXP, sigma_NCEXP] = calc_T2_NCEXP(te,signal_measured)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng 

maxsignal = max(signal_measured);
minsignal = min(signal_measured);

param0(1) = maxsignal;
param0(2) = 0.5*max(te);
param0(3) = 10;

lb=[maxsignal 0.1 min(0.5*minsignal,0)];
% lb=[];
ub=[max(10.0*maxsignal,100) 2*max(te) 100];
% ub=[];%set no bounds

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
           'ScaleProblem','jacobian',...
     'TolFun',10^(-10),'TolX',10^(-10),...
  'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag]=lsqcurvefit(@fun_NCEXP,param0,te,signal_measured,lb,ub,options);
exitflag

T2_NCEXP = param(2);
M0_NCEXP = param(1);
sigma_NCEXP = param(3);

return