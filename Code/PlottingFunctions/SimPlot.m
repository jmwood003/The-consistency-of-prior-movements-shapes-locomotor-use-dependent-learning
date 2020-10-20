function SimPlot(TMAP,X,numstr,N)

%Indexing variables
Constidx = 1:N;
LVidx = N+1:N*2;
HVidx = N*2+1:N*3;
%Washout index
wshidx = 752:1499;
AEidxI = 752:756;
AEidxE = 757:786;
%Learning indices
PlatIdx = 722:751;
LrnIdx = 251:260;

%Mean aftereffects for both simulations 
AEi_ConstAB = nanmean(TMAP(Constidx,AEidxI),2);
AEe_ConstAB = nanmean(TMAP(Constidx,AEidxE),2);
AEi_LowAB = nanmean(TMAP(LVidx,AEidxI),2);
AEe_LowAB = nanmean(TMAP(LVidx,AEidxE),2);
AEi_HighAB = nanmean(TMAP(HVidx,AEidxI),2);
AEe_HighAB = nanmean(TMAP(HVidx,AEidxE),2);

AEi_ConstSU = nanmean(X(Constidx,AEidxI),2);
AEe_ConstSU = nanmean(X(Constidx,AEidxE),2);
AEi_LowSU = nanmean(X(LVidx,AEidxI),2);
AEe_LowSU = nanmean(X(LVidx,AEidxE),2);
AEi_HighSU = nanmean(X(HVidx,AEidxI),2);
AEe_HighSU = nanmean(X(HVidx,AEidxE),2);

%Washout rates using regression:
WR_ConstAB = RateRegress(TMAP(Constidx,wshidx),numstr);
WR_LowAB = RateRegress(TMAP(LVidx,wshidx),numstr);
WR_HighAB = RateRegress(TMAP(HVidx,wshidx),numstr);

WR_ConstSU = RateRegress(X(Constidx,wshidx),numstr);
WR_LowSU = RateRegress(X(LVidx,wshidx),numstr);
WR_HighSU = RateRegress(X(HVidx,wshidx),numstr);

%Plot 
figure; hold on
%Plot the stable condition
subplot(4,3,1:3); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Constidx,:),1),nanstd(TMAP(Constidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Constidx,:),1),nanstd(X(Constidx,:),0,1),'lineProps','-r');
ylim([0 40]);
ylabel('Step Asymmetry (%)');
title('Constant Condition');
legend('Adaptive Bayes prediction','Strategy + UDP prediction','Location','north');
legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .8 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(Constidx,wshidx),1),nanstd(TMAP(Constidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(Constidx,wshidx),1),nanstd(X(Constidx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
%Create inset of early learning
axes('Position',[.15 .8 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(Constidx,LrnIdx),1),nanstd(TMAP(Constidx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(Constidx,LrnIdx),1),nanstd(X(Constidx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);

%Plot the uniform condition
subplot(4,3,4:6); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(LVidx,:),1),nanstd(TMAP(LVidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(LVidx,:),1),nanstd(X(LVidx,:),0,1),'lineProps','-r');
ylim([0 40]);
ylabel('Step Asymmetry (%)');
title('Low Variability Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .59 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(LVidx,wshidx),1),nanstd(TMAP(LVidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(LVidx,wshidx),1),nanstd(X(LVidx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
% set(gca,'YTickLabel',[]);
% set(gca,'XTickLabel',[]);
axes('Position',[.15 .59 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(LVidx,LrnIdx),1),nanstd(TMAP(LVidx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(LVidx,LrnIdx),1),nanstd(X(LVidx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);


%Plot the uniform condition
subplot(4,3,7:9); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(HVidx,:),1),nanstd(TMAP(HVidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(HVidx,:),1),nanstd(X(HVidx,:),0,1),'lineProps','-r');
ylim([0 40]);
xlabel('Strides')
ylabel('Step Asymmetry (%)');
title('High Variability Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .37 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(HVidx,wshidx),1),nanstd(TMAP(HVidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(HVidx,wshidx),1),nanstd(X(HVidx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
% set(gca,'YTickLabel',[]);
% set(gca,'XTickLabel',[]);
axes('Position',[.15 .37 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(HVidx,LrnIdx),1),nanstd(TMAP(HVidx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(HVidx,LrnIdx),1),nanstd(X(HVidx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);

%Plot washout rates 
%Bayes model
subplot(4,3,10); hold on
plot(1,nanmean(WR_ConstAB),'bo','MarkerFaceColor','b');
errorbar(1,nanmean(WR_ConstAB),nanstd(WR_ConstAB),'b');
plot(2,nanmean(WR_ConstSU),'ro','MarkerFaceColor','r');
errorbar(2,nanmean(WR_ConstSU),nanstd(WR_ConstSU),'r');
plot(4,nanmean(WR_LowAB),'bo','MarkerFaceColor','b');
errorbar(4,nanmean(WR_LowAB),nanstd(WR_LowAB),'b');
plot(5,nanmean(WR_LowSU),'ro','MarkerFaceColor','r');
errorbar(5,nanmean(WR_LowSU),nanstd(WR_LowSU),'r');
plot(7,nanmean(WR_HighAB),'bo','MarkerFaceColor','b');
errorbar(7,nanmean(WR_HighAB),nanstd(WR_HighAB),'b');
plot(8,nanmean(WR_HighSU),'ro','MarkerFaceColor','r');
errorbar(8,nanmean(WR_HighSU),nanstd(WR_HighSU),'r');
% plot(1:3,[nanmean(RateRegress(TMAP(Ridx,wshidx),numstr)),nanmean(RateRegress(TMAP(Fidx,wshidx),numstr)),nanmean(RateRegress(TMAP(Uidx,wshidx),numstr))],'k-');
ylim([-0.1 1]);
title('Washout Rates');
ylabel('Unlearning/stride');
% xlabel('Conditions');
ax = gca;
ax.XTick = [1.5:8.5];
ax.XTickLabel = {'Const.','','','LV','','','HV','',''};

% %Two process model
% subplot(3,3,6); hold on
% bar(3,nanmean(RateRegress(X(Uidx,wshidx),numstr)),'EdgeColor','r','FaceColor','w','LineWidth',2);
% errorbar(3,nanmean(RateRegress(X(Uidx,wshidx),numstr)),nanstd(RateRegress(X(Uidx,wshidx),numstr)),'r');
% plot(1:3,[nanmean(RateRegress(X(Ridx,wshidx),numstr)),nanmean(RateRegress(X(Fidx,wshidx),numstr)),nanmean(RateRegress(X(Uidx,wshidx),numstr))],'k-');
% ylim([0 1]);
% title('Strategy + UDP');
% ylabel('Retention Factor');
% % xlabel('Conditions');
% ax = gca;
% ax.XTick = [1:3];
% ax.XTickLabel = {'R','5% \sigma','U'};

% %plot learning plateau
% subplot(4,3,10); hold on
% plot(1,nanmean(nanmean(TMAP(Ridx,PlatIdx),1)),'bo');
% errorbar(1,nanmean(nanmean(TMAP(Ridx,PlatIdx),1)),nanstd(nanmean(TMAP(Ridx,PlatIdx),1)),'b');
% plot(1.1,nanmean(nanmean(X(Ridx,PlatIdx),1)),'ro');
% errorbar(1.1,nanmean(nanmean(X(Ridx,PlatIdx),1)),nanstd(nanmean(X(Ridx,PlatIdx),1)),'r');
% plot(2,nanmean(nanmean(TMAP(Fidx,PlatIdx),1)),'bo');
% errorbar(2,nanmean(nanmean(TMAP(Fidx,PlatIdx),1)),nanstd(nanmean(TMAP(Fidx,PlatIdx),1)),'b');
% plot(2.1,nanmean(nanmean(X(Fidx,PlatIdx),1)),'ro');
% errorbar(2.1,nanmean(nanmean(X(Fidx,PlatIdx),1)),nanstd(nanmean(X(Fidx,PlatIdx),1)),'r');
% plot(3,nanmean(nanmean(TMAP(Uidx,PlatIdx),1)),'bo');
% errorbar(3,nanmean(nanmean(TMAP(Uidx,PlatIdx))),nanstd(nanmean(TMAP(Uidx,PlatIdx))),'b');
% plot(3.1,nanmean(nanmean(X(Uidx,PlatIdx),1)),'ro');
% errorbar(3.1,nanmean(nanmean(X(Uidx,PlatIdx))),nanstd(nanmean(X(Uidx,PlatIdx))),'r');
% xlim([0.5 3.5]);
% ylim([15 25]);
% ax = gca;
% ax.XTick = [1:3];
% ax.XTickLabel = {'R','5% \sigma','U'};
% title('Learning Palteau');
% ylabel('SAI (%)');
% xlabel('Conditions');

%plot initial washout aftereffects
subplot(4,3,11); hold on
plot(1,nanmean(AEi_ConstAB),'bo','MarkerFaceColor','b');
errorbar(1,nanmean(AEi_ConstAB),nanstd(AEi_ConstAB),'b');
plot(1.1,nanmean(AEi_ConstSU),'ro','MarkerFaceColor','r');
errorbar(1.1,nanmean(AEi_ConstSU),nanstd(AEi_ConstSU),'r');
plot(2,nanmean(AEi_LowAB),'bo','MarkerFaceColor','b');
errorbar(2,nanmean(AEi_LowAB),nanstd(AEi_LowAB),'b');
plot(2.1,nanmean(AEi_LowSU),'ro','MarkerFaceColor','r');
errorbar(2.1,nanmean(AEi_LowSU),nanstd(AEi_LowSU),'r');
plot(3,nanmean(AEi_HighAB),'bo','MarkerFaceColor','b');
errorbar(3,nanmean(AEi_HighAB),nanstd(AEi_HighAB),'b');
plot(3.1,nanmean(AEi_HighSU),'ro','MarkerFaceColor','r');
errorbar(3.1,nanmean(AEi_HighSU),nanstd(AEi_HighSU),'r');
xlim([0.5 3.5]);
ylim([0 10]);
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'Const.','LV','HV'};
title('Initial Bias');
ylabel('SAI (%)');
xlabel('Conditions');

%plot early washout aftereffects
subplot(4,3,12); hold on
plot(1,nanmean(AEe_ConstAB),'bo','MarkerFaceColor','b');
errorbar(1,nanmean(AEe_ConstAB),nanstd(AEe_ConstAB),'b');
plot(1.1,nanmean(AEe_ConstSU),'ro','MarkerFaceColor','r');
errorbar(1.1,nanmean(AEe_ConstSU),nanstd(AEe_ConstSU),'r');
plot(2,nanmean(AEe_LowAB),'bo','MarkerFaceColor','b');
errorbar(2,nanmean(AEe_LowAB),nanstd(AEe_LowAB),'b');
plot(2.1,nanmean(AEe_LowSU),'ro','MarkerFaceColor','r');
errorbar(2.1,nanmean(AEe_LowSU),nanstd(AEe_LowSU),'r');
plot(3,nanmean(AEe_HighAB),'bo','MarkerFaceColor','b');
errorbar(3,nanmean(AEe_HighAB),nanstd(AEe_HighAB),'b');
plot(3.1,nanmean(AEe_HighSU),'ro','MarkerFaceColor','r');
errorbar(3.1,nanmean(AEe_HighSU),nanstd(AEe_HighSU),'r');
xlim([0.5 3.5]);
ylim([0 10]);
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'Const.','LV','HV'};
title('Early Washout');
ylabel('SAI (%)');
xlabel('Conditions');
% 
% %Plot aftereffects different from stable
% AEreferenceABs = nanmean(TMAP(Ridx,AEidxB),2);
% AEB5 = AEreferenceABs - nanmean(TMAP(Fidx,AEidxB),2);
% AEBu = AEreferenceABs - nanmean(TMAP(Uidx,AEidxB),2);
% AEreferenceSUs = nanmean(X(Ridx,AEidx),2);
% AET5 = AEreferenceSUs - nanmean(X(Fidx,AEidx),2);
% AETu = AEreferenceSUs - nanmean(X(Uidx,AEidx),2);
% 
% subplot(3,3,9); hold on
% %Plot Bayes AEs difference from reference
% p1 = plot(1,nanmean(AEB5),'bo');
% errorbar(1,nanmean(AEB5),nanstd(AEB5),'b');
% plot(2,nanmean(AEBu),'bo');
% errorbar(2,nanmean(AEBu),nanstd(AEBu),'b');
% 
% %Plot two P AEs difference from reference
% p2 = plot(1.1,nanmean(AET5),'ro');
% errorbar(1.1,nanmean(AET5),nanstd(AET5),'r');
% plot(2.1,nanmean(AETu),'ro');
% errorbar(2.1,nanmean(AETu),nanstd(AETu),'r');
% 
% plot(0.5:2.5,zeros(1,3),'k');
% xlim([0.5 2.5]);
% ylim([-5 5]);
% ax = gca;
% ax.XTick = [1:2];
% ax.XTickLabel = {'R-5\sigma','R-U'};
% % legend([p1 p2],'Bayes Model', 'TwoP Model');
% % legend('boxoff');
% title('Aftereffects');
% ylabel('Delta SAI');
% xlabel('Conditions');

%Is the change greater in the Bayesian model each time simulation?
% Varcomp = AEB5>AET5;
% Unifcomp = AEBu>AETu;

end