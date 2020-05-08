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

<<<<<<< Updated upstream
%Set the targets
t = [ST(LrnStrides,Tmu,N); VT(LrnStrides,Tmu,reprng,N); UT(LrnStrides,reprng,N)];

%Number of strides to account for in the rate calculation
numstr = 750;
=======
%Number of strides to account for in the rate calculation
numstr = 50;


% 
% pT = [0.9123, 0.8203, 0.9874, 0.0141];
% pT = [0.8939, 0.8977, 0.9929, 0.0116];**
% pT = [0.9089, 0.9882, 0.9895, 0.0116];
% pT = [0.9774, 0.8138, 0.9939, 0.0124];**
>>>>>>> Stashed changes

%Set parameters
paramsB = [];
paramsT = [];

<<<<<<< Updated upstream
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
=======
for i = 1:N
    
    i
    
    %Set the target
    tS = ST(LrnStrides,Tmu,1);
    tV = VT(LrnStrides,Tmu,reprng,1); 
    tU = UT(LrnStrides,reprng,1);
    
    %Set the parameters
    pB = [normrnd(0.0256,0.0443), normrnd(2.5448, 1.7898)];
    while pB(1)<=0 || pB(2)<=0
        pB = [normrnd(0.0256,0.0443), normrnd(2.5448, 1.7898)];
    end
    pT = [normrnd(0.9345,0.0521), normrnd(0.8626,0.0542), normrnd(0.9702,0.0081), normrnd(0.0128,0.0021)];
    while pT(1)>=1 || pT(2)>=1 || pT(3)>=0.982 || pT(4)<=0
        pT = [normrnd(0.9345,0.0521), normrnd(0.8626,0.0542), normrnd(0.9702,0.0081), normrnd(0.0128,0.0021)];
    end    

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

[Varcomp, Unifcomp] = SimPlot(TMAP,X,numstr,N);

VarcompPrct = (sum(Varcomp)/length(Varcomp))*100
UnifcompPrct = (sum(Unifcomp)/length(Unifcomp))*100

>>>>>>> Stashed changes

end