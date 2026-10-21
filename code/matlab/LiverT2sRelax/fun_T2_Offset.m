% pure exponential decay, truncation model
function F = fun_T2_Offset(param,xdata)
F = param(1)*exp(-xdata/param(2))+param(3);