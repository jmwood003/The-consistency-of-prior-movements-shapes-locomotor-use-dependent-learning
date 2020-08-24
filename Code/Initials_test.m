function PilotDataFit

%Fit two process model to data from prior study
clear all;
%close all; clear; clc;

initials = 20;
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

%Order of subjects
% 'VarTest_Stable_05'
% 'VarTest_Stable_06'
% 'VarTest_Unif_05'
% 'VarTest_Unif_06'

%Set up data for fitting (concenate individual subjects)
dataidx = [1,2,4,5];
load('PilotdataAll.mat')
D = Pilot_data(dataidx,:);
T = Trgts(dataidx,:)*100;
P = phases;

%Bin data
Dbin = Bin(D,Bins,1,'mean');
Tbin = Bin(T,Bins,1,'mean');
Pbin = Bin(P,Bins,1,'mean');

P01 = [Dbin(1,:), Dbin(3,:)]; T01 = [Tbin(1,:), Tbin(3,:)];
P02 = [Dbin(2,:), Dbin(4,:)]; T02 = [Tbin(2,:), Tbin(4,:)];

Data = [P01; P02];
Targets = [T01; T02];
Phases = [Pbin, Pbin];

ABparams1 = [];
SUparams1 = [];
SUr2 = [];
ABr2 = [];
for j = 1:initials
    j
    num_initials = j;
    
    %Fit the models to data
    for Subj_i = 1:size(Targets,1)

        Subj_i

        %Pre-allocate space for error parameters and r2
        temp_best_errAB = [];     temp_best_errSU = [];
        temp_bestparamAB = [];    temp_bestparamSU = [];
        temp_r2AB = [];   temp_r2SU = [];
        tempaicAB = [];   tempaicSU = [];

        for initials_i = 1:num_initials

            [paramsAB,errorAB,AICab, ~] = ABfit(Data(Subj_i,:),Targets(Subj_i,:));
            [paramsSU,errorSU,AICsu] = SUfit(Data(Subj_i,:),Targets(Subj_i,:));

            % Save the best fitting parameters
            best_errAB = Inf;
            if errorAB <= best_errAB
                best_errAB = errorAB;
                bestparamAB = paramsAB;
                SSr = errorAB;
                SSt = sum((Data(Subj_i,:) - mean(Data(Subj_i,:))).^2);
                r2AB = 1 - (SSr/SSt);
            end

            temp_best_errAB(initials_i,:) = best_errAB;
            temp_bestparamAB(initials_i,:) = bestparamAB;
            temp_r2AB(initials_i,:) = r2AB;
            tempaicAB(initials_i,:) = AICab;

            % Save the best fitting parameters
            best_errSU = Inf;
            if errorSU <= best_errSU
                best_errSU = errorSU;
                bestparamSU = paramsSU;
                SSr = errorSU;
                SSt = sum((D(Subj_i,:) - mean(D(Subj_i,:))).^2);
                r2SU = 1 - (SSr/SSt);
            end

            temp_best_errSU(initials_i,:) = best_errSU;
            temp_bestparamSU(initials_i,:) = bestparamSU;
            temp_r2SU(initials_i,:) = r2SU;
            tempaicSU(initials_i,:) = AICsu;


        end

            [~,bestidxAB] = min(temp_best_errAB);
            best_parametersAB(Subj_i,:) = temp_bestparamAB(bestidxAB,:);
            r2_paramAB(Subj_i,:) = temp_r2AB(bestidxAB,:);
            aic_paramAB(Subj_i,:) = tempaicAB(bestidxAB,:);
            best_sseAB(Subj_i,:) = min(temp_best_errAB);   

            [~,bestidxSU] = min(temp_best_errSU);
            best_parametersSU(Subj_i,:) = temp_bestparamSU(bestidxSU,:);
            r2_paramSU(Subj_i,:) = temp_r2SU(bestidxSU,:);
            aic_paramSU(Subj_i,:) = tempaicSU(bestidxSU,:);
            best_sseSU(Subj_i,:) = min(temp_best_errSU);    
    end

    ABparams1 = [ABparams1; [best_parametersAB(1,:),best_parametersAB(2,:)]];
    SUparams1 = [SUparams1; [best_parametersSU(1,:),best_parametersSU(2,:)]];
    SUr2 = [SUr2; [r2_paramSU(1,:),r2_paramSU(2,:)]];
    ABr2 = [ABr2; [r2_paramAB(1,:),r2_paramAB(2,:)]];

end

%Simulate the experiment for plotting
for i = 1:size(Data,1)
    sims_plotAB(i,:) = ABsim(best_parametersAB(i,:),Targets(i,:));
    [sims_plotSUx(i,:),sims_plotSUw(i,:),sims_plotSUs(i,:) ] = ...
        SUsim(best_parametersSU(i,:),Targets(i,:));
end

% disp('AB params');
% disp(num2str(best_parametersAB));
% disp('SU params');
% disp(num2str(best_parametersSU));

%Order of subjects
% 'VarTest_Stable_05'
% 'VarTest_Stable_06'
% 'VarTest_Unif_05'
% 'VarTest_Unif_06'

%Set up plotting
%Colors
DataCs = cool(4);
ModelCs = hot(6);

titles = {'P05 (AB model fit)','P06 (AB model fit)',...
    'P05 (SU model fit)','P06 (SU model fit)'};
pltidx = [1,2,1,2];
posstrti = [1,3,5,7]; posendi = [2,4,6,8];
%Plot
figure; 
for i = 1:length(pltidx)
    subplot(3,4,posstrti(i):posendi(i)); hold on
    plot(1:length(Data),Data(pltidx(i),:),'b.');
    if i == 1 || i == 2
        plot(1:length(sims_plotAB),sims_plotAB(pltidx(i),:),'Color',DataCs(3,:),'LineWidth',1.2);
        plot(1:length(Targets),[Tbin(1,:),Tbin(1,:)],'k--');
        text(length(Phases)-100,15,['r^2 = ' num2str(r2_paramAB(i))]);
        text(length(Phases)-100,11,['AIC = ' num2str(aic_paramAB(i))]);
        legend('Data', 'AB model (MAP)', 'Mean Target');
        legend('boxoff');
    end
    if i == 3 || i ==4
        plot(1:length(sims_plotSUx),sims_plotSUx(pltidx(i),:),'Color',ModelCs(2,:),'LineWidth',1.2);
        plot(1:length(sims_plotSUw),sims_plotSUw(pltidx(i),:),'Color',ModelCs(1,:),'LineWidth',1.2);
        plot(1:length(sims_plotSUs),sims_plotSUs(pltidx(i),:),'Color',ModelCs(3,:),'LineWidth',1.2);
        plot(1:length(Targets),[Tbin(1,:),Tbin(1,:)],'k--');
        text(length(Phases)-100,15,['r^2 = ' num2str(r2_paramSU(i-2))]);
        text(length(Phases)-100,11,['AIC = ' num2str(aic_paramSU(i-2))]);
        legend('Data', 'SU model (x)', 'SU (w)', 'SU (s)', 'Mean Target');
        legend('boxoff');
    end
    ylim([-5 45]); 
    line([length(Tbin) length(Tbin)],get(gca,'ylim'),'LineWidth',3,'Color','k')
    title(titles{i});
    text(length(Tbin)/5,42,'Consistent Condition');
    text((length(Tbin)/5)+length(Tbin),42,'High Variability Condition');
    ylabel('SAI (%)');
    xlabel(['Strides (bins of ' num2str(Bins) ')']);
end


%Aftereffects (Here I am plotting binned aftereffects because the models
%are fit to binned data)
%Set up indexing:
wshout = find(Phases==3);
ConstIBi = wshout(1:IWsh);
HVIBi = wshout((find(diff(wshout)>1)+1):(find(diff(wshout)>1)+IWsh));
ConstEWi = wshout(EWsh);
HVEWi = wshout((find(diff(wshout)>1)+EWsh(1)):(find(diff(wshout)>1)+EWsh(end)));

%Initial Bias subject 1
%Setup
subj1IB = [nanmean(Data(1,ConstIBi),2), nanmean(Data(1,HVIBi),2)];
ABs1IB = [nanmean(sims_plotAB(1,ConstIBi),2), nanmean(sims_plotAB(1,HVIBi),2)];
SUs1IB = [nanmean(sims_plotSUx(1,ConstIBi),2), nanmean(sims_plotSUx(1,HVIBi),2)];
%Plot
subplot(3,4,9); hold on
plot(subj1IB,'k-','MarkerEdgeColor','w','MarkerFaceColor','b','Marker','o','MarkerSize',10);
plot(ABs1IB,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(3,:),'Marker','d','MarkerSize',10);
plot(SUs1IB,'k-','MarkerEdgeColor','w','MarkerFaceColor',ModelCs(2,:),'Marker','d','MarkerSize',10);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([-1 10]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
ylabel('SAI (%)');
legend('PS2','AB','SU');
legend('boxoff');
title('P05 Initial Bias (strides 1:5)');

%Initial bias subject 2
%Setup
subj2IB = [nanmean(Data(2,ConstIBi),2), nanmean(Data(2,HVIBi),2)];
ABs2IB = [nanmean(sims_plotAB(2,ConstIBi),2), nanmean(sims_plotAB(2,HVIBi),2)];
SUs2IB = [nanmean(sims_plotSUx(2,ConstIBi),2), nanmean(sims_plotSUx(2,HVIBi),2)];
%Plot
subplot(3,4,11); hold on
plot(subj2IB,'k-','MarkerEdgeColor','w','MarkerFaceColor','b','Marker','o','MarkerSize',10);
plot(ABs2IB,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(3,:),'Marker','d','MarkerSize',10);
plot(SUs2IB,'k-','MarkerEdgeColor','w','MarkerFaceColor',ModelCs(2,:),'Marker','d','MarkerSize',10);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([-1 10]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('PS2','AB','SU');
legend('boxoff');
ylabel('SAI (%)');
title('P06 Initial Bias (strides 1:5)');

%Early Washout Subject 1
%Setup
subj1EW = [nanmean(Data(1,ConstEWi),2), nanmean(Data(1,HVEWi),2)];
ABs1EW = [nanmean(sims_plotAB(1,ConstEWi),2), nanmean(sims_plotAB(1,HVEWi),2)];
SUs1EW = [nanmean(sims_plotSUx(1,ConstEWi),2), nanmean(sims_plotSUx(1,HVEWi),2)];
%Plot
subplot(3,4,10); hold on
plot(subj1EW,'k-','MarkerEdgeColor','w','MarkerFaceColor','b','Marker','o','MarkerSize',10);
plot(ABs1EW,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(3,:),'Marker','d','MarkerSize',10);
plot(SUs1EW,'k-','MarkerEdgeColor','w','MarkerFaceColor',ModelCs(2,:),'Marker','d','MarkerSize',10);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([-1 10]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('PS2','AB','SU');
legend('boxoff');
xlabel('Condition');
title('P05 Early Washout (strides 6:30)');
ylabel('SAI (%)');

%Early Washout Subject 2
subj2EW = [nanmean(Data(2,ConstEWi),2), nanmean(Data(2,HVEWi),2)];
ABs2EW = [nanmean(sims_plotAB(2,ConstEWi),2), nanmean(sims_plotAB(2,HVEWi),2)];
SUs2EW = [nanmean(sims_plotSUx(2,ConstEWi),2), nanmean(sims_plotSUx(2,HVEWi),2)];
%Plot
subplot(3,4,12); hold on
plot(subj2EW,'k-','MarkerEdgeColor','w','MarkerFaceColor','b','Marker','o','MarkerSize',10);
plot(ABs2EW,'k-','MarkerEdgeColor','w','MarkerFaceColor',DataCs(3,:),'Marker','d','MarkerSize',10);
plot(SUs2EW,'k-','MarkerEdgeColor','w','MarkerFaceColor',ModelCs(2,:),'Marker','d','MarkerSize',10);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([-1 10]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','High Variability'};
legend('PS2','AB','SU');
legend('boxoff');
xlabel('Condition');
title('P06 Early Washout (strides 6:30)');
ylabel('SAI (%)');


end