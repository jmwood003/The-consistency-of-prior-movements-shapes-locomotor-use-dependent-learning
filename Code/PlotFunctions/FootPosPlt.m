function FootPosPlt(T, nbins, pltCondStr)

%Plots stride by stride data of foot position and limb asmmyery

%T = data table
%nbins = number of bins for plotting
%pltCondStr = string for the condition to plot (only plot 1 condition
%becuse more than 1 would be too much to plot)

%Some participants lost the hip marker during the learning phase, need to 
%Remove subjects with missing data:
%HV condition: UDLV_01, UDLV_02, UDLV_05
%LV condition UDLV_04, UDLV_16 
%Constant: none
if strcmp(pltCondStr,'Constant')==1
    T = T;
    disp('Constant Condition (N = 18)');
elseif strcmp(pltCondStr,'LV')==1
    Subjs = {'UDLV_01','UDLV_02','UDLV_03','UDLV_05', 'UDLV_06',...
        'UDLV_07','UDLV_08','UDLV_09','UDLV_10','UDLV_11', 'UDLV_12',...
        'UDLV_13', 'UDLV_14', 'UDLV_15', 'UDLV_17', 'UDLV_18'};
    T = T(ismember(T.SID,Subjs),:);
    disp(['LV Condition (N = ' num2str(length(Subjs)) ')']);    
elseif strcmp(pltCondStr,'HV')==1
    Subjs = {'UDLV_03','UDLV_04', 'UDLV_06',...
        'UDLV_07','UDLV_08','UDLV_09','UDLV_10','UDLV_11', 'UDLV_12',...
        'UDLV_13', 'UDLV_14', 'UDLV_15', 'UDLV_16', 'UDLV_17', 'UDLV_18'};
    T = T(ismember(T.SID,Subjs),:); 
    disp(['HV Condition (N = ' num2str(length(Subjs)) ')']);
end

%Find the shortest phase to truncate
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
allRT = []; allLT = []; 
allRL = []; allLL = []; 
allLA = []; allTA = [];

%Loop through conditions 
Cs = {'Constant','LV','HV'};
for c = 1:length(Cs)
    
    %Current condition and index
    CurrentC = Cs{c}; 
    Cidx = find(strcmp(CurrentC,T.Condition)==1);
    
    %loop through subjects
    Subjs = unique(T.SID(Cidx));
    for s = 1:length(Subjs)
        
        %Current subject
        CurrentS = Subjs{s};
        
        %Pre-allocate
        RTdata = [];         LTdata = []; 
        RLdata = [];         LLdata = []; 
        LAdata = [];         TAdata = []; 
        pidx = [];
        
        %Loop through phases
        Phases = {'baseline', 'learning', 'washout'};        
        for p = 1:length(Phases)
            
            %Current phase
            CurrentP = Phases{p};
            
            %Create index
            idx = find(strcmp(CurrentC,T.Condition)==1 & strcmp(CurrentS,T.SID)==1 & strcmp(CurrentP,T.phase)==1);
            trunc_idx = idx(1:short_phase(p));
            
            %Index variables of interest
            RTbins = Bin(T.Right_Trailing(trunc_idx),nbins,2,'mean');
            LTbins = Bin(T.Left_Trailing(trunc_idx),nbins,2,'mean');
            RLbins = Bin(T.Right_Leading(trunc_idx),nbins,2,'mean');
            LLbins = Bin(T.Left_Leading(trunc_idx),nbins,2,'mean');
            LAbins = Bin(T.LeadingAsym(trunc_idx),nbins,2,'mean');
            TAbins = Bin(T.TrailingAsym(trunc_idx),nbins,2,'mean');
            
            %Save data
            RTdata = [RTdata, RTbins.'];  LTdata = [LTdata, LTbins.'];
            RLdata = [RLdata, RLbins.'];   LLdata = [LLdata, LLbins.'];
            LAdata = [LAdata, LAbins.'];   TAdata = [TAdata, TAbins.'];
            
            %Make indexing variable for phase length
            pidx = [pidx, ones(1,length(RTbins))*p];

        end
        
        %Save data
        allRT = [allRT; RTdata];
        allLT = [allLT; LTdata];
        allRL = [allRL; RLdata];
        allLL = [allLL; LLdata];
        allLA = [allLA; LAdata];
        allTA = [allTA; TAdata];
        
        %Indexing variable for condition
        if strcmp(CurrentC,'Constant')==1
            idxvar = [idxvar; 1];
        elseif strcmp(CurrentC,'LV')==1
            idxvar = [idxvar; 2];
         elseif strcmp(CurrentC,'HV')==1
            idxvar = [idxvar; 3];   
        end
    end
end

%indexing variables for conditions
Constidx = find(idxvar==1);
LVidx  = find(idxvar==2);
HVidx = find(idxvar==3);
%and phase
Lrnidx = find(pidx==2);

%Set colors
c1 = jet(60);
bluec = c1(1:length(Constidx),:);
redc = c1(end-length(Constidx)+1:end,:);
mcolors = lines(3);

%Set up indices and colors depending on which condition being plotting
if strcmp(pltCondStr,'Constant')==1
    %Index
    CondIdx = Constidx;
    %Colors
    icolors = jet(60);
    meancolor = mcolors(1,:);
    indivcolors = icolors(1:length(CondIdx),:);
elseif strcmp(pltCondStr,'LV')==1  
    %Index 
    CondIdx = LVidx;
    %Colors 
    icolors = jet(60);
    meancolor = mcolors(2,:);
    indivcolors = icolors(end-length(CondIdx)+1:end,:);    
elseif strcmp(pltCondStr,'HV')==1    
    %Index
    CondIdx = HVidx;
    %Colors
    icolors = summer(length(CondIdx));
    meancolor = mcolors(3,:);
    indivcolors = icolors;   
end

%Plot learning left limb position
figure; subplot(2,6,[1 2 7 8]); hold on
for i = 1:length(CondIdx)
    plot(1:length(Lrnidx),allLL(CondIdx(i),Lrnidx),'Color',redc(i,:),'LineWidth',0.3);
    plot(1:length(Lrnidx),allLT(CondIdx(i),Lrnidx),'Color',bluec(i,:),'LineWidth',0.3);
end
plot(1:length(Lrnidx),mean(allLT(CondIdx,Lrnidx)), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',6);
plot(1:length(Lrnidx),mean(allLL(CondIdx,Lrnidx)), 'o', 'MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',6);
xlim([0 length(Lrnidx)]); ylim([-550 500]);
ylabel('mm'); xlabel(['Binned (bins = ', num2str(nbins) ') Learning Strides' ]);
text(10,200,'Left Leading Limb','Color','r');
text(10,-200,'Left Trailing Limb','Color','b');
title('Left Foot Position');

%Plot learning right limb position
subplot(2,6,[3 4 9 10]); hold on
for i = 1:length(CondIdx)
    plot(1:length(Lrnidx),allRT(CondIdx(i),Lrnidx),'Color',redc(i,:),'LineWidth',0.3);
    plot(1:length(Lrnidx),allRL(CondIdx(i),Lrnidx),'Color',bluec(i,:),'LineWidth',0.3);
end
plot(1:length(Lrnidx),mean(allRL(CondIdx,Lrnidx)), 'o', 'MarkerFaceColor','b','MarkerEdgeColor','k','MarkerSize',6);
plot(1:length(Lrnidx),mean(allRT(CondIdx,Lrnidx)), 'o', 'MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',6);
xlim([0 length(Lrnidx)]); ylim([-550 500]);
text(10,100,'Right Leading Limb','Color','b');
text(10,-300,'Right Trailing Limb','Color','r');
set(gca,'ytick',[]); title('Right Foot Position');

%plot leading limb asymmetry
subplot(2,6,[5 6]); hold on
space = 0; 
for phase_i = 1:length(Phases)
    current_epoc = Phases{phase_i};
    current_epoc_idx = find(pidx==phase_i);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)), -200, length(current_epoc_idx) 800], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    end
    hold on
    for i = 1:length(CondIdx)
        plot(current_epoc_idx+space, allLA(CondIdx(i),current_epoc_idx),'LineWidth',0.2,'Color',indivcolors(i,:));
    end
    plot(current_epoc_idx+space, nanmean(allLA(CondIdx,current_epoc_idx)), 'o', 'MarkerFaceColor',meancolor,'MarkerEdgeColor','k','MarkerSize',4);
    space = space + 1;
end
plot(1:(length(current_epoc_idx)+space),zeros(1,(length(current_epoc_idx)+space)),'k-');
ylim([-50 250]); xlim([0 current_epoc_idx(end)+space-50]);
title('Leading Asymmetry');
set(gca,'xtick',[]);
ylabel('mm');

%Plot trailing limb asymmetry
subplot(2,6,[11 12]); hold on
space = 0; 
for phase_i = 1:length(Phases)
    current_epoc = Phases{phase_i};
    current_epoc_idx = find(pidx==phase_i);
    if strcmp(current_epoc,'baseline')==1 || strcmp(current_epoc,'washout')==1
        rectangle('Position',[(current_epoc_idx(1)), -200, length(current_epoc_idx) 800], 'FaceColor',[0.8 0.8 0.8],'EdgeColor','none');
    end
    hold on
    for i = 1:length(CondIdx)
        plot(current_epoc_idx+space, allTA(CondIdx(i),current_epoc_idx),'LineWidth',0.2,'Color',indivcolors(i,:));
    end
    plot(current_epoc_idx+space, nanmean(allTA(CondIdx,current_epoc_idx)),  'o', 'MarkerFaceColor',meancolor,'MarkerEdgeColor','k','MarkerSize',3);
    space = space + 1;
end
plot(1:(length(current_epoc_idx)+space),zeros(1,(length(current_epoc_idx)+space)),'k-');
ylim([-50 250]); xlim([0 current_epoc_idx(end)+space-50]);
title('Trailing Asymmetry');
ylabel('mm');
xlabel(['Binned (bins = ', num2str(nbins) ') Strides' ]);

end