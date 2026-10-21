function [f] = costfun(x)
global TE sigma Ncoils Sn

%% logarithm && addition
f = 0;
for i = 1 : length(TE)
    f = f + log(x(3)) + (Ncoils - 1) * log(x(1)) - (Ncoils - 1) * x(2) * TE(i) + (x(1)^2 / (2 * x(3))) * exp(-2 * TE(i) * x(2)) - Ncoils * log(Sn(i)) + (1 / (2 * x(3))) * Sn(i)^2 - log(besseli(Ncoils - 1, (Sn(i) * x(1) * exp(- TE(i) * x(2))) / x(3)));
end

%% fix sigma
% f = 0;
% for i = 1 : length(TE)
%     f = f + log(sigma^2) + (Ncoils - 1) * log(x(1)) - (Ncoils - 1) * x(2) * TE(i) + (x(1)^2 / (2 * sigma^2)) * exp(-2 * TE(i) * x(2)) - Ncoils * log(Sn(i)) + (1 / (2 * sigma^2)) * Sn(i)^2 - log(besseli(Ncoils - 1, (Sn(i) * x(1) * exp(- TE(i) * x(2))) / sigma^2));
% end

end