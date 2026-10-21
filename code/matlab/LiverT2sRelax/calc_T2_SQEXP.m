function [T2_SQEXP, M0_SQEXP, sigma_SQEXP] = calc_T2_SQEXP(te,signal_measured_square)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng
maxsignal = sqrt(max(signal_measured_square));
minsignal = min((signal_measured_square));

param0(1) = maxsignal;
param0(2) = 0.5*max(te);
param0(3) = maxsignal/20;

lb=[maxsignal 0.1 min(0.5*minsignal,0)];
% lb=[];
ub=[max(10.0*maxsignal,100) 3*max(te) 100];

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
           'ScaleProblem','jacobian',...
     'TolFun',10^(-10),'TolX',10^(-10),...
  'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag]=lsqcurvefit(@fun_SQEXP,param0,te,signal_measured_square,lb,ub,options);
exitflag

T2_SQEXP = param(2);
M0_SQEXP = param(1);
sigma_SQEXP = param(3);

return