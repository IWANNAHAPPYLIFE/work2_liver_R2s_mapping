function [R2_NCEXPacc M0_NCEXPacc] = calc_R2_NCEXPacc_NonChi_fixsigma(te,signal_measured)
% Fitting the curve using NCEXPacc method.


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

[param,res,residual,exitflag,output]=lsqcurvefit(@fun_NCEXPacc_NonChi_fixsigma,param0,te,signal_measured,lb,ub,options);
exitflag
R2_NCEXPacc = param(2);
M0_NCEXPacc= param(1);
% xx=output;
return