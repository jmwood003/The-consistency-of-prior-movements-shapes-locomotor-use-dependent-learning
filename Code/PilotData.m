function PilotData

% close all; clear all; clc;
%Order of subjects
% 'VarTest_Stable_05'
% 'VarTest_Stable_06'
% 'VarTest_Unif_04'
% 'VarTest_Unif_05'
% 'VarTest_Unif_06'

Bins = 3;
IWsh = 5;
EWsh = 6:30;

%Set directory and load data
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
plotdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\PlottingFunctions';
addpath(helpdir);
addpath(simdir);
addpath(directory);
addpath(plotdir);
cd(datadir);

%Load data
load('PilotdataAll.mat')
load('IndParamsBys.mat');
ABparams = best_parameters;
load('IndParamsTwop.mat');
SUparams = best_parameters;

%Assign variables
D = Pilot_data;
T = Trgts*100;
P = phases;

%Bin data
Dbin = Bin(D,Bins,1,'mean');
Tbin = Bin(T,Bins,1,'mean');
Pbin = Bin(P,Bins,1,'mean');

oddi = find(ismember(Pbin,[1,2,3])==0);
Tbin(:,oddi) = 22;
%Colors
DataCs = cool(4);

%--------------------------------------------------------------------------
%Plot option 1: by condition (difficult to fit in models)
%--------------------------------------------------------------------------
%Plot the stable condition 
figure; hold on
subplot(3,3,1:3); hold on
plot(1:length(Dbin),Dbin(1,:),'Color',DataCs(1,:),'Marker','none','LineStyle','-','MarkerSize',7);
plot(1:length(Dbin),Dbin(2,:),'Color',DataCs(2,:),'Marker','none','LineStyle','-','MarkerSize',7);
plot(1:length(Dbin),nanmean(Dbin(1:2,:),1),'Color',DataCs(3,:),'LineWidth',2);
plot(1:length(Tbin),Tbin(1,:),'k--');
ylim([-5 40]); %xlim([0 450]);
ylabel('SAI (%)');
title('Consistent Condition');

%Plot the uniform condition
subplot(3,3,4:6); hold on
plot(1:length(Dbin),Dbin(4,:),'Color',DataCs(1,:),'Marker','none','LineStyle','-','MarkerSize',7);
plot(1:length(Dbin),Dbin(5,:),'Color',DataCs(2,:),'Marker','none','LineStyle','-','MarkerSize',7);
plot(1:length(Dbin),Dbin(3,:),'Color',DataCs(4,:),'Marker','none','LineStyle','-','MarkerSize',7);
plot(1:length(Dbin),nanmean(Dbin(3:5,:),1),'Color',DataCs(3,:),'LineWidth',2);
plot(1:length(Tbin),Tbin(1,:),'k--');
ylim([-5 40]); %xlim([0 450]);
legend('Participant1','Particiapnt2','Participant3','Mean','MeanTrgt');
legend('boxoff');
ylabel('SAI (%)');
xlabel(['Strides (bins of ', num2str(Bins), ')' ]);
title('High Variability Condition');

%Initial bias (DO NOT BIN!!)
wshout = find(P==3);
IWidx = wshout(1:IWsh);
EWidx = wshout(EWsh);
IW1 = [mean(D(1,IWidx),2), mean(D(4,IWidx),2)];
IW2 = [mean(D(2,IWidx),2), mean(D(5,IWidx),2)];
EW1 = [mean(D(1,EWidx),2), mean(D(4,EWidx),2)];
EW2 = [mean(D(2,EWidx),2), mean(D(5,EWidx),2)];

subplot(3,3,7); hold on
plot(IW1,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(1,:),'Marker','o','MarkerSize',10);
plot(IW2,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(2,:),'Marker','o','MarkerSize',10);
xlim([0 3]); ylim([0 5]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('PS1','PS2');
legend('boxoff');
xlabel('Condition');
title('Initial Bias (strides 1:5)');
ylabel('SAI (%)');

subplot(3,3,8); hold on
plot(EW1,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(1,:),'Marker','o','MarkerSize',10);
plot(EW2,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(2,:),'Marker','o','MarkerSize',10);
xlim([0 3]); ylim([0 5]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('PS1','PS2');
legend('boxoff');
xlabel('Condition');
title('Early Washout (strides 6:30)');


%Learning mean and SAI (DO NOT BIN)
Lrnidx = find(P==2);
pltpos = [1,1,2,2,2];
rand
subplot(3,3,9); hold on
for i = 1:size(Dbin,1)
        jitterx1 = (pltpos(i)-0.05) + (0.1)*rand(1);
        jitterx2 = (pltpos(i)-0.05) + (0.1)*rand(1);
        p1 = plot(jitterx1, nanmean(D(i,Lrnidx),2),'wo','MarkerFaceColor','b','MarkerSize',5);
        p2 = plot(jitterx2, nanstd(D(i,Lrnidx),0,2),'wo','MarkerFaceColor','r','MarkerSize',5);
end
ylim([0 25]); xlim([0 3]);
legend([p1, p2],'Learning Mean', 'Learning Std dev');
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('boxoff');
xlabel('Condition');
title('Learning SAI Mean and Standard Deviation (unbinned)');

%--------------------------------------------------------------------------
%Plot option 2: by subject
%--------------------------------------------------------------------------
% figure; 
% subplot(2,2,1); hold on
% plot(1:length(Dbin),Dbin(1,:),'Color',DataCs(1,:),'Marker','.','LineStyle','none','MarkerSize',7);
% plot(1:length(StabMAP),StabMAP,'Color',DataCs(3,:),'LineWidth',1.2);
% plot(1:length(StabX),StabX,'Color',ModelCs(2,:),'LineWidth',1.2);
% plot(1:length(StabW),StabW,'Color',ModelCs(1,:));
% plot(1:length(StabS),StabS,'Color',ModelCs(3,:));
% plot(1:length(Tbin),Tbin(1,:),'k--');
% ylim([-5 40]); %xlim([0 450]);
% ylabel('SAI (%)');
% xlabel(['Strides (bins of ', num2str(Bins), ')' ]);
% title('Pilot Subject 1 - Consistant Condition');
% legend('Subj 1','AB MAP','SU X','SU W','SU S','Trgt mean');
% legend('boxoff');
% 
% subplot(2,2,2); hold on
% plot(1:length(Dbin),Dbin(2,:),'Color',DataCs(2,:),'Marker','.','LineStyle','none','MarkerSize',7);
% plot(1:length(StabMAP),StabMAP,'Color',DataCs(3,:),'LineWidth',1.2);
% plot(1:length(StabX),StabX,'Color',ModelCs(2,:),'LineWidth',1.2);
% plot(1:length(StabW),StabW,'Color',ModelCs(1,:));
% plot(1:length(StabS),StabS,'Color',ModelCs(3,:));
% plot(1:length(Tbin),Tbin(1,:),'k--');
% ylim([-5 40]); %xlim([0 450]);
% ylabel('SAI (%)');
% xlabel(['Strides (bins of ', num2str(Bins), ')' ]);
% title('Pilot Subject 2 - Consistant Condition');
% legend('boxoff');
% 
% subplot(2,2,4); hold on
% plot(1:length(Dbin),Dbin(3,:),'Color',DataCs(1,:),'Marker','.','LineStyle','none','MarkerSize',7);
% plot(1:length(HVMAP1),HVMAP1,'Color',DataCs(3,:),'Marker','.','LineStyle','none');
% % plot(1:length(HVX),HVX,'Color',ModelCs(2,:),'Marker','.','LineStyle','none');
% % plot(1:length(HVW),HVW,'Color',ModelCs(1,:));
% % plot(1:length(HVS),HVS,'Color',ModelCs(3,:));
% plot(1:length(Tbin),Tbin(1,:),'k--');
% ylim([-5 40]); %xlim([0 450]);
% ylabel('SAI (%)');
% xlabel(['Strides (bins of ', num2str(Bins), ')' ]);
% title('Pilot Subject 1 - High Variability Condition');
% legend('boxoff');
% 
% subplot(2,2,5); hold on
% plot(1:length(Dbin),Dbin(4,:),'Color',DataCs(2,:),'Marker','.','LineStyle','none','MarkerSize',7);
% % plot(1:length(HVMAP),HVMAP,'Color',DataCs(3,:),'Marker','.','LineStyle','none');
% plot(1:length(HVX2),HVX2,'Color',ModelCs(2,:),'Marker','.','LineStyle','none');
% plot(1:length(HVW2),HVW2,'Color',ModelCs(1,:));
% % plot(1:length(HVS),HVS,'Color',ModelCs(3,:));
% plot(1:length(Tbin),Tbin(1,:),'k--');
% ylim([-5 40]); %xlim([0 450]);
% ylabel('SAI (%)');
% xlabel(['Strides (bins of ', num2str(Bins), ')' ]);
% title('Pilot Subject 2 - High Variability Condition');
% legend('boxoff');

% %other plots to probably add: (moved these to other plot)
% Lrnidx = find(Pbin==2);
% 
% subplot(2,3,3); hold on
% plot(1, mean(Dbin(1,Lrnidx),2),'wo','MarkerFaceColor','b','MarkerSize',10);
% p1 = plot(1, mean(Dbin(2,Lrnidx),2),'wo','MarkerFaceColor','b','MarkerSize',10);
% p2 = plot(2, std(Dbin(3,Lrnidx),0,2),'wo','MarkerFaceColor','r','MarkerSize',10);
% plot(2, std(Dbin(4,Lrnidx),0,2),'wo','MarkerFaceColor','r','MarkerSize',10);
% plot(1, std(Dbin(1:2,Lrnidx),0,2),'wo','MarkerFaceColor','r','MarkerSize',10);
% plot(2, mean(Dbin(3:4,Lrnidx),2),'wo','MarkerFaceColor','b','MarkerSize',10);
% ylim([0 25]); xlim([0 3]);
% legend([p1, p2],'Learning Mean', 'Learning Std dev');
% ax = gca;
% ax.XTick = [1 2];
% ax.XTickLabel = {'Consistent','High Variability'};
% legend('boxoff');
% xlabel('Condition');
% title('Learning SAI Mean and Standard Deviation');
% 
% %Model predictions of aftereffect vs pilot data
% wshout = find(Pbin==3);
% wshidx = wshout(1:AWidx);
% subj1 = [mean(Dbin(1,wshidx),2), mean(Dbin(3,wshidx),2)];
% subj2 = [mean(Dbin(2,wshidx),2), mean(Dbin(4,wshidx),2)];
% MAP = [mean(StabMAP(wshidx),2), mean(HVMAP1(wshidx),2)];
% X = [mean(StabX(wshidx),2), mean(HVX1(wshidx),2)];
% 
% subplot(2,3,6); hold on
% plot(subj1,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(1,:),'Marker','o');
% plot(subj2,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(2,:),'Marker','o');
% plot(MAP,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(3,:),'Marker','o');
% plot(X,'k-','MarkerEdgeColor','w','MarkerFaceColor',ModelCs(2,:),'Marker','o');
% xlim([0 3]);
% ax = gca;
% ax.XTick = [1 2];
% ax.XTickLabel = {'Consistent','High Variability'};
% legend('PS1','PS2','MAP','X');
% legend('boxoff');
% xlabel('Condition');
% title('Aftereffects');


% %Regression plot - not very compelling
% [b1,~,~,~,stats1] = regress(HVMAP1(Lrnidx)',[ones(length(Lrnidx),1),Dbin(3,Lrnidx)']);
% [b2,~,~,~,stats2] = regress(HVMAP2(Lrnidx)',[ones(length(Lrnidx),1),Dbin(4,Lrnidx)']);
% y1 = b1(1) + b1(2)*Dbin(3,Lrnidx);
% y2 = b2(1) + b2(2)*Dbin(4,Lrnidx);
% r2str1 = ['r^2 = ', num2str(stats1(1))];
% r2str2 = ['r^2 = ', num2str(stats2(1))];
% 
% figure; hold on
% plot(Dbin(3,Lrnidx),HVMAP1(Lrnidx),'b.');
% plot(Dbin(3,Lrnidx),y1,'b');
% plot(Dbin(4,Lrnidx),HVMAP2(Lrnidx),'r.');
% plot(Dbin(4,Lrnidx),y2,'r');
% plot(linspace(0,45,46),linspace(0,45,46),'k')
% xlabel('Individual SAI(%)');
% ylabel('Model based SAI(%)');
% legend('Pilot Subj 1',r2str1,'Pilot Subj 2',r2str2); 
% 



end