%命令窗口实验数据处理
clear
clc
currentFolder = pwd;
global global_sigma;
global Ncoils;
global iPat;
global pp_initial;
load pp_initial.mat;

PatientsIndx = [6 7 14 20 24 54]; 
for ii = 1: length(PatientsIndx)
    
iPat=PatientsIndx(ii);% 
Ncoils=8;

run read_dicom
% inputname=[num2str(iPat) '_mask.mat'];
% load(inputname)

tic
for i=2:64
for j=2:128
[R2_ncexpacc M0_ncexpacc] = calc_R2_NCEXPacc_NonChi_fixsigma(TE,squeeze(ImgData(i,j,:))');
R2_NCEXPACC(i,j)=1000*R2_ncexpacc;M0_NCEXPACC(i,j)=M0_ncexpacc;
end
end
t_ncexp_acc=toc;

outputfname = [currentFolder '\Result_M1NCM\Invivo_M1NCMLUT_' num2str(iPat) 'Pat.mat'];
save(outputfname, 'R2_NCEXPACC_total','R2_NCEXPACC','t_ncexp_acc');

tic
for i=2:64
for j=2:128
[R2_ncexp M0_ncexp] = calc_R2_NCEXP_NonChi_fixsigma(TE,squeeze(ImgData(i,j,:))');
R2_NCEXP(i,j)=1000*R2_ncexp;M0_NCEXP(i,j)=M0_ncexp;
end
end
t_ncexp=toc;

outputfname = [currentFolder '\Result_M1NCM\Invivo_M1NCM_' num2str(iPat) 'Pat.mat'];
save(outputfname, 'R2_NCEXPACC_total','R2_NCEXP','t_ncexp');

% 
% figure(1);imshow(R2_NCEXPACC.*handles.ROI.mask,[]);
% title('R2_NCEXPACC')
% set(gcf,'position',[100 100 600 600])
% colormap hot
% saveas(figure(1),'C:\Users\TEMP.Lab2-PC.000\Desktop\实验结果\真实数据\第6组数据\R2_NCEXPACC','fig');
% 
% figure(2);imshow(R2_NCEXP.*handles.ROI.mask,[]);
% title('R2_NCEXP')
% set(gcf,'position',[100 100 600 600])
% colormap hot
% saveas(figure(2),'C:\Users\TEMP.Lab2-PC.000\Desktop\实验结果\真实数据\第6组数据\R2_NCEXP','fig');
% 
% figure(3);imshow(abs(R2_NCEXP-R2_NCEXPACC).*handles.ROI.mask,[]);
% title('Compare')
% set(gcf,'position',[100 100 600 600])
% colormap hot
% saveas(figure(3),'C:\Users\TEMP.Lab2-PC.000\Desktop\实验结果\真实数据\第6组数据\Compare','fig');

end
