function [grpIB, grpEW, ARrate, grpAllWsh] = WshDataPlt(T,nbins)

%Plots stride by stride washout data and washout variables of interest

%Input: 
%T = data table
%nbins = number of bins for plotting

%Output: 
%grpIB = Initial bias for each subject
%grpEW = Early washout for each subject
%ARrate = washout rate for each subject
%AllBins = All washout data for each participant, set up so that the first
%column is the indexing variable for each condition

%Pre-allocate variables
grpAllWsh = [];
idxCond = [];
AllBins = [];

%Index and loop through conditions 
Cs = {'Constant','LV','HV'};
for c = 1:length(Cs)
    
    %Current condition and index
    CurrentC = Cs{c}; 
    Cidx = find(strcmp(CurrentC,T.Condition)==1);
    
    %Index and loop through subjects
    Subjs = unique(T.SID(Cidx));
    for s = 1:length(Subjs)
        
        %Current subject
        CurrentS = Subjs{s};
        
        %Make learning and washout indices
        lrnidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('learning',T.phase)==1);        
        wshidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('washout',T.phase)==1);
           
        %Index SAI data
        SAIwsh = T.BslCor_SAI(wshidx);
        SAIwsh(isnan(SAIwsh)==1) = [];
        grpAllWsh = [grpAllWsh; SAIwsh(1:745)'];

        %Bin
        Binwsh = Bin(SAIwsh(1:745).',nbins, 1, 'mean');
        AllBins = [AllBins; Binwsh];
        
        %Calculate learning mean and SD (for regression analysis)
        grpSAI_Lrnmu(s,c) = nanmean(T.BslCor_SAI(lrnidx));
        grpSAI_Lrnsd(s,c) = nanstd(T.BslCor_SAI(lrnidx));        
        
        %Calculate washout variables of interest
        grpIB(s,c) = mean(SAIwsh(1:5));
        grpEW(s,c) = mean(SAIwsh(6:30));
        ARrate(s,c) = RateRegress(SAIwsh',50);
        
        %Indexing variables for each condition
        if strcmp(CurrentC,'Constant')==1
            idxCond = [idxCond; 1];
        elseif strcmp(CurrentC,'LV')==1
            idxCond = [idxCond; 2];
         elseif strcmp(CurrentC,'HV')==1
            idxCond = [idxCond; 3];   
        end  
    end
end

%Add the indexing variable to all the washout strides
grpAllWsh = [idxCond, grpAllWsh];

%Set indexing variables
Constidx = find(idxCond==1);
LVidx = find(idxCond==2);
HVidx = find(idxCond==3);

%Set up legend
pltlegend = {'Constant','Low Variability', 'High Variability'};

%Colors for plotting
colors = lines(6);
pc = colors(4,:);
meancolors = lines(3);
icolors = gray(3);

%Plot washout strides
figure; subplot(3,6,1:6); hold on
shadedErrorBar(1:length(AllBins), nanmean(AllBins(Constidx,:)),SEM(AllBins(Constidx,:),1), 'lineProps', {'color',meancolors(1,:),'linewidth',1});
shadedErrorBar(1:length(AllBins), nanmean(AllBins(LVidx,:)),SEM(AllBins(LVidx,:),1), 'lineProps', {'color',meancolors(2,:),'linewidth',1});
shadedErrorBar(1:length(AllBins), nanmean(AllBins(HVidx,:)),SEM(AllBins(HVidx,:),1), 'lineProps', {'color',meancolors(3,:),'linewidth',1});
plot(1:length(AllBins),zeros(1,length(AllBins)),'k');
title('Washout');
ylabel('SAI (%)'); xlabel(['Binned (bins = ', num2str(nbins), ') Strides']);
ylim([-1 4]); xlim([-7 length(AllBins)]);
legend(pltlegend); legend('boxoff');
%Plot mean of first 5 strides in shaded region
rectangle('Position',[-7, -3, 7, 9], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
plot(-3,mean(grpIB(:,1)),'MarkerFaceColor',meancolors(1,:),'Marker','o','MarkerEdgeColor',meancolors(1,:));
errorbar(-3,mean(grpIB(:,1)),SEM(grpIB(:,1),1),'Color',meancolors(1,:),'LineWidth',2);
plot(-5,mean(grpIB(:,2)),'MarkerFaceColor',meancolors(2,:),'Marker','o','MarkerEdgeColor',meancolors(2,:));
errorbar(-5,mean(grpIB(:,2)),SEM(grpIB(:,2),1),'Color',meancolors(2,:),'LineWidth',2);
plot(-2,mean(grpIB(:,3)),'MarkerFaceColor',meancolors(3,:),'Marker','o','MarkerEdgeColor',meancolors(3,:));
errorbar(-2,mean(grpIB(:,3)),SEM(grpIB(:,3),1),'Color',meancolors(3,:),'LineWidth',2);

%Plot Initial Bias
subplot(3,6,7:8); hold on
for i = 1:length(grpIB)
    p2 = plot([1,2,3], grpIB(i,:), 'Marker','none', 'Color', icolors(2,:),'LineWidth',0.2);
end
p1 = plot(nanmean(grpIB),'-', 'Color', pc, 'LineWidth', 2, 'Marker','.');
plot(0:4, zeros(1,5), 'k-');
title('Initial Bias');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([-3 6]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = Cs;
legend([p1,p2],'Mean','Indiv','location','south');
legend('boxoff');

%Plot Early Washout
subplot(3,6,9:10); hold on
for i = 1:length(grpEW)
    plot([1,2,3], grpEW(i,:), 'Marker','none', 'Color',icolors(2,:),'LineWidth',0.2);
end
plot(nanmean(grpEW),'-', 'Color', pc, 'LineWidth', 2, 'Marker','.');
plot(0:4, zeros(1,5), 'k-');
title('Early Washout');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([-3 6]);
ax = gca;ax.XTick = 1:3;
ax.XTickLabels = Cs;

%Plot Washout rates
subplot(3,6,11:12); hold on
for i = 1:length(ARrate)
    plot([1,2,3], ARrate(i,:), 'Marker','none', 'Color', icolors(2,:),'LineWidth',0.2);
end
plot(nanmean(ARrate),'-', 'Color', pc, 'LineWidth', 2, 'Marker','.');
title('Washout Rate');
ylabel({'Unlearning per stride'; 'Faster Washout \rightarrow'});
xlim([0.5 3.5]); ylim([0 1.3]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = Cs;

%Plot Learning SD vs Initial bias
subplot(3,6,14:15); hold on 
for s = 1:length(grpSAI_Lrnsd)
    %Regress
    y = grpIB(s,:)';
    x = [ones(3,1), grpSAI_Lrnsd(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bIB(:,s) = betas;
    yhat = x * betas;
    
    %Plot each individual's regression
    plot(grpSAI_Lrnsd(s,:),yhat, 'Color',icolors(2,:),'LineWidth',0.2);
end
%Calculate mean regression
[~,pIB,~,stats] = ttest(bIB(2,:));
meanx = [ones(3,1), mean(grpSAI_Lrnsd)'];
meanyhat = meanx * mean(bIB,2);
%Plot
p1 = plot(mean(grpSAI_Lrnsd), meanyhat,'Color',colors(4,:),'LineWidth',2);
xlabel('Learning SAI SD'); ylabel('Initial Bias (SAI %)');
title('Learning SAI SD vs Initial Bias');
xlim([0 14]); ylim([-1 6]);

%Plot inset of the mean and individual slopes
axes('Position',[.45 .2 .03 .1]);
hold on
bar(1, mean(bIB(2,:)), 'FaceColor', 'w', 'EdgeColor', colors(4,:));
errorbar(1,mean(bIB(2,:)),SEM(bIB(2,:),2),'Color',colors(4,:));
xlim([0 2]); ylim([-1 0.1]);
ax = gca; ax.XTick = 1:2;
ax.XTickLabels = '';
ylabel('slopes');

%Learning SD vs Early washout
subplot(3,6,16:17); hold on 
for s = 1:length(grpSAI_Lrnsd)
    %Regress
    y = grpEW(s,:)';
    x = [ones(3,1), grpSAI_Lrnsd(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bEW(:,s) = betas;
    yhat = x * betas;
    
    %Plot each individual's regression
    plot(grpSAI_Lrnsd(s,:),yhat, 'Color',icolors(2,:),'LineWidth',0.2);
end
%Calculate mean regression
[~,pEW,~,stats] = ttest(bEW(2,:));
meanx = [ones(3,1),  mean(grpSAI_Lrnsd)'];
meanyhat = meanx * mean(bEW,2);

%Plot
p1 = plot(mean(grpSAI_Lrnsd), meanyhat,'Color',colors(4,:),'LineWidth',2);
xlabel('Learning SAI SD');
ylabel('Early Washout (SAI %)');
title('Learning SAI SD vs Early Washout');
xlim([0 14]); ylim([-1 6]);

%Plot inset of the mean and individual slopes
axes('Position',[.73 .2 .03 .1]); hold on
bar(1, mean(bEW(2,:)), 'FaceColor', 'w', 'EdgeColor',colors(4,:));
errorbar(1,mean(bEW(2,:)),SEM(bEW(2,:),2),'Color',colors(4,:));
xlim([0 2]); ylim([-1 0.1]);
ax = gca; ax.XTick = 1:2;
ax.XTickLabels = ''; 
ylabel('slopes');

%Display statistics for the relationship calculations 
disp(['Learning SAI SD vs Initial Bias beta = ' num2str(round(mean(bIB(2,:)),2)), ' [' num2str(CI95(bIB(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(pIB,2))]);

disp(['Learning SAI SD vs Early Washout beta = ' num2str(round(mean(bEW(2,:)),2)), ' [' num2str(CI95(bEW(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p=' num2str(round(pEW,2))]);


%Display learning mean and aftereffect relationships

%Learning mean vs initial bias
for s = 1:length(grpSAI_Lrnmu)
    %Regress
    y = grpIB(s,:)';
    x = [ones(3,1), grpSAI_Lrnmu(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bIB(:,s) = betas;
    yhat = x * betas;
end
[~,pIB,~,stats] = ttest(bIB(2,:));
%Display stats
disp(['Learding SAI Mean vs Initial Bias beta = ' num2str(round(mean(bIB(2,:)),2)), ' [' num2str(CI95(bIB(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p=' num2str(round(pIB,2))]);

%Learning mean vs early washout
for s = 1:length(grpSAI_Lrnmu)
    %Regress
    y = grpEW(s,:)';
    x = [ones(3,1), grpSAI_Lrnmu(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bEW(:,s) = betas;
    yhat = x * betas;
end
[~,pEW,~,stats] = ttest(bEW(2,:));
%Display stats
disp(['Learding SAI Mean vs Early Washout beta = ' num2str(round(mean(bEW(2,:)),2)), ' [' num2str(CI95(bEW(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p=' num2str(round(pEW,2))]);

end