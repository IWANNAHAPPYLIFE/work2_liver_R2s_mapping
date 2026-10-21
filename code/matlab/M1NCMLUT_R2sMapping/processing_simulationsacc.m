clear
clc
currentFolder = pwd;
R2s_Truth=[100 200 300 400 500 600 800 1000]./1000;
numofR2s = length(R2s_Truth);
te = [0.93 2.27 3.61 4.95 6.29 7.63 8.97 10.30 11.64 12.98 14.32 15.66];
numofechoes = length(te);
numofrepeats = 1;
M0=200;
global Ncoils;
global global_sigma;
SNRs=[15,30,60];
Ncoilss=[1 2 4 8 16 32 64 128];
load pp_initial.mat
global pp_initial;
for iSNR = 1:length(SNRs)
    SNR=SNRs(iSNR);
    global_sigma=(M0/SNR);
      for iNcoils=1:length(Ncoilss)
          Ncoils=Ncoilss(iNcoils);
          inputfname = [currentFolder '\Result_M1NCM\R2IMGs_' num2str(numofR2s) 'R2_E' num2str(numofechoes) '_SNR' num2str(SNR) '_Reps' num2str(numofrepeats) 'Ncoils_' num2str(Ncoils) '.mat'];
          load(inputfname);
          tic
          for i=1:size(IMGs_noise,1)
              for j=1:size(IMGs_noise,2)
                  [R2_NCEXPacc M0_NCEXP]=calc_R2_NCEXPacc_NonChi_fixsigma(te,squeeze(IMGs_noise(i,j,:))');
                  R2_NCEXPACC_total(i,j,iNcoils,iSNR)=1000.*R2_NCEXPacc;
              end
          end
          t=toc;
          time_diffNcoil_SNR(iNcoils,iSNR)=t;
      end
end
outputfname = [currentFolder '\Result_M1NCM\Sim_M1NCMLUT.mat'];
save(outputfname, 'R2_NCEXPACC_total','time_diffNcoil_SNR');