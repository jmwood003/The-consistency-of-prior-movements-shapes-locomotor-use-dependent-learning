<<<<<<< Updated upstream
function SimPlot(TMAP,X,numstr,N)
=======
function [Varcomp, Unifcomp] = SimPlot(TMAP,X,numstr,N)
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
shadedErrorBar(1:length(wshidx),nanmean(TMAP(Sidx,wshidx),1),nanstd(TMAP(Sidx,wshidx),0,1),'lineProps','-b');
shadedErrorBar(1:length(wshidx),nanmean(X(Sidx,wshidx),1),nanstd(X(Sidx,wshidx),0,1),'lineProps','-r');
ylim([0 20]);
ylabel('Step Asymmetry');
title('Stable Condition Washout');
=======
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Sidx,:),1),nanstd(TMAP(Sidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Sidx,:),1),nanstd(X(Sidx,:),0,1),'lineProps','-r');
% ylim([0 40]);
ylabel('Step Asymmetry');
title('Stable Condition');
>>>>>>> Stashed changes
legend('Bayes Prediction','Two process prediction');
legend('boxoff');

%Plot the variable condition
subplot(3,3,4:5); hold on
<<<<<<< Updated upstream
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
=======
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Vidx,:),1),nanstd(TMAP(Vidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Vidx,:),1),nanstd(X(Vidx,:),0,1),'lineProps','-r');
ylim([0 40]);
ylabel('Step Asymmetry');
title('Variable Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');

%Plot the uniform condition
subplot(3,3,7:8); hold on
shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(Uidx,:),1),nanstd(TMAP(Uidx,:),0,1),'lineProps','-b');
shadedErrorBar(1:size(X,2),nanmean(X(Uidx,:),1),nanstd(X(Uidx,:),0,1),'lineProps','-r');
ylim([0 40]);
xlabel('Washout Strides')
ylabel('Step Asymmetry');
title('Uniform Condition');
% legend('Bayes Prediction','Two process prediction');
% legend('boxoff');
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
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

=======
% %plot aftereffects
% subplot(3,3,9); hold on
% plot(1,nanmean(nanmean(TMAP(Sidx,AEidx),1)),'bo');
% errorbar(1,nanmean(nanmean(TMAP(Sidx,AEidx),1)),nanstd(nanmean(TMAP(Sidx,AEidx),1)),'b');
% plot(1.1,nanmean(nanmean(X(Sidx,AEidx),1)),'ro');
% errorbar(1.1,nanmean(nanmean(X(Sidx,AEidx),1)),nanstd(nanmean(X(Sidx,AEidx),1)),'r');
% plot(2,nanmean(nanmean(TMAP(Vidx,AEidx),1)),'bo');
% errorbar(2,nanmean(nanmean(TMAP(Vidx,AEidx),1)),nanstd(nanmean(TMAP(Vidx,AEidx),1)),'b');
% plot(2.1,nanmean(nanmean(X(Vidx,AEidx),1)),'ro');
% errorbar(2.1,nanmean(nanmean(X(Vidx,AEidx),1)),nanstd(nanmean(X(Vidx,AEidx),1)),'r');
% plot(3,nanmean(nanmean(TMAP(Uidx,AEidx),1)),'bo');
% errorbar(3,nanmean(nanmean(TMAP(Uidx,AEidx))),nanstd(nanmean(TMAP(Uidx,AEidx))),'b');
% plot(3.1,nanmean(nanmean(X(Uidx,AEidx),1)),'ro');
% errorbar(3.1,nanmean(nanmean(X(Uidx,AEidx))),nanstd(nanmean(X(Uidx,AEidx))),'r');
% xlim([0.5 3.5]);
% ylim([0 15]);
% ax = gca;
% ax.XTick = [1:3];
% ax.XTickLabel = {'S','V','U'};
% title('AEs');
% ylabel('Aftereffect');
% xlabel('Conditions');

%Plot aftereffects different from stable
AEreferenceB = nanmean(TMAP(Sidx,AEidx),2);
AEBv = AEreferenceB - nanmean(TMAP(Vidx,AEidx),2);
AEBu = AEreferenceB - nanmean(TMAP(Uidx,AEidx),2);
AEreferenceTs = nanmean(X(Sidx,AEidx),2);
AETv = AEreferenceTs - nanmean(X(Vidx,AEidx),2);
AETu = AEreferenceTs - nanmean(X(Uidx,AEidx),2);

subplot(3,3,9); hold on
%Plot Bayes AEs difference from reference
p1 = plot(1,nanmean(AEBv),'bo');
errorbar(1,nanmean(AEBv),nanstd(AEBv),'b');
plot(2,nanmean(AEBu),'bo');
errorbar(2,nanmean(AEBu),nanstd(AEBu),'b');

%Plot two P AEs difference from reference
p2 = plot(1.1,nanmean(AETv),'ro');
errorbar(1.1,nanmean(AETv),nanstd(AETv),'r');
plot(2.1,nanmean(AETu),'ro');
errorbar(2.1,nanmean(AETu),nanstd(AETu),'r');

plot(0.5:2.5,zeros(1,3),'k');
xlim([0.5 2.5]);
ylim([-5 5]);
ax = gca;
ax.XTick = [1:2];
ax.XTickLabel = {'S-V','S-U'};
% legend([p1 p2],'Bayes Model', 'TwoP Model');
% legend('boxoff');
title('Var AE - Refrence');
ylabel('Delta SAI');
xlabel('Conditions');

%Is the change greater in the Bayesian model each time simulation?
Varcomp = AEBv>AETv;
Unifcomp = AEBu>AETu;
>>>>>>> Stashed changes

end