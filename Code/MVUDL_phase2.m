%Wood, Morton and Kim - The consistency of prior movements shapes locomotor use-dependent learning

%Figures and analysis for phase 2 of registered report
%Run these codes in order to reconstruct all the results from Wood et al., 2021
%registered report: "The consistency of prior movements shapes locomotor use-dependent learning" 

close all; clear; clc;

%First, set the paths where the code and functions were extracted. This
%will need to be changed for each persons compter
addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\PlotFunctions'); %Path for plotting functions
addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFunctions'); %Path for the helper functions
addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\ModelFunctions'); %Path for model functions
addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\ModelFunctions\Fitfunctions'); %Model fitting functions
addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\ModelFunctions\Simfunctions'); %Model simulation funcitons 
%Set the directory where the data are located
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
cd(datadir);

%Load data
load('AllT.mat','AllT');
T = AllT;

%Create arrays for ANOVAs 
Subjs = unique(T.SID);
sample = [ones(length(Subjs),1); ones(length(Subjs),1)*2; ones(length(Subjs),1)*3];
subjcode = [1:length(Subjs), 1:length(Subjs), 1:length(Subjs)]';

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% SAI data by condition (Figure 4)

%Plots mean and individual SAI data for each condition seperately. Also
%plots histograms of all the learning strides for all the subjects and the
%mean and individual SAI Learning mean and SAI Learning sigma across
%conditions.

%Option to set the number of bins. The figure in the manuscript is 5 bins
nbins = 5;

%Plot
[grpSAI_Lrnmean, grpSAI_Lrnsd] = ConditionPlot(T,nbins);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Test for differences in learning SAI mean

%Runs statistical analysis for *Learning SAI mean* data including: means and
%95% CIs, tests of normality and homoscedasticity, and repeated measures
%ANOVA. Post hoc comparisons are displayed with significant ANOVA. If no
%significant ANOVA, performs TOST procedure. Displays the results in the command window.

disp(' '); disp('Learning SAI Mean (mean [95%CIs]):');
displaystats(sample,subjcode,grpSAI_Lrnmean);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Test for differences in Learning SAI SD

%Runs statistical analysis for *Learning SAI SD* data including: means and
%95% CIs, tests of normality and homoscedasticity, and repeated measures
%ANOVA. Post hoc comparisons are displayed with significant ANOVA. If no
%significant ANOVA, performs TOST procedure. Displays the results in the command window.

disp(' '); disp('Learning SAI SD (mean [95%CIs]):');
displaystats(sample,subjcode,grpSAI_Lrnsd);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Limb position data (Figure 5)

%Plots mean and individual leading and trailing limb position data for the
%learning phase of the selected condition (in the manuscript we chose the
%high variability condition). Also plots mean and individual leading and
%trailing limb asymmetry. 

%Option to chose number of bins
nbins = 5;
%Option to chose the condition to plot
condstr = 'HV'; %either 'Constant', 'LV' or 'HV'

%Plot
FootPosPlt(T, nbins, condstr);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Washout SAI data (Figure 6)

%Plots the stride by stride SAI data during washout for each condition.
%Also plots the primary dependent variabiles: Initial Bias, Early Washout
%and washout rates across conditions. We also plot the exploratory analysis
%of individual regressions for Learning SAI sigma vs Initial Bias and Early
%Washout and displays the relevant statistics in the command line. 

%Option to chose number of bins
nbins = 3;

%Plot function
[grpIB, grpEW, ARrate, WshD] = WshDataPlt(T,nbins);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Test for differences in Initial Bias

%Runs statistical analysis for *Initial Bias* data including: means and
%95% CIs, tests of normality and homoscedasticity, and repeated measures
%ANOVA. Post hoc comparisons are displayed with significant ANOVA. If no
%significant ANOVA, performs TOST procedure. Displays the results in the command window.

disp(' '); disp('Initial Bias (mean [95%CIs]):');
displaystats(sample,subjcode,grpIB);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Test for differences in Early Washout

%Runs statistical analysis for *Early Washout* data including: means and
%95% CIs, tests of normality and homoscedasticity, and repeated measures
%ANOVA. Post hoc comparisons are displayed with significant ANOVA. If no
%significant ANOVA, performs TOST procedure. Displays the results in the command window.

disp(' '); disp('Early Washout (mean [95%CIs]):');
displaystats(sample,subjcode,grpEW);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Test for differences in washout rate

%Runs statistical analysis for *Washout rates* data including: means and
%95% CIs, tests of normality and homoscedasticity, and repeated measures
%ANOVA. Post hoc comparisons are displayed with significant ANOVA. If no
%significant ANOVA, performs TOST procedure. Displays the results in the command window.

disp(' '); disp('Washout Rate (mean [95%CIs]):');
displaystats(sample,subjcode,ARrate);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%% Cluster permutation analysis for washout data (binned by 3)

%Performs and plots cluster permutation analysis for comparisons between
%each condition. When there are no clusters > 3 in the emperical data, we
%do not perform a comparison between resampled data. 

%Organize the stride by stride washout data into each different condition
Cidx = WshD(:,1);
WashData = WshD(:,2:end);
ConstantWsh = WashData(Cidx==1,:);
LVWsh = WashData(Cidx==2,:);
HVWsh = WashData(Cidx==3,:);

%Perform cluster permutation analysis for each comparison
clustPerm(ConstantWsh,HVWsh);
clustPerm(ConstantWsh,LVWsh);
clustPerm(LVWsh,HVWsh);

%% Model fits (Figures 7 and 8 and Extended Data Figures 7-1, 7-2, 8-1, 8-2)

%Fits and plots group and individual model fits for all of the 4 models (original
%and modified). Also tests for differences in AIC values.

%Set the length of the washout inset
insetlen = 100;
%Set the number of initializations 
num_initials = 10;

%Fit and plot
GroupModelFits(T, insetlen, num_initials);

%% Discussion analysis

%We performed a few different analyses for the discussion section of the
%manuscript: 

%first we determined the relationship between reward and 
%use-dependent biases
RwdRelationshipPlot(T);

%next we determine if the end end of learning was different between
%conditoins
EndLrnPlot(T, 50);
