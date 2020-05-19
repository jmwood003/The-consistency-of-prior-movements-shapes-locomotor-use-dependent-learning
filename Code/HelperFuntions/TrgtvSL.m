function D = TrgtvSL(T)

Conditions = unique(T.Condition);
RSL_all = [];
LSL_all = [];
        
for c = 1:length(Conditions)
    
    currCond = Conditions{c};
    Condidx = find(ismember(T.Condition,currCond)==1);
    Subjs = unique(T.Subject_ID(Condidx));
    
    Rtrgt = [];
    Ltrgt = [];
    RSL = [];
    LSL = [];

    for s = 1:length(Subjs)
        
        currSubj = Subjs{s};
        Subjidx = find(ismember(T.Subject_ID,currSubj)==1 & ...
            ismember(T.Condition,currCond)==1 & ...
            ismember(T.Trial_name,'learning')==1);
        
        %Find the targets for each leg 
        Rtrgt = [Rtrgt; T.RSLtrgt(Subjidx)];
        Ltrgt = [Ltrgt; T.LSLtrgt(Subjidx)];
        
        %Index actual step length
        RSL = [RSL; T.Right_step_length(Subjidx)];
        LSL = [LSL; T.Left_step_length(Subjidx)];
        
    end
    
    RSL_all = [RSL_all; Rtrgt, RSL];
    LSL_all = [LSL_all; Ltrgt, LSL];
    D.(currCond).Right = [Rtrgt, RSL];
    D.(currCond).Left = [Ltrgt, LSL];

end

corrplot(RSL_all,'varNames',{'Rtrgt','RSL'});
corrplot(LSL_all,'varNames',{'Ltrgt','LSL'});

end