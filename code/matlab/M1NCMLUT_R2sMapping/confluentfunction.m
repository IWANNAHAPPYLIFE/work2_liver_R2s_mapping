%produce look up table
%an array coil of L units

clear
clc

z1=0:0.002:999.998;
z2=1000:1:50000;
z=[z1,z2];
% z1=0:0.01:10000;
L=128%[1,2,4,8,16,32,64,128];
for i=1:length(L)
    tic
    for j=1:length(z)
        i
        j
    y_hyper(i,j)=hypergeom(-0.5,L(i),-z(j));
    end
%     pp_interval1_50=spline(z,app1(i,:));
    t_hyper(i)=toc;
end

% app1=hypergeom(-0.5,1,-z1);
% save('interval_001app_z1.mat','app1','z1')
% save pp1_001
%ppval(pp(i),(s/sigma)^2)) return 1F1(-0.5,2^i,-(s/sigma)^2));