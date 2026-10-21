clear; clc;

for i = 1 : 5000
    R2s = 1;
    S0 = 100;
    sigma = 5;
    TE = 0 : 0.01 : 20;
    Sreal = S0 * exp(- TE * R2s);
    Simag = 0;
    nreal = normrnd(0, sigma, size(Sreal));
    nimag = normrnd(0, sigma, size(Sreal));
    SM(i, :) = sqrt((Sreal + nreal).^2 + (Simag + nimag).^2);
    SM2(i, :) = (Sreal + nreal).^2 + (Simag + nimag).^2;
end

ESM2 = Sreal.^2 + 2 * sigma^2;
SMm = mean(SM, 1); SM2m = mean(SM2, 1);

figure; 
plot(TE, Sreal, 'Color', 'r', 'LineWidth', 2); 
hold on; 
line([0,20], [0,0], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2); 
hold off; 
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-10, 105]);

figure
plot(TE, Simag, 'Color', 'r', 'LineWidth', 2);
hold on;
line([0,20], [0,0], 'linestyle', '-', 'Color', 'r', 'LineWidth', 2);
hold off;
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-10, 105]);

figure
plot(TE, nreal, 'Color', 'r', 'LineWidth', 2); 
hold on;
line([0,20], [0,0], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-10, 105]);

figure
plot(TE, nimag, 'Color', 'r', 'LineWidth', 2); 
hold on;
line([0,20], [0,0], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-10, 105]);

figure
plot(TE, SM(2500, :), 'Color', 'r', 'LineWidth', 2); 
hold on;
plot(TE, SMm, 'Color', 'g', 'LineWidth', 2);
line([0,20], [0,0], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-10, 105]);

figure
plot(TE, SM2(2500, :), 'Color', 'r', 'LineWidth', 2); 
hold on
plot(TE, SM2m, 'Color', 'g', 'LineWidth', 2);
line([0,20], [0,0], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('TE', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
ylabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');
set(gca, 'YLim',[-1000, 11000]);

A = SM(500, 401:2001);
y1 = median(A);
figure
histogram(A, 20);
hold on;
line([y1,y1], [0,250], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');

B = SM2(500, 401:2001);
y2 = median(B);
figure
histogram(B, 20);
hold on;
line([y2,y2], [0,500], 'linestyle', '--', 'Color', 'k', 'LineWidth', 2);
hold off;
xlabel('Signal Intensity', 'FontName', 'Times New Roman', 'FontWeight', 'bold');

C = SM2m(401:2001);
D = B - C;
E = D(D < 0);
F = D(D > 0);
G = sum(E);
G = abs(sum(E));
H = sum(F);