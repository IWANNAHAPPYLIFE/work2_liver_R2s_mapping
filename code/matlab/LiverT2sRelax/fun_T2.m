% pure exponential decay, truncation model
function F = fun_T2(param,xdata)
F = param(1)*exp(-xdata/param(2));

