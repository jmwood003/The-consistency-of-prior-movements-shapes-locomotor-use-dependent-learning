function [D CorR CorL] = TrgtvSL(T)

Conditions = unique(T.Condition);
        
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
        
        [Rr Pvalr] = corrplot([RSL,Rtrgt],'varNames',{'RSL','Trgt'});
        [Rl Pvall] = corrplot([LSL,Ltrgt],'varNames',{'RSL','Trgt'});

        D.(currCond).(currSubj).Right = [Rr, Pvalr];
        D.(currCond).(currSubj).Left = [Rl, Pvall];
        
        if strcmp(currCond,'Uniform')==1
            CorR(s,:) = [Rr(2,1) Pvalr(2,1)];
            CorL(s,:) = [Rl(2,1) Pvall(2,1)];
        end

    end
    

end

end