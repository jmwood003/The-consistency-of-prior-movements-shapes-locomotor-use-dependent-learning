function DataFitBootAB

%Fit Bayes model to data from prior study

close all; clear all; clc;

%Set the number of bins, bootstraps, initials
nbins = 5; 
<<<<<<< Updated upstream
nboot = 10000; 
=======
nboot = 100; 
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

        [params,error,AIC] = BysFit(Data_btstrp(Subj_i,:),Target_bin);
        
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
    sims_plot(i,:) = BayesSim(best_parameters(i,:),Target_bin);
end

%Calculate the mean r2
meanr2 = mean(r2_param_boot);
meanaic = mean(aic_param_boot);

%Obtain parameter means 
Beta_mean = nanmean(best_parameters(:,1));
Sigma_Lmean = nanmean(best_parameters(:,2));

%Obtain 95% confidence intervals for the parameters
%Set the index
LowerIdx = round((nboot/100)*2.5);
UpperIdx = round((nboot/100)*97.5);
%Index the CI for each parameter
Beta_sorted = sort(best_parameters(:,1));
Beta_LB = Beta_sorted(LowerIdx); Beta_UB = Beta_sorted(UpperIdx);
Beta_CIs = [Beta_sorted(LowerIdx) Beta_sorted(UpperIdx)];
SigmaL_sorted = sort(best_parameters(:,2));
SigmaL_LB = SigmaL_sorted(LowerIdx); SigmaL_UB = SigmaL_sorted(UpperIdx);
SigmaL_CIs = [SigmaL_sorted(LowerIdx) SigmaL_sorted(UpperIdx)];

means = [Beta_mean Sigma_Lmean];
LBs = [Beta_LB SigmaL_LB];
UBs = [Beta_UB SigmaL_UB];

%Plot the parameters and confidence intervals 
figure; hold on
for i = 1:length(means)
    errorbar(i,means(i),means(i)-LBs(i),UBs(i)-means(i),'rx','MarkerSize',10,'LineWidth',1);
    text(i+0.1,means(i),num2str(means(i)));
end
ylim([-10 100]);
title('Parameter Values and CIs');
ylabel('Parameter Value')
ax = gca;
ax.XTick = [1:3];
ax.XTickLabel = {'Beta', 'Sigma Liklihood', 'Prior Variance'};
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
title('Bayes Model Fit');

%Plot correaltion between parameters
corrplot(best_parameters,'varNames',{'Beta','SigL'});

save('ParamsBys','best_parameters','r2_param_boot','aic_param_boot');

end