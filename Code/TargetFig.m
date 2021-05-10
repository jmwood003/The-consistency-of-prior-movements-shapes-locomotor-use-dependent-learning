function TargetFig

%Plot the stride by stride targets and target distributions for the three
%differen conditions

% close all; clear all; clc;

helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
addpath(helpdir);

colors = lines(3);
Ccolor = colors(1,:);
LVcolor = colors(2,:);
HVcolor = colors(3,:);

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
histogram(T_Rep(251:750),'FaceColor',Ccolor);
xlim([0 45]);
xlabel('SAI Target (%)','FontSize',10);
ylabel('Strides','FontSize',10);
title('Constant Condition','FontSize',12);

subplot(2,3,4); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8]);
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8]);
plot(T_Rep,'-', 'Color', Ccolor, 'LineWidth',3);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);
ylabel('SAI Target (%)','FontSize',10);

subplot(2,3,2); hold on
histogram(T_5sig(251:750),15,'FaceColor',LVcolor);
xlim([0 45]);
xlabel('SAI Target (%)','FontSize',10);
title('Low Variability Condition','FontSize',12);

subplot(2,3,5); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8]);
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8]);
plot(T_5sig,'-','Color', LVcolor, 'LineWidth',1);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);

subplot(2,3,3); hold on
histogram(T_Uniform(251:750),15,'FaceColor',HVcolor);
xlim([0 45]);
xlabel('SAI Target (%)','FontSize',10);
title('High Variability Condition','FontSize',12);

subplot(2,3,6); hold on
rectangle('Position',[0,-5,250,50],'FaceColor',[0.8 0.8 0.8]);
rectangle('Position',[750,-5,750,50],'FaceColor',[0.8 0.8 0.8]);
plot(T_Uniform,'-','Color',HVcolor ,'LineWidth',1);
ylim([-5 45]);
xlim([0 1500]);
xlabel('Strides','FontSize',10);

end