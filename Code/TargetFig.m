function TargetFig

%Plot the stride by stride targets and target distributions for the three
%differen conditions

% close all; clear all; clc;

helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
addpath(helpdir);

%Set experimental parameters:
%Number of learning strides:
LrnStrides = 500;
%Range of strides to be stable:
reprng = [1 5];
%Target mean:
Tmu = 22;

%Change seed:
rng('shuffle','twister');

%Set the targets for each condition
T_Rep = RT(LrnStrides,Tmu,1);
T_5sig = FT(LrnStrides,Tmu,reprng,1);
T_Uniform = UT(LrnStrides,reprng,1);

%Plot
figure; hold on
subplot(2,3,1); hold on
histogram(T_Rep(251:750),'FaceColor','k');
xlim([0 45]);
% ylim([0 500]);
xlabel('SAI Target (%)','FontSize',10);
% xlabel(['SAI Target (%; Mu = ',num2str(Stablemu), '; Sigma = ', num2str(Stablestd), ')'],'FontSize',10);
ylabel('Probability','FontSize',10);
title('Repeated Condition','FontSize',12);

subplot(2,3,4); hold on
plot(T_Rep,'-k','LineWidth',3);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);
ylabel('SAI Target (%)','FontSize',10);

subplot(2,3,2); hold on
histogram(T_5sig(251:750),15,'FaceColor','b');
xlim([0 45]);
% ylim([0 1]);
xlabel('SAI Target (%)','FontSize',10);
% xlabel(['SAI Target (%; Mu = ',num2str(Var5mu), '; Sigma = ', num2str(Var5std), ')'],'FontSize',15);
% ylabel('Frequency','FontSize',10);
title('5\sigma Condition','FontSize',12);

subplot(2,3,5); hold on
plot(T_5sig,'-b','LineWidth',1);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);
% ylabel('SAI Target (%)','FontSize',10);
% title('Variable Condition','FontSize',12);

subplot(2,3,3); hold on
histogram(T_Uniform(251:750),15,'FaceColor','r');
xlim([0 45]);
% ylim([0 1]);
xlabel('SAI Target (%)','FontSize',10);
% xlabel(['SAI Target (%; Mu = ',num2str(Uniformmu), '; Sigma = ', num2str(Uniformstd), ')'],'FontSize',15);
% ylabel('Frequency','FontSize',10);
title('Uniform Condition','FontSize',12);

subplot(2,3,6); hold on
plot(T_Uniform,'-r','LineWidth',1);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);
% ylabel('SAI Target (%)','FontSize',15);
% title('Uniform Condition','FontSize',20);

end