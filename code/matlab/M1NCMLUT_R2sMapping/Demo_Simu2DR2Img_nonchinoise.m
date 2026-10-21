% demo_simu_noncentral chi noise
clear;close all;clc;

system('mkdir Result_M1NCM');
currentFolder = pwd;
M0 = 200;
i=1;
for Ncoils=[1 2 4 8 16 32 64 128]
    
for SNR =[15,30 60]
    
sigma = (M0/SNR);

te = [0.93 2.27 3.61 4.95 6.29 7.63 8.97 10.30 11.64 12.98 14.32 15.66];
te_finer = 0:0.2:max(te)+0.2;
numofechoes = length(te);

MapSize = [64,128];BlockSize = [64,16];

R2s_Truth=[100 200 300 400 500 600 800 1000]./1000;

[R2MAP_Truth R2masks] = SimuR2Map2D_nonchi(MapSize,R2s_Truth, 1, 8,BlockSize);
% figure;imshow(R2MAP_Truth,[]);title('True R2*');
% set(gcf,'position',[400 400 400 400])
% figure;imshow((1000./T2MAP_Truth) .* sum(T2masks,3),[]);title('True R2*')

numofR2s = length(R2s_Truth);

numofrepeats = 1;

IMGs_noise = zeros(MapSize(1),MapSize(2),size(te,2),numofrepeats);

for iRep = 1:numofrepeats
    img_noise=zeros(MapSize(1),MapSize(2));
    
    for iTE = 1:size(te,2)
        TE = te(iTE);
        img_truth = M0* exp(-TE .*R2MAP_Truth );   
        
        for iCoil = 1:Ncoils
                signal_noise_rician =ricernd(img_truth, sigma);
                img_noise = img_noise + signal_noise_rician .^2;          
        end
      
        img_noise=sqrt(img_noise);
       
%         figure(2*i);subplot(121);imshow(img_truth,[]);subplot(122);
%         figure
%         imshow(img_noise,[])
%         set(gcf,'position',[400 400 400 400])
%         title(['TE=' num2str(te(iTE)) 'ms'])
        IMGs_noise(:,:,iTE,iRep) = img_noise(:,:);
    end 
    
end
outputfname = [currentFolder '\Result_M1NCM\T2IMGs_' num2str(numofT2s) 'T2_E' num2str(numofechoes) '_SNR' num2str(SNR) '_Reps' num2str(numofrepeats) '.mat'];
save(outputfname, 'IMGs_noise', 'R2MAP_Truth', 'R2masks','R2s_Truth','te','Ncoils');
i=i+1;
end
end

