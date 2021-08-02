function [grpSAI_Lrnmean, grpSAI_Lrnsd] = ConditionPlot(T,nbins)

%This function plots stride by stride data for each condition as well as
%histograms for learning strides and mean and SD SAI during learning strides

%Input:
%T = data table
%nbins = number of bins to use for plotting

%Output:
%grpSAI_Lrnmean = Learning SAI mean for each individual across conditions
%grpSAI_Lrnsd = Learning SAI sigma for each individual across conditions

%Find the shortest phase for truncating
phaselength = [];
allS = unique(T.sessionID);
for i = 1:length(allS)
    bsl_len = length(find(strcmp(allS{i},T.sessionID)==1 & strcmp('baseline',T.phase)==1));
    lrn_len = length(find(strcmp(allS{i},T.sessionID)==1 & strcmp('learning',T.phase)==1));
    wsh_len = length(find(strcmp(allS{i},T.sessionID)==1 & strcmp('washout',T.phase)==1));
    phaselength(i,:) = [bsl_len, lrn_len, wsh_len];
end
phaselength(phaselength==0) = nan;
short_phase = nanmin(phaselength);

%Pre-allocate variables
idxvar = [];
allSAI = [];

%Loop through conditions 
Cs = {'Constant','LV','HV'};
for c = 1:length(Cs)
    
    %Current condition and index
    CurrentC = Cs{c}; 
    Cidx = find(strcmp(CurrentC,T.Condition)==1);

    %Index and loop through subjects
    Subjs = unique(T.SID(Cidx));
    LrnSAIall = [];
    LrnTrgtall = [];       
    for s = 1:length(Subjs)
        
        %Current subject
        CurrentS = Subjs{s};
        
        %Loop through phases
        Phases = {'baseline', 'learning', 'washout'};        
        Sdata = []; pidx = [];
        for p = 1:length(Phases)
            
            %Current phase
            CurrentP = Phases{p};
            
            %Index and truncate
            idx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp(CurrentP,T.phase)==1);
            trunc_idx = idx(1:short_phase(p));
            
            %Bin and save
            bins = Bin(T.BslCor_SAI(trunc_idx),nbins,2,'mean');
            Sdata = [Sdata, bins.'];
                       
            %make indexing variable for phases length
            pidx = [pidx, ones(1,length(bins))*p];

        end
        
        %Save SAI data for each subject
        allSAI = [allSAI; Sdata];
        
        %Create index for learning phase only
        lrnidx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp('learning',T.phase)==1);
        
        %Index SAI and targets for the learning phase
        grpSAI_Lrnmean(s,c) = nanmean(T.BslCor_SAI(lrnidx));
        grpSAI_Lrnsd(s,c) = nanstd(T.BslCor_SAI(lrnidx));

        grpTrgt_Lrnmean(s,c) = nanmean(T.TrgtSAI(lrnidx));
        grpTrgt_Lrnsd(s,c) = nanstd(T.TrgtSAI(lrnidx));

        %Save all learning strides for histogram
        LrnSAIall = [LrnSAIall; T.BslCor_SAI(lrnidx)];
        LrnTrgtall = [LrnTrgtall; T.TrgtSAI(lrnidx)];           

        %Make indexing variable for conditions
        if strcmp(CurrentC,'Constant')==1
            idxvar = [idxvar; 1];
        elseif strcmp(CurrentC,'LV')==1
            idxvar = [idxvar; 2];
         elseif strcmp(CurrentC,'HV')==1
            idxvar = [idxvar; 3];   
        end
        
    end
    
    %Save all data into structure 
    Struct.(CurrentC).AllSAI = LrnSAIall;
    Struct.(CurrentC).AllT = LrnTrgtall;    
    
end

S=struct;
%Set indexing variables for conditions in a structure 
S(1).Cond = find(idxvar==1);
S(2).Cond = find(idxvar==2);
S(3).Cond = find(idxvar==3);

%Set up some plotting variables
plotLoc = [1:4; 5:8; 9:12];
plotCs = {'Constant Condition', 'Low Variability Condition','High Variability Condition'};
meancolors = lines(3);

%Plot SAI for each individual and each condition
GrpSAI = figure; 
for Cond_i = 1:length(Cs)
    subplot(4,4, plotLoc(Cond_i,:)); hold on
    Condidx = S(Cond_i).Cond;
    
    %Set colors for individuals
    c1 = jet(60);
    c2 = summer(length(Condidx));
    colors = [c1(1:length(Condidx),:); c1(end-length(Condidx)+1:end,:); c2];
    
    space = 0; 
    for phase_i = 1:length(Phases)
        current_epoc = Phases{phase_i};
        current_epoc_idx = find(pidx==phase_i);
        if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
            rectangle('Position',[(current_epoc_idx(1)+space), -20, length(current_epoc_idx) 100], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
        end
        hold on
        for i = 1:length(Condidx)
            p2 = plot(current_epoc_idx+space, allSAI(Condidx(i),current_epoc_idx),'LineWidth',0.5,'Color',colors(Condidx(i),:));
        end
        p1 = plot(current_epoc_idx+space, nanmean(allSAI(Condidx,current_epoc_idx)), 'o', 'MarkerFaceColor',meancolors(Cond_i,:),'MarkerEdgeColor','k','MarkerSize',6);
        txtstart = ((current_epoc_idx(1)+space)+(current_epoc_idx(end)+space))/2;
        if strcmp(Cs{Cond_i},'Constant')==1
            text(txtstart, 30, current_epoc);
        end
        if strcmp(current_epoc,'learning')==1
            p3 = plot(current_epoc_idx+space,ones(1,length(current_epoc_idx))*nanmean(Struct.(Cs{Cond_i}).AllT),'k--','LineWidth',2);
        end
        space = space + 1;
    end
    plot(1:(length(current_epoc_idx)+space),zeros(1,(length(current_epoc_idx)+space)),'k-');
    ylim([-5 40]);    xlim([0 current_epoc_idx(end)+space-10]);
    title(plotCs{Cond_i}); 
    legend([p1,p2,p3],'Mean','Individual','Mean SAI target','location','east'); legend('boxoff');
    if Cond_i==1
        set(gca,'xtick',[]);
    elseif Cond_i==2
        set(gca,'xtick',[]);
        ylabel('SAI(%)');
    elseif Cond_i==3
        xlabel(['Stride (' num2str(nbins) ' bins)']);    
    end
end

%reset colors
colors = parula(3);
icolors = gray(3);

%plot histogram for the learning phase
subplot(4,4,13:14); hold on
histogram(Struct.HV.AllSAI,'FaceColor',meancolors(3,:),'FaceAlpha',0.5);
histogram(Struct.LV.AllSAI,'FaceColor',meancolors(2,:),'FaceAlpha',0.5);
histogram(Struct.Constant.AllSAI,'FaceColor',meancolors(1,:),'FaceAlpha',0.5);
legend('HV', 'LV', 'Constant');
legend('boxoff');
xlim([0 50]);
title('All Learning Strides');
xlabel('SAI (%)');
ylabel('Stride Count');

%Plot learning SAI mean and sigma across conditions
subplot(4,4,15:16); hold on
plot([1,2,3],nanmean(grpTrgt_Lrnmean),':', 'LineWidth', 3, 'Color', 'k', 'MarkerFaceColor', colors(1,:),'MarkerEdgeColor', 'k');
p3 = plot([1,2,3],nanmean(grpTrgt_Lrnsd),':', 'LineWidth', 3, 'Color', 'k', 'MarkerFaceColor', colors(2,:),'MarkerEdgeColor', 'k');
for i = 1:length(grpSAI_Lrnmean)
   plot([1,2,3],grpSAI_Lrnmean(i,:),'Marker','none','Color',icolors(2,:),'LineWidth',0.2);
   p4 = plot([1,2,3],grpSAI_Lrnsd(i,:),'Marker','none','Color',icolors(2,:),'LineWidth',0.2);
end
p1 = plot([1,2,3],nanmean(grpSAI_Lrnmean),'Color', colors(1,:),'LineWidth', 3);
p2 = plot([1,2,3],nanmean(grpSAI_Lrnsd),'Color', colors(2,:),'LineWidth', 3);
xlim([0.5 3.5]); ylim([0 30]);
legend([p1,p2,p3,p4],{'Learning SAI mean', 'Learning SAI SD','Target mean and SD','Individuals'},...
    'Position',[0.91 0.17, 0.03, 0.03]);
legend('boxoff');
ylabel('SAI (%)'); xlabel('Conditions');
ax = gca; ax.XTick = 1:3;
ax.XTickLabels = {'Constant', 'LV', 'HV'};
title('Learning SAI Mean and SD');  

end