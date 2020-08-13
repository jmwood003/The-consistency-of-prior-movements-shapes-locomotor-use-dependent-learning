function PilotDataFit

%Fit two process model to data from prior study

close all; clear all; clc;

num_initials = 5;
IB = 1:10;
EW = 11:30;

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

load('Pilotdata.mat')
D = Pilot_data;
T = Trgts*100;


for Subj_i = 1:size(T,1)
    
    Subj_i
    
    %Pre-allocate space for error parameters and r2
    temp_best_errAB = [];     temp_best_errSU = [];
    temp_bestparamAB = [];    temp_bestparamSU = [];
    temp_r2AB = [];   temp_r2SU = [];
    tempaicAB = [];   tempaicSU = [];

    for initials_i = 1:num_initials

        [paramsAB,errorAB,AICab, ~] = ABfit(D(Subj_i,:),T(Subj_i,:));
        [paramsSU,errorSU,AICsu] = SUfit(D(Subj_i,:),T(Subj_i,:));
        
        % Save the best fitting parameters
        best_errAB = Inf;
        if errorAB <= best_errAB
            best_errAB = errorAB;
            bestparamAB = paramsAB;
            SSr = errorAB;
            SSt = sum((D(Subj_i,:) - mean(D(Subj_i,:))).^2);
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


%Simulate the experiment for plotting
for i = 1:size(D,1)
    sims_plotAB(i,:) = ABsim(best_parametersAB(i,:),T(i,:));
    sims_plotSU(i,:) = SUsim(best_parametersSU(i,:),T(i,:));
end

%Order of subjects
% 'VarTest_Stable_05'
% 'VarTest_Stable_06'
% 'VarTest_Unif_05'
% 'VarTest_Unif_06'
titles = {'VarTest05 - Stable','VarTest06 - Stable','VarTest05 - Unif','VarTest06 - Unif'};
pos = [1,2,5,6];
figure; 
for p = 1:4
    subplot(2,4,pos(p)); hold on
    plot(1:length(D),D(p,:),'b.');
%     plot(1:length(sims_plotAB),sims_plotAB(p,:),'r');
%     plot(1:length(sims_plotSU),sims_plotSU(p,:),'m');
    plot(1:length(D),zeros(1,length(D)),'k');
%     plot(1:length(T),T(p,:),'k');
    title(titles{p});
    ylim([-5 45]); xlim([0 1250]);
    if p == 1
        legend('Data','AB model','SU model');
        legend('boxoff');
    end

end

% wshidx = find(phases==3);
% subplot(2,4,3); hold on
% plot(1,mean(D(:,wshidx(IB))),'bo');
% plot(2,mean(sims_plotAB(:,wshidx(IB))),'ro');
% plot(3,mean(sims_plotSU(:,wshidx(IB))),'mo');
% ylim([0 8]); xlim([0 4]);



% %Extracted and trim pilot data subjects then saved into an array so we dont
% %need this anymore. 
% load('UDPVT.mat')
% T = UDPVT;
% 
% T(strcmp('VarTest_Unif_04',T.Subject_ID)==1,:) = [];
% T(strcmp('orientation',T.Trial_name)==1,:) = [];
% 
% SID = unique(T.Subject_ID);
% Trls = unique(T.Trial_name);
% trllen = [];
% for i = 1:length(SID)
%     for j = 1:length(Trls)
%         Ctrli = T.Baseline_corrected_SAI(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
%         Ctrli(isnan(Ctrli)==1) = [];
%         trllen(i,j) = length(Ctrli);     
%     end
% end
% 
% mintrls = min(trllen,[],1);
% phases = [ones(1,mintrls(1)), ones(1,mintrls(2))*2, ones(1,mintrls(3))*3];
% 
% Pilot_data = [];
% Trgts = [];
% for i = 1:length(SID)
%     CsubjSAI = [];
%     CsubjTrgt = [];
%     for j = 1:length(Trls)
%         Ctrl = T.Baseline_corrected_SAI(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
%         Ctrl(isnan(Ctrl)==1) = [];
%         CsubjSAI = [CsubjSAI, Ctrl(1:mintrls(j))'];
%         
%         trgt = T.Trgt(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
%         trgt(isnan(trgt)==1) = [];
%         CsubjTrgt = [CsubjTrgt, trgt(1:mintrls(j))'];
%     end
%     
%     Pilot_data = [Pilot_data; CsubjSAI];
%     Trgts = [Trgts; CsubjTrgt];
% 
% end
% save('Pilotdata.mat','Pilot_data','Trgts','phases');

end