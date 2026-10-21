clc,clear
% addpath('code\')
SNR = zeros(108,1);
R2s = zeros(108,1);
M0s = zeros(108,1);
currentFolder = pwd;
global global_sigma;
global Ncoils;
global iPat;
% ii = 1;
% for iPat =[6]%[6 7 14 20 24 54];
%     tic
    studyNames= dir([currentFolder '\liver_data\' num2str(iPat,'%-.3d')]);
    inpath = [currentFolder '\liver_data\' num2str(iPat,'%-.3d') '\' studyNames(3).name '\'];
    imfiles = dir([inpath '*.dcm']);
    ImgData = zeros(64,128,12);
    TE = zeros(1,12);
    for jj = 1:12;
        file_info = dicominfo([inpath  imfiles(jj).name]); %图像的信息
        ImgData(:,:,jj) = dicomread(file_info);
        TE(jj) = file_info.EchoTime;
    end

    [sigma,squaresigma] = calcBKGnoiseandSquaresigma(ImgData,0.1,1,8);
    global_sigma =sigma;
%     maskpath = ['D:\MRI用户\Wang_Changqing\liver_data\' num2str(iPat,'%-.3d') '\' ...
%         studyNames(3).name '\T2sLiverLargeMask.mat'];
%     load(maskpath);
%     mask_ROI = LiverLargeMask{1};
%     ROIindicies = find(mask_ROI);
%     tempdata = reshape(ImgData, size(ImgData,1)*size(ImgData,2), size(ImgData,3));
% %     ydata = mean( tempdata(ROIindicies, :) );
%       ydata =tempdata(ROIindicies, :);
% %     [T2 M0] = calc_T2_NCEXP_fixsigma(TE, ydata);
%      for k=1:size(ydata,1)
%      [R2 M0] = calc_R2_NCEXP_NonChi_fixsigma(TE, ydata(k,:))
% %     R2s(ii) = 1000/T2;
%     R2s(k) = R2;
%     M0s(k) = M0;
%      end
% %     SNR(ii) = M0/global_sigma;
%     t=toc;
%     time_acc(ii)=t;
%     ii = ii+1;
%   
    
% end
% R2s([28,42 50 62 85 92 99 102])=[];
% R2s([5 38 52 58 94])=[];
% SNR([28,42 50 62 85 92 99 102])=[];
% SNR([5 38 52 58 94])=[];
% figure
% set(gcf,'Position', [100 100 350 400])
% plot(R2s,SNR,'k*');
% xlabel('R2* (s^-^1)','FontName','times','FontSize',10,'FontWeight','bold')
% ylabel('SNR','FontName','times','FontSize',10,'FontWeight','bold')





