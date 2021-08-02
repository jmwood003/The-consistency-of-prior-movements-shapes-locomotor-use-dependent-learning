function newT = GaitAnalysis(T, ET)

%This function performs gait analysis calculations

%The following gait analyses are performed:
%Spatial
%Right and left step lengths
%Right and left stride lengths
%Temporal
%Right and left stance times
%Right and left step times
%Right and left swing times
%Right and left stride times
%Right and left double support times

%The code finds which heel strike was first then starts with the next stride
%because the first heel strike is a smaller step becase the treadmill is
%starting

%Index the phases and get them in the correct order
phases = unique(ET.phase);
if ismember('orientation',phases)==1
    phases = {'baseline','orientation','learning','washout'};
else
    phases = {'baseline','learning','washout'};
end

newT = table;
%Loop through each trial
for phase_i = 1:length(phases)
    
    %Index current phase
    ETphaseidx = find(strcmp(phases{phase_i},ET.phase)==1);
    Tphaseidx = find(strcmp(phases{phase_i},T.phase)==1);

    %Get the event frames for each events and remove nans
    RHS_frames = ET.RHSV_Frames_cor(ETphaseidx);
    RHS_frames = RHS_frames(isnan(RHS_frames)==0);
    RTO_frames = ET.RTOV_Frames_cor(ETphaseidx);
    RTO_frames = RTO_frames(isnan(RTO_frames)==0);
    LHS_frames = ET.LHSV_Frames_cor(ETphaseidx);
    LHS_frames = LHS_frames(isnan(LHS_frames)==0);    
    LTO_frames = ET.LTOV_Frames_cor(ETphaseidx);
    LTO_frames = LTO_frames(isnan(LTO_frames)==0);
    StrideChange = ET.StrideChange_cor(ETphaseidx);
    StrideChange = StrideChange(isnan(StrideChange)==0);

    %Find which foot took the first step
    if RHS_frames(1) < LHS_frames(1)
        %This means the right foot moved first so make the LEFT
        %heel strike the first event (this prevents a small erroneous first step)
        RHS_frames = RHS_frames(2:end);
        LTO_frames = LTO_frames(LTO_frames > LHS_frames(1));
        RTO_frames = RTO_frames(RTO_frames > LHS_frames(1));  
        Radd = 1; Ladd = 0;    
    elseif LHS_frames(1) < RHS_frames(1)
        LHS_frames = LHS_frames(2:end);
        StrideChange = StrideChange(2:end);
        LTO_frames = LTO_frames(LTO_frames > RHS_frames(1));
        RTO_frames = RTO_frames(RTO_frames > RHS_frames(1)); 
        Radd = 0; Ladd = 1;
    end
   
    %Get the right and left heel marker position for each frame of data
    %All marker data
    All_markers_Right = T.RHLBY_filt(Tphaseidx);
    All_markers_Left = T.LHLBY_filt(Tphaseidx);
    %Right heel marker
    RHS_RHLB = All_markers_Right(RHS_frames);
    RTO_RHLB = All_markers_Right(RTO_frames);
    LHS_RHLB = All_markers_Right(LHS_frames);
    LTO_RHLB = All_markers_Right(LTO_frames);
    %Left heel marker
    RHS_LHLB = All_markers_Left(RHS_frames);
    RTO_LHLB = All_markers_Left(RTO_frames);
    LHS_LHLB = All_markers_Left(LHS_frames);
    LTO_LHLB = All_markers_Left(LTO_frames);
    
    %Index hip markers
    All_hipmkrs_Right = T.RTRCY_filt(Tphaseidx);
    All_hipmkrs_Left = T.LTRCY_filt(Tphaseidx);
    Lhip_LHS = All_hipmkrs_Left(LHS_frames);
    Lhip_LTO = All_hipmkrs_Left(LTO_frames);
    Rhip_RHS = All_hipmkrs_Right(RHS_frames);
    Rhip_RTO = All_hipmkrs_Right(RTO_frames);
    %Index ankle markers
    All_ankmkrs_Right = T.RMALY_filt(Tphaseidx);
    All_ankmkrs_Left = T.LMALY_filt(Tphaseidx);    
    Lank_LHS = All_ankmkrs_Left(LHS_frames);
    Lank_LTO = All_ankmkrs_Left(LTO_frames);
    Rank_RHS = All_ankmkrs_Right(RHS_frames);
    Rank_RTO = All_ankmkrs_Right(RTO_frames);  
    
    %Index sample rate to calculate time variables
    samprate = ET.Sample_Rate(1);
    %--------------------------------------------------------------------------
    
    %Make gait parameter calculations
    %Note: motion monitor and vicon records marker positions in different 
    %units (Vicon: mm, Motion monitor: meters) so we dont have to divide by
    %anything

    %-------------------
    %Step length (meters) 
    Right_step_length = nan(length(ETphaseidx),1);
    Left_step_length = nan(length(ETphaseidx),1);
    for RHS_frames_i = 1:length(RHS_frames)
        Right_step_length(RHS_frames_i,1) = (RHS_RHLB(RHS_frames_i) - All_markers_Left(RHS_frames(RHS_frames_i)));
    end
    %position difference between RHLB of RHS of the next stride and the position of LHLB at the same time
    for LHS_frames_i = 1:length(LHS_frames)
        Left_step_length(LHS_frames_i,1) = (LHS_LHLB(LHS_frames_i) - All_markers_Right(LHS_frames(LHS_frames_i))); 
    end 
    %position difference between LHLB of LHS and the position of the RHLB at the same time

    %-------------------
    %Stride length (meters)
    %the distance traveled between consecutive RHSs calculated by vt, and 
    %adjusted by the distance between RHS positions to account for movement on the treadmill 
    Right_stride_length = nan(length(ETphaseidx),1);
    Left_stride_length = nan(length(ETphaseidx),1);
    for RHS_frames_i = 1:(length(RHS_frames)-1)
        RHSfuture = RHS_frames(RHS_frames_i) + 10;
        RTOfuture = RTO_frames(RHS_frames_i+Radd) - 10; 
        if RTOfuture > RHSfuture
            position_differenceR = (All_markers_Right(RHSfuture) - All_markers_Right(RTOfuture));
            MetersperFrmR = position_differenceR/((RTOfuture-RHSfuture));
            Right_stride_length(RHS_frames_i,1) = (RHS_RHLB(RHS_frames_i+1)-RHS_RHLB(RHS_frames_i)) + MetersperFrmR*(RHS_frames(RHS_frames_i+1)-RHS_frames(RHS_frames_i));
        else
            disp('frame number not correct Right stride length')
            disp([phases{phase_i} ', stride ' num2str(RHS_frames_i)]) 
        end
    end
    for LHS_frames_i = 1:(length(LHS_frames)-1)    
        LHSnext = LHS_frames(LHS_frames_i) + 10;
        LTOnext = LTO_frames(LHS_frames_i+Ladd) - 10; 
        if LTOnext > LHSnext
            position_differenceL = (All_markers_Left(LHSnext) - All_markers_Left(LTOnext));
            walking_speedL = position_differenceL/((LTOnext-LHSnext));
            Left_stride_length(LHS_frames_i,1) = (LHS_LHLB(LHS_frames_i+1)-LHS_LHLB(LHS_frames_i)) + walking_speedL*(LHS_frames(LHS_frames_i+1)-LHS_frames(LHS_frames_i));
        else
            disp('frame number not correct Left stride length')
            disp([phases{phase_i} ', stride ' num2str(LHS_frames_i)]) 
        end
    end
    %-------------------
    
    %Stance time (seconds)
    Right_stance_time = nan(length(ETphaseidx),1);
    Left_stance_time = nan(length(ETphaseidx),1);    
    %time difference between toe off of the next stride and heel strike 
    for RTO_frames_i = 1:(length(RTO_frames)-Radd)
        Right_stance_time(RTO_frames_i,1) = (RTO_frames(RTO_frames_i+Radd) - RHS_frames(RTO_frames_i))/samprate;
    end
    for LTO_frames_i = 1:(length(LTO_frames)-Ladd)
        Left_stance_time(LTO_frames_i,1) = (LTO_frames(LTO_frames_i+Ladd) - LHS_frames(LTO_frames_i))/samprate;  
    end 
    %-------------------

    %Step time (seconds)
    Right_step_time = nan(length(ETphaseidx),1);
    Left_step_time = nan(length(ETphaseidx),1);
    %time difference between left and right heel strike of the same stride
    for RHS_frames_i = 1:(length(RHS_frames)-Ladd)
        Right_step_time(RHS_frames_i,1) = (RHS_frames(RHS_frames_i+Ladd) - LHS_frames(RHS_frames_i))/samprate; 
    end
    for LHS_frames_i = 1:(length(LHS_frames)-Radd)
        Left_step_time(LHS_frames_i,1) = (LHS_frames(LHS_frames_i+Radd) - RHS_frames(LHS_frames_i))/samprate; 
    end   
    %-------------------

    %Swing time (seconds)
    Right_swing_time = nan(length(ETphaseidx),1);
    Left_swing_time = nan(length(ETphaseidx),1);
    %time difference between heel strike and toe off of the same stride
    for RHS_frames_i = 1:(length(RHS_frames)-Ladd)
        Right_swing_time(RHS_frames_i,1) = (RHS_frames(RHS_frames_i+Ladd) - RTO_frames(RHS_frames_i))/samprate; 
    end
    for LHS_frames_i = 1:(length(LHS_frames)-Radd)
        Left_swing_time(LHS_frames_i,1) = (LHS_frames(LHS_frames_i+Radd) - LTO_frames(LHS_frames_i))/samprate; 
    end
    %-------------------

    %Stride time (seconds)
    Right_stride_time = nan(length(ETphaseidx),1);
    Left_stride_time = nan(length(ETphaseidx),1);
    %time difference between consecutive heel strikes 
    for RHS_frames_i = 1:(length(RHS_frames)-1)
        Right_stride_time(RHS_frames_i,1) = (RHS_frames(RHS_frames_i+1) - RHS_frames(RHS_frames_i))/samprate;
    end
    for LHS_frames_i = 1:(length(LHS_frames)-1)
        Left_stride_time(LHS_frames_i,1) = (LHS_frames(LHS_frames_i+1) - LHS_frames(LHS_frames_i))/samprate;   
    end 
    %-------------------

    %Double Support time (seconds)
    Right_DblSupport_time = nan(length(ETphaseidx),1);
    Left_DblSupport_time = nan(length(ETphaseidx),1);
    %time difference between RTO and LHS in the same stride,  divided by the sampling rate 
    for RTO_frames_i = 1:(length(RTO_frames)-1)
        Right_DblSupport_time(RTO_frames_i,1) = (LTO_frames(RTO_frames_i) - RHS_frames(RTO_frames_i))/samprate;  
    end
    for LTO_frames_i = 1:(length(LTO_frames)-1)
        Left_DblSupport_time(LTO_frames_i,1) = (RTO_frames(LTO_frames_i) - LHS_frames(LTO_frames_i))/samprate;
    end
    %-------------------
    
    %Leading and trailing distance (mm) 
    Right_Trailing = nan(length(ETphaseidx),1);   
    Left_Trailing = nan(length(ETphaseidx),1);
    Right_Leading = nan(length(ETphaseidx),1);    
    Left_Leading = nan(length(ETphaseidx),1);
    %different between troch and ankle markers at heel strike and toe off,
    %respectively
    Right_Leading(1:length(Rank_RHS),1) = (Rank_RHS - Rhip_RHS)*1000;
    Right_Trailing(1:length(Rhip_RTO),1) = (Rank_RTO - Rhip_RTO)*1000;
    Left_Leading(1:length(Lank_LHS),1) = (Lank_LHS - Lhip_LHS)*1000;
    Left_Trailing(1:length(Lhip_LTO),1) = (Lank_LTO - Lhip_LTO)*1000;

    %-------------------
    
    %Put all parameters back into a table
    %Make events the same length to fit into table
    if length(ETphaseidx) ~= length(LHS_frames)
        LHS_frames = [LHS_frames; nan(length(ETphaseidx)-length(LHS_frames),1)];
        StrideChange = [StrideChange; nan(length(ETphaseidx)-length(StrideChange),1)];
    end
    if length(ETphaseidx) ~= length(LTO_frames)
        LTO_frames = [LTO_frames; nan(length(ETphaseidx)-length(LTO_frames),1)];
    end
    if length(ETphaseidx) ~= length(RHS_frames)
        RHS_frames = [RHS_frames; nan(length(ETphaseidx)-length(RHS_frames),1)];
    end
    if length(ETphaseidx) ~= length(RTO_frames)
        RTO_frames = [RTO_frames; nan(length(ETphaseidx)-length(RTO_frames),1)];
    end   
    
    newT = [newT; ET(ETphaseidx,1:8), array2table(LHS_frames),...
        array2table(LTO_frames), array2table(RHS_frames), array2table(RTO_frames), array2table(StrideChange)...
        array2table(Right_step_length), array2table(Left_step_length), array2table(Right_stride_length),...
        array2table(Left_stride_length), array2table(Right_stance_time), array2table(Left_stance_time),...
        array2table(Right_step_time), array2table(Left_step_time), array2table(Right_swing_time),...
        array2table(Left_swing_time), array2table(Right_stride_time), array2table(Left_stride_time),...
        array2table(Right_DblSupport_time), array2table(Left_DblSupport_time), array2table(Right_Trailing),...
        array2table(Right_Leading), array2table(Left_Trailing), array2table(Left_Leading)];

end 
end


