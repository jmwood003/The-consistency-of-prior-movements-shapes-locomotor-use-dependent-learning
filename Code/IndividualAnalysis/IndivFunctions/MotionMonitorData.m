function newST = MotionMonitorData(T,ST)

%Index phases and put in the proper order
phases = unique(ST.phase);
if ismember('orientation',phases)==1
    phases = {'baseline','orientation','learning','washout'};
else
    phases = {'baseline','learning','washout'};
end

%Pre-allocate
Frame = [];
StrideCount = [];
TrgtLeftMM = [];
TrgtRightMM = [];
Trgt = [];
TrgtLeft = [];
TrgtRight = [];
TrgtSAI = [];
LeftSuccessSum = [];
RightSuccessSum = [];
LeftHit = [];
RightHit = [];
LSL_live = [];
RSL_live = [];
    
for p = 1:length(phases)
    
    %Index phase
    STphaseidx = find(strcmp(ST.phase,phases{p})==1);
    Tphase = T(find(strcmp(T.phase,phases{p})==1),:);
    
    %Index events
    LHSidx = ST.LHS_frames(STphaseidx);
    LHSidx = LHSidx(isnan(LHSidx)==0);
    StrChangeidx = ST.StrideChange(STphaseidx);
    StrChangeidx = StrChangeidx(isnan(StrChangeidx)==0);
    
    %Add nans for table
    addnans = nan(length(STphaseidx) - length(StrChangeidx),1);
    
    %Final check: make sure both events are consistent
    if sum(abs(LHSidx-StrChangeidx)>30)>0
        error('WARNING: SL indices are not lined up');
    end
        
    %Frame number and stride count
    Frame = [Frame; Tphase.Sample(StrChangeidx); addnans];
    StrideCount = [StrideCount; Tphase.LeftCount(StrChangeidx); addnans];
    
    %Target information
    if strcmp(phases{p},'baseline')==1 || strcmp(phases{p},'washout')==1 
        TrgtLeftMM = [TrgtLeftMM; zeros(length(STphaseidx),1)];
        TrgtRightMM = [TrgtRightMM; zeros(length(STphaseidx),1)];
        Trgt = [Trgt; zeros(length(STphaseidx),1)];
        TLeft = zeros(length(StrChangeidx),1);
        TRight = zeros(length(StrChangeidx),1);
        Tsai = zeros(length(StrChangeidx),1);
    else
        %Motion monitor targets
        TrgtLeftMM = [TrgtLeftMM; Tphase.TrgtLeft(StrChangeidx); addnans];
        TrgtRightMM = [TrgtRightMM; Tphase.TrgtRight(StrChangeidx); addnans]; %Keep the current index because this is the current target
        Trgt = [Trgt; Tphase.Trgt(StrChangeidx); addnans];
        
        %Calculate targets in terms of matlab baselines
        TLeft = ST.BslLSLmat(1) + (ST.BslLSLmat(1).*Tphase.Trgt(StrChangeidx));
        TRight = ST.BslRSLmat(1) - (ST.BslRSLmat(1).*Tphase.Trgt(StrChangeidx));
        
        %Calculate target SAI
        bslSAI = ((ST.BslLSLmat(1) - ST.BslRSLmat(1))/(ST.BslLSLmat(1) + ST.BslRSLmat(1)))*100;
        Tsai = (((TLeft - TRight)./(ST.BslLSLmat(1)+ST.BslRSLmat(1)))*100)-bslSAI;
    end
    
    %Save targets
    TrgtLeft = [TrgtLeft; TLeft; addnans];
    TrgtRight = [TrgtRight; TRight; addnans];
    TrgtSAI = [TrgtSAI; Tsai; addnans];
        
    %Target hit information
    LeftSuccessSum = [LeftSuccessSum; Tphase.LeftSuccessCount(StrChangeidx); addnans];
    RightSuccessSum = [RightSuccessSum; Tphase.RightSuccessCount(StrChangeidx); addnans];
    LeftHit = [LeftHit; 0; diff(Tphase.LeftSuccessCount(StrChangeidx))>0; addnans];
    RightHit = [RightHit; 0; diff(Tphase.RightSuccessCount(StrChangeidx))>0; addnans];
    
    %Step lengths from motion monitor
    if StrChangeidx(end)+3 > height(Tphase)
        StrChangeidx(end) = height(Tphase);
    end
    %Left
    LSL_live = [LSL_live; Tphase.LSL(StrChangeidx); addnans];
    
    %Right
    RSL = [];
    for lsl_i = 1:length(StrChangeidx)
        if lsl_i==length(StrChangeidx)
            nexti = StrChangeidx(end);
        else
            nexti = StrChangeidx(lsl_i+1);
        end
        RSL(lsl_i,1) = max(Tphase.RSL(StrChangeidx(lsl_i):nexti));
    end
    RSL_live = [RSL_live; RSL; addnans];
    
end

%Put back into table
ST.Frame = Frame;
ST.StrideCount = StrideCount;
ST.TrgtLeftMM = TrgtLeftMM;
ST.TrgtRightMM = TrgtRightMM;
ST.Trgt = Trgt;
ST.TrgtLeft = TrgtLeft;
ST.TrgtRight = TrgtRight;
ST.TrgtSAI = TrgtSAI;
ST.LeftSuccessSum = LeftSuccessSum;
ST.RightSuccessSum = RightSuccessSum;
ST.LeftHit = LeftHit;
ST.RightHit = RightHit;
ST.LSL_live = LSL_live;
ST.RSL_live = RSL_live;

%Seperate out subject ID to add to table
SessionID = ST.sessionID{1};
undidx = strfind(SessionID,'_');
cond = SessionID(undidx(1)+1:undidx(2));
subjID = [SessionID(1:undidx(1)) SessionID(undidx(2)+1:end)];

for i = 1:height(ST)
    SID{i,1} = subjID;
    Condition{i,1} = cond(1:end-1);
end

newST = [cell2table(SID), cell2table(Condition), ST];

end
