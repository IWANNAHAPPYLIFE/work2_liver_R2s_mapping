clear;clc;
global pp_initial; 
load('pp_initial.mat','pp_initial')
global TE sigma Ncoils Sn
%% %% simulation in average
TE = [0.93, 2.27, 3.61, 4.95, 6.29, 7.63, 8.97, 10.4, 11.8, 13.2, 14.6, 16];
sigma = 10;
Ncoils = 8;
S_0 = 150;
R2_s = 0.05;
for j = 1 : 20
    S = S_0 * exp(- TE * R2_s);
    for i = 1 : 1000
        Sn = addNoise(S, sigma, Ncoils);
        %% MLE no sigma
%         fun = @costfun;
%         x0 = [max(Sn), 1 / (0.5 * max(TE))];
%         lb = [max(Sn), 1 / (2 * max(TE))];
%         ub = [max(10 * max(Sn), 100), 3];
%         [x, fval, exitflag, output] = fmincon(fun, x0, [], [], [], [], lb, ub, []);
%         MLE_S0(i) = x(1); 
%         MLE_R2s(i) = x(2) * 1000;
        %% MLE with sigma
        fun = @costfun;
        x0 = [max(Sn), 1 / (0.5 * max(TE)), 100];
        lb = [max(Sn), 1 / (2 * max(TE)), min(0.5 * min(Sn), 0)];
        ub = [max(10 * max(Sn), 100), 3, 400];
        [x, fval, exitflag, output] = fmincon(fun, x0, [], [], [], [], lb, ub, []);
        MLE_S0(i) = x(1); 
        MLE_R2s(i) = x(2) * 1000; 
        MLE_sigma(i) = sqrt(x(3));
        %% look-up M1NCM
        [R2_NCEXP(i), M0_NCEXP(i), sigma_NCEXP(i)] = calc_R2_NCEXPacc_NonChi(TE, Sn);
    end
    mean_MLE_R2s(j) = mean(MLE_R2s); std_MLE_R2s(j) = std(MLE_R2s, 1);
    mean_R2_NCEXP(j) = mean(R2_NCEXP); std_R2_NCEXP(j) = std(R2_NCEXP, 1);
    clc
    R2_s = R2_s + 0.05;
end

x = 50 : 50 : 1000;
plot(x, x, 'MarkerSize',25,'Marker','.', 'LineWidth', 2, 'Color', 'r');
hold on
plot(x, mean_MLE_R2s, 'MarkerSize',25,'Marker','.', 'LineWidth', 2, 'Color', 'm');
hold on
plot(x, mean_R2_NCEXP, 'MarkerSize',25,'Marker','.', 'LineWidth', 2, 'Color', 'g');
hold on
line([0,1000],[1000,1000],'linestyle','--', 'LineWidth', 1.1, 'Color', 'k');
set(gcf,'Position',[400 200 430 550]);
set(gca, 'ytick',[0 500 1000 1500], ... 
         'YLim', [0 1500], ...
         'LineWidth', 1.1, ...
         'FontSize', 11);
title('SNR = 30', 'FontSize', 16, 'FontName', 'Times New Roman');
xlabel('True R2*(s^-^1)', 'FontSize', 16, 'FontName', 'Times New Roman');
ylabel('Mean of Estimated R2*(s^-^1)', 'FontSize', 16, 'FontName','Times New Roman');
legend('Identity', 'MLE', 'M1NCM', 'FontSize', 14, 'FontName', 'Times New Roman', 'Location','northwest');

figure
plot(x, std_MLE_R2s, 'MarkerSize',25,'Marker','.', 'LineWidth', 2, 'Color', 'm');
hold on
plot(x, std_R2_NCEXP, 'MarkerSize',25,'Marker','.', 'LineWidth', 2, 'Color', 'g');
set(gcf,'Position',[400 200 430 550]);
set(gca, 'LineWidth', 1.1, ...
         'FontSize', 11);
xlabel('True R2*(s^-^1)', 'FontSize', 16, 'FontName', 'Times New Roman');
ylabel('SD of Estimated R2*(s^-^1)', 'FontSize', 16, 'FontName','Times New Roman');
legend('MLE', 'M1NCM', 'FontSize', 14, 'FontName', 'Times New Roman', 'Location','northwest');
%% %% simulation in images
% Ncoils = 8;
% %% read dicom images
% nfolder = 'C:\Users\MRIlab\Desktop\temp\dcm\1';
% dfiles = dir(nfolder);
% dfiles = dfiles(3 : end);  
% nfiles=length(dfiles);
% DicomFileNo = 0;
% for currentfile = 1 : nfiles
%     file_info = dicominfo([nfolder, '\', dfiles(currentfile).name]);
%     DicomFileNo = DicomFileNo + 1;
%     TE(DicomFileNo) = file_info.EchoTime;
%     ImgData(:, :, DicomFileNo) = dicomread(file_info);
%     ImgData = double(ImgData);
%     subplot(3, 4, currentfile);
%     imshow(ImgData(:, :, currentfile), []);
% end
% mask = double(imread('F:\data\liver internal contour\gray\1.png'));
% mask = mask(:, :, 1);
% mask(mask == 255) = 1;
% mask = logical(mask);
% [X, Y] = find(mask);
% %% PCANR
% [S0map, R2smap]=qPCANR(ImgData, TE);
% figure
% imshow(R2smap, []);
% %% pixel wise fitting for PCANR
% SIM = zeros(size(ImgData, 1),size(ImgData, 2), size(ImgData, 3));
% figure
% for k = 1 : size(SIM, 3)
%     for i = 1 : size(SIM, 1)
%         for j = 1 : size(SIM, 2)
%             SIM(i, j, k) = S0map(i, j) * exp(- TE(k) * 0.001 * R2smap(i, j));
%         end
%     end
%     subplot(3, 4, k);
%     imshow(SIM(:, :, k), []);
% end
% %% add NonChi noise
% sigma = 7;
% noiseSIM = addNoise(SIM, sigma, Ncoils);
% figure
% for k = 1 : size(noiseSIM, 3)
%     subplot(3, 4, k);
%     imshow(noiseSIM(:,:,k), []);
% end
% %% MLE
% MLE_S0 = zeros(size(mask));
% MLE_R2s = zeros(size(mask));
% MLE_sigma = zeros(size(mask));
% for i = 1 : size(X, 1)
%     Sn = noiseSIM(X(i), Y(i), :);
%     fun = @costfun;
%     x0 = [max(Sn), max(Sn), 100];
%     lb = [max(Sn), 1 / (2 * max(TE)), min(0.5 * min(Sn), 0)];
%     ub = [max(10 * max(Sn), 100), 3, 400];
%     [x, fval, exitflag, output] = fmincon(fun, x0, [], [], [], [], lb, ub, []);
%     MLE_S0(X(i), Y(i)) = x(1); 
%     MLE_R2s(X(i), Y(i)) = x(2) * 1000; 
%     MLE_sigma(X(i), Y(i)) = sqrt(x(3));
% end
% figure
% imshow(MLE_R2s, [])
% %% M1NCM
% M1NCM_S0 = zeros(size(mask));
% M1NCM_R2s = zeros(size(mask));
% M1NCM_sigma = zeros(size(mask));
% for i = 1 : size(X, 1)
% [R2_NCEXP, M0_NCEXP, sigma_NCEXP] = calc_R2_NCEXPacc_NonChi(TE, squeeze(noiseSIM(X(i), Y(i), :))');
% M1NCM_S0(X(i), Y(i)) = M0_NCEXP; 
% M1NCM_R2s(X(i), Y(i)) = R2_NCEXP * 1000;
% M1NCM_sigma(X(i), Y(i)) = sigma_NCEXP;
% end
% figure
% imshow(M1NCM_R2s, []);
% clc

%% %% in in vivo
% Ncoils = 8;
% nfolder = 'C:\Users\MRIlab\Desktop\temp\dcm\1';
% dfiles = dir(nfolder);
% dfiles = dfiles(3 : end);  
% nfiles=length(dfiles);
% DicomFileNo = 0;
% for currentfile = 1 : nfiles
%     file_info = dicominfo([nfolder, '\', dfiles(currentfile).name]);
%     DicomFileNo = DicomFileNo + 1;
%     TE(DicomFileNo) = file_info.EchoTime;
%     ImgData(:, :, DicomFileNo) = dicomread(file_info);
%     ImgData = double(ImgData);
% end
% mask = double(imread('F:\data\liver internal contour\gray\1.png'));
% mask = mask(:, :, 1);
% mask(mask == 255) = 1;
% mask = logical(mask);
% [X, Y] = find(mask);
% %% PCANR
% [S0map, R2smap]=qPCANR(ImgData, TE);
% R2smap = R2smap .* mask;
% imshow(R2smap, []);
% %% MLE
% MLE_S0 = zeros(size(mask));
% MLE_R2s = zeros(size(mask));
% MLE_sigma = zeros(size(mask));
% for i = 1 : size(X, 1)
%     Sn = ImgData(X(i), Y(i), :);
%     fun = @costfun;
%     x0 = [max(Sn), max(Sn), 100];
%     lb = [max(Sn), 1 / (2 * max(TE)), min(0.5 * min(Sn), 0)];
%     ub = [max(10 * max(Sn), 100), 3, 400];
%     [x, fval, exitflag, output] = fmincon(fun, x0, [], [], [], [], lb, ub, []);
%     MLE_S0(X(i), Y(i)) = x(1); 
%     MLE_R2s(X(i), Y(i)) = x(2) * 1000; 
%     MLE_sigma(X(i), Y(i)) = sqrt(x(3));
% end
% figure
% imshow(MLE_R2s, [])
% %% M1NCM
% M1NCM_S0 = zeros(size(mask));
% M1NCM_R2s = zeros(size(mask));
% M1NCM_sigma = zeros(size(mask));
% for i = 1 : size(X, 1)
% [R2_NCEXP, M0_NCEXP, sigma_NCEXP] = calc_R2_NCEXPacc_NonChi(TE, squeeze(ImgData(X(i), Y(i), :))');
% M1NCM_S0(X(i), Y(i)) = M0_NCEXP; 
% M1NCM_R2s(X(i), Y(i)) = R2_NCEXP * 1000;
% M1NCM_sigma(X(i), Y(i)) = sigma_NCEXP;
% end
% figure
% imshow(M1NCM_R2s, [])
% clc