function SimIndboot

%Simulate both models for the three conditions 

% clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;
rng('shuffle','twister');

%Number of bootstraps per condition
nboot = 1000;
%Number of strides to account for in the rate calculation
numstr = 50;

%Set directory and load data
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
plotdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\PlottingFunctions';
addpath(helpdir);
addpath(simdir);
addpath(plotdir);
addpath(directory);
cd(datadir);

%Load individual parameters
load('IndParamsBys.mat');
IndABParams = best_parameters;
load('IndParamsTwop.mat');
IndSUParams = best_parameters;

%Bootstrap
Betas = bootstrp(nboot,@mean,IndABParams(:,1));
SigmaLs = bootstrp(nboot,@mean,IndABParams(:,2));
Cs = bootstrp(nboot,@mean,IndSUParams(:,1));
As = bootstrp(nboot,@mean,IndSUParams(:,2));
Es = bootstrp(nboot,@mean,IndSUParams(:,3));
Fs = bootstrp(nboot,@mean,IndSUParams(:,4));

for i = 1:nboot
    
    i
    
    %Set the target
    tR = RT(LrnStrides,Tmu,1);
    tF = FT(LrnStrides,Tmu,reprng,1); 
    tU = UT(LrnStrides,reprng,1);
    
    %Set the parameters
    pB = [Betas(i), SigmaLs(i)];
    pT = [Cs(i), As(i), Es(i), Fs(i)];

    %Simulate
    %Repeated
    [T_map] = ABsim(pB,tR);
    [x,~,~] = SUsim(pT,tR);
    TMAPr(i,:) = T_map;
    Xr(i,:) = x;  
    %5% sigma
    [T_map] = ABsim(pB,tF);
    [x,~,~] = SUsim(pT,tF);
    TMAPf(i,:) = T_map;
    Xf(i,:) = x;  
    %Uniform
    [T_map] = ABsim(pB,tU);
    [x,~,~] = SUsim(pT,tU);
    TMAPu(i,:) = T_map;
    Xu(i,:) = x;  
    
end

TMAP = [TMAPr; TMAPf; TMAPu];
X = [Xr; Xf; Xu];

[Fcomp, Unifcomp] = SimPlot(TMAP,X,numstr,nboot);

VarcompPrct = (sum(Fcomp)/length(Fcomp))*100
UnifcompPrct = (sum(Unifcomp)/length(Unifcomp))*100


end