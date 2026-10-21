function [R2_NCEXP M0_NCEXP res exitflag] = calc_R2_NCEXP_NonChi_fixsigma(te,signal_measured)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng 

maxsignal = max(signal_measured);
minsignal = min(signal_measured);

param0(1) = maxsignal;
param0(2) = 0.5;

lb=[maxsignal 0];
% lb=[];
ub=[10.0*maxsignal 2];
% ub=[];%set no bounds

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
           'ScaleProblem','jacobian',...
     'TolFun',10^(-10),'TolX',10^(-10),...
  'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag,output]=lsqcurvefit(@fun_NCEXP_NonChi_fixsigma,param0,te,signal_measured,lb,ub,options);
exitflag
R2_NCEXP = param(2);
M0_NCEXP = param(1);
% xx=output;
return