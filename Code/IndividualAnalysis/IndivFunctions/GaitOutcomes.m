function ST = GaitOutcomes(ST)

%This function makes the calculations for the primary outcome measures
%Calculations include:
%Step Asymmetry Index (SAI)
%Baseline Corrected Step length (Right and left)
%Baseline Corrected SAI
%Step lenght differnece

%Get the phases and put them in the proper order
phases = unique(ST.phase);
if ismember('orientation',phases)==1
    phases = {'baseline','orientation','learning','washout'};
else
    phases = {'baseline','learning','washout'};
end

%Pre-allocate
SAI = [];
SL_diff = [];
LeadingAsym = [];
TrailingAsym = [];  
SAI2 = [];

%Loop through each phase
for phase_i = 1:length(phases) 
    
    %Index phase
    phaseidx = find(strcmp(phases{phase_i},ST.phase)==1);
    
    %Index the right and left step lenghts for the current trial
    Current_RSL = ST.Right_step_length(phaseidx);
    Current_LSL = ST.Left_step_length(phaseidx);
    
    %Index leading and trailing asymmetry
    Rlead = ST.Right_Leading(phaseidx);
    Llead = ST.Left_Leading(phaseidx);
    Rtrail = ST.Right_Trailing(phaseidx);
    Ltrail = ST.Left_Trailing(phaseidx);    
     
    %Loop through each stride to calculate step asymmetry index and step
    %difference
    Step_asymmetry_idx = nan(length(phaseidx),1);
    Step_length_diff = nan(length(phaseidx),1);
    for stride_i = 1:length(Current_LSL)-1
        Step_asymmetry_idx(stride_i,1) = ((Current_LSL(stride_i) - Current_RSL(stride_i))./(Current_LSL(stride_i) + Current_RSL(stride_i)))*100;
        Step_length_diff(stride_i,1) = (Current_LSL(stride_i) - Current_RSL(stride_i));
    end
    
    %Leading asymmetry
    Leading_asym = nan(length(phaseidx),1);
    Trailing_asym = nan(length(phaseidx),1);
    for Lead_i = 1:(length(Llead)-1)
        Leading_asym(Lead_i,1) = Llead(Lead_i) - Rlead(Lead_i);
    end
    %Trailing asymmetry
    for Trail_i = 1:(length(Ltrail)-1)
        Trailing_asym(Trail_i,1) = Ltrail(Trail_i) - Rtrail(Trail_i);
    end
            
    %Save
    SAI = [SAI; Step_asymmetry_idx];
    SL_diff = [SL_diff; Step_length_diff];
    LeadingAsym = [LeadingAsym; Leading_asym];
    TrailingAsym = [TrailingAsym; Trailing_asym];    

    %Calculate Baseline step asymmetry and step lengths based on the above
    %index
    if strcmp(phases{phase_i},'baseline')==1
        %Remove nans and calculate baselines
        SAIbsl = SAI(isnan(SAI)==0);
        SAIbsl = mean(SAIbsl(end-49:end));
        RSLbsl = Current_RSL(isnan(Current_RSL)==0);
        RSLbsl = mean(RSLbsl(end-49:end));
        LSLbsl = Current_LSL(isnan(Current_LSL)==0);
        LSLbsl = mean(LSLbsl(end-49:end));
        
        %Save baselines back into table
        ST.BslSAImat = ones(height(ST),1)*SAIbsl;
        ST.BslRSLmat = ones(height(ST),1)*RSLbsl;
        ST.BslLSLmat = ones(height(ST),1)*LSLbsl;
        
        %Create baseline corrected right and left step lengths 
        ST.BslCor_RSL = ST.Right_step_length - RSLbsl;
        ST.BslCor_LSL = ST.Left_step_length - LSLbsl;
    end

    %Calculate second SAI measure that is normalized by baseline step
    %length
    Step_asymmetry_idx2 = nan(length(phaseidx),1);
    for stride_i = 1:length(Current_LSL)-1
        Step_asymmetry_idx2(stride_i,1) = ((Current_LSL(stride_i) - Current_RSL(stride_i))./(LSLbsl + RSLbsl))*100;
    end
    SAI2 = [SAI2; Step_asymmetry_idx2];

end

ST.SAI = SAI;
ST.BslCor_SAI = SAI - SAIbsl;
ST.SL_diff = SL_diff;
ST.LeadingAsym = LeadingAsym;
ST.TrailingAsym = TrailingAsym;    
ST.BslCor_SAI2 = SAI2 - SAIbsl;

end

