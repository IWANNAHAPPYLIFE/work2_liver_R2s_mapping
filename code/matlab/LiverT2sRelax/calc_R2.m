function [M0,R2] = calc_R2(TE,S)

param0(1) = max(S(:));
param0(2) = 0.5*max(TE);
lb=[max(S(:)) 0.1];%
ub=[max(10*max(S(:)), 100) 3*max(TE)];%
% lb=[];ub=[];%set no bounds

options = optimset('LargeScale','on',...
           'Algorithm', 'levenberg-marquardt',...
     'TolFun',10^(-10),'TolX',10^(-10),... % TolX(Steptolerance),TolFun(OptimalityTolerance/functionTolerance)
  'MaxFunEvals',1000000,'MaxIter',1000000); % MaxIter(MaxItrations), MaxFunEvals(MaxFunctionEvaluations)

[param,~,~,exitflag]=lsqcurvefit(@fun_T2,param0,TE,S,lb,ub,options);
% exitflag;

R2 = 1/param(2);
M0 = param(1);

return

function S = fun_T2(para,TE)

S = para(1).*exp(-TE/para(2));

