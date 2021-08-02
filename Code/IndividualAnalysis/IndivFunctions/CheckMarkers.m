function T = CheckMarkers(T,pltstr)

%This funciton makes sure the markers are not flipped between the right and
%left sides. Puts the corrected data back into the same table. 
%Option to plot to visually inspect data and correction

%Pre-allocate
RHLBt = []; RMALt = [];
RMELt = []; RKNLt = [];
RTRCt = [];    
LHLBt = []; LMALt = [];
LMELt = []; LMEMt = [];
LKNLt = []; LTRCt = [];

%Loop through each phsae
phases = unique(T.phase); 
for i = 1:length(phases);

    %Index current phase
    cphase = phases{i};
    phs_idx = find(strcmp(cphase,T.phase));
    
    %Organize the markers into 3d (when one marker flips, it flips in all
    %directions)
    RHLB = [T.RHLBX(phs_idx) T.RHLBY(phs_idx) T.RHLBZ(phs_idx)];
    RMAL = [T.RMALX(phs_idx) T.RMALY(phs_idx) T.RMALZ(phs_idx)];
    RMEL = [T.RMELX(phs_idx) T.RMELY(phs_idx) T.RMELZ(phs_idx)];
    RKNL = [T.RKNLX(phs_idx) T.RKNLY(phs_idx) T.RKNLZ(phs_idx)];
    RTRC = [T.RTRCX(phs_idx) T.RTRCY(phs_idx) T.RTRCZ(phs_idx)];     
    LHLB = [T.LHLBX(phs_idx) T.LHLBY(phs_idx) T.LHLBZ(phs_idx)];
    LMAL = [T.LMALX(phs_idx) T.LMALY(phs_idx) T.LMALZ(phs_idx)];
    LMEL = [T.LMELX(phs_idx) T.LMELY(phs_idx) T.LMELZ(phs_idx)];
    LMEM = [T.LMEMX(phs_idx) T.LMEMY(phs_idx) T.LMEMZ(phs_idx)];
    LKNL = [T.LKNLX(phs_idx) T.LKNLY(phs_idx) T.LKNLZ(phs_idx)];
    LTRC = [T.LTRCX(phs_idx) T.LTRCY(phs_idx) T.LTRCZ(phs_idx)];

    %Preallocate:
    RHLBnew = RHLB;     LHLBnew = LHLB; 
    RMALnew = RMAL;     LMALnew = LMAL; 
    RMELnew = RMEL;     LMELnew = LMEL; 
    RKNLnew = RKNL;     LKNLnew = LKNL; 
    RTRCnew = RTRC;     LTRCnew = LTRC; 
    LMEMnew = LMEM; 

    %----------------------------------------------------------------------
    %Z direction correcting (more superior should always be greater) - this
    %should be rare 
    [LTRCnew, LKNLnew] = CorrectMarkers(LTRC,LKNL,'Z',cphase,0.1,pltstr);    
    [RTRCnew, RKNLnew] = CorrectMarkers(RTRC,RKNL,'Z',cphase,0.1,pltstr);

    [LKNLnew, LMALnew] = CorrectMarkers(LKNLnew,LMAL,'Z',cphase,0,pltstr);    
    [RKNLnew, RMALnew] = CorrectMarkers(RKNLnew,RMAL,'Z',cphase,-0.1,pltstr);

    [LKNLnew, LHLBnew] = CorrectMarkers(LKNLnew,LHLB,'Z',cphase,-0.1,pltstr);    
    [RKNLnew, RHLBnew] = CorrectMarkers(RKNLnew,RHLB,'Z',cphase,-0.1,pltstr);

    %----------------------------------------------------------------------
    %X direction correcting (Right side position should always be more 
    %positive than the left
    [RTRCnew, LTRCnew] = CorrectMarkers(RTRCnew,LTRCnew,'X',cphase,0.1,pltstr);    

    [RKNLnew, LKNLnew] = CorrectMarkers(RKNLnew,LKNLnew,'X',cphase,0.1,pltstr);

    [RMELnew,LMELnew] = CorrectMarkers(RMEL,LMEL,'X',cphase,0.1,pltstr);

    [RMALnew,LMALnew] = CorrectMarkers(RMALnew,LMALnew,'X',cphase,0.1,pltstr);

    [RHLBnew,LHLBnew] = CorrectMarkers(RHLBnew,LHLBnew,'X',cphase,-0.05,pltstr);
 
    RHLBt = [RHLBt; RHLBnew];
    RMALt = [RMALt; RMALnew];
    RMELt = [RMELt; RMELnew];
    RKNLt = [RKNLt; RKNLnew];
    RTRCt = [RTRCt; RTRCnew];    
    LHLBt = [LHLBt; LHLBnew];
    LMALt = [LMALt; LMALnew];
    LMELt = [LMELt; LMELnew];
    LMEMt = [LMEMt; LMEMnew];
    LKNLt = [LKNLt; LKNLnew];
    LTRCt = [LTRCt; LTRCnew];
 
end

%Put back into the table
T.RHLBX_cor = RHLBt(:,1); T.RHLBY_cor = RHLBt(:,2); T.RHLBZ_cor = RHLBt(:,3);
T.RMALX_cor = RMALt(:,1); T.RMALY_cor = RMALt(:,2); T.RMALZ_cor = RMALt(:,3);
T.RMELX_cor = RMELt(:,1); T.RMELY_cor = RMELt(:,2); T.RMELZ_cor = RMELt(:,3);
T.RKNLX_cor = RKNLt(:,1); T.RKNLY_cor = RKNLt(:,2); T.RKNLZ_cor = RKNLt(:,3);
T.RTRCX_cor = RTRCt(:,1); T.RTRCY_cor = RTRCt(:,2); T.RTRCZ_cor = RTRCt(:,3);     
T.LHLBX_cor = LHLBt(:,1); T.LHLBY_cor = LHLBt(:,2); T.LHLBZ_cor = LHLBt(:,3);
T.LMALX_cor = LMALt(:,1); T.LMALY_cor = LMALt(:,2); T.LMALZ_cor = LMALt(:,3);
T.LMELX_cor = LMELt(:,1); T.LMELY_cor = LMELt(:,2); T.LMELZ_cor = LMELt(:,3);
T.LMEMX_cor = LMEMt(:,1); T.LMEMY_cor = LMEMt(:,2); T.LMEMZ_cor = LMEMt(:,3);
T.LKNLX_cor = LKNLt(:,1); T.LKNLY_cor = LKNLt(:,2); T.LKNLZ_cor = LKNLt(:,3);
T.LTRCX_cor = LTRCt(:,1); T.LTRCY_cor = LTRCt(:,2); T.LTRCZ_cor = LTRCt(:,3);    

end
