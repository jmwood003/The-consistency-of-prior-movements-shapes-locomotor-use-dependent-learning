function EndLrnPlot(T, strides)

%Plots SAI and SAI targets at the end of learning across the 3 different 
%conditions

%T = data table
%strides = number of strides to consider at the end of learning (last n
%strides)

%Create arrays for ANOVAs 
Subjs = unique(T.SID);
sample = [ones(length(Subjs),1); ones(length(Subjs),1)*2; ones(length(Subjs),1)*3];
subjcode = [1:length(Subjs), 1:length(Subjs), 1:length(Subjs)]';

%pre-allocate variables
AllStrides = [];
AllTargets = [];
idxCond = [];

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

        %Create learning phase index
        lrnidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('learning',T.phase)==1);
               
        %Index SAI data
        LrnData = T.BslCor_SAI(lrnidx);
        LrnData(isnan(LrnData)==1) = [];
        EndLrn = LrnData(end-strides+1:end);

        %Index target SAI data
        TrgtData = T.TrgtSAI(lrnidx);
        TrgtData(isnan(TrgtData)==1) = [];
        EndT = TrgtData(end-strides+1:end);
        
        %Save end of learning means
        endLrnT(s,c) = mean(EndT);
        endLrn(s,c) = mean(EndLrn);
    
        %Save all end of learning strides
        AllStrides = [AllStrides; EndLrn'];
        AllTargets = [AllTargets; EndT'];
        
        EarlySAI(s,c) = mean(LrnData(1:166));
        MidSAI(s,c) = mean(LrnData(167:332));
        LateSAI(s,c) = mean(LrnData(333:end));
        EarlySAI_T(s,c) = mean(TrgtData(1:166));
        MidSAI_T(s,c) = mean(TrgtData(167:332));
        LateSAI_T(s,c) = mean(TrgtData(333:end));        
        
        %Create indexing variable
        if strcmp(CurrentC,'Constant')==1
            idxCond = [idxCond; 1];
        elseif strcmp(CurrentC,'LV')==1
            idxCond = [idxCond; 2];
         elseif strcmp(CurrentC,'HV')==1
            idxCond = [idxCond; 3];
        end    
    end
end

%Set indexing variables
Constidx = find(idxCond==1);
LVidx = find(idxCond==2);
HVidx = find(idxCond==3);

%Set colors for plotting
colors = lines(7);
Datacolor = colors(4,:);
icolors = gray(3);
meancolors = lines(3);

%Plot SAI at the end of learning
figure;
subplot(2,3,1:2); hold on
shadedErrorBar(1:size(AllStrides,2), nanmean(AllStrides(Constidx,:)),SEM(AllStrides(Constidx,:),1), 'lineProps', {'color',meancolors(1,:),'linewidth',1});
shadedErrorBar(1:size(AllStrides,2), nanmean(AllStrides(LVidx,:)),SEM(AllStrides(LVidx,:),1), 'lineProps', {'color',meancolors(2,:),'linewidth',1});
shadedErrorBar(1:size(AllStrides,2), nanmean(AllStrides(HVidx,:)),SEM(AllStrides(HVidx,:),1), 'lineProps', {'color',meancolors(3,:),'linewidth',1});
xlim([0 50]); ylim([0 30]);
legend('Constant', 'Low Variability', 'High Variability','location','south'); legend('boxoff');
set(gca,'xtick',[]);
xlabel(['Last ' num2str(strides) ' learning strides']);
ylabel('SAI (%)'); title('SAI');

%Plot mean SAI at the end of learning
subplot(2,3,3); hold on
for i = 1:length(endLrn)
    plot([1,2,3], endLrn(i,:), 'Marker','none', 'Color',icolors(2,:),'LineWidth',0.2);
end
plot(nanmean(endLrn),'-', 'Color', Datacolor, 'LineWidth', 2, 'Marker','.');
plot(0:4, zeros(1,5), 'k-');
title('End Learning SAI');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([10 30]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = Cs;

%Plot target SAI at the end of learning
subplot(2,3,4:5); hold on
shadedErrorBar(1:size(AllTargets,2), nanmean(AllTargets(Constidx,:)),SEM(AllTargets(Constidx,:),1), 'lineProps', {'color',meancolors(1,:),'linewidth',1});
shadedErrorBar(1:size(AllTargets,2), nanmean(AllTargets(LVidx,:)),SEM(AllTargets(LVidx,:),1), 'lineProps', {'color',meancolors(2,:),'linewidth',1});
shadedErrorBar(1:size(AllTargets,2), nanmean(AllTargets(HVidx,:)),SEM(AllTargets(HVidx,:),1), 'lineProps', {'color',meancolors(3,:),'linewidth',1});
xlim([0 50]); ylim([0 30]);
set(gca,'xtick',[]);
xlabel(['Last ' num2str(strides) ' learning targets']);
ylabel('SAI target (%)');
title('SAI Targets');

%Plot mean target SAI at the end of learning
subplot(2,3,6); hold on
for i = 1:length(endLrnT)
    plot([1,2,3], endLrnT(i,:), 'Marker','none', 'Color',icolors(2,:),'LineWidth',0.2);
end
plot(nanmean(endLrnT),'-', 'Color', Datacolor, 'LineWidth', 2, 'Marker','.');
plot(0:4, zeros(1,5), 'k-');
title('End Learning Targets');
ylabel('SAI (%)');
xlim([0.5 3.5]); ylim([10 30]);
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = Cs;
suptitle('End Learning SAI and SAI targets');

disp(' ');
disp('Differences between SAI at the end of learning acorss conditions');

D = [endLrn(:,1); endLrn(:,2); endLrn(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp(' ');
disp('Differences between SAI TARGETS at the end of learning acorss conditions');

D = [endLrnT(:,1); endLrnT(:,2); endLrnT(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);


%------------------------------------------------
%Learning epochs plot
%Plot Learning epochs
%Constant condition
figure;
subplot(2,3,1); hold on
plot(1:3,[EarlySAI(:,1), MidSAI(:,1), LateSAI(:,1)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI(:,1), MidSAI(:,1), LateSAI(:,1)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('Constant Condition');

%Low variability condition
subplot(2,3,2); hold on
plot(1:3,[EarlySAI(:,2), MidSAI(:,2), LateSAI(:,2)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI(:,2), MidSAI(:,2), LateSAI(:,2)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('LV Condition');

%High variability condition
subplot(2,3,3); hold on
plot(1:3,[EarlySAI(:,3), MidSAI(:,3), LateSAI(:,3)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI(:,3), MidSAI(:,3), LateSAI(:,3)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('HV Condition');

%Target data
subplot(2,3,4); hold on
plot(1:3,[EarlySAI_T(:,1), MidSAI_T(:,1), LateSAI_T(:,1)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI_T(:,1), MidSAI_T(:,1), LateSAI_T(:,1)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('Target SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('Constant Condition');

%Low variability condition
subplot(2,3,5); hold on
plot(1:3,[EarlySAI_T(:,2), MidSAI_T(:,2), LateSAI_T(:,2)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI_T(:,2), MidSAI_T(:,2), LateSAI_T(:,2)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('Target SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('LV Condition');

%High variability condition
subplot(2,3,6); hold on
plot(1:3,[EarlySAI_T(:,3), MidSAI_T(:,3), LateSAI_T(:,3)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlySAI_T(:,3), MidSAI_T(:,3), LateSAI_T(:,3)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylabel('Target SAI');
ax = gca; ax.XTick = 1:3; ylim([0 30]);
ax.XTickLabels = {'Early','Middle','Late'};
xlabel('Learning Epochs');
title('HV Condition');

suptitle('SAI and Target SAI during Learning Epochs');

disp(' ');
disp('Differences in SAI acorss early, middle and late learning');
disp('Constant Condition');

D = [EarlySAI(:,1); MidSAI(:,1); LateSAI(:,1)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('LV Condition');

D = [EarlySAI(:,2); MidSAI(:,2); LateSAI(:,2)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('HV Condition');

D = [EarlySAI(:,3); MidSAI(:,3); LateSAI(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('Post-hoc for the HV condition');
[~,p,~,~] = ttest(EarlySAI(:,3), MidSAI(:,3));
disp(['SAI decreased from Early to Middle Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(EarlySAI(:,3), LateSAI(:,3));
disp(['SAI decreased from Early to Late Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(MidSAI(:,3), LateSAI(:,3));
disp(['But not from Middle to Late Learning (p = ' num2str(p) ')']);


disp(' ');
disp('Differences in SAI TARGET acorss early, middle and late learning');
disp('No need to run Constant Condition');

disp('LV Condition');

D = [EarlySAI_T(:,2); MidSAI_T(:,2); LateSAI_T(:,2)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('HV Condition');

D = [EarlySAI_T(:,3); MidSAI_T(:,3); LateSAI_T(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('Post-hoc for the HV condition');
[~,p,~,~] = ttest(EarlySAI_T(:,3), MidSAI_T(:,3));
disp(['SAI decreased from Early to Middle Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(EarlySAI_T(:,3), LateSAI_T(:,3));
disp(['SAI decreased from Early to Late Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(MidSAI_T(:,3), LateSAI_T(:,3));
disp(['But not from Middle to Late Learning (p = ' num2str(p) ')']);


end