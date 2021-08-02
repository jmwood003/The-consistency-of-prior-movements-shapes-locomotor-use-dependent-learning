function PilotDataPlot(D,T,P,Bins,num_initials)

%Fit models to pilot data and plot each indivudal and the aftereffects
%against their respective model simulations.

%D = Data
%T = targets
%P = phase index 
%Bins = number of bins
%num_initials = number of intilizations for the model fits

%Set strides for the initial bias and early washout
IWsh = 5;
EWsh = 6:30;

%Bin data
Dbin = Bin(D,Bins,1,'mean');
Tbin = Bin(T,Bins,1,'mean');
Pbin = Bin(P,Bins,1,'mean');

%Cat data and targets 
P01 = [Dbin(1,:), Dbin(3,:)]; T01 = [Tbin(1,:), Tbin(3,:)];
P02 = [Dbin(2,:), Dbin(4,:)]; T02 = [Tbin(2,:), Tbin(4,:)];
Data = [P01; P02];
Targets = [T01; T02];
Phases = [Pbin, Pbin];

%Fit the models to data
for Subj_i = 1:size(Targets,1)

    Subj_i

    %Pre-allocate space for error parameters and r2
    temp_best_errAB = [];     temp_best_errSU = [];
    temp_bestparamAB = [];    temp_bestparamSU = [];
    temp_r2AB = [];   temp_r2SU = [];
    tempaicAB = [];   tempaicSU = [];

    for initials_i = 1:num_initials

        %Fit each model to the data
        [paramsAB,errorAB,AICab, ~] = ABfit(Data(Subj_i,:),Targets(Subj_i,:));
        [paramsSU,errorSU,AICsu] = SUfit(Data(Subj_i,:),Targets(Subj_i,:));

        %Calculate r2 for AB model
        best_errAB = Inf;
        if errorAB <= best_errAB
            best_errAB = errorAB;
            bestparamAB = paramsAB;
            SSr = errorAB;
            SSt = sum((Data(Subj_i,:) - mean(Data(Subj_i,:))).^2);
            r2AB = 1 - (SSr/SSt);
        end

        %Save values for each initialization for the AB model
        temp_best_errAB(initials_i,:) = best_errAB;
        temp_bestparamAB(initials_i,:) = bestparamAB;
        temp_r2AB(initials_i,:) = r2AB;
        tempaicAB(initials_i,:) = AICab;

        %Calculate r2 for SU model
        best_errSU = Inf;
        if errorSU <= best_errSU
            best_errSU = errorSU;
            bestparamSU = paramsSU;
            SSr = errorSU;
            SSt = sum((D(Subj_i,:) - mean(D(Subj_i,:))).^2);
            r2SU = 1 - (SSr/SSt);
        end
        
        %Save values for each initialization for the SU model
        temp_best_errSU(initials_i,:) = best_errSU;
        temp_bestparamSU(initials_i,:) = bestparamSU;
        temp_r2SU(initials_i,:) = r2SU;
        tempaicSU(initials_i,:) = AICsu;

    end

        %Save best values for the AB model
        [~,bestidxAB] = min(temp_best_errAB);
        best_parametersAB(Subj_i,:) = temp_bestparamAB(bestidxAB,:);
        r2_paramAB(Subj_i,:) = temp_r2AB(bestidxAB,:);
        aic_paramAB(Subj_i,:) = tempaicAB(bestidxAB,:);
        best_sseAB(Subj_i,:) = min(temp_best_errAB);   

        %Save best values for the SU model        
        [~,bestidxSU] = min(temp_best_errSU);
        best_parametersSU(Subj_i,:) = temp_bestparamSU(bestidxSU,:);
        r2_paramSU(Subj_i,:) = temp_r2SU(bestidxSU,:);
        aic_paramSU(Subj_i,:) = tempaicSU(bestidxSU,:);
        best_sseSU(Subj_i,:) = min(temp_best_errSU);  
        
end

%Simulate 
for i = 1:size(Data,1)
    sims_plotAB(i,:) = ABsim(best_parametersAB(i,:),Targets(i,:));
    [sims_plotSUx(i,:),sims_plotSUw(i,:),sims_plotSUs(i,:) ] = ...
        SUsim(best_parametersSU(i,:),Targets(i,:));
end

%Set up plotting
%Colors
colors = lines(7);
Datacolor = colors(4,:);
ABcolor = colors(6,:);
Xcolor = colors(3,:);
Stratcolor = colors(2,:);
UDcolor = colors(7,:);

%Other plotting info
titles = {'P05 (AB model fit)','P06 (AB model fit)',...
    'P05 (SU model fit)','P06 (SU model fit)'};
pltidx = [1,2,1,2];
posstrti = [1,3,5,7]; posendi = [2,4,6,8];

%Plot
figure; 
for i = 1:length(pltidx)
    subplot(3,4,posstrti(i):posendi(i)); hold on
    plot(1:length(Data),Data(pltidx(i),:),'Marker','.','Color',Datacolor,'LineStyle','none');
    if i == 1 || i == 2
        plot(1:length(sims_plotAB),sims_plotAB(pltidx(i),:),'Color',ABcolor,'LineWidth',1.2);
        text(length(Phases)-400,15,['r^2 = ' num2str(round(r2_paramAB(i),2))]);
        text(length(Phases)-400,11,['AIC = ' num2str(round(aic_paramAB(i)))]);
        if i == 1
            legend('Data',  'AB model','location','north');
            legend('boxoff');
            text(length(Tbin)/5,42,'Consistent Condition');
            text((length(Tbin)/5)+length(Tbin),42,'High Variability Condition');

        end
    end
    if i == 3 || i ==4
        plot(1:length(sims_plotSUw),sims_plotSUw(pltidx(i),:),'Color',UDcolor,'LineWidth',1.2);
        plot(1:length(sims_plotSUs),sims_plotSUs(pltidx(i),:),'Color',Stratcolor,'LineWidth',1.2);
        plot(1:length(sims_plotSUx),sims_plotSUx(pltidx(i),:),'Color',Xcolor,'LineWidth',1.2);
        text(length(Phases)-400,15,['r^2 = ' num2str(round(r2_paramSU(i-2),2))]);
        text(length(Phases)-400,11,['AIC = ' num2str(round(aic_paramSU(i-2)))]);
        if i == 3   
            legend('Data', 'S+U (w)', 'S+U (s)', 'S+U model (x)', 'location','north');
            legend('boxoff');
        end
    end
    ylim([-5 40]);  xlim([0 length(Tbin)*2]);
    plot(1:length(Tbin)*2, zeros(length(Tbin)*2,1),'k');
    line([length(Tbin) length(Tbin)],get(gca,'ylim'),'LineWidth',3,'Color','k')
    title(titles{i});
    set(gca,'xtick',[]);
    if i == 3
         xlabel(['Strides (bins of ' num2str(Bins) ')']);     ylabel('SAI (%)');
    end
end

%Aftereffects

%Set up indexing:
wshout = find(Phases==3);
ConstIBi = wshout(1:IWsh);
HVIBi = wshout((find(diff(wshout)>1)+1):(find(diff(wshout)>1)+IWsh));
ConstEWi = wshout(EWsh);
HVEWi = wshout((find(diff(wshout)>1)+EWsh(1)):(find(diff(wshout)>1)+EWsh(end)));

%Initial Bias subject 1
%Calculate
subj1IB = [nanmean(Data(1,ConstIBi),2), nanmean(Data(1,HVIBi),2)];
ABs1IB = [nanmean(sims_plotAB(1,ConstIBi),2), nanmean(sims_plotAB(1,HVIBi),2)];
SUs1IB = [nanmean(sims_plotSUx(1,ConstIBi),2), nanmean(sims_plotSUx(1,HVIBi),2)];
%Plot
subplot(3,4,9); hold on
plot(subj1IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',Datacolor,'Marker','o','MarkerSize',5);
plot(ABs1IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',ABcolor,'Marker','o','MarkerSize',5);
plot(SUs1IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',Xcolor,'Marker','o','MarkerSize',5);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([0 15]);
ax = gca; ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','HV'};
ylabel('SAI (%)');
legend('Data','AB','S+U');
legend('boxoff');
title('P05 Initial Bias (strides 1:5)');

%Initial bias subject 2
%Calculate
subj2IB = [nanmean(Data(2,ConstIBi),2), nanmean(Data(2,HVIBi),2)];
ABs2IB = [nanmean(sims_plotAB(2,ConstIBi),2), nanmean(sims_plotAB(2,HVIBi),2)];
SUs2IB = [nanmean(sims_plotSUx(2,ConstIBi),2), nanmean(sims_plotSUx(2,HVIBi),2)];
%Plot
subplot(3,4,11); hold on
plot(subj2IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',Datacolor,'Marker','o','MarkerSize',5);
plot(ABs2IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',ABcolor,'Marker','o','MarkerSize',5);
plot(SUs2IB,'k-','MarkerEdgeColor','k','MarkerFaceColor',Xcolor,'Marker','o','MarkerSize',5);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([0 15]);
ax = gca; ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','HV'};
ylabel('SAI (%)');
title('P06 Initial Bias (strides 1:5)');

%Early Washout Subject 1
%Calculate
subj1EW = [nanmean(Data(1,ConstEWi),2), nanmean(Data(1,HVEWi),2)];
ABs1EW = [nanmean(sims_plotAB(1,ConstEWi),2), nanmean(sims_plotAB(1,HVEWi),2)];
SUs1EW = [nanmean(sims_plotSUx(1,ConstEWi),2), nanmean(sims_plotSUx(1,HVEWi),2)];
%Plot
subplot(3,4,10); hold on
plot(subj1EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',Datacolor,'Marker','o','MarkerSize',5);
plot(ABs1EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',ABcolor,'Marker','o','MarkerSize',5);
plot(SUs1EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',Xcolor,'Marker','o','MarkerSize',5);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([0 15]);
ax = gca; ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','HV'};
title('P05 Early Washout (strides 6:30)');
ylabel('SAI (%)');

%Early Washout Subject 2
%Calcualte
subj2EW = [nanmean(Data(2,ConstEWi),2), nanmean(Data(2,HVEWi),2)];
ABs2EW = [nanmean(sims_plotAB(2,ConstEWi),2), nanmean(sims_plotAB(2,HVEWi),2)];
SUs2EW = [nanmean(sims_plotSUx(2,ConstEWi),2), nanmean(sims_plotSUx(2,HVEWi),2)];
%Plot
subplot(3,4,12); hold on
plot(subj2EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',Datacolor,'Marker','o','MarkerSize',5);
plot(ABs2EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',ABcolor,'Marker','o','MarkerSize',5);
plot(SUs2EW,'k-','MarkerEdgeColor','k','MarkerFaceColor',Xcolor,'Marker','o','MarkerSize',5);
plot(0:4,zeros(1,5),'k');
xlim([0 3]); ylim([0 15]);
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Consistent','HV'};
title('P06 Early Washout (strides 6:30)');
ylabel('SAI (%)');


end