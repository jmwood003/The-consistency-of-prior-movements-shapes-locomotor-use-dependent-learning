function SimPlot(TMAP,X,W,S,numstr,N)

%Index-----------------------------------------------------------------
%Washout index
wshidx = 752:1499;
AEidxI = 752:756;
AEidxE = 757:786;
%Learning indices
LrnIdx = 251:260;

%Plot --------------------------------------------------------------------

%Colors
colors = lines(7);
ABcolor = colors(6,:);
Xcolor = colors(3,:);
Stratcolor = colors(2,:);
UDcolor = colors(7,:);

%Setup indices
subplotidx = [1:3; 4:6; 7:9];
CurrentIdx = 1:N;
InsetPos = [.8 .59 .37];
Titles = {'Constant', 'LV', 'HV'};

figure; hold on
for i = 1:3
    
    %Plot the constant condition
    subplot(4,3,subplotidx(i,:)); hold on
    rectangle('Position',[1, -20, 250 100], 'FaceColor',[0.8 0.8 0.8]);
    rectangle('Position',[750, -20, 750 100], 'FaceColor',[0.8 0.8 0.8]);
    shadedErrorBar(1:size(TMAP,2),nanmean(TMAP(CurrentIdx,:),1),nanstd(TMAP(CurrentIdx,:),0,1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
    shadedErrorBar(1:size(W,2),nanmean(W(CurrentIdx,:),1),nanstd(W(CurrentIdx,:),0,1),'lineprops',{'linestyle','-','color',UDcolor,'linewidth',1});
    shadedErrorBar(1:size(S,2),nanmean(S(CurrentIdx,:),1),nanstd(S(CurrentIdx,:),0,1),'lineprops',{'linestyle','-','color',Stratcolor,'linewidth',1});
    shadedErrorBar(1:size(X,2),nanmean(X(CurrentIdx,:),1),nanstd(X(CurrentIdx,:),0,1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
    plot(1:size(X,2),zeros(1,size(X,2)),'k');
    ylim([-1 35]);     title(Titles{i});
    if i==1
        legend('AB model','W','S','S+U model (x)','Location','north');
        legend('boxoff');
    elseif i==2
        ylabel('Step Asymmetry (%)');
    end
    %Create Inset of washout
    axes('Position',[.6 InsetPos(i) .2 .1])
    box on; hold on;
    shadedErrorBar(1:size(TMAP(wshidx),2),nanmean(TMAP(CurrentIdx,wshidx),1),nanstd(TMAP(CurrentIdx,wshidx),0,1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
    shadedErrorBar(1:size(X(wshidx),2),nanmean(X(CurrentIdx,wshidx),1),nanstd(X(CurrentIdx,wshidx),0,1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
    plot(1:size(X(wshidx),2),zeros(1,size(X(1,wshidx),2)),'k-');
    ylim([-2 10]); xlim([0 50]);
    %Create inset of early learning
    axes('Position',[.15 InsetPos(i) .08 .08]);
    box on; hold on;
    shadedErrorBar(1:size(TMAP(LrnIdx),2),nanmean(TMAP(CurrentIdx,LrnIdx),1),nanstd(TMAP(CurrentIdx,LrnIdx),0,1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
    shadedErrorBar(1:size(X(LrnIdx),2),nanmean(X(CurrentIdx,LrnIdx),1),nanstd(X(CurrentIdx,LrnIdx),0,1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
    plot(1:size(X(LrnIdx),2),ones(1,size(X(1,LrnIdx),2))*22,'k-');
    xlim([0 length(LrnIdx)]);
    
    %Make some calculations--------------------------------------------------
    %Mean aftereffects for both simulations 
    AEi_AB(:,i) = nanmean(TMAP(CurrentIdx,AEidxI),2);
    AEi_SU(:,i) = nanmean(X(CurrentIdx,AEidxI),2);
    AEe_AB(:,i) = nanmean(TMAP(CurrentIdx,AEidxE),2);
    AEe_SU(:,i) = nanmean(X(CurrentIdx,AEidxE),2);

    %Washout rates using regression:
    WR_AB(:,i) = RateRegress(TMAP(CurrentIdx,wshidx),numstr);
    WR_SU(:,i) = RateRegress(X(CurrentIdx,wshidx),numstr);
    
    %Update index
    %Index current condition
    startidx = CurrentIdx(end)+1;
    CurrentIdx = startidx:startidx+N-1;

end

%plot initial washout aftereffects
subplot(4,3,10); hold on
errorbar([0.9, 1.9, 2.9],nanmean(AEi_AB),nanstd(AEi_AB),'Marker','o','MarkerFaceColor',ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar([1.1, 2.1, 3.1],nanmean(AEi_SU),nanstd(AEi_SU),'Marker','o','MarkerFaceColor',Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
xlim([0.5 3.5]); ylim([0 8]);
ax = gca; ax.XTick = [1:3];
ax.XTickLabel = {'Constant','LV','HV'};
title('Initial Bias');
ylabel('SAI (%)');
xlabel('Conditions');

%plot early washout aftereffects
subplot(4,3,11); hold on
errorbar([0.9, 1.9, 2.9],nanmean(AEe_AB),nanstd(AEe_AB),'Marker','o','MarkerFaceColor',ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar([1.1, 2.1, 3.1],nanmean(AEe_SU),nanstd(AEe_SU),'Marker','o','MarkerFaceColor',Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
xlim([0.5 3.5]); ylim([0 8]);
ax = gca; ax.XTick = [1:3];
ax.XTickLabel = {'Constant','LV','HV'};
title('Early Washout');
ylabel('SAI (%)');
xlabel('Conditions');

%Plot washout rates 
subplot(4,3,12); hold on
errorbar([0.9, 1.9, 2.9],nanmean(WR_AB),nanstd(WR_AB),'Marker','o','MarkerFaceColor',ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar([1.1, 2.1, 3.1],nanmean(WR_SU),nanstd(WR_SU),'Marker','o','MarkerFaceColor',Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
% ylim([-0.1 1]);
title('Washout Rates');
ylabel('Unlearning/stride');
ax = gca; ax.XTick = [1:3];
ax.XTickLabel = {'Constant','LV','HV'};

end