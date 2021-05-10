function SimIndboot

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

    %Set the target
    tR = RT(LrnStrides,Tmu,1);
    tF = FT(LrnStrides,Tmu,reprng,1); 
    tU = UT(LrnStrides,reprng,1);
    
    %Set the parameters
    pB = IndABParams(ABidx,:);
    pT = IndSUParams(SUidx,:);    
 
    for j = 1:size(pB,1)
        %Simulate
        %Constant
        [T_map] = ABsim(pB(j,:),tR);
        [x,w,s] = SUsim(pT(j,:),tR);
        tmapc(j,:) = T_map;
        xc(j,:) = x;  
        wc(j,:) = w;
        sc(j,:) = s;
        %Low variability
        [T_map] = ABsim(pB(j,:),tF);
        [x,w,s] = SUsim(pT(j,:),tF);
        tmapLV(j,:) = T_map;
        xLV(j,:) = x;  
        wLV(j,:) = w;
        sLV(j,:) = s;        
        %High Variability
        [T_map] = ABsim(pB(j,:),tU);
        [x,w,s] = SUsim(pT(j,:),tU);
        tmapHV(j,:) = T_map;
        xHV(j,:) = x;  
        wHV(j,:) = w;
        sHV(j,:) = s;        
    end

    TMAPc(i,:) = nanmean(tmapc,1);
    Xc(i,:) = nanmean(xc,1);  
    Wc(i,:) = nanmean(wc,1);
    Sc(i,:) = nanmean(sc,1);
    TMAPlv(i,:) = nanmean(tmapLV,1);
    Xlv(i,:) = nanmean(xLV,1);  
    Wlv(i,:) = nanmean(wLV,1);
    Slv(i,:) = nanmean(sLV,1);
    TMAPhv(i,:) = nanmean(tmapHV,1);
    Xhv(i,:) = nanmean(xHV,1);  
    Whv(i,:) = nanmean(wHV,1);
    Shv(i,:) = nanmean(sHV,1);
end

TMAP = [TMAPc; TMAPlv; TMAPhv];
X = [Xc; Xlv; Xhv];
W = [Wc; Wlv; Whv];
S = [Sc; Slv; Shv];

SimPlot(TMAP,X,W,S,numstr,N);

% VarcompPrct = (sum(Fcomp)/length(Fcomp))*100
% UnifcompPrct = (sum(Unifcomp)/length(Unifcomp))*100


end