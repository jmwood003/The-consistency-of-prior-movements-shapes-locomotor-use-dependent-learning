%Wood, Morton and Kim - Phase 1 registered report: How Variability Constrains use-dependent locomotor
%learning 

%Figures and analysis for phase 1 of registered report
%1. Plot example target distributions as seen in Figure 1
%2. Perform model recovery analysis and plot confusion matrices as seen in
%Figure 2. Performs model recovery for BIC as well.
%3. Fit both models to data from prior study data(n=16)
%and obtain best parameter values
%4. Use the best fit parameter values to simulate the models as in Figure 3

close all; clear all; clc;

%First, set the paths where the code and functions were extracted. This
%will need to be changed for each persons compter
addpath('C:\Users\Jonathan\Downloads\Code\PlotFunctions'); %Path for plotting functions
addpath('C:\Users\Jonathan\Downloads\Code\HelperFunctions'); %Path for the helper functions
addpath('C:\Users\Jonathan\Downloads\Code\ModelFunctions'); %Path for model functions
addpath('C:\Users\Jonathan\Downloads\Code\ModelFunctions\Fitfunctions'); %Model fitting functions
addpath('C:\Users\Jonathan\Downloads\Code\ModelFunctions\Simfunctions'); %Model simulation funcitons 
%Set the directory where the data are located
datadir = 'C:\Users\Jonathan\Downloads\Data';

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Example target distributions (Figure 1 C and D)

%This section plot target distributions and stride by stride targets for
%each condtition 

%Note: because of randomization will get slightly different results each
%time 

%Set the number of learning strides
LrnStrides = 500;
%set the range of the frequency of target changes (uniform dist between
%this rage)
reprng = [1 5];
%set the mean of the targets during the learning phase
Tmu = 22;

%Plot example targets
ExampleTrgts(LrnStrides,reprng,Tmu);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Confusion matrix (Figure 2)

%This section performs model recovery for the Strategy plus use-dependent 
%model and the adaptive bayesian model with the results plotted in a
%confusion matrix. Also compares AIC and BIC to determine which to use to
%compare the models. These are close but AIC is consistently better.

%Note: this takes a while to run if doing 1k sims for each condition. 100
%gives similar results. 
%Note 2: because of randomized targets, will get slightly different results each
%time this is run

%Number of simulations 
N = 100; 

%Runs model recovery for both AIC and BIC, with AIC generally showing
%better ability to distinguish between the models
ModelRecovery(N);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Fit models to prior data

%Fit both models to data from a prior study to obtain best fit parameters. 

%Load baseline corrected SAI data 
cd(datadir);
load('PriorStudyData.mat','DRR_bslcor_data');
D = DRR_bslcor_data;

%Set the number of bins, and number of initializations 
nbins = 5; 
num_initials = 5;

%Fit each model to the data
ABparams = DataFitAB(D,nbins,num_initials);
SUparams = DataFitSU(D,nbins,num_initials);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Simulate models using best fit parameters 

%Simulate using bootstrapped parameter values from the fitted models above
%Need to run prior section for the parameter values
%Also plots the mean simulations

%Number of bootstraps per condition
N = 100;

%Simulate and plot
SimIndboot(SUparams,ABparams,N);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Pilot data

%We collected 5 participants to test for feasibility during
%phase 1 of the registered report. These participants performed only the
%constand and high variability conditions and were not included in the
%final manuscript.

%We plot the indvidual data and each model fits to 4 participants (the 5th
%did not complete both conditions)

%Set the number of initials
num_initials = 20; 
%Set the number of bins
Bins = 1;

%Load data
load('Pilotdata.mat');
%Set up data for fitting (concenate individual subjects)
dataidx = [1,2,4,5];
D = Pilot_data(dataidx,:);
T = Trgts(dataidx,:)*100;
P = phases;

%Fit models to data and plot
PilotDataPlot(D,T,P,Bins,num_initials);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------