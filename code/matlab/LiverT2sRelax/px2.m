clear;clc;
L = [1 2 4 8];
sigma = 1;
S = [5 15 30 60];
% for i = 1 : 4
    for j = 1 : 4
        for k = 1 : 10000000
           Sn = 0;
           temp = S(3) / sqrt(L(j));
           for N = 1 : L(j)
               real = temp +  sigma * randn(1);
               imag = sigma * randn(1);
               Sn = Sn + real.^2 + imag.^2;
           end
           SM(k) = Sn;
        end
        [f,xi] = ksdensity(SM);
        hold on
        plot(xi, f, 'LineWidth', 2);
    end
    line([900,900], [0,0.0066], 'linestyle', '--', 'LineWidth', 2, 'Color', 'k');
    legend('SNR=30, L=1', 'SNR=30, L=2', 'SNR=30, L=4', 'SNR=30, L=8', 'S^2');
% end 
