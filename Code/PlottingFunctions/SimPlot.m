function SimPlot(TMAP,X,numstr,N)

%Indexing variables
Ridx = 1:N;
Fidx = N+1:N*2;
Uidx = N*2+1:N*3;
%Washout index
wshidx = 752:1499;
AEidxI = 752:756;
AEidxE = 757:786;
%Learning indices
PlatIdx = 722:751;
LrnIdx = 251:260;

%Plot 
figure; hold on
%Plot the stable condition
subplot(4,3,1:3); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Ridx,:),1),nanstd(TMAP(Ridx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Ridx,:),1),nanstd(X(Ridx,:),0,1),'lineProps','-r');
ylim([0 40]);
ylabel('Step Asymmetry (%)');
title('Repeated Condition');
legend('Adaptive Bayes prediction','Strategy + UDP prediction','Location','north');
legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .8 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(Ridx,wshidx),1),nanstd(TMAP(Ridx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(Ridx,wshidx),1),nanstd(X(Ridx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
%Create inset of early learning
axes('Position',[.15 .8 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(Ridx,LrnIdx),1),nanstd(TMAP(Ridx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(Ridx,LrnIdx),1),nanstd(X(Ridx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);

%Plot the uniform condition
subplot(4,3,4:6); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Fidx,:),1),nanstd(TMAP(Fidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Fidx,:),1),nanstd(X(Fidx,:),0,1),'lineProps','-r');
ylim([0 40]);
ylabel('Step Asymmetry (%)');
title('5% \sigma Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .59 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(Fidx,wshidx),1),nanstd(TMAP(Fidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(Fidx,wshidx),1),nanstd(X(Fidx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
% set(gca,'YTickLabel',[]);
% set(gca,'XTickLabel',[]);
axes('Position',[.15 .59 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(Fidx,LrnIdx),1),nanstd(TMAP(Fidx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(Fidx,LrnIdx),1),nanstd(X(Fidx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);


%Plot the uniform condition
subplot(4,3,7:9); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Uidx,:),1),nanstd(TMAP(Uidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Uidx,:),1),nanstd(X(Uidx,:),0,1),'lineProps','-r');
ylim([0 40]);
xlabel('Strides')
ylabel('Step Asymmetry (%)');
title('Uniform Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');
%Create Inset of washout
axes('Position',[.6 .37 .2 .1])
box on
hold on
shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(Uidx,wshidx),1),nanstd(TMAP(Uidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(wshidx),2),nanmean(X(Uidx,wshidx),1),nanstd(X(Uidx,wshidx),0,1),'lineProps','-r');
plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
ylim([-2 10]);
xlim([0 50]);
% set(gca,'YTickLabel',[]);
% set(gca,'XTickLabel',[]);
axes('Position',[.15 .37 .08 .08])
box on
hold on
shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(Uidx,LrnIdx),1),nanstd(TMAP(Uidx,LrnIdx),0,1),'lineProps','-b');
shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(Uidx,LrnIdx),1),nanstd(X(Uidx,LrnIdx),0,1),'lineProps','-r');
plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
xlim([0 length(LrnIdx)]);

%Plot washout rates 
%Bayes model
subplot(4,3,10); hold on
plot(1,nanmean(RateRegress(TMAP(Ridx,wshidx),numstr)),'bo');
errorbar(1,nanmean(RateRegress(TMAP(Ridx,wshidx),numstr)),nanstd(RateRegress(TMAP(Ridx,wshidx),numstr)),'b');
plot(2,nanmean(RateRegress(X(Ridx,wshidx),numstr)),'ro');
errorbar(2,nanmean(RateRegress(X(Ridx,wshidx),numstr)),nanstd(RateRegress(X(Ridx,wshidx),numstr)),'r');
plot(4,nanmean(RateRegress(TMAP(Fidx,wshidx),numstr)),'bo');
errorbar(4,nanmean(RateRegress(TMAP(Fidx,wshidx),numstr)),nanstd(RateRegress(TMAP(Fidx,wshidx),numstr)),'b');
plot(5,nanmean(RateRegress(X(Fidx,wshidx),numstr)),'ro');
errorbar(5,nanmean(RateRegress(X(Fidx,wshidx),numstr)),nanstd(RateRegress(X(Fidx,wshidx),numstr)),'r');
plot(7,nanmean(RateRegress(TMAP(Uidx,wshidx),numstr)),'bo');
errorbar(7,nanmean(RateRegress(TMAP(Uidx,wshidx),numstr)),nanstd(RateRegress(TMAP(Uidx,wshidx),numstr)),'b');
plot(8,nanmean(RateRegress(X(Uidx,wshidx),numstr)),'ro');
errorbar(8,nanmean(RateRegress(X(Uidx,wshidx),numstr)),nanstd(RateRegress(X(Uidx,wshidx),numstr)),'r');
% plot(1:3,[nanmean(RateRegress(TMAP(Ridx,wshidx),numstr)),nanmean(RateRegress(TMAP(Fidx,wshidx),numstr)),nanmean(RateRegress(TMAP(Uidx,wshidx),numstr))],'k-');
% ylim([0 0.]);
title('Washout Rates');
ylabel('Unlearning/stride');
% xlabel('Conditions');
ax = gca;
ax.XTick = [1.5:8.5];
ax.XTickLabel = {'R','','','5% \sigma','','','U','',''};

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

%plot aftereffects
subplot(4,3,11); hold on
plot(1,nanmean(nanmean(TMAP(Ridx,AEidxI),1)),'bo');
errorbar(1,nanmean(nanmean(TMAP(Ridx,AEidxI),1)),nanstd(nanmean(TMAP(Ridx,AEidxI),1)),'b');
plot(1.1,nanmean(nanmean(X(Ridx,AEidxI),1)),'ro');
errorbar(1.1,nanmean(nanmean(X(Ridx,AEidxI),1)),nanstd(nanmean(X(Ridx,AEidxI),1)),'r');
plot(2,nanmean(nanmean(TMAP(Fidx,AEidxI),1)),'bo');
errorbar(2,nanmean(nanmean(TMAP(Fidx,AEidxI),1)),nanstd(nanmean(TMAP(Fidx,AEidxI),1)),'b');
plot(2.1,nanmean(nanmean(X(Fidx,AEidxI),1)),'ro');
errorbar(2.1,nanmean(nanmean(X(Fidx,AEidxI),1)),nanstd(nanmean(X(Fidx,AEidxI),1)),'r');
plot(3,nanmean(nanmean(TMAP(Uidx,AEidxI),1)),'bo');
errorbar(3,nanmean(nanmean(TMAP(Uidx,AEidxI))),nanstd(nanmean(TMAP(Uidx,AEidxI))),'b');
plot(3.1,nanmean(nanmean(X(Uidx,AEidxI),1)),'ro');
errorbar(3.1,nanmean(nanmean(X(Uidx,AEidxI))),nanstd(nanmean(X(Uidx,AEidxI))),'r');
xlim([0.5 3.5]);
ylim([0 10]);
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'R','5% \sigma','U'};
title('Initial Bias');
ylabel('SAI (%)');
xlabel('Conditions');

%plot aftereffects
subplot(4,3,12); hold on
plot(1,nanmean(nanmean(TMAP(Ridx,AEidxE),1)),'bo');
errorbar(1,nanmean(nanmean(TMAP(Ridx,AEidxE),1)),nanstd(nanmean(TMAP(Ridx,AEidxE),1)),'b');
plot(1.1,nanmean(nanmean(X(Ridx,AEidxE),1)),'ro');
errorbar(1.1,nanmean(nanmean(X(Ridx,AEidxE),1)),nanstd(nanmean(X(Ridx,AEidxE),1)),'r');
plot(2,nanmean(nanmean(TMAP(Fidx,AEidxE),1)),'bo');
errorbar(2,nanmean(nanmean(TMAP(Fidx,AEidxE),1)),nanstd(nanmean(TMAP(Fidx,AEidxE),1)),'b');
plot(2.1,nanmean(nanmean(X(Fidx,AEidxE),1)),'ro');
errorbar(2.1,nanmean(nanmean(X(Fidx,AEidxE),1)),nanstd(nanmean(X(Fidx,AEidxE),1)),'r');
plot(3,nanmean(nanmean(TMAP(Uidx,AEidxE),1)),'bo');
errorbar(3,nanmean(nanmean(TMAP(Uidx,AEidxE))),nanstd(nanmean(TMAP(Uidx,AEidxE))),'b');
plot(3.1,nanmean(nanmean(X(Uidx,AEidxE),1)),'ro');
errorbar(3.1,nanmean(nanmean(X(Uidx,AEidxE))),nanstd(nanmean(X(Uidx,AEidxE))),'r');
xlim([0.5 3.5]);
ylim([0 10]);
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'R','5% \sigma','U'};
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