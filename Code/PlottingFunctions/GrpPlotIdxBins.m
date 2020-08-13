function Struct = GrpPlotIdxBins( T,metric,Groups,nbins )
%Jonathan Wood
%8/20/19
%--------------------------------------------------------------------------
%General:
%This function combines groups into a structure of a specified metric and
%plots the group averaged data
%--------------------------------------------------------------------------
%Input:
%Experiment table

%Metric: the specific outcome measure desired. This must be a string in the
%exact same format as is in the table. 
%For example: 'Step_asymmetry_idx'

%Groups: A cell array of strings or a string which are the desired groups to
%be plotted and analyzed. 
%For example: Groups = {'SMA','UDP','UDP_DRR'};

%--------------------------------------------------------------------------
%Output: 
%Output is a structure with fields for each group, each group name is a 
%structure with fieldnames which are the trials, within each trial is an
%array with rows which are subjects and columns are strides for the
%specified trial. There is also an extra array for all the strides of the
%experiment in one array. 
%Also plots a shaded error bar plot
%--------------------------------------------------------------------------
%This function is called in the 'Group_analysis' script
%--------------------------------------------------------------------------

%Group stride by stride plots
T=T;
%Pre-allocate an array of nans for the all strides array
phase_length = nan(length(Groups),length(unique(T.Trial_name)));

%Loop through each group
for grp_i = 1:length(Groups)
    current_grp = Groups{grp_i}; %Index the current group
    
    %Replace any strings with '_' into spaces for plotting later
    Legend_str = Groups;
    if isempty(strfind(current_grp,'_'))==0
        Legend_str{grp_i} = strrep(current_grp,'_',' ');
    end
    
    %Index all the phases 
    grp_idx = find(strcmp(T.Condition,current_grp)==1);
    Phases = unique(T.Trial_name(grp_idx),'stable');
    All_strides = []; %Pre-allocate

    %Loop through each phase
    for phase_i = 1:length(Phases)
        current_phase_nm = Phases{phase_i}; %Current phase
        %Index the current phase from the table
        phase_idx = find(strcmp(T.Condition,current_grp)==1 & strcmp(T.Trial_name,current_phase_nm));
        Subjects = unique(T.Subject_ID(phase_idx)); %Find all the subjects
        Grp_outcome_array = []; %Pre-allocate
        %Add space for the all strides array
        space = nan(100,length(Subjects));
        
        %Loop through each subjects
        for subj_i = 1:length(Subjects)
            current_subj = Subjects{subj_i}; %index current subject
            %index current phase
            phase_idx = find(strcmp(T.Condition,current_grp)==1 & strcmp(T.Trial_name,current_phase_nm) & strcmp(T.Subject_ID,current_subj));
            current_data = T.(metric)(phase_idx);
            %Remove nans
            current_data = current_data(~isnan(current_data));
            
            binned_data = Bin(current_data,nbins,2,'mean');
            
            %Truncate each phase from prior groups
            if grp_i > 1
                shortest_phase = min(phase_length(:,phase_i),[],'omitnan');
                if length(binned_data) > shortest_phase    
                    binned_data = binned_data(1:shortest_phase); 
                elseif length(binned_data) < shortest_phase && grp_i == 2
                    if isfield(Struct, 'SMA')==1
                        Struct.SMA.(current_phase_nm) = Struct.SMA.(current_phase_nm)(:,1:length(binned_data));
                        phase_length(:,phase_i) = length(binned_data);
                    elseif isfield(Struct, 'UDP')==1
                        Struct.UDP.(current_phase_nm) = Struct.UDP.(current_phase_nm)(:,1:length(binned_data));                        
                        phase_length(:,phase_i) = length(binned_data);
                    end
                elseif length(binned_data) < shortest_phase && grp_i == 3
                    Struct.SMA.(current_phase_nm) = Struct.SMA.(current_phase_nm)(:,1:length(binned_data));                    
                    Struct.UDP.(current_phase_nm) = Struct.UDP.(current_phase_nm)(:,1:length(binned_data));
                    phase_length(:,phase_i) = length(binned_data);
                end
            end
            
            %Truncates the data for current group
            if length(binned_data) < size(Grp_outcome_array,1) && isempty(Grp_outcome_array)==0 %Truncates
            	Grp_outcome_array = Grp_outcome_array(1:length(binned_data),:);
                Grp_outcome_array = [Grp_outcome_array, binned_data];
            elseif length(binned_data) > size(Grp_outcome_array,1) && isempty(Grp_outcome_array)==0     
                binned_data = binned_data(1:size(Grp_outcome_array,1),:);
                Grp_outcome_array = [Grp_outcome_array, binned_data];
            else
                Grp_outcome_array = [Grp_outcome_array, binned_data];
            end
        end
        
        phase_length(grp_i,phase_i) = size(Grp_outcome_array,1);
        All_strides = [All_strides; Grp_outcome_array; space];
        G.(current_phase_nm) = Grp_outcome_array.';

    end
    
        current_grpnew = 'str100';
    
    %Save to struct
    Struct.(current_grpnew) = G;
    Struct.(current_grpnew).All = All_strides.';
    
end

%Combine all truncated phases
for grp_i = 1:length(Groups)
    All_trunk = [];
    current_grp = Groups{grp_i};
    space = nan(size(Struct.(current_grpnew).baseline,1),100);
    for ph_i = 1:length(Phases)
        current_phase_nm = Phases{ph_i};
        current_phase = Struct.(current_grpnew).(current_phase_nm);
        All_trunk = [All_trunk, current_phase, space];
    end
    Struct.(current_grpnew).All_trunk = All_trunk;
end


%Colors
%Custom colors: SMA:red UDP:blue DRR:black
grpclrs = [1,0,0;0,0,1;0,0,0];
%Experiment 2 custom colors: UDP:blue DRR:black
% grpclrs = [0,0,1;0,0,0];

metric_str = strrep(metric,'_',' ');

%Group plot
figure; hold on
for grps_i = 1:length(Groups)
    current_grp = Groups{grps_i};
    start= 1;
    for phase_i = 1:length(Phases)
        current_phase_name = Phases{phase_i};
        current_data = Struct.(current_grpnew).(current_phase_name);
        x = start:start+size(current_data,2)-1;
        current_color = grpclrs(grps_i,:);
        plotlines(grps_i,phase_i) = shadedErrorBar(x,nanmean(current_data),SEM(current_data,1),'lineprops',{'Color',current_color},'transparent',1);
        start = x(end)+(100/nbins);
    end
end
plotmean = mean(mean(Struct.str100.baseline(:,end-round(49/nbins):end)));
plot(1:start,ones(1,start)*plotmean,'k-');
plot(1:start,ones(start)*11,'r--');
legend([plotlines(1:length(Groups),1).mainLine],...
    Legend_str);
legend('boxoff');
title(['Group ' metric_str]);
xlabel('Strides');
ylabel(metric_str);
saveas(gcf,['GroupBin_' metric '.fig']);

end
