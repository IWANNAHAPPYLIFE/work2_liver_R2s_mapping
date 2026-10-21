function [te_trunc signal_noise_trunc] = dataTrunc(te, signal_noise, numoftrunc)

numofdatanew = size(te,2) - numoftrunc;
te_trunc = te(1:numofdatanew);
signal_noise_trunc = signal_noise(1:numofdatanew);