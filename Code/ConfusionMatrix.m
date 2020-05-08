function ConfusionMatrix

%Perform model recovery for all three conditions and plot using confusion
%matrix.

clear all; close all; clc;

%Set experiment parameters:
reprng = [1 5];
LrnStrides = 500;
Tmu = 22;
Conditions = {'All', 'Stable', 'Variable', 'Uniform'};

%Number of simulations per condition
N = 100;

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
t = [ST(LrnStrides,Tmu,N); VT(LrnStrides,Tmu,reprng,N); UT(LrnStrides,reprng,N)];
%Indexing variables
Sidx = 1:N;
Vidx = N+1:N*2;
Uidx = N*2+1:N*3;

%Initialze confusion matrices
CMall = zeros(2);
CMbys = zeros(2);
CM2p = zeros(2);

for i = 1:N*3

    i
    
    %Simulate Bayes Model
    ParamsB = [rand, 0+(25-0).*rand];
    [T_map] = BayesSim(ParamsB,t(i,:)); 
    %Fit
    [BEST,iBest,AIC] = FitAll(T_map,t(i,:));
    BEST = BEST/sum(BEST);
    CMall(1,:) = CMall(1,:)+BEST;
    CMbys(i,:) = BEST; 

    %Simulate Two Process Model
    ParamsT = [rand(1,3), 0+(0.2-0).*rand];
    [x,W,S] = TwopSim(ParamsT,t); 
    %Fit
    [BEST,iBest,AIC] = FitAll(x,t(i,:));
    BEST = BEST/sum(BEST);
    CMall(2,:) = CMall(2,:)+BEST;
    CM2p(i,:) = BEST;

end

%Create Final CMs for each condition
<<<<<<< Updated upstream
FM(1).all = round(100*CMall/sum(CMall(1,:)))/100;
%Stable
CMs = [sum(CMbys(Sidx,:)); sum(CM2p(Sidx,:))];
FM(2).all = round(100*CMs/sum(CMs(1,:)))/100;
%Variable
CMv = [sum(CMbys(Vidx,:)); sum(CM2p(Vidx,:))];
FM(3).all = round(100*CMv/sum(CMv(1,:)))/100;
%Uniform
CMu = [sum(CMbys(Uidx,:)); sum(CM2p(Uidx,:))];
FM(4).all = round(100*CMu/sum(CMu(1,:)))/100;
=======
FM(1).all = round(100*CMall/sum(CMall(1,:)),3)/100;
%Stable
CMs = [sum(CMbys(Sidx,:)); sum(CM2p(Sidx,:))];
FM(2).all = round(100*CMs/sum(CMs(1,:)),3)/100;
%Variable
CMv = [sum(CMbys(Vidx,:)); sum(CM2p(Vidx,:))];
FM(3).all = round(100*CMv/sum(CMv(1,:)),3)/100;
%Uniform
CMu = [sum(CMbys(Uidx,:)); sum(CM2p(Uidx,:))];
FM(4).all = round(100*CMu/sum(CMu(1,:)),3)/100;
>>>>>>> Stashed changes

%Plot all Confusion Matrices
clims = [0.3 1];
for i = 1:4
    subplot(2,2,i), imagesc(FM(i).all,clims);
    text(1,1,num2str(FM(i).all(1,1)),'FontSize',15);
    text(2,1,num2str(FM(i).all(1,2)),'FontSize',15);
    text(0.75,2,num2str(FM(i).all(2,1)),'FontSize',15);
    text(1.75,2,num2str(FM(i).all(2,2)),'FontSize',15);
<<<<<<< Updated upstream
    set(gca, 'xtick', [1:2], 'ytick', [1:2], 'fontsize', 10, 'tickdir', 'out')
=======
    set(gca, 'xtick', [1:2], 'ytick', [1:2], 'fontsize', 10, ...
        'tickdir', 'out','xaxislocation', 'top');
>>>>>>> Stashed changes
    set(gca,'xticklabel',{'Bayes', 'TwoP'});
    set(gca,'yticklabel',{'Bayes', 'TwoP'});
    xlabel('Fitted Model');
    ylabel('Simulated Model');
    title(Conditions{i});
end

<<<<<<< Updated upstream

=======
>>>>>>> Stashed changes
end

