function extractpilotdata

%Extracted and trim pilot data subjects then saved into an array so we dont
%need this anymore. 
load('UDPVT.mat')
T = UDPVT;

% T(strcmp('VarTest_Unif_04',T.Subject_ID)==1,:) = [];
T(strcmp('orientation',T.Trial_name)==1,:) = [];

SID = unique(T.Subject_ID);
Trls = unique(T.Trial_name);
trllen = [];
for i = 1:length(SID)
    if strcmp('VarTest_Unif_04',SID{i})==1
        trllen(i,:) = nan(1,3);  
        continue
    end
    for j = 1:length(Trls)
        Ctrli = T.Baseline_corrected_SAI(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
        Ctrli(isnan(Ctrli)==1) = [];
        trllen(i,j) = length(Ctrli);     
    end
end

mintrls = min(trllen,[],1);
phases = [ones(1,mintrls(1)), ones(1,mintrls(2))*2, ones(1,mintrls(3))*3];

Pilot_data = [];
Trgts = [];
for i = 1:length(SID)
    CsubjSAI = [];
    CsubjTrgt = [];

    for j = 1:length(Trls)
        
        if strcmp('VarTest_Unif_04',SID{i})==1
            Ctrl = T.Baseline_corrected_SAI(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
            Ctrl(isnan(Ctrl)==1) = [];
            
            trgt = T.Trgt(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
            trgt(isnan(trgt)==1) = [];

            if strcmp('baseline',Trls{j})==1
                CsubjSAI = [CsubjSAI, Ctrl(1:mintrls(j))'];
                CsubjTrgt = [CsubjTrgt, trgt(1:mintrls(j))'];
            elseif strcmp('learning',Trls{j})==1
                CsubjSAI = [CsubjSAI, Ctrl(1:303)', nan(1,178)];
                CsubjTrgt = [CsubjTrgt, trgt(1:mintrls(j))'];
            elseif strcmp('washout',Trls{j})==1
                CsubjSAI = [CsubjSAI, nan(1,mintrls(3))];
                CsubjTrgt = [CsubjTrgt, trgt', nan(1,240)];
            end
       
            
        else
            Ctrl = T.Baseline_corrected_SAI(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
            Ctrl(isnan(Ctrl)==1) = [];
            CsubjSAI = [CsubjSAI, Ctrl(1:mintrls(j))'];

            trgt = T.Trgt(strcmp(T.Trial_name,Trls{j})==1 & strcmp(SID{i},T.Subject_ID)==1);
            trgt(isnan(trgt)==1) = [];
            CsubjTrgt = [CsubjTrgt, trgt(1:mintrls(j))'];
        end
    end
    
    Pilot_data = [Pilot_data; CsubjSAI];
    Trgts = [Trgts; CsubjTrgt];

end
save('PilotdataAll.mat','Pilot_data','Trgts','phases');

end