function SimPlot(TMAP,X,numstr,N)

%Indexing variables
Sidx = 1:N;
Vidx = N+1:N*2;
Uidx = N*2+1:N*3;
%Washout index
wshidx = 751:1500;
AEidx = 751:760;

%Plot 
figure; hold on
%Plot the stable condition
subplot(3,3,1:2); hold on
shadedErrorBar(1:length(wshidx),nanmean(TMAP(Sidx,wshidx),1),nanstd(TMAP(Sidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:length(wshidx),nanmean(X(Sidx,wshidx),1),nanstd(X(Sidx,wshidx),0,1),'lineProps','-r');
ylim([0 20]);
ylabel('Step Asymmetry');
title('Stable Condition Washout');
legend('Bayes Prediction','Two process prediction');
legend('boxoff');

%Plot the variable condition
subplot(3,3,4:5); hold on
shadedErrorBar(1:length(wshidx),nanmean(TMAP(Vidx,wshidx),1),nanstd(TMAP(Vidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:length(wshidx),nanmean(X(Vidx,wshidx),1),nanstd(X(Vidx,wshidx),0,1),'lineProps','-r');
ylim([0 20]);
ylabel('Step Asymmetry');
title('Variable Condition Washout');
legend('Bayes Prediction','Two process prediction');
legend('boxoff');

%Plot the uniform condition
subplot(3,3,7:8); hold on
shadedErrorBar(1:length(wshidx),nanmean(TMAP(Uidx,wshidx),1),nanstd(TMAP(Uidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:length(wshidx),nanmean(X(Uidx,wshidx),1),nanstd(X(Uidx,wshidx),0,1),'lineProps','-r');
ylim([0 20]);
xlabel('Washout Strides')
ylabel('Step Asymmetry');
title('Variable Condition Washout');
legend('Bayes Prediction','Two process prediction');
legend('boxoff');

%Plot washout rates 
%Bayes model
subplot(3,3,3); hold on
bar(1,nanmean(RateRegress(TMAP(Sidx,wshidx),numstr)),'EdgeColor','b','FaceColor','w','LineWidth',2);
errorbar(1,nanmean(RateRegress(TMAP(Sidx,wshidx),numstr)),nanstd(RateRegress(TMAP(Sidx,wshidx),numstr)),'b');
bar(2,nanmean(RateRegress(TMAP(Vidx,wshidx),numstr)),'EdgeColor','b','FaceColor','w','LineWidth',2);
errorbar(2,nanmean(RateRegress(TMAP(Vidx,wshidx),numstr)),nanstd(RateRegress(TMAP(Vidx,wshidx),numstr)),'b');
bar(3,nanmean(RateRegress(TMAP(Uidx,wshidx),numstr)),'EdgeColor','b','FaceColor','w','LineWidth',2);
errorbar(3,nanmean(RateRegress(TMAP(Uidx,wshidx),numstr)),nanstd(RateRegress(TMAP(Uidx,wshidx),numstr)),'b');
plot(1:3,[nanmean(RateRegress(TMAP(Sidx,wshidx),numstr)),nanmean(RateRegress(TMAP(Vidx,wshidx),numstr)),nanmean(RateRegress(TMAP(Uidx,wshidx),numstr))],'k-');
ylim([0 1]);
title('Bayes Model Washout Rate');
ylabel('Rate');
xlabel('Conditions');
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'S','V','U'};

%Two process model
subplot(3,3,6); hold on
bar(1,nanmean(RateRegress(X(Sidx,wshidx),numstr)),'EdgeColor','r','FaceColor','w','LineWidth',2);
errorbar(1,nanmean(RateRegress(X(Sidx,wshidx),numstr)),nanstd(RateRegress(X(Sidx,wshidx),numstr)),'r');
bar(2,nanmean(RateRegress(X(Vidx,wshidx),numstr)),'EdgeColor','r','FaceColor','w','LineWidth',2);
errorbar(2,nanmean(RateRegress(X(Vidx,wshidx),numstr)),nanstd(RateRegress(X(Vidx,wshidx),numstr)),'r');
bar(3,nanmean(RateRegress(X(Uidx,wshidx),numstr)),'EdgeColor','r','FaceColor','w','LineWidth',2);
errorbar(3,nanmean(RateRegress(X(Uidx,wshidx),numstr)),nanstd(RateRegress(X(Uidx,wshidx),numstr)),'r');
plot(1:3,[nanmean(RateRegress(X(Sidx,wshidx),numstr)),nanmean(RateRegress(X(Vidx,wshidx),numstr)),nanmean(RateRegress(X(Uidx,wshidx),numstr))],'k-');
ylim([0 1]);
title('TwoP Model Washout Rate');
ylabel('Rate');
xlabel('Conditions');
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'S','V','U'};

%plot aftereffects
subplot(3,3,9); hold on
plot(1,nanmean(nanmean(TMAP(Sidx,AEidx),1)),'bo');
errorbar(1,nanmean(nanmean(TMAP(Sidx,AEidx),1)),nanstd(nanmean(TMAP(Sidx,AEidx),1)),'b');
plot(1.1,nanmean(nanmean(X(Sidx,AEidx),1)),'ro');
errorbar(1.1,nanmean(nanmean(X(Sidx,AEidx),1)),nanstd(nanmean(X(Sidx,AEidx),1)),'r');
plot(2,nanmean(nanmean(TMAP(Vidx,AEidx),1)),'bo');
errorbar(2,nanmean(nanmean(TMAP(Vidx,AEidx),1)),nanstd(nanmean(TMAP(Vidx,AEidx),1)),'b');
plot(2.1,nanmean(nanmean(X(Vidx,AEidx),1)),'ro');
errorbar(2.1,nanmean(nanmean(X(Vidx,AEidx),1)),nanstd(nanmean(X(Vidx,AEidx),1)),'r');
plot(3,nanmean(nanmean(TMAP(Uidx,AEidx),1)),'bo');
errorbar(3,nanmean(nanmean(TMAP(Uidx,AEidx))),nanstd(nanmean(TMAP(Uidx,AEidx))),'b');
plot(3.1,nanmean(nanmean(X(Uidx,AEidx),1)),'ro');
errorbar(3.1,nanmean(nanmean(X(Uidx,AEidx))),nanstd(nanmean(X(Uidx,AEidx))),'r');
xlim([0.5 3.5]);
ylim([0 15]);
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'S','V','U'};
title('AEs');
ylabel('Aftereffect');
xlabel('Conditions');


end