function Simmodels

%Simulate both models for the three conditions 

clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;
rng('shuffle','twister');

%Number of simulations per condition
N = 1000;

%Set paths
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
addpath(helpdir);
addpath(simdir);
addpath(directory);

%Set the targets
t = [ST(LrnStrides,Tmu,N); VT(LrnStrides,Tmu,reprng,N); UT(LrnStrides,reprng,N)];

%Number of strides to account for in the rate calculation
numstr = 750;

%Set parameters
paramsB = [];
paramsT = [];

%Mean params:
for i = 1:N*3
    pB = [0.0256, 2.5448];
    pT = [0.9345, 0.8626, 0.9702, 0.0128];
    paramsB = [paramsB; pB];
    paramsT = [paramsT; pT];
end

% %Rand params (based on sim fits)
% for i = 1:N
%     pB = [normrnd(0.0256,0.0443), normrnd(2.5448, 1.7898)];
%     pT = [normrnd(0.9345,0.0521), normrnd(0.8626,0.0542), normrnd(0.9702,0.0081), normrnd(0.0128,0.0021)];
%     paramsB = [paramsB; pB; pB; pB];
%     paramsT = [paramsT; pT; pT; pT];
% end

for i = 1:size(t,1)
    
    i
    
    %Simulate
    [T_map] = BayesSim(paramsB(i,:),t(i,:));
    [x,~,~] = TwopSim(paramsT(i,:),t(i,:));
    TMAP(i,:) = T_map;
    X(i,:) = x;  
        
end

SimPlot(TMAP,X,numstr,N);

end