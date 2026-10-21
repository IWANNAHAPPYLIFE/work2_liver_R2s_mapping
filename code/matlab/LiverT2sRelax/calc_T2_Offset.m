function  [T2_est, M0_est, Offset] = calc_T2_Offset(te,signal_measured)
% Fitting the curve using NCEXP method.
% Written by Yanqiu Feng 


maxsignal = max(signal_measured);
minsignal = min(signal_measured);

param0(1) = maxsignal;
param0(2) = 0.5*max(te);
param0(3) = 10;

lb=[maxsignal 0.1 0];%
% lb=[];
ub=[max(10.0*maxsignal, 100) 3*max(te) 100];%

options = optimset('LargeScale','on',...
            'Algorithm', 'levenberg-marquardt',...
            'ScaleProblem','jacobian',...
            'TolFun',10^(-10),'TolX',10^(-10),...
            'MaxFunEvals',1000000,'MaxIter',1000000);

[param,res,residual,exitflag]=lsqcurvefit(@fun_T2_Offset,param0,te,signal_measured,lb,ub,options);
exitflag

T2_est = param(2);
M0_est = param(1);
Offset = param(3);

return