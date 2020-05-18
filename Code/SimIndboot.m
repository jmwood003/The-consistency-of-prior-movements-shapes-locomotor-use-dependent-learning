function SimIndboot

%Simulate both models for the three conditions 

clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;
rng('shuffle','twister');

%Number of bootstraps per condition
nboot = 100;
%Number of strides to account for in the rate calculation
numstr = 750;

%Set paths
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
addpath(helpdir);
addpath(simdir);
addpath(directory);
cd(datadir);

%Load individual parameters
load('IndParamsBys.mat');
IndBysParams = best_parameters;
load('IndParamsTwop.mat');
IndTwopParams = best_parameters;

%Bootstrap
Betas = bootstrp(nboot,@mean,IndBysParams(:,1));
SigmaLs = bootstrp(nboot,@mean,IndBysParams(:,2));
Cs = bootstrp(nboot,@mean,IndTwopParams(:,1));
As = bootstrp(nboot,@mean,IndTwopParams(:,2));
Es = bootstrp(nboot,@mean,IndTwopParams(:,3));
Fs = bootstrp(nboot,@mean,IndTwopParams(:,4));

for i = 1:nboot
    
    i
    
    %Set the target
    tS = ST(LrnStrides,Tmu,1);
    tV = VT(LrnStrides,Tmu,reprng,1); 
    tU = UT(LrnStrides,reprng,1);
    
    %Set the parameters
    pB = [Betas(i), SigmaLs(i)];
    pT = [Cs(i), As(i), Es(i), Fs(i)];

    %Simulate
    %Stable
    [T_map] = BayesSim(pB,tS);
    [x,~,~] = TwopSim(pT,tS);
    TMAPs(i,:) = T_map;
    Xs(i,:) = x;  
    %Variable
    [T_map] = BayesSim(pB,tV);
    [x,~,~] = TwopSim(pT,tV);
    TMAPv(i,:) = T_map;
    Xv(i,:) = x;  
    %Uniform
    [T_map] = BayesSim(pB,tU);
    [x,~,~] = TwopSim(pT,tU);
    TMAPu(i,:) = T_map;
    Xu(i,:) = x;  
    
    %Save params:
    paramsB(i,:) = pB;
    paramsT(i,:) = pT;
    
end

TMAP = [TMAPs; TMAPv; TMAPu];
X = [Xs; Xv; Xu];

[Varcomp, Unifcomp] = SimPlot(TMAP,X,numstr,nboot);

VarcompPrct = (sum(Varcomp)/length(Varcomp))*100
UnifcompPrct = (sum(Unifcomp)/length(Unifcomp))*100


end