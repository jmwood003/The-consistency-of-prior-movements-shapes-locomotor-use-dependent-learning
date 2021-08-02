function  ST = PlotOutcomes(ST, savestr)

%This function plots individual data:
%Distributions of targets and behavior during learning
%Accuracy data during learning
%Step asymmetry index
%Baseline corrected step asymmetry index 
%Step Length 
%Baseline Corrected Step Length plot

%Index data
SAIcor = ST.BslCor_SAI;

%Extracts the trial names out of the subject table while keeping the
%same orgniziation
Phase_names = unique(ST.phase);
if ismember('orientation',Phase_names)==1
    Phase_names = {'baseline','orientation','learning','washout'};
else
    Phase_names = {'baseline','learning','washout'};
end

%Extracts the subject ID as a string for plotting titles and saving
Subject_id = ST.SID{1};
Cond = ST.Condition{1};
titlenm = strrep(Subject_id,'_',' ');

%Index important phases:
baseline_idx = find(strcmp(ST.phase,'baseline')==1);
lrnidx = find(strcmp(ST.phase,'learning')==1);

%--------------------------------------------------------------------------
%Target and step distritbutions:
Distributions = figure;

LSL = ST.Left_step_length;
RSL = ST.Right_step_length;

%Plot histograms:
%SAI
subplot(2,3,1); hold on
histogram(ST.TrgtSAI(lrnidx),20);
histogram(SAIcor(lrnidx),20);
xlim([-10 55]);
xlabel('SAI (%)');
ylabel('Step Count');
legend('Target','Behavior');
legend('boxoff');
title('SAI Distribution');
%LSL
subplot(2,3,2); hold on
histogram(ST.TrgtLeft(lrnidx),20);
histogram(LSL(lrnidx),20);
xlim([0.2 1]);
xlabel('LSL (m)');
ylabel('Step Count');
title('LSL Distribution');
%RSL
subplot(2,3,3); hold on
histogram(ST.TrgtRight(lrnidx),20);
histogram(RSL(lrnidx),20);
xlim([0.2 1]);
xlabel('RSL (m)');
ylabel('Step Count');
title('RSL Distribution');

%Plot mean and standard deviation
%SAI
subplot(2,3,4); hold on
plot(0.9,nanmean(ST.TrgtSAI(lrnidx)),'bo','MarkerFaceColor','b');
plot(1.1,nanmean(SAIcor(lrnidx)),'ro','MarkerFaceColor','r');
plot(1.9,nanstd(ST.TrgtSAI(lrnidx)),'bo','MarkerFaceColor','b');
plot(2.1,nanstd(SAIcor(lrnidx)),'ro','MarkerFaceColor','r');
xlim([0 3]);
ylim([0 30]);
legend('Target','Behavior');
legend('boxoff');
title('SAI Mean and StDev');
ylabel('SAI (%)');
ax = gca;
ax.XTick = ([1 2]);
ax.XTickLabels = {'Mean', 'StDev'};
%LSL
subplot(2,3,5); hold on
plot(0.9,nanmean(ST.TrgtLeft(lrnidx)),'bo','MarkerFaceColor','b');
plot(1.1,nanmean(LSL(lrnidx)),'ro','MarkerFaceColor','r');
plot(1.9,nanstd(ST.TrgtLeft(lrnidx)),'bo','MarkerFaceColor','b');
plot(2.1,nanstd(LSL(lrnidx)),'ro','MarkerFaceColor','r');
xlim([0 3]);
ylim([0 1]);
title('LSL Mean and StDev');
ylabel('LSL (m)');
ax = gca;
ax.XTick = ([1 2]);
ax.XTickLabels = {'Mean', 'StDev'};
%RSL
subplot(2,3,6); hold on
plot(0.9,abs(nanmean(ST.TrgtRight(lrnidx))),'bo','MarkerFaceColor','b');
plot(1.1,abs(nanmean(RSL(lrnidx))),'ro','MarkerFaceColor','r');
plot(1.9,nanstd(ST.TrgtRight(lrnidx)),'bo','MarkerFaceColor','b');
plot(2.1,nanstd(RSL(lrnidx)),'ro','MarkerFaceColor','r');
xlim([0 3]);
ylim([0 1]);
title('RSL Mean and StDev');
ylabel('RSL (m)');
ax = gca;
ax.XTick = ([1 2]);
ax.XTickLabels = {'Mean', 'StDev'};
annotation('textbox', [0.4 0.9, 0.1 0.1], 'String',[titlenm, ' ', Cond, ' Distributions']);

%--------------------------------------------------------------------------
%Overall accuracy and hit percent plots
Accuracy = figure; 

%Plot correlation with target and step length
subplot(2,2,1); hold on
plot(ST.TrgtLeft(lrnidx),LSL(lrnidx),'b.');
axis equal
title('Left Accuracy');
xlabel('Target');
ylabel('Step Length');

subplot(2,2,3); hold on
plot(ST.TrgtRight(lrnidx),RSL(lrnidx),'b.');
axis equal
title('Right Accuracy');
ylabel('Step Length');
xlabel('Target');

%Absolute accuracy
R_acc = abs(RSL(lrnidx) - ST.TrgtRight(lrnidx));
L_acc = abs(LSL(lrnidx) - ST.TrgtLeft(lrnidx));

subplot(2,2,2); hold on
plot(1,nanmean(L_acc),'bo','MarkerFaceColor','b');
errorbar(1,nanmean(L_acc),nanstd(L_acc),'b');
plot(2,nanmean(R_acc),'ro','MarkerFaceColor','r');
errorbar(2,nanmean(R_acc),nanstd(R_acc),'r');
xlim([0 3]);
ylim([0 0.1]);
title('Absolute Accuracy');
ylabel('Meters');
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Left', 'Right'};

%Hit percentage
TotalHitL = ST.LeftSuccessSum(lrnidx);
TotalHitL = TotalHitL(isnan(TotalHitL)==0);
TotalHitR = ST.RightSuccessSum(lrnidx);
TotalHitR = TotalHitR(isnan(TotalHitR)==0);

Lhitprect = (TotalHitL(end) / length(TotalHitL)) * 100;
Rhitprect = (TotalHitR(end) / length(TotalHitR)) * 100;

subplot(2,2,4); hold on
plot(1,Lhitprect,'bo','MarkerFaceColor','b');
plot(2,Rhitprect,'ro','MarkerFaceColor','r');
xlim([0 3]);
ylim([0 100]);
title('Hit Percentage');
ylabel('Prct');
ax = gca;
ax.XTick = [1 2];
ax.XTickLabel = {'Left', 'Right'};

annotation('textbox', [0.4 0.92, 0.1 0.1], 'String',[titlenm, ' ', Cond, ' Accuracy']);
%--------------------------------------------------------------------------
%Limb position and asymmetry

Limb_position = figure; 
subplot(3,2,[1,3]); hold on
plot(ST.Left_Trailing(lrnidx),'b.');
plot(ST.Left_Leading(lrnidx),'r.');
xlim([0 550]);
ylim([-500 500]);
xlabel('Learning Strides');
ylabel('Limb position relative to hip (mm)');
legend('Right Step','Left Step');
title('Left Limb Position');

subplot(3,2,[2,4]); hold on
plot(ST.Right_Trailing(lrnidx),'r.');
plot(ST.Right_Leading(lrnidx),'b.');
xlim([0 550]);
ylim([-500 500]);
xlabel('Learning Strides');
ylabel('Limb position relative to hip (mm)');
title('Right Limb Position');

%Loops through each phase and plots each phase after another with some
%space in between
subplot(3,2,5); hold on
space = 0; 
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1); 
    plot(current_epoc_idx+space,ST.LeadingAsym(current_epoc_idx),'k.','MarkerSize',10);
    hold on
    space = space + 100;
end
baseline = nanmean(ST.LeadingAsym(baseline_idx(length(baseline_idx)-49:end)));
plot(1:(height(ST)+space),(ones(1,height(ST)+space))*baseline,'k-');
% ylim([-0.4 0.4]);
title('Leading limb Asymmetry');
xlabel('Strides');
ylabel('Millimeters');

subplot(3,2,6); hold on
space = 0; 
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1);
    plot(current_epoc_idx+space,ST.TrailingAsym(current_epoc_idx),'k.','MarkerSize',10);
    hold on
    space = space + 100;
end
baseline = nanmean(ST.TrailingAsym(baseline_idx(length(baseline_idx)-49:end)));
plot(1:(height(ST)+space),(ones(1,height(ST)+space))*baseline,'k-');
% ylim([-0.4 0.4]);
title('Trailing limb Asymmetry');
xlabel('Strides');
ylabel('Millimeters');

annotation('textbox', [0.4 0.92, 0.1 0.1], 'String',[titlenm, ' ', Cond, ' Limb Position']);
%--------------------------------------------------------------------------
%Step_asymmetry_index plot
Step_asymmetry_index = figure; 
space = 0; 
%Loops through each phase and plots each phase after another with some
%space in between
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)+space)-50, -20, length(current_epoc_idx)+100 100], 'FaceColor',[0.8 0.8 0.8]);
    end
    hold on    
    plot(current_epoc_idx+space,ST.SAI(current_epoc_idx),'b.','MarkerSize',10);
    txtstart = ((current_epoc_idx(1)+space)+(current_epoc_idx(end)+space))/2;
    text(txtstart, 54, current_epoc);
    space = space + 100;
end
baseline = nanmean(ST.SAI(baseline_idx(length(baseline_idx)-49:end)));
plot(1:(height(ST)+space),(ones(1,height(ST)+space))*baseline,'k-');
title([titlenm, ' ', Cond, ' Step Asymmtry Index Stride by Stride']);
ylim([-20 55]);
xlim([-50 current_epoc_idx(end)+350]);
xlabel('Strides');
ylabel('Step Asymmetry Index (%)');

%--------------------------------------------------------------------------
%Baseline corrected step asymmetry index plot
Baseline_corrected_SAI = figure;
space = 0; 
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)+space)-50, -20, length(current_epoc_idx)+100 100], 'FaceColor',[0.8 0.8 0.8]);
    end
    hold on
    plot(current_epoc_idx+space,SAIcor(current_epoc_idx),'b.','MarkerSize',10);
    txtstart = ((current_epoc_idx(1)+space)+(current_epoc_idx(end)+space))/2;
    text(txtstart, 54, current_epoc);
    space = space + 100;
end
plot(1:(height(ST)+space),zeros((height(ST)+space)),'k-');
ylim([-20 55]);
xlim([-50 current_epoc_idx(end)+350]);
title([titlenm, ' ' , Cond, ' Baseline Corrected SAI Stride by Stride']);
xlabel('Strides');
ylabel('Step Asymmetry Index (%)');

%--------------------------------------------------------------------------
%Step_Length plot
Step_Length = figure;
space = 0; 
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)+space)-50, 0, length(current_epoc_idx)+100 1], 'FaceColor',[0.8 0.8 0.8]);
    end
    hold on    
    baseline_RSL = nanmean(ST.Right_step_length(baseline_idx(length(baseline_idx)-49:end)));
    baseline_LSL = nanmean(ST.Left_step_length(baseline_idx(length(baseline_idx)-49:end)));
    plot(current_epoc_idx+space,ST.Right_step_length(current_epoc_idx),'b.','MarkerSize',10);
    plot(current_epoc_idx+space,ST.Left_step_length(current_epoc_idx),'r.','MarkerSize',10);
    txtstart = ((current_epoc_idx(1)+space)+(current_epoc_idx(end)+space))/2;
    text(txtstart, 0.95, current_epoc);    
    space = space + 100;
end
plot(1:(height(ST)+space),zeros((height(ST)+space)) + baseline_RSL,'b-');
plot(1:(height(ST)+space),zeros((height(ST)+space)) + baseline_LSL,'r-');
ylim([0 1]);
xlim([-50 current_epoc_idx(end)+350]);
title([titlenm, ' ', Cond, ' Step Length Stride by Stride']);
xlabel('Strides');
ylabel('Step Length (m)');
legend('Right Step Length','Left Step Length');

%--------------------------------------------------------------------------
%Baseline Corrected Step_Length plot
Baseline_Corrected_Step_Length = figure;
space = 0; 
for phase_i = 1:length(Phase_names)
    current_epoc = Phase_names{phase_i};
    current_epoc_idx = find(strcmp(ST.phase,current_epoc)==1);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)+space)-50, -1, length(current_epoc_idx)+100 2], 'FaceColor',[0.8 0.8 0.8]);
    end
    hold on    
    plot(current_epoc_idx+space,ST.BslCor_RSL(current_epoc_idx),'b.','MarkerSize',10);
    plot(current_epoc_idx+space,ST.BslCor_LSL(current_epoc_idx),'r.','MarkerSize',10);
    txtstart = ((current_epoc_idx(1)+space)+(current_epoc_idx(end)+space))/2;
    text(txtstart, 0.49, current_epoc);       
    space = space + 100;
end
plot(1:(height(ST)+space),zeros((height(ST)+space)),'k-');
ylim([-0.6 0.6]);
xlim([-50 current_epoc_idx(end)+350]);
title([titlenm, ' ', Cond, ' Baseline Corrected Step Length']);
xlabel('Strides');
ylabel('Step Length (m)');
legend('Right Step Length','Left Step Length');

%Save plots if desired
if strcmp(savestr,'Yes') == 1
    saveas(Distributions,[Subject_id, '_', Cond, '_Distributions_new.fig']);    
    saveas(Accuracy,[Subject_id, '_', Cond, '_Accuracy_new.fig']);    
    saveas(Baseline_Corrected_Step_Length,[Subject_id, '_', Cond, '_Baseline_Corrected_SL_new.fig']);
    saveas(Step_Length,[Subject_id, '_', Cond, '_Step_length_new.fig']);
    saveas(Baseline_corrected_SAI,[Subject_id, '_', Cond, '_Baseline_Corrected_SAI_new.fig']);
    saveas(Step_asymmetry_index,[Subject_id, '_', Cond, '_Step_Asymmetry_Index_new.fig']);
    saveas(Limb_position,[Subject_id, '_', Cond, '_Limb_position_new.fig']);
    disp('Plots Saved');
else
    disp('Plots Not Saved');
end

end


