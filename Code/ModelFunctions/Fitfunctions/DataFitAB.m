function best_params = DataFitAB(D,nbins,num_initials)

%Fit Adaptive Bayesian model to data from prior study

%D = data
%nbins = number of bins
%num_initials = number of initializations

%Set the targets 
%Have to estimate the targets because they were not matched in the motion
%capture software
grad_err = [ones(1,52)*2, ones(1,52)*4, ones(1,52)*6, ones(1,52)*8, ones(1,52)*10, ones(1,52)*12, ones(1,52)*14, ones(1,52)*16,...
    ones(1,52)*18, ones(1,52)*20, ones(1,50)*22];
baseline = zeros(1,100);
catch_1 = zeros(1,24);
learning_2 = ones(1,229)*22;
catch_2 = zeros(1,24);
learning_3 = ones(1,234)*22;
washout = zeros(1,1031);
%Combine targets for the whole experiment
t = [baseline,grad_err,catch_1,learning_2,catch_2,learning_3,washout];

%Bin the data and the targets to keep target changes as close to data as possible 
Data_bin = Bin(D,nbins,1,'mean');
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

        %Fit
        [params,error,AIC,~] = ABfit(Data_bin(Subj_i,:),Target_bin);
        
        %Calculate r^2
        best_err = Inf;
        if error <= best_err
            best_err = error;
            bestparam = params;
            SSr = error;
            SSt = sum((Data_bin(Subj_i,:) - mean(Data_bin(Subj_i,:))).^2);
            r2 = 1 - (SSr/SSt);
        end

        %Save values
        temp_best_err(initials_i,:) = best_err;
        temp_bestparam(initials_i,:) = bestparam;
        temp_r2(initials_i,:) = r2;
        tempaic(initials_i,:) = AIC;
        
    end

        %Save the values from the best parameters
        [~,bestidx] = min(temp_best_err);
        best_params(Subj_i,:) = temp_bestparam(bestidx,:);
        r2_param(Subj_i,:) = temp_r2(bestidx,:);
        aic_param(Subj_i,:) = tempaic(bestidx,:);
        best_sse(Subj_i,:) = min(temp_best_err);
        
end

%Simulate the experiment for plotting
for i = 1:size(Data_bin,1)
    sims_plot(i,:) = ABsim(best_params(i,:),Target_bin);
end

%Colors
colors = lines(7);
Datacolor = colors(4,:);
ABcolor = colors(6,:);

%Index no visual feedback trials for plotting
startC1 = round((length(grad_err)+length(baseline))/nbins);
startC2 = round((length(grad_err)+length(baseline) + length(learning_2) + length(catch_1))/nbins);
startwsh = round((length(grad_err)+length(baseline) + length(learning_2) +length(catch_2) + length(catch_1) + length(learning_3))/nbins);

%Plot mean model fits and data
figure; hold on
rectangle('Position',[0 -5 round(length(baseline)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[startC1 -5 round(length(catch_1)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[startC2 -5 round(length(catch_2)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
rectangle('Position',[startwsh -5 round(length(washout)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
shadedErrorBar(1:size(Data_bin,2),mean(Data_bin),SEM(Data_bin,1),'lineProps',{'Color',Datacolor,'LineWidth',1.5});
shadedErrorBar(1:size(sims_plot,2),nanmean(sims_plot),SEM(sims_plot,1),'lineProps',{'Color', ABcolor,'LineWidth',2});
plot(1:length(Target_bin),Target_bin,'k--');
plot(1:length(Target_bin),zeros(1,length(Target_bin)),'k');
text(startwsh+50, 15, ['r^2 = ' num2str(round(mean(r2_param),2)) ' +/- ' num2str(round(SEM(r2_param,1),2))]); 
text(startwsh+50, 12, ['AIC = ' num2str(round(mean(aic_param))) ' +/- ' num2str(round(SEM(aic_param,1)))]); 
ylim([-2 30]); xlim([0 length(Data_bin)]);
ylabel('Step Asymmetry Index (%)'); xlabel('Strides');
legend('Behavior','TMAP','Target'); legend('boxoff');
title('Adaptive Bayesian Model Fit');

%Plot individual model fits and data
figure; hold on
for i = 1:length(best_params)
    subplot(4,4,i); hold on
    rectangle('Position',[0 -5 round(length(baseline)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    rectangle('Position',[startC1 -5 round(length(catch_1)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    rectangle('Position',[startC2 -5 round(length(catch_2)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    rectangle('Position',[startwsh -5 round(length(washout)/nbins), 40],'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    plot(1:size(Data_bin,2),Data_bin(i,:),'Marker','.','LineStyle','none','Color',Datacolor,'MarkerSize',4);   
    plot(1:size(sims_plot,2),sims_plot(i,:),'Color',ABcolor,'LineWidth',2);
    plot(1:length(Target_bin),zeros(1,length(Target_bin)),'k');
    xlim([0 length(Target_bin)]);    ylim([-3 35]);
    title(['Participant ' num2str(i)],'FontSize',8);
    if i == 1
        legend({'Data','TMAP'},'FontSize',6,'location','east');
        legend('boxoff');
    elseif i ==13
        xlabel('Strides');     ylabel('SAI (%)');
    end
    s1 = ['r^{2} = ' num2str(round(r2_param(i),2))]; s2 = ['AIC = ' num2str(round(aic_param(i)))]; 
    text([1500 1500],[30 25],{{s1},s2},'FontSize',6);
end
suptitle('Individual Fits Adaptive Bayes Model');

end