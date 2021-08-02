function PlotEvents(T, ET,savestr)
%This function plots events against markers to ensure they have been
%selected and corrected accurately 

%Loop through each phase
phases = unique(ET.phase);
for phase_i = 1:length(phases)

    %Index current phase
    ETphaseidx = find(strcmp(phases{phase_i},ET.phase)==1);
    Tphaseidx = find(strcmp(phases{phase_i},T.phase)==1);

    %Index the Marker data
    RHLB = T.RHLBY_filt(Tphaseidx);
    LHLB = T.LHLBY_filt(Tphaseidx);
    
    %Index events
    %Right
    RHS_idx = ET.RHSpos_Frames(ETphaseidx);
    RHS_idx = RHS_idx(isnan(RHS_idx)==0);
    RTO_idx = ET.RTOpos_Frames(ETphaseidx);
    RTO_idx = RTO_idx(isnan(RTO_idx)==0);
    RHSV_idx = ET.RHSV_Frames_cor(ETphaseidx);
    RHSV_idx = RHSV_idx(isnan(RHSV_idx)==0);
    RTOV_idx = ET.RTOV_Frames_cor(ETphaseidx);
    RTOV_idx = RTOV_idx(isnan(RTOV_idx)==0);

    %Left
    LHS_idx = ET.LHSpos_Frames(ETphaseidx);
    LHS_idx = LHS_idx(isnan(LHS_idx)==0);
    LTO_idx = ET.LTOpos_Frames(ETphaseidx);
    LTO_idx = LTO_idx(isnan(LTO_idx)==0);
    LHSV_idx = ET.LHSV_Frames_cor(ETphaseidx);
    LHSV_idx = LHSV_idx(isnan(LHSV_idx)==0);
    LTOV_idx = ET.LTOV_Frames_cor(ETphaseidx);    
    LTOV_idx = LTOV_idx(isnan(LTOV_idx)==0);
    
    %Index live event detection
    MMe = ET.StrideChange_cor(ETphaseidx);
    MMe = MMe(isnan(MMe)==0);
   
    %Plot Events on Heel marker data
    EventsOnMarkers_fig = figure;
    %Right
    subplot(2,1,1); hold on
    plot(RHLB,'b');
    scatter(RHS_idx,RHLB(RHS_idx),'*','r');
    scatter(RTO_idx,RHLB(RTO_idx),'o','r');
    scatter(RHSV_idx,RHLB(RHSV_idx),'*','k');
    scatter(RTOV_idx,RHLB(RTOV_idx),'o','k');    
    title(['Right Heel Marker Y and Events - ', phases{phase_i}]);
    xlabel('Frames');
    ylabel('Meters');
    %Left  
    subplot(2,1,2); hold on
    plot(LHLB,'b');
    scatter(LHS_idx,LHLB(LHS_idx),'*','r');
    scatter(LTO_idx,LHLB(LTO_idx),'o','r');
    scatter(LHSV_idx,LHLB(LHSV_idx),'*','k');
    scatter(LTOV_idx,LHLB(LTOV_idx),'o','k');  
    scatter(MMe,LHLB(MMe),'d','m');           
    title(['Left Heel Marker Y and Events - ', phases{phase_i}]);
    xlabel('Frames');
    ylabel('Meters');    
    legend('Heel Marker','PosHS','PosTO','VelHS','VelTO','MMevent');
       
    %Save if desired
    if strcmp(savestr,'Yes')==1
        saveas(EventsOnMarkers_fig, [T.sessionID{1} '_EventsOnMarkers new.fig']);
    end
end
end
