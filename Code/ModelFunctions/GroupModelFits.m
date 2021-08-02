function GroupModelFits(T, insetlen, num_initials)

%Fits individual data to each (4) model. Plots the individual fits and mean
%model fits. Calculates the aftereffects for the emperical data and model
%simulations and plots. 

%T = data table
%insetlen = length of washout inset
%num_initials = number of initializations to run

close all;

%Aftereffect index
IBidx = 1:5;
EWidx = 6:30;

%Find the shortest phase to truncate
SesID = unique(T.sessionID);
shortest = [];
for i = 1:length(SesID)
    bsl = find(strcmp(T.sessionID,SesID{i})==1 & strcmp(T.phase,'baseline')==1);
    bsl = bsl(isnan(T.BslCor_SAI(bsl))==0); 
    lrn = find(strcmp(T.sessionID,SesID{i})==1 & strcmp(T.phase,'learning')==1);
    lrn = lrn(isnan(T.BslCor_SAI(lrn))==0);    
    wsh = find(strcmp(T.sessionID,SesID{i})==1 & strcmp(T.phase,'washout')==1);
    wsh = wsh(isnan(T.BslCor_SAI(wsh))==0); 
    shortest = [shortest; length(bsl), length(lrn), length(wsh)];
end
trunc = min(shortest);

%Set colors for plotting
colors = lines(7);
Datacolor = colors(4,:);
ABcolor = colors(6,:);
Stratcolor = colors(2,:);
UDcolor = colors(7,:);
Xcolor = colors(3,:);
icolors = gray(3);

%Set information for individual plotting
figT = {'S+U Model','AB Model','Modified S+U Model','Modified AB Model'};
modelstr = {'SU','AB','SU2','AB2'}; 
outputstr = {'x','tmap','x','tmap'};
loopCs = [Xcolor; ABcolor; Xcolor; ABcolor];

%Loop throughe each subject
Subjs = unique(T.SID);
for s = 1:length(Subjs)

    %Current subject
    CS = Subjs{s};
    disp(CS);

    %Index the subject
    Sidx = find(strcmp(T.SID,CS)==1);

    %Find the order the subject performed each condition
    [~, SortedIdx] = sort(T.DateTime(Sidx));
    Order = unique(T.Condition(Sidx(SortedIdx)),'stable');

	%Loop through conditions to organize the data and targets for this subject 
    Data = []; Trgt = [];
    Cidx = []; Pidx = [];
    for c = 1:length(Order)

        %loop through phases
        phases = {'baseline','learning','washout'};
        for p = 1:length(phases)

            %Create index for the data 
            Didx = find(strcmp(T.Condition,Order{c})==1 & strcmp(T.phase,phases{p})==1 & strcmp(T.SID,CS)==1);
            
            %Index and remove nans for the data and the target
            Dtemp = T.BslCor_SAI(Didx);
            d = Dtemp(isnan(Dtemp)==0);
            Data = [Data, d'];
            Ttemp = T.TrgtSAI(Didx);
            Trgt = [Trgt, Ttemp(1:length(d))'];
                 
            %Make indexing variables
            Pidx = [Pidx, ones(1,length(d))*p];
            if strcmp(Order{c},'Constant')==1
                Cidx = [Cidx, ones(1,length(d))];            
            elseif strcmp(Order{c},'LV')==1
                Cidx = [Cidx, ones(1,length(d))*2];                            
            elseif strcmp(Order{c},'HV')==1
                Cidx = [Cidx, ones(1,length(d))*3];                            
            end
        end
    end
    
	%Fit models to data, simulate and assess fits
    S = Fit4Models(Data,Trgt,Cidx,Pidx,num_initials);
    
    %Calculate Aftereffects for data and each model for each condition and
    Conds = unique(Cidx, 'stable');    
    for c = 1:length(Conds)
        %Create index
        currentIdx = find(Cidx==c & Pidx==3);
        %AB
        S.AB.IB(c) = nanmean(S.AB.tmap(currentIdx(IBidx)));
        S.AB.EW(c) = nanmean(S.AB.tmap(currentIdx(EWidx)));
        %SU
        S.SU.IB(c) = nanmean(S.SU.x(currentIdx(IBidx)));
        S.SU.EW(c) = nanmean(S.SU.x(currentIdx(EWidx)));
        %SU gain
        S.SU2.IB(c) = nanmean(S.SU2.x(currentIdx(IBidx)));
        S.SU2.EW(c) = nanmean(S.SU2.x(currentIdx(EWidx)));
        %AB 2L 2B
        S.AB2.IB(c) = nanmean(S.AB2.tmap(currentIdx(IBidx)));
        S.AB2.EW(c) = nanmean(S.AB2.tmap(currentIdx(EWidx)));
        %Data
        S.Data.IB(c) = nanmean(Data(currentIdx(IBidx)));
        S.Data.EW(c) = nanmean(Data(currentIdx(EWidx)));   
    end    
    
    %Plot individual fits

    %For plotting lines between conditions
    condchange = find(abs(diff(Cidx))>0);
    %Create indexing variables for each condition
    cBsl = find(Pidx==1 & Cidx==1);
    lvBsl = find(Pidx==1 & Cidx==2);
    hvBsl = find(Pidx==1 & Cidx==3);
    cWsh = find(Pidx==3 & Cidx==1);
    lvWsh = find(Pidx==3 & Cidx==2);
    hvWsh = find(Pidx==3 & Cidx==3);
    
    %Loop through each model and plot individual fits
    for m = 1:4
        
        %Set up structure of plot
        figure(m);
        subplot(6,3,s); hold on
        rectangle('Position',[cBsl(1), -5, length(cBsl) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        rectangle('Position',[lvBsl(1), -5, length(lvBsl) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        rectangle('Position',[hvBsl(1), -5, length(hvBsl) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        rectangle('Position',[cWsh(1), -5, length(cWsh) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        rectangle('Position',[lvWsh(1), -5, length(lvWsh) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        rectangle('Position',[hvWsh(1), -5, length(hvWsh) 50], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        line([condchange(1) condchange(1)],get(gca,'ylim'),'LineWidth',1,'Color','k');
        line([condchange(2) condchange(2)],get(gca,'ylim'),'LineWidth',1,'Color','k');
        
        %Plot data
        plot(1:length(Data),zeros(length(Data),1),'k');
        p1 = plot(Data,'.','Color',Datacolor,'LineStyle','none','MarkerSize',2);
        p2 = plot(S.(modelstr{m}).(outputstr{m}),'Color',loopCs(m,:),'LineWidth',0.5);
        
        %Add information
        xlim([0 length(Data)]); ylim([-5 40]);
        title(strrep(CS,'_',' '),'FontName','Arial','FontSize',12);
        text(3900,30,['r^2 = ' num2str(round(S.(modelstr{m}).r2,2))],'FontSize',10);
        text(3900,20,['AIC = ' num2str(round(S.(modelstr{m}).aic))],'FontSize',10);
        set(gca,'xtick',[750, 2250, 3750],'xTickLabel',Order);
        
        %Add labels and legend and title
        if s==16
            xlabel('Strides'); ylabel('SAI'); 
        elseif s==18
            legend([p1, p2], {'Data', 'Model'}, 'Position', [0.9 0.5, 0.1 0.1]);
            legend('boxoff');   
            suptitle(['Inidivudal fits: ', figT{m}]);
        end
    end
    
    %Save model fits parameters, and aftereffects from structure into
    %variables
    %AB model
    ABparams(s,:) = S.AB.params;
    ABr2(s,:) = S.AB.r2;    ABr2W(s,:) = S.AB.r2W;
    ABaic(s,:) = S.AB.aic;    ABaicW(s,:) = S.AB.aicW;
    AB_IB(s,:) = S.AB.IB;    AB_EW(s,:) = S.AB.EW;
    
    %SU model
    SUparams(s,:) = S.SU.params;
    SUr2(s,:) = S.SU.r2;    SUr2W(s,:) = S.SU.r2W;
    SUaic(s,:) = S.SU.aic;    SUaicW(s,:) = S.SU.aicW;
    SU_IB(s,:) = S.SU.IB;    SU_EW(s,:) = S.SU.EW;
    
    %Modified AB model
    AB2params(s,:) = S.AB2.params;
    AB2r2(s,:) = S.AB2.r2;    AB2r2W(s,:) = S.AB2.r2W;
    AB2aic(s,:) = S.AB2.aic;    AB2aicW(s,:) = S.AB2.aicW;
    AB2_IB(s,:) = S.AB2.IB;    AB2_EW(s,:) = S.AB2.EW;
    
    %Modified SU model
    SU2params(s,:) = S.SU2.params;
    SU2r2(s,:) = S.SU2.r2;    SU2r2W(s,:) = S.SU2.r2W;
    SU2aic(s,:) = S.SU2.aic;    SU2aicW(s,:) = S.SU2.aicW;
    SU2_IB(s,:) = S.SU2.IB;    SU2_EW(s,:) = S.SU2.EW;
    
    %Data
    Data_IB(s,:) = S.Data.IB;    Data_EW(s,:) = S.Data.EW;
    
    %Truncate all data and model simulations for group plotting
    Dall = [];      PidxAll = [];    CidxAll = [];    
    T_mapAll = [];  T_map2All = [];
    xAll = [];      x2All = [];
    WAll = [];      W2All = [];
    SAll = [];      S2All = [];
    for c = 1:length(Order)
        for p = 1:length(phases)
            Idx = find(Cidx==c & Pidx==p);
            Idx = Idx(1:trunc(p));
            
            Dall = [Dall, Data(Idx)];
            T_mapAll = [T_mapAll, S.AB.tmap(Idx)];
            T_map2All = [T_map2All, S.AB2.tmap(Idx)];
            xAll = [xAll, S.SU.x(Idx)];
            WAll = [WAll, S.SU.w(Idx)];
            SAll = [SAll, S.SU.s(Idx)];
            x2All = [x2All, S.SU2.x(Idx)];
            W2All = [W2All, S.SU2.w(Idx)];
            S2All = [S2All, S.SU2.s(Idx)];
            %Indexing variables
            PidxAll = [PidxAll, ones(1,length(Idx))*p];
            CidxAll = [CidxAll, ones(1,length(Idx))*c];            
        end
    end    
    Data_All(s,:) = Dall;
    AB_All(s,:) = T_mapAll;     AB2_All(s,:) = T_map2All;
    SUx_All(s,:) = xAll;        SU2x_All(s,:) = x2All;
    SUw_All(s,:) = WAll;        SU2w_All(s,:) = W2All;
    SUs_All(s,:) = SAll;        SU2s_All(s,:) = S2All;
    
end

%Plot group averaged simulations and aftereffects--------------------------

%For plotting lines between conditions
condchangeAll = find(abs(diff(CidxAll))>0);

%Create indexing variables for each condition
HVidxAll = find(CidxAll==3);
ConstBsl = find(PidxAll==1 & CidxAll==1);
ConstWsh = find(PidxAll==3 & CidxAll==1);
LVBsl = find(PidxAll==1 & CidxAll==2);
LVWsh = find(PidxAll==3 & CidxAll==2);
HVBsl = find(PidxAll==1 & CidxAll==3);
HVWsh = find(PidxAll==3 & CidxAll==3);

%Plot group averaged model fits for the original models
figure;
%Plot SU model
subplot(4,5,1:5); hold on
rectangle('Position',[ConstBsl(1), -20, length(ConstBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[ConstWsh(1), -20, length(ConstWsh)+length(LVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[LVWsh(1), -20, length(LVWsh)+length(HVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[HVWsh(1), -20, length(HVWsh) 100], 'FaceColor',[0.8 0.8 0.8]);
shadedErrorBar(1:length(Data_All),mean(Data_All),SEM(Data_All,1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SUs_All),SEM(SUs_All,1),'lineprops',{'linestyle',':','color',Stratcolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SUw_All),SEM(SUw_All,1),'lineprops',{'linestyle',':','color',UDcolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SUx_All),SEM(SUx_All,1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
plot(1:length(Data_All),zeros(1,length(Data_All)),'k');
xlim([0 length(Data_All)]); ylim([-1 32]);
line([condchangeAll(1) condchangeAll(1)],get(gca,'ylim'),'LineWidth',3,'Color','k');
line([condchangeAll(2) condchangeAll(2)],get(gca,'ylim'),'LineWidth',3,'Color','k');
text(length(Data_All)-length(HVidxAll)/3,30,['r^2 = ' num2str(round(mean(SUr2),2))  ' +/- ' num2str(round(std(SUr2),2))]);
text(length(Data_All)-length(HVidxAll)/3,25,['AIC = ' num2str(round(mean(SUaic))) ' +/- ' num2str(round(std(SUaic)))]);
text(15,30,'Baseline'); text(450,30,'Learning'); text(1030,30,'Washout');
legend({'Data', 'S', 'W', 'X'},'Position',[0.93, 0.8, 0.03, 0.03]); legend('boxoff');
title('Strategy Plus Use-Dependent Model Fits');
ylabel('SAI %');  set(gca,'xtick',[]);

%Plot washout insets
axes('Position',[0.27,0.77,0.1,0.1]);
plot(1:length(ConstWsh),zeros(1,length(ConstWsh)),'k');
shadedErrorBar(1:length(ConstWsh),mean(Data_All(:,ConstWsh)),SEM(Data_All(:,ConstWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(ConstWsh),mean(SUx_All(:,ConstWsh)),SEM(SUx_All(ConstWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
set(gca,'xtick',[]); 
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.53,0.77,0.1,0.1]);
plot(1:length(LVWsh),zeros(1,length(LVWsh)),'k');
shadedErrorBar(1:length(LVWsh),mean(Data_All(:,LVWsh)),SEM(Data_All(:,LVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(LVWsh),mean(SUx_All(:,LVWsh)),SEM(SUx_All(LVWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.8,0.77,0.1,0.1]);
plot(1:length(HVWsh),zeros(1,length(HVWsh)),'k');
shadedErrorBar(1:length(HVWsh),mean(Data_All(:,HVWsh)),SEM(Data_All(:,HVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(HVWsh),mean(SUx_All(:,HVWsh)),SEM(SUx_All(HVWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]); set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

%Plot AB model
subplot(4,5,6:10); hold on
rectangle('Position',[ConstBsl(1), -20, length(ConstBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[ConstWsh(1), -20, length(ConstWsh)+length(LVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[LVWsh(1), -20, length(LVWsh)+length(HVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[HVWsh(1), -20, length(HVWsh) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
shadedErrorBar(1:length(Data_All),mean(Data_All),SEM(Data_All,1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(AB_All),SEM(AB_All,1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
plot(1:length(Data_All),zeros(1,length(Data_All)),'k');
xlim([0 length(Data_All)]); ylim([-1 32]);
line([condchangeAll(1) condchangeAll(1)],get(gca,'ylim'),'LineWidth',3,'Color','k');
line([condchangeAll(2) condchangeAll(2)],get(gca,'ylim'),'LineWidth',3,'Color','k');
text(length(Data_All)-length(HVidxAll)/3,30,['r^2 = ' num2str(round(mean(ABr2),2)) ' +/- ' num2str(round(std(ABr2),2))]);
text(length(Data_All)-length(HVidxAll)/3,25,['AIC = ' num2str(round(mean(ABaic))) ' +/- ' num2str(round(std(ABaic)))]);
legend({'Data', 'MAP'},'Position',[0.93, 0.6, 0.03, 0.03]); legend('boxoff');
title('Adaptive Bayesian Model Fits');
ylabel('SAI %'); xlabel('Strides');
set(gca,'xtick',[]);

%Plot washout insets
axes('Position',[0.27,0.57,0.1,0.1]);
plot(1:length(ConstWsh),zeros(1,length(ConstWsh)),'k');
shadedErrorBar(1:length(ConstWsh),mean(Data_All(:,ConstWsh)),SEM(Data_All(:,ConstWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(ConstWsh),mean(AB_All(:,ConstWsh)),SEM(AB_All(ConstWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]); 
set(gca,'xtick',[]); 
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.53,0.57,0.1,0.1]);
plot(1:length(LVWsh),zeros(1,length(LVWsh)),'k');
shadedErrorBar(1:length(LVWsh),mean(Data_All(:,LVWsh)),SEM(Data_All(:,LVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(LVWsh),mean(AB_All(:,LVWsh)),SEM(AB_All(LVWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]); 
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.8,0.57,0.1,0.1]);
plot(1:length(HVWsh),zeros(1,length(HVWsh)),'k');
shadedErrorBar(1:length(HVWsh),mean(Data_All(:,HVWsh)),SEM(Data_All(:,HVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(HVWsh),mean(AB_All(:,HVWsh)),SEM(AB_All(HVWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

%Aftereffects

%Initial Bias
subplot(4,5,[11 12 16 17]); hold on
errorbar(1:3,mean(Data_IB),SEM(Data_IB,1),'Marker','o', 'MarkerFaceColor', Datacolor,'MarkerEdgeColor','k','Color',Datacolor);
errorbar(1:3,mean(AB_IB),SEM(AB_IB,1),'Marker','o', 'MarkerFaceColor', ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar(1:3,mean(SU_IB),SEM(SU_IB,1),'Marker','o', 'MarkerFaceColor', Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
plot([0:4],zeros(1,5),'k');
title('Initial Bias');
ylabel('SAI (%)');
legend('Data','AB model','S+U model'); legend('boxoff');
xlim([0.5 3.5]); ylim([-1 8]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = {'Constant', 'LV', 'HV'};

%Early Washout
subplot(4,5,[13 14 18 19]); hold on
errorbar(1:3,mean(Data_EW),SEM(Data_EW,1),'Marker','o', 'MarkerFaceColor', Datacolor,'MarkerEdgeColor','k','Color',Datacolor);
errorbar(1:3,mean(AB_EW),SEM(AB_EW,1),'Marker','o', 'MarkerFaceColor', ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar(1:3,mean(SU_EW),SEM(SU_EW,1),'Marker','o', 'MarkerFaceColor', Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
plot([0:4],zeros(1,5),'k');
title('Early Washout');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([-1 8]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = {'Constant', 'LV', 'HV'};

%AIC comparisons
%All data
subplot(4,5,15); hold on
for i = 1:length(ABaic)
    plot(ABaic(i)-SUaic(i), normrnd(1,0.03), 'Marker', '.', 'Color',icolors(2,:),'MarkerSize',15);
end
herrorbar(mean(ABaic-SUaic), 1, SEM(ABaic-SUaic,1),'k');
plot(mean(ABaic-SUaic), 1, 'o', 'MarkerFaceColor', Datacolor, 'MarkerEdgeColor', 'k');
line([0 0], [0 2],'Color','k','LineStyle','--');
ylim([0.5 1.5]); xlim([-3000 3000]);
text(-3000,1.5,'Favors AB'); text(-3000,1.3,['(n=' num2str(sum(ABaic-SUaic <0)) ')']);
text(1000,1.5,'Favors S+U'); text(1000,1.3,['(n=' num2str(sum(ABaic-SUaic >0)) ')']);
ylabel([{'All'}; {'Strides'}]);
title('AIC Diff (All Data)');
set(gca,'ytick',[]);

%Washout only
subplot(4,5,20); hold on
for i = 1:length(ABaicW)
    plot(ABaicW(i)-SUaicW(i), normrnd(1,0.03), 'Marker', '.', 'Color',icolors(2,:),'MarkerSize',15);
end
herrorbar(mean(ABaicW-SUaicW), 1, SEM(ABaicW-SUaicW,1),'k');
plot(mean(ABaicW-SUaicW), 1, 'o', 'MarkerFaceColor', Datacolor, 'MarkerEdgeColor', 'k');
line([0 0], [0 2],'Color','k','LineStyle','--');
ylim([0.5 1.5]); xlim([-3000 3000]);
text(-3000,1.5,'Favors AB'); text(-3000,1.3,['(n=' num2str(sum(ABaicW-SUaicW <0)) ')']);
text(1000,1.5,'Favors S+U'); text(1000,1.3,['(n=' num2str(sum(ABaicW-SUaicW >0)) ')']);
ylabel([{'Washout'}; {'Strides'}]);
title('AIC Diff (Washout Only)');
set(gca,'ytick',[]);

annotation('textbox',[0.23, 0.84, 0.1, 0.1],'String','Constant','EdgeColor','none','FontSize',11);
annotation('textbox',[0.48, 0.84, 0.1, 0.1],'String','Low Variability','EdgeColor','none','FontSize',11);
annotation('textbox',[0.73, 0.84, 0.1, 0.1],'String','High Variability','EdgeColor','none','FontSize',11);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Plot group averaged model fits for the modified models
figure;
%Plot modified SU model
subplot(4,5,1:5); hold on
rectangle('Position',[ConstBsl(1), -20, length(ConstBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[ConstWsh(1), -20, length(ConstWsh)+length(LVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[LVWsh(1), -20, length(LVWsh)+length(HVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[HVWsh(1), -20, length(HVWsh) 100], 'FaceColor',[0.8 0.8 0.8]);
shadedErrorBar(1:length(Data_All),mean(Data_All),SEM(Data_All,1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SU2s_All),SEM(SU2s_All,1),'lineprops',{'linestyle',':','color',Stratcolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SU2w_All),SEM(SU2w_All,1),'lineprops',{'linestyle',':','color',UDcolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(SU2x_All),SEM(SU2x_All,1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
plot(1:length(Data_All),zeros(1,length(Data_All)),'k');
xlim([0 length(Data_All)]); ylim([-1 32]);
line([condchangeAll(1) condchangeAll(1)],get(gca,'ylim'),'LineWidth',3,'Color','k');
line([condchangeAll(2) condchangeAll(2)],get(gca,'ylim'),'LineWidth',3,'Color','k');
text(length(Data_All)-length(HVidxAll)/3,30,['r^2 = ' num2str(round(mean(SU2r2),2))  ' +/- ' num2str(round(std(SU2r2),2))]);
text(length(Data_All)-length(HVidxAll)/3,25,['AIC = ' num2str(round(mean(SUaic))) ' +/- ' num2str(round(std(SU2aic)))]);
text(15,30,'Baseline'); text(450,30,'Learning'); text(1030,30,'Washout');
legend({'Data', 'S', 'W', 'X'},'Position',[0.93, 0.8, 0.03, 0.03]); legend('boxoff');
title('Modified Strategy Plus Use-Dependent Model Fits');
ylabel('SAI %');  set(gca,'xtick',[]);

%Plot washout insets
axes('Position',[0.27,0.78,0.1,0.1]);
plot(1:length(ConstWsh),zeros(1,length(ConstWsh)),'k');
shadedErrorBar(1:length(ConstWsh),mean(Data_All(:,ConstWsh)),SEM(Data_All(:,ConstWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(ConstWsh),mean(SU2x_All(:,ConstWsh)),SEM(SU2x_All(ConstWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
set(gca,'xtick',[]); 
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.53,0.78,0.1,0.1]);
plot(1:length(LVWsh),zeros(1,length(LVWsh)),'k');
shadedErrorBar(1:length(LVWsh),mean(Data_All(:,LVWsh)),SEM(Data_All(:,LVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(LVWsh),mean(SU2x_All(:,LVWsh)),SEM(SU2x_All(LVWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.8,0.78,0.1,0.1]);
plot(1:length(HVWsh),zeros(1,length(HVWsh)),'k');
shadedErrorBar(1:length(HVWsh),mean(Data_All(:,HVWsh)),SEM(Data_All(:,HVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(HVWsh),mean(SU2x_All(:,HVWsh)),SEM(SU2x_All(HVWsh),1),'lineprops',{'linestyle','-','color',Xcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]); set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

%Plot AB model
subplot(4,5,6:10); hold on
rectangle('Position',[ConstBsl(1), -20, length(ConstBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[ConstWsh(1), -20, length(ConstWsh)+length(LVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[LVWsh(1), -20, length(LVWsh)+length(HVBsl) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[HVWsh(1), -20, length(HVWsh) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
shadedErrorBar(1:length(Data_All),mean(Data_All),SEM(Data_All,1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(Data_All),mean(AB2_All),SEM(AB2_All,1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
plot(1:length(Data_All),zeros(1,length(Data_All)),'k');
xlim([0 length(Data_All)]); ylim([-1 32]);
line([condchangeAll(1) condchangeAll(1)],get(gca,'ylim'),'LineWidth',3,'Color','k');
line([condchangeAll(2) condchangeAll(2)],get(gca,'ylim'),'LineWidth',3,'Color','k');
text(length(Data_All)-length(HVidxAll)/3,30,['r^2 = ' num2str(round(mean(AB2r2),2)) ' +/- ' num2str(round(std(AB2r2),2))]);
text(length(Data_All)-length(HVidxAll)/3,25,['AIC = ' num2str(round(mean(AB2aic))) ' +/- ' num2str(round(std(AB2aic)))]);
legend({'Data', 'MAP'},'Position',[0.93, 0.6, 0.03, 0.03]); legend('boxoff');
title('Modified Adaptive Bayesian Model Fits');
ylabel('SAI %'); xlabel('Strides');
set(gca,'xtick',[]);

%Plot washout insets
axes('Position',[0.27,0.57,0.1,0.1]);
plot(1:length(ConstWsh),zeros(1,length(ConstWsh)),'k');
shadedErrorBar(1:length(ConstWsh),mean(Data_All(:,ConstWsh)),SEM(Data_All(:,ConstWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(ConstWsh),mean(AB2_All(:,ConstWsh)),SEM(AB2_All(ConstWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]); 
set(gca,'xtick',[]); 
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.53,0.57,0.1,0.1]);
plot(1:length(LVWsh),zeros(1,length(LVWsh)),'k');
shadedErrorBar(1:length(LVWsh),mean(Data_All(:,LVWsh)),SEM(Data_All(:,LVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(LVWsh),mean(AB2_All(:,LVWsh)),SEM(AB2_All(LVWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]); 
set(gca,'Color',[0.8 0.8 0.8]);

axes('Position',[0.8,0.57,0.1,0.1]);
plot(1:length(HVWsh),zeros(1,length(HVWsh)),'k');
shadedErrorBar(1:length(HVWsh),mean(Data_All(:,HVWsh)),SEM(Data_All(:,HVWsh),1),'lineprops',{'color',Datacolor,'linewidth',1});
shadedErrorBar(1:length(HVWsh),mean(AB2_All(:,HVWsh)),SEM(AB2_All(HVWsh),1),'lineprops',{'linestyle','-','color',ABcolor,'linewidth',1});
xlim([0 insetlen]); ylim([-1 8]);
set(gca,'xtick',[]);  set(gca,'ytick',[]);
set(gca,'Color',[0.8 0.8 0.8]);

%Aftereffects

%Initial Bias
subplot(4,5,[11 12 16 17]); hold on
errorbar(1:3,mean(Data_IB),SEM(Data_IB,1),'Marker','o', 'MarkerFaceColor', Datacolor,'MarkerEdgeColor','k','Color',Datacolor);
errorbar(1:3,mean(AB2_IB),SEM(AB2_IB,1),'Marker','d', 'MarkerFaceColor', ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar(1:3,mean(SU2_IB),SEM(SU2_IB,1),'Marker','d', 'MarkerFaceColor', Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
plot([0:4],zeros(1,5),'k');
title('Initial Bias');
ylabel('SAI (%)');
legend('Data','Modified AB model','Modified S+U model'); legend('boxoff');
xlim([0.5 3.5]); ylim([-1 12]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = {'Constant', 'LV', 'HV'};

%Early Washout
subplot(4,5,[13 14 18 19]); hold on
errorbar(1:3,mean(Data_EW),SEM(Data_EW,1),'Marker','o', 'MarkerFaceColor', Datacolor,'MarkerEdgeColor','k','Color',Datacolor);
errorbar(1:3,mean(AB2_EW),SEM(AB2_EW,1),'Marker','d', 'MarkerFaceColor', ABcolor,'MarkerEdgeColor','k','Color',ABcolor);
errorbar(1:3,mean(SU2_EW),SEM(SU2_EW,1),'Marker','d', 'MarkerFaceColor', Xcolor,'MarkerEdgeColor','k','Color',Xcolor);
plot([0:4],zeros(1,5),'k');
title('Early Washout');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([-1 8]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = {'Constant', 'LV', 'HV'};

%AIC comparisons
%All data
subplot(4,5,15); hold on
for i = 1:length(AB2aic)
    plot(AB2aic(i)-SU2aic(i), normrnd(1,0.03), 'Marker', '.', 'Color',icolors(2,:),'MarkerSize',15);
end
herrorbar(mean(AB2aic-SU2aic), 1, SEM(AB2aic-SU2aic,1),'k');
plot(mean(AB2aic-SU2aic), 1, 'o', 'MarkerFaceColor', Datacolor, 'MarkerEdgeColor', 'k');
line([0 0], [0 2],'Color','k','LineStyle','--');
ylim([0.5 1.5]); xlim([-3000 3000]);
text(-3000,1.5,'Favors AB'); text(-3000,1.3,['(n=' num2str(sum(AB2aic-SU2aic <0)) ')']);
text(1000,1.5,'Favors S+U'); text(1000,1.3,['(n=' num2str(sum(AB2aic-SU2aic >0)) ')']);
ylabel([{'All'}; {'Strides'}]);
title('AIC Diff (All Data)');
set(gca,'ytick',[]);

%Washout only
subplot(4,5,20); hold on
for i = 1:length(AB2aicW)
    plot(AB2aicW(i)-SU2aicW(i), normrnd(1,0.03), 'Marker', '.', 'Color',icolors(2,:),'MarkerSize',15);
end
herrorbar(mean(AB2aicW-SU2aicW), 1, SEM(AB2aicW-SU2aicW,1),'k');
plot(mean(AB2aicW-SU2aicW), 1, 'o', 'MarkerFaceColor', Datacolor, 'MarkerEdgeColor', 'k');
line([0 0], [0 2],'Color','k','LineStyle','--');
text(-3000,1.5,'Favors AB'); text(-3000,1.3,['(n=' num2str(sum(AB2aicW-SU2aicW <0)) ')']);
text(1000,1.5,'Favors S+U'); text(1000,1.3,['(n=' num2str(sum(AB2aicW-SU2aicW >0)) ')']);
ylim([0.5 1.5]); xlim([-3000 3000]);
ylabel([{'Washout'}; {'Strides'}]);
title('AIC Diff (Washout Only)');
set(gca,'ytick',[]);

annotation('textbox',[0.23, 0.84, 0.1, 0.1],'String','Constant','EdgeColor','none','FontSize',11);
annotation('textbox',[0.48, 0.84, 0.1, 0.1],'String','Low Variability','EdgeColor','none','FontSize',11);
annotation('textbox',[0.73, 0.84, 0.1, 0.1],'String','High Variability','EdgeColor','none','FontSize',11);

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%Display r2 and AIC values for Original models
disp(' ');
disp('Original Model Fits (All Strides):');
disp(['S+U r^2 = ' num2str(round(mean(SUr2),2)) ' +/- ' num2str(round(std(SUr2),2))]);
disp(['AB r^2 = ' num2str(round(mean(ABr2),2)) ' +/- ' num2str(round(std(ABr2),2))]);
disp('AICs:');
disp(['S+U model AIC = ' num2str(round(mean(SUaic))) '[' num2str(round(CI95(SUaic))) ']']); 
disp(['AB model AIC = ' num2str(round(mean(ABaic))) '[' num2str(round(CI95(ABaic))) ']']); 
[~,pval,~,stats] = ttest(SUaic,ABaic);
Dz = cohensDz(SUaic,ABaic);
disp(['t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])

disp(' ');
disp('Original Model Fits (Washout only Strides):');
disp(['S+U r^2 = ' num2str(round(mean(SUr2W),2)) ' +/- ' num2str(round(std(SUr2W),2))]);
disp(['AB r^2 = ' num2str(round(mean(ABr2W),2)) ' +/- ' num2str(round(std(ABr2W),2))]);
disp('AICs:');
disp(['S+U model AIC = ' num2str(round(mean(SUaicW))) '[' num2str(round(CI95(SUaicW))) ']']); 
disp(['AB model AIC = ' num2str(round(mean(ABaicW))) '[' num2str(round(CI95(ABaicW))) ']']); 
[~,pval,~,stats] = ttest(SUaicW,ABaicW);
Dz = cohensDz(SUaicW,ABaicW);
disp(['t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])

disp(' ');
disp('Modified Model Fits (All Strides):');
disp(['modified S+U r^2 = ' num2str(round(mean(SU2r2),2)) ' +/- ' num2str(round(std(SU2r2),2))]);
disp(['modified AB r^2 = ' num2str(round(mean(AB2r2),2)) ' +/- ' num2str(round(std(AB2r2),2))]);
disp('modified AICs:');
disp(['modified S+U model AIC = ' num2str(round(mean(SU2aic))) '[' num2str(round(CI95(SU2aic))) ']']); 
disp(['modified AB model AIC = ' num2str(round(mean(AB2aic))) '[' num2str(round(CI95(AB2aic))) ']']); 
[~,pval,~,stats] = ttest(SU2aic,AB2aic);
Dz = cohensDz(SU2aic,AB2aic);
disp(['t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])

disp(' ');
disp('Modified Model Fits (Washout only Strides):');
disp(['modified S+U r^2 = ' num2str(round(mean(SU2r2W),2)) ' +/- ' num2str(round(std(SU2r2W),2))]);
disp(['modified AB r^2 = ' num2str(round(mean(AB2r2W),2)) ' +/- ' num2str(round(std(AB2r2W),2))]);
disp('AICs:');
disp(['modified S+U model AIC = ' num2str(round(mean(SU2aicW))) '[' num2str(round(CI95(SU2aicW))) ']']); 
disp(['modified AB model AIC = ' num2str(round(mean(AB2aicW))) '[' num2str(round(CI95(AB2aicW))) ']']); 
[~,pval,~,stats] = ttest(SU2aicW,AB2aicW);
Dz = cohensDz(SU2aicW,AB2aicW);
disp(['t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])

%test if the AIC scores better for the original or modified models
disp(' ');
[~,pval,~,stats] = ttest(SUaic,SU2aic);
Dz = cohensDz(SUaic,SU2aic);
disp(['Original vs modified S+U model: t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])
[~,pval,~,stats] = ttest(ABaic,AB2aic);
Dz = cohensDz(ABaic,AB2aic);
disp(['Original vs modified AB model: t(' num2str(stats.df) ') = ' num2str(round(stats.tstat,2))...
    ', p = ' num2str(pval) ', Cohens dz = ' num2str(round(Dz,2))])

%Display Bootstrapped parameter values for each model

%Bootstrapped CIs
ABparamsCI = bootci(1e4, @mean, ABparams);
AB2paramsCI = bootci(1e4, @mean, AB2params);
SUparamsCI = bootci(1e4, @mean, SUparams);
SU2paramsCI = bootci(1e4, @mean, SU2params);
%Means
meanAB = mean(bootstrp(1e4, @mean, ABparams));
meanAB2 = mean(bootstrp(1e4, @mean, AB2params));
meanSU = mean(bootstrp(1e4, @mean, SUparams));
meanSU2 = mean(bootstrp(1e4, @mean, SU2params));

disp(' ');
disp(' ');
fprintf(1,'                              Bootstrapped Parameters: Adaptive Bayesian Models                                                     \n');
fprintf(1,'     Model            beta (VF)       sigma_{likelihood}(VF)           beta (no VF)            sigma_{likelihood} (no VF)     \n');
fprintf(1,'------------------------------------------------------------------------------------------------------------------------------\n');
fprintf(1,'  AB              %4.2f [%1.2f  %1.2f] %8.2f [%1.2f  %1.2f]               n/a                          n/a \n',meanAB(1), ABparamsCI(1,1), ABparamsCI(2,1), meanAB(2), ABparamsCI(1,2), ABparamsCI(2,2));
fprintf(1,'  Modified AB     %4.2f [%1.2f  %1.2f] %8.2f [%1.2f  %1.2f] %11.1e [%1.1e  %1.1e] %8.2f [%1.2f  %1.2f] \n', meanAB2(1), AB2paramsCI(1,1), AB2paramsCI(2,1), meanAB2(3), AB2paramsCI(1,3), AB2paramsCI(2,3), meanAB2(2), AB2paramsCI(1,2), AB2paramsCI(2,2), meanAB2(4), AB2paramsCI(1,4), AB2paramsCI(2,4));
disp(' ');
disp(' ');
fprintf(1,'                        Bootstrapped Parameters: Strategy plus Use-Dependent Models                                         \n');
fprintf(1,'     Model                C                     A                    F                          E                 gamma_{LV}           gamma_{HV}   \n');
fprintf(1,'----------------------------------------------------------------------------------------------------------------------------------------------------\n');
fprintf(1,'  S+U             %4.2f [%1.2f %1.2f] %8.2f [%1.2f %1.2f]  %8.1e [%1.1e  %1.1e] %8.2f [%1.2f %1.2f]          n/a                  n/a \n',meanSU(1),SUparamsCI(1,1),SUparamsCI(2,1), meanSU(2),SUparamsCI(1,2),SUparamsCI(2,2), meanSU(4),SUparamsCI(1,4),SUparamsCI(2,4), meanSU(3),SUparamsCI(1,3),SUparamsCI(2,3));
fprintf(1,'  Modified S+U    %4.2f [%1.2f %1.2f] %8.2f [%1.2f %1.2f]  %8.1e [%1.1e  %1.1e] %8.2f [%1.2f %1.2f] %8.2f [%1.2f %1.2f] %8.2f [%1.2f %1.2f] \n',meanSU2(1),SU2paramsCI(1,1),SU2paramsCI(2,1), meanSU2(2),SU2paramsCI(1,2),SU2paramsCI(2,2), meanSU2(4),SU2paramsCI(1,4),SU2paramsCI(2,4), meanSU2(3),SU2paramsCI(1,3),SU2paramsCI(2,3), meanSU2(5),SU2paramsCI(1,5),SU2paramsCI(2,5), meanSU2(6),SU2paramsCI(1,6),SU2paramsCI(2,6));
disp(' ');
disp(' ');

    
end