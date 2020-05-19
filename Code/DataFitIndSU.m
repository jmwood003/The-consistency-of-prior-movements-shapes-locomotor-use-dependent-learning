function DataFitIndSU


%Fit two process model to data from prior study

close all; clear all; clc;

%Set the number of bins, bootstraps, initials
nbins = 5; 
num_initials = 5;

%Set directory and load data
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
plotdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\PlottingFunctions';
addpath(helpdir);
addpath(simdir);
addpath(plotdir);
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

for Subj_i = 1:size(Data_bin,1)
    
    Subj_i
    
    %Pre-allocate space for error parameters and r2
    temp_best_err = [];
    temp_bestparam = [];
    temp_r2 = [];
    tempaic = [];
        
    for initials_i = 1:num_initials

        [params,error,AIC] = SUfit(Data_bin(Subj_i,:),Target_bin);
        
        % Save the best fitting parameters
        best_err = Inf;
        if error <= best_err
            best_err = error;
            bestparam = params;
            SSr = error;
            SSt = sum((Data_bin(Subj_i,:) - mean(Data_bin(Subj_i,:))).^2);
            r2 = 1 - (SSr/SSt);
        end

        temp_best_err(initials_i,:) = best_err;
        temp_bestparam(initials_i,:) = bestparam;
        temp_r2(initials_i,:) = r2;
        tempaic(initials_i,:) = AIC;
        
    end

        [~,bestidx] = min(temp_best_err);
        best_parameters(Subj_i,:) = temp_bestparam(bestidx,:);
        r2_param(Subj_i,:) = temp_r2(bestidx,:);
        aic_param(Subj_i,:) = tempaic(bestidx,:);
        best_sse(Subj_i,:) = min(temp_best_err);
        
end

%Simulate the experiment for plotting
for i = 1:size(Data_bin,1)
    sims_plot(i,:) = SUsim(best_parameters(i,:),Target_bin);
end

%Calculate the mean r2
meanr2 = mean(r2_param);
meanaic = mean(aic_param);

%Obtain parameter means 
C_mean = nanmean(best_parameters(:,1));
A_mean = nanmean(best_parameters(:,2));
E_mean = nanmean(best_parameters(:,3));
F_mean = nanmean(best_parameters(:,4));

C_std = nanstd(best_parameters(:,1));
A_std = nanstd(best_parameters(:,2));
E_std = nanstd(best_parameters(:,3));
F_std = nanstd(best_parameters(:,4));

means = [C_mean A_mean E_mean F_mean];
stds = [C_std A_std E_std F_std];


%Plot the parameters and confidence intervals 
figure; hold on
for i = 1:length(means)
    errorbar(i,means(i),stds(i),'rx','MarkerSize',10,'LineWidth',1);
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
shadedErrorBar(1:size(Data_bin,2),mean(Data_bin),std(Data_bin),'lineProps','r','transparent',1);
plot(1:length(Target_bin),Target_bin,'k--');
plot(1:length(Target_bin),zeros(1,length(Target_bin)),'k');
ylabel('Step Asymmetry Index');
xlabel('Strides');
legend('Model','Behavior','Target');
title('Two Process Model Fit');

%Plot individuals 
figure; hold on
for i = 1:length(best_parameters)
    subplot(4,4,i); hold on
    plot(1:size(sims_plot,2),sims_plot(i,:),'k-');
    plot(1:size(Data_bin,2),Data_bin(i,:),'r-');   
%     plot(1:length(Target_bin),Target_bin,'k--');
    plot(1:length(Target_bin),zeros(1,length(Target_bin)),'k');
    xlim([0 500]);
    ylim([-10 40]);
    title(['Participant ' num2str(i)],'FontSize',8);
    if i == 1
%         legend({'Model Fit','Data'},'FontSize',6);
%         legend('boxoff');
    elseif i ==13
        xlabel('Stride Bin');
        ylabel('SAI (%)');
    end
    s1 = ['r^{2} = ' num2str(r2_param(i))]; s2 = ['AIC = ' num2str(aic_param(i))]; 
    text([300 300],[25 20],{{s1},s2},'FontSize',6);
end
suptitle('Individual Fits Strategy + UDP Model');

%Plot correlation between parameters
corrplot(best_parameters,'varNames',{'C','A','E','F'});

save('IndParamsTwop','best_parameters','r2_param','aic_param');

end