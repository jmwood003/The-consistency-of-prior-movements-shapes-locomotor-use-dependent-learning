function ConfusionMatrix

%Perform model recovery for all three conditions and plot using confusion
%matrix.

clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;

%Number of simulations per condition
N = 1000;

%Change Seed
rng('shuffle','twister');

%Set paths
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
addpath(helpdir);
addpath(simdir);
addpath(directory);

%Set the targets
t = [RT(LrnStrides,Tmu,N); FT(LrnStrides,Tmu,reprng,N); UT(LrnStrides,reprng,N)];

%Initialze confusion matrices
CMallaic = zeros(2);
CMABaic = zeros(2);
CMSUaic = zeros(2);

CMallbic = zeros(2);
CMABbic = zeros(2);
CMSUbic = zeros(2);

for i = 1:N*3

    i
    
    %Simulate Adaptive Bayes Model
    ParamsAB = [rand, 0+(100-0).*rand];
    [T_map] = ABsim(ParamsAB,t(i,:)); 
    %Fit
    [BESTaic,BESTbic] = FitAll(T_map,t(i,:));
    BESTaic = BESTaic/sum(BESTaic);
    CMallaic(1,:) = CMallaic(1,:)+BESTaic;
    CMABaic(i,:) = BESTaic; 
    BESTbic = BESTbic/sum(BESTbic);
    CMallbic(1,:) = CMallbic(1,:)+BESTbic;
    CMABbic(i,:) = BESTbic; 

    %Simulate Strategy + UDP Model
    C = rand(1);
    F = 0+((C/5)-0)*rand;
    ParamsT = [C, rand(1,2), F];
    [x,~,~] = SUsim(ParamsT,t); 
    %Fit
    [BESTaic,BESTbic] = FitAll(x,t(i,:));
    BESTaic = BESTaic/sum(BESTaic);
    CMallaic(2,:) = CMallaic(2,:)+BESTaic;
    CMSUaic(i,:) = BESTaic;
    BESTbic = BESTbic/sum(BESTbic);
    CMallbic(2,:) = CMallbic(2,:)+BESTbic;
    CMSUbic(i,:) = BESTbic; 

end

%-----------------AIC----------------------
FMaic = CMplot(CMallaic,CMABaic,CMSUaic,N,'AIC');
%-----------------BIC----------------------
FMbic = CMplot(CMallbic,CMABbic,CMSUbic,N,'BIC');



end

