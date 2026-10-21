Manuscript, codes, data and result for paper "Rapid Look-Up Table Method for Noise-Corrected Curve Fitting in the R2* Mapping of Iron Loaded Liver" on Mangetic Resonance in Medicine 73: 865-871 (2015) on 2017-12-03 by Changqing Wang (cwang488@wisc.edu).


M1NCMLUT_R2sMapping folder:
	manuscript folder: the paper in pdf version;
	
	liver data folder : data of six in vivo examples;

	Result_M1NCM folder: simulations and corresponding results;
		
	*_mask.mat are mask for corresponding in vivo data;

	processing_simulations.m and processing_simulationsacc.m are the codes for processing simulations with different combinations of SNRs and R2s, and calc_R2_NCEXP_NonChi_fixesigma.m and calc_R2_NCEXPacc_NonChi_fixsigma.m are called, respectively;

	SimuR2Map2D_nonchi.m and Demo_Simu2DR2Img_nonchinoise.m are used to simulate R2* maps as well as corresponding noisy images;

	pp_initial.mat is the look-up table of confluent hypergeometric function.
	
	