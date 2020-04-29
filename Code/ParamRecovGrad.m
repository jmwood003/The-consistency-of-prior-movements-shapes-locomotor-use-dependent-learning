function ParamRecovGrad

%Recover the parameters for both models for the gradual experiment 

close all; clear all; clc;

%Number of Simulations
N = 1000;

%Set paths
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
addpath(helpdir);
addpath(simdir);
addpath(directory);

%Set the targets 
grad_err = [ones(1,52)*2, ones(1,52)*4, ones(1,52)*6, ones(1,52)*8, ones(1,52)*10, ones(1,52)*12, ones(1,52)*14, ones(1,52)*16,...
    ones(1,52)*18, ones(1,52)*20, ones(1,50)*22];
baseline = zeros(1,100);
catch_1 = zeros(1,24);
learning_2 = ones(1,229)*22;
catch_2 = zeros(1,24);
learning_3 = ones(1,234)*22;
washout = zeros(1,1031);
%Targets for the whole experiment
t = [baseline,grad_err,catch_1,learning_2,catch_2,learning_3,washout];

for i = 1:N
    
    i
    
    %Simulate Bayes data
    SimB = [rand(1) 0+(25-0).*rand];
    TMAP = BayesSim(SimB,t);
    %Fit Bayes data
    [paramsB,~,~] = BysFit(TMAP,t);
    
    %Simulate Two process data
    C = rand(1);
    F = 0+((C/5)-0)*rand;
    SimT = [C, rand(1,2), F];
    X = TwopSim(SimT,t);
    %Fit two process data
    [paramsT,~,~] = TpFit(X,t);
    
    %Hold onto sim and fit params
    SimPbys(i,:) = SimB;
    FitPbys(i,:) = paramsB;
    SimPtp(i,:) = SimT;
    FitPtp(i,:) = paramsT;
    
end

%Plot parameter recovery for each model
plotrecovbys(SimPbys,FitPbys,0.25);
plotrecovtp(SimPtp,FitPtp,0.25);

%Plot correlations of recovered parameters
corrplot(FitPbys,'varNames',{'Beta','SigL'});
corrplot(FitPtp,'varNames',{'C','A','E','F'});

end
