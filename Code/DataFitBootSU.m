function DataFitTwopBoot

%Fit two process model to data from prior study

close all; clear all; clc;

%Set the number of bins, bootstraps, initials
nbins = 5; 
<<<<<<< Updated upstream
nboot = 10000; 
=======
nboot = 1000; 
>>>>>>> Stashed changes
num_initials = 5;

%Set directory and load data
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
addpath(helpdir);
addpath(simdir);
addpath(directory);
cd(datadir);

load('Data.mat','DRR_bslcor_data');
Strides = DRR_bslcor_data;

%Set the targets 
grad_err = [ones(1,52)*2, ones(1,52)*4, ones(1,52)*6, ones(1,52)*8, ones(1,52)*10, ones(1,52)*12, ones(1,52)*14, ones(1,52)*16,...
    ones(1,52)*18, ones(1,52)*20, ones(1,50)*22];
baseline = zeros(1,100);
catch_1 = zeros(1,24);
learning_2 = ones(1,229)*22;
catch_2 = zeros(1,24);
learning_3 = ones(1,234)*22;
washout = zeros(1,1031);
%Targets for the whole experiment
t = [baseline,grad_err,catch_1,learning_2,catch_2,learning_3,washout];

%Bin the data and the targets to keep target changes as close to data as possible 
Data_bin = Bin(Strides,nbins,1,'mean');
Target_bin = Bin(t,nbins,1,'mean');
for i = 1:length(Target_bin)
    if rem(Target_bin(i),1)~=0
        Target_bin(i) = Target_bin(i-1);  
    end
end

%Bootstrap
Data_btstrp = bootstrp(nboot,@mean,Data_bin);

for Subj_i = 1:size(Data_btstrp,1)
    
    Subj_i
    
    %Pre-allocate space for error parameters and r2
    temp_best_err = [];
    temp_bestparam = [];
    temp_r2 = [];
    tempaic = [];
        
    for initials_i = 1:num_initials

        [params,error,AIC] = TpFit(Data_btstrp(Subj_i,:),Target_bin);
        
        % Save the best fitting parameters
        best_err = Inf;
        if error <= best_err
            best_err = error;
            bestparam = params;
            SSr = error;
            SSt = sum((Data_btstrp(Subj_i,:) - mean(Data_btstrp(Subj_i,:))).^2);
            r2 = 1 - (SSr/SSt);
        end

        temp_best_err(initials_i,:) = best_err;
        temp_bestparam(initials_i,:) = bestparam;
        temp_r2(initials_i,:) = r2;
        tempaic(initials_i,:) = AIC;
        
    end

        [~,bestidx] = min(temp_best_err);
        best_parameters(Subj_i,:) = temp_bestparam(bestidx,:);
        r2_param_boot(Subj_i,:) = temp_r2(bestidx,:);
        aic_param_boot(Subj_i,:) = tempaic(bestidx,:);
        best_sse(Subj_i,:) = min(temp_best_err);
        
end

%Simulate the experiment for plotting
for i = 1:size(Data_btstrp,1)
    sims_plot(i,:) = TwopSim(best_parameters(i,:),Target_bin);
end

%Calculate the mean r2
meanr2 = mean(r2_param_boot);
meanaic = mean(aic_param_boot);

%Obtain parameter means 
C_mean = nanmean(best_parameters(:,1));
A_mean = nanmean(best_parameters(:,2));
E_mean = nanmean(best_parameters(:,3));
F_mean = nanmean(best_parameters(:,4));

%Obtain 95% confidence intervals for the parameters
%Set the index
LowerIdx = round((nboot/100)*2.5);
UpperIdx = round((nboot/100)*97.5);
%Index the CI for each parameter
C_sorted = sort(best_parameters(:,1));
C_LB = C_sorted(LowerIdx); C_UB = C_sorted(UpperIdx);
C_CIs = [C_sorted(LowerIdx) C_sorted(UpperIdx)];
A_sorted = sort(best_parameters(:,2));
A_LB = A_sorted(LowerIdx); A_UB = A_sorted(UpperIdx);
A_CIs = [A_sorted(LowerIdx) A_sorted(UpperIdx)];
E_sorted = sort(best_parameters(:,3));
E_LB = E_sorted(LowerIdx); E_UB = E_sorted(UpperIdx); 
E_CIs = [E_sorted(LowerIdx) E_sorted(UpperIdx)];
F_sorted = sort(best_parameters(:,4));
F_LB = F_sorted(LowerIdx); F_UB = F_sorted(UpperIdx);
F_CIs = [F_sorted(LowerIdx) F_sorted(UpperIdx)];

means = [C_mean A_mean E_mean F_mean];
LBs = [C_LB A_LB E_LB F_LB];
UBs = [C_UB A_UB E_UB F_UB];

%Plot the parameters and confidence intervals 
figure; hold on
for i = 1:length(means)
    errorbar(i,means(i),means(i)-LBs(i),UBs(i)-means(i),'rx','MarkerSize',10,'LineWidth',1);
    text(i+0.1,means(i),num2str(means(i)));
end
ylim([-0.1 1.1]);
title('Parameter Values and CIs');
ylabel('Parameter Value')
ax = gca;
ax.XTick = [1:4];
ax.XTickLabel = {'Correction Rate (C)', 'Strategic Retention Rate (A)', 'Use-Dependent Retention Rate (E)', 'Use-Dependent Learning Rate (F)'};
ax.XTickLabelRotation = 45;

%Plot mean model and bootstrapped data
figure; hold on
shadedErrorBar(1:size(sims_plot,2),nanmean(sims_plot),nanstd(sims_plot),'lineProps','k-','transparent',1);
shadedErrorBar(1:size(Data_btstrp,2),mean(Data_btstrp),std(Data_btstrp),'lineProps','r','transparent',1);
plot(1:length(Target_bin),Target_bin,'k--');
plot(1:length(Target_bin),zeros(1,length(Target_bin)),'k');
ylabel('Step Asymmetry Index');
xlabel('Strides');
legend('Model','Behavior','Target');
title('Two Process Model Fit');

%Plot correlation between parameters
corrplot(best_parameters,'varNames',{'C','A','E','F'});

save('ParamsTwop','best_parameters','r2_param_boot','aic_param_boot');


end