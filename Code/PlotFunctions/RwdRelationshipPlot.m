function RwdRelationshipPlot(T)

%Code to determine if there is a relationship between variability during
%the learning phase and the use-dependent aftereffect
%Also calculates and plots the reward during the beginning, middle and end of the
%learning phase

%Create arrays for ANOVAs 
Subjs = unique(T.SID);
sample = [ones(length(Subjs),1); ones(length(Subjs),1)*2; ones(length(Subjs),1)*3];
subjcode = [1:length(Subjs), 1:length(Subjs), 1:length(Subjs)]';

%loop through conditions 
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
        
        %Create indices 
        lrnidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('learning',T.phase)==1);
        wshidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('washout',T.phase)==1);
        
        %Index washout variables
        grpIB(s,c) = nanmean(T.BslCor_SAI(wshidx(1:5)));
        grpEW(s,c) = nanmean(T.BslCor_SAI(wshidx(6:30)));         
        
        %Target hits
        %Index target hit data and remove nans
        AllLhits = T.LeftHit(lrnidx);
        AllLhits = AllLhits(isnan(AllLhits)==0);
        AllRhits = T.RightHit(lrnidx);
        AllRhits = AllRhits(isnan(AllRhits)==0);

        %Calcualte total reward hits
        SumHits = sum(AllRhits)+sum(AllLhits);
        LenLrn = length(AllRhits) + length(AllLhits);
        grpTotRwd(s,c) = SumHits / LenLrn; 
        
        %Seperate beginning middle and end of learning phase
        EarlyHits(s,c) = (sum(AllLhits(1:166)) + sum(AllRhits(1:166))) / (length(AllLhits(1:166)) + length(AllRhits(1:166)));
        MidHits(s,c) = (sum(AllLhits(167:332)) + sum(AllRhits(167:332))) / (length(AllLhits(167:332)) + length(AllRhits(167:332)));
        LateHits(s,c) = (sum(AllLhits(333:end)) + sum(AllRhits(333:end))) / (length(AllLhits(333:end)) + length(AllRhits(333:end)));
        
        %Target accuracy
        %Index Step lengths
        RSL = T.Right_step_length(lrnidx);
        RSL = RSL(isnan(RSL)==0);        
        LSL = T.Left_step_length(lrnidx);
        LSL = LSL(isnan(LSL)==0);

        %Index Targets
        Rtrgt = T.TrgtRight(lrnidx(1:length(RSL)));
        Ltrgt = T.TrgtLeft(lrnidx(1:length(LSL)));
        
        %Calculate accuracy
        Racc = abs(RSL - Rtrgt);
        Lacc = abs(LSL - Ltrgt);
        
        %Seperate beginning middle and end of learning phase
        EarlyAcc(s,c) = (nanmean(Racc(1:166)) +  nanmean(Lacc(1:166))) / 2;
        MidAcc(s,c) = (nanmean(Racc(167:332)) +  nanmean(Lacc(167:332))) / 2;
        LateAcc(s,c) = (nanmean(Racc(333:end)) +  nanmean(Lacc(333:end))) / 2;
       
    end
end

%Set colors for plotting
colors = lines(7);
icolors = gray(3);

%Plot target hit rate vs Initial bias
figure; subplot(3,6,1:3); hold on 
for s = 1:length(grpTotRwd)
    %Regress
    y = grpIB(s,:)';
    x = [ones(3,1), grpTotRwd(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bIB(:,s) = betas;
    yhat = x * betas;
    
    %Plot individual regressions
    plot(grpTotRwd(s,:),yhat, 'Color',icolors(2,:),'LineWidth',0.2);
end
%Calcualte mean regression
[~,pIB,~,stats] = ttest(bIB(2,:));
meanx = [ones(3,1), mean(grpTotRwd)'];
meanyhat = meanx * mean(bIB,2);

%Plot group mean
plot(mean(grpTotRwd), meanyhat,'Color',colors(4,:),'LineWidth',2);
xlabel('Target hit rate'); ylabel('SAI %');
title('Target hit rate vs Initial Bias');
xlim([0 1]); ylim([-1 6]);

%Inset of mean and individual slope values
axes('Position',[.45 .8 .03 .1]); hold on
bar(1, mean(bIB(2,:)), 'FaceColor', 'w', 'EdgeColor', colors(4,:));
plot(1,bIB(2,:),'.','Color',icolors(2,:));
xlim([0 2]);
ax = gca; ax.XTick = 1:2;
ax.XTickLabels = '';
ylabel('slopes');

disp(' ');
disp(['Target hit rate vs Initial Bias slope = ' num2str(round(mean(bIB(2,:)),2)), ' [' num2str(CI95(bIB(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(pIB,2))]);


%Plot target hit rate vs Early washout
subplot(3,6,4:6); hold on 
for s = 1:length(grpTotRwd)
    %Regress
    y = grpEW(s,:)';
    x = [ones(3,1), grpTotRwd(s,:)'];
    betas = pinv(x' * x) * x' * y;
    bEW(:,s) = betas;
    yhat = x * betas;
    
    %Plot individual regressions
    plot(grpTotRwd(s,:),yhat, 'Color',icolors(2,:),'LineWidth',0.2);
end
%Calculate mean regression
[~,pIB,~,stats] = ttest(bEW(2,:));
meanx = [ones(3,1), mean(grpTotRwd)'];
meanyhat = meanx * mean(bEW,2);

%Plot
plot(mean(grpTotRwd), meanyhat,'Color',colors(4,:),'LineWidth',2);
xlabel('Target hit rate'); ylabel('SAI %');
title('Target hit rate vs Early Washout');
xlim([0 1]); ylim([-1 6]);

%Inset of individual and mean slopes
axes('Position',[.83 .8 .03 .1]); hold on
bar(1, mean(bEW(2,:)), 'FaceColor', 'w', 'EdgeColor', colors(4,:));
plot(1,bEW(2,:),'.','Color',icolors(2,:));
xlim([0 2]); ylim([-2 2]);
ax = gca; ax.XTick = 1:2;
ax.XTickLabels = '';
ylabel('slopes');

%Display stats for reward vs use-dependent learning relaionships
disp(' ');
disp(['Target hit rate vs Early Washout slope = ' num2str(round(mean(bEW(2,:)),2)), ' [' num2str(CI95(bEW(2,:))) '] t(',...
    num2str(stats.df) ') = ' num2str(round(stats.tstat,2)) ' p = ' num2str(round(pIB,2))]);

%Plot Hits across learning epochs
%Constant condition
subplot(3,6,7:8); hold on
plot(1:3,[EarlyHits(:,1), MidHits(:,1), LateHits(:,1)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyHits(:,1), MidHits(:,1), LateHits(:,1)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylim([0 1]);
ylabel('Taget Hit Rate');
set(gca,'XTick',[]); title('Constant Condition');

%Low variability condition
subplot(3,6,9:10); hold on
plot(1:3,[EarlyHits(:,2), MidHits(:,2), LateHits(:,2)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyHits(:,2), MidHits(:,2), LateHits(:,2)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylim([0 1]);
set(gca,'xtick',[]);  title('LV Condition');

%High variability condition
subplot(3,6,11:12); hold on
plot(1:3,[EarlyHits(:,3), MidHits(:,3), LateHits(:,3)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyHits(:,3), MidHits(:,3), LateHits(:,3)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylim([0 1]);
set(gca,'xtick',[]); title('HV Condition');

disp(' ');
disp('Differences in TARGET HIT RATE acorss early, middle and late learning');
disp('Constant Condition');

D = [EarlyHits(:,1); MidHits(:,1); LateHits(:,1)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('LV Condition');

D = [EarlyHits(:,2); MidHits(:,2); LateHits(:,2)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('HV Condition');

D = [EarlyHits(:,3); MidHits(:,3); LateHits(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);


%Plot absolute target accuracy during learning epochs
%Constant condition
subplot(3,6,13:14); hold on
plot(1:3,[EarlyAcc(:,1), MidAcc(:,1), LateAcc(:,1)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyAcc(:,1), MidAcc(:,1), LateAcc(:,1)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]);  ylim([0 0.1])
ylabel('Distance from target (m)');
set(gca,'xtick',1:3,'xticklabel',{'Early', 'Middle','Late'}); 

%Low variability condition
subplot(3,6,15:16); hold on
plot(1:3,[EarlyAcc(:,2), MidAcc(:,2), LateAcc(:,2)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyAcc(:,2), MidAcc(:,2), LateAcc(:,2)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylim([0 0.1])
set(gca,'xtick',1:3,'xticklabel',{'Early', 'Middle','Late'}); 
xlabel('Learning Epochs');

%High variability condition
subplot(3,6,17:18); hold on
plot(1:3,[EarlyAcc(:,3), MidAcc(:,3), LateAcc(:,3)],'Color',icolors(2,:),'LineWidth',0.2);
plot(1:3,mean([EarlyAcc(:,3), MidAcc(:,3), LateAcc(:,3)]),'Color',colors(4,:),'LineWidth',2);
xlim([0.5 3.5]); ylim([0 0.1]);
set(gca,'xtick',1:3,'xticklabel',{'Early', 'Middle','Late'}); 


disp(' ');
disp('Differences in ACCURACY acorss early, middle and late learning');
disp('Constant Condition');

D = [EarlyAcc(:,1); MidAcc(:,1); LateAcc(:,1)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('LV Condition');

D = [EarlyAcc(:,2); MidAcc(:,2); LateAcc(:,2)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('HV Condition');

D = [EarlyAcc(:,3); MidAcc(:,3); LateAcc(:,3)];
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

disp('Post-hoc for the HV condition');
[~,p,~,~] = ttest(EarlyAcc(:,3), MidAcc(:,3));
disp(['Accuracy increased from Early to Middle Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(EarlyAcc(:,3), LateAcc(:,3));
disp(['Accuracy increased from Early to Late Learning (p = ' num2str(p) ')']);
[~,p,~,~] = ttest(MidAcc(:,3), LateAcc(:,3));
disp(['But not from Middle to Late Learning (p = ' num2str(p) ')']);


end