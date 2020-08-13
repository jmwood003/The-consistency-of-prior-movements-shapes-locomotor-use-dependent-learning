function SimIndbootGrad

%Simulate both models for the three conditions 

% clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;
rng('shuffle','twister');

%Number of bootstraps per condition
N = 1000;
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

for i = 1:N
    
    i
    
    %Bootstrap
    [~, ABidx] = bootstrp(1,@mean,IndABParams);
    [~, SUidx] = bootstrp(1,@mean,IndSUParams);
%     [~, Cidx] = bootstrp(1,@mean,IndSUParams(:,1));
%     [~, Aidx] = bootstrp(1,@mean,IndSUParams(:,2));
%     [~, Eidx] = bootstrp(1,@mean,IndSUParams(:,3));
%     [~, Fidx] = bootstrp(1,@mean,IndSUParams(:,4));
    
    %Set the target
    tG = [zeros(1,250) linspace(0,22,500) zeros(1,750)];
    tF = FT(LrnStrides,Tmu,reprng,1); 
    tU = UT(LrnStrides,reprng,1);
    
    %Set the parameters
%     pB = [IndABParams(Bidx,1), IndABParams(Sidx,2)];
%     pT = [IndSUParams(Cidx,1), IndSUParams(Aidx,2), IndSUParams(Eidx,3), IndSUParams(Fidx,4)];
    pB = IndABParams(ABidx,:);
    pT = IndSUParams(SUidx,:);
    
    for j = 1:length(pB)
        %Simulate
        %Repeated
        [T_map] = ABsim(pB(j,:),tG);
        [x,~,~] = SUsim(pT(j,:),tG);
        tmapr(j,:) = T_map;
        xr(j,:) = x;  
        %5% sigma
        [T_map] = ABsim(pB(j,:),tF);
        [x,~,~] = SUsim(pT(j,:),tF);
        tmapf(j,:) = T_map;
        xf(j,:) = x;  
        %Uniform
        [T_map] = ABsim(pB(j,:),tU);
        [x,~,~] = SUsim(pT(j,:),tU);
        tmapu(j,:) = T_map;
        xu(j,:) = x;  
    end

    TMAPr(i,:) = nanmean(tmapr);
    Xr(i,:) = nanmean(xr);  
    TMAPf(i,:) = nanmean(tmapf);
    Xf(i,:) = nanmean(xf);  
    TMAPu(i,:) = nanmean(tmapu);
    Xu(i,:) = nanmean(xu);  

end

TMAP = [TMAPr; TMAPf; TMAPu];
X = [Xr; Xf; Xu];

SimPlot(TMAP,X,numstr,N);

% VarcompPrct = (sum(Fcomp)/length(Fcomp))*100
% UnifcompPrct = (sum(Unifcomp)/length(Unifcomp))*100


end