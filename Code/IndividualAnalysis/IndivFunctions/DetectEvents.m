function EventsTable = DetectEvents(T)
%This function detects heel strike and toe off events using the derivative
%of the marker as it crosses 0. Moving from negative to positive equals 
%toe off. Moving from postive to negative equals heel strike. Also cross 
%references this detection method with the peaks of the marker positions
%using 'findpeaks'.

%Set the find peaks variables
MinPeakProminence = 0.1; 
MinPeakDistance = 75; 
MaxPeakWidth = 100;

%Pre-allocate
Events = [];
phaseT = [];

%Loop through each phase
phases = unique(T.phase);
for phase_i = 1:length(phases)
    
    %Index current phase
    phaseidx = find(strcmp(phases{phase_i},T.phase)==1);
            
    %Index motion monitor live detected events (stride changes). Used as
    %the start/end points for event detection
    MMstri = find(diff(T.LeftCount(phaseidx))~=0)+1;
    endframe = MMstri(end);

    %Extract the current trial's marker data, heel markers and toe markers
    %Y direction only
    RHLB = T.RHLBY_filt(phaseidx);
    LHLB = T.LHLBY_filt(phaseidx);
    RMEL = T.RMELY_filt(phaseidx);
    LMEL = T.LMELY_filt(phaseidx);

    %Find the derivative of the markers
    samplerate = T.Sample_Rate(1);
    fs = 1/samplerate;
    RheelD = diff(RHLB)./fs;
    LheelD = diff(LHLB)./fs;
    RtoeD = diff(RMEL)./fs;
    LtoeD = diff(LMEL)./fs;
    
    %Filter the derivative to make it easier to detect the events
    filtRheelD = lowpassfilter(RheelD,6,4,100);
    filtLheelD = lowpassfilter(LheelD,6,4,100);
    filtRtoeD = lowpassfilter(RtoeD,6,4,100);
    filtLtoeD = lowpassfilter(LtoeD,6,4,100);
    
    %Find the heel strikes and toe offs by finding the local maxima and minima
    [~, RHSpos_idx] = findpeaks(RHLB,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, LHSpos_idx] = findpeaks(LHLB,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, RTOpos_idx] = findpeaks(-RMEL,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);
    [~, LTOpos_idx] = findpeaks(-LMEL,'MinPeakProminence',MinPeakProminence,'MinPeakDistance',MinPeakDistance,'MaxPeakWidth',MaxPeakWidth);

    %Detect Right heel strike
    RheelDchange = diff(filtRheelD>0);
    RHSV_idx = find(RheelDchange == -1); 
    RHSV_idx = RHSV_idx(RHSV_idx > RHSpos_idx(1)-5);
    RHSV_idx = RHSV_idx((RHSV_idx < endframe+5));
    
    %Detect Left heel strike
    LheelDchange = diff(filtLheelD>0);
    LHSV_idx = find(LheelDchange == -1);
    LHSV_idx = LHSV_idx(LHSV_idx > MMstri(1)-10);
    LHSV_idx = LHSV_idx((LHSV_idx < endframe+5));
    
    %Detect Right toe off
    RtoeDchange = diff(filtRtoeD>0);
    RTOV_idx = find(RtoeDchange == 1);
    RTOV_idx = RTOV_idx(RTOV_idx > RTOpos_idx(1)-5);
    RTOV_idx = RTOV_idx((RTOV_idx < endframe+5));
    
    %Detect Left toe off
    LtoeDchange = diff(filtLtoeD>0);
    LTOV_idx = find(LtoeDchange == 1);
    LTOV_idx = LTOV_idx(LTOV_idx > LTOpos_idx(1)-5);
    LTOV_idx = LTOV_idx((LTOV_idx < endframe+5)); 
    
    %Create new event table
    lengths = [length(RHSpos_idx),length(RTOpos_idx),length(LHSpos_idx),length(LTOpos_idx),...
        length(RHSV_idx),length(RTOV_idx),length(LHSV_idx),length(LTOV_idx),...
        length(MMstri)];
    longest = max(lengths);
    
    PhaseEvents = nan(max(lengths),9);
    PhaseEvents(1:length(RHSpos_idx),1) = RHSpos_idx;
    PhaseEvents(1:length(RTOpos_idx),2) = RTOpos_idx;
    PhaseEvents(1:length(LHSpos_idx),3) = LHSpos_idx;
    PhaseEvents(1:length(LTOpos_idx),4) = LTOpos_idx;
    PhaseEvents(1:length(RHSV_idx),5) = RHSV_idx;
    PhaseEvents(1:length(RTOV_idx),6) = RTOV_idx;
    PhaseEvents(1:length(LHSV_idx),7) = LHSV_idx;
    PhaseEvents(1:length(LTOV_idx),8) = LTOV_idx;
    PhaseEvents(1:length(MMstri),9) = MMstri;
    
    Events = [Events; PhaseEvents];
    phaseT = [phaseT; T(phaseidx(1:length(PhaseEvents)),1:8)];
end

%Save back into new table
TempT = array2table(Events,'VariableNames',{'RHSpos_Frames','RTOpos_Frames',...
    'LHSpos_Frames','LTOpos_Frames','RHSV_Frames','RTOV_Frames',...
    'LHSV_Frames','LTOV_Frames','StrideChange'});
EventsTable = [phaseT, TempT];

end

