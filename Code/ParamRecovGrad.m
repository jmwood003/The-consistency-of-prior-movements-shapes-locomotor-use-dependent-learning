function ParamRecovGrad

%Recover the parameters for both models for the gradual experiment 

close all; clear all; clc;

%Number of Simulations
N = 1000;

%Set paths
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
    SimPsAB = [rand(1) 0+(25-0).*rand];
    TMAP = ABsim(SimPsAB,t);
    %Fit Bayes data
    [paramsAB,~,~] = ABfit(TMAP,t);
    
    %Simulate Two process data
    C = rand(1);
    F = 0+((C/5)-0)*rand;
    SimpsSU = [C, rand(1,2), F];
    X = SUsim(SimpsSU,t);
    %Fit two process data
    [paramsSU,~,~] = SUfit(X,t);
    
    %Hold onto sim and fit params
    SimParamsAB(i,:) = SimPsAB;
    FitParamsAB(i,:) = paramsAB;
    SimParamsSU(i,:) = SimpsSU;
    FitParamsSU(i,:) = paramsSU;
    
end

%Plot parameter recovery for each model
plotrecovAB(SimParamsAB,FitParamsAB,0.25);
plotrecovSU(SimParamsSU,FitParamsSU,0.25);

%Plot correlations of recovered parameters
corrplot(FitParamsAB,'varNames',{'Beta','SigL'});
corrplot(FitParamsSU,'varNames',{'C','A','E','F'});

end
