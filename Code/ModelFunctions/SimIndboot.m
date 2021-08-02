function SimIndboot(SUParams,ABParams,N)

%Simulate both models for all three conditions 

%SUParams = parameters for the SU model
%ABParams = parameters for the AB model
%N = number of bootstrapped samples to simulate 

%Set experiment parameters
reprng = [1 5]; %Frequency of target change
LrnStrides = 500; %Number of learning strides
Tmu = 22; %mean of the learning targets

%Number of strides to account for in the washout rate calculation
numstr = 50;

for i = 1:N
    
    i
    
    %Bootstrap
    [~, ABidx] = bootstrp(1,@mean,ABParams);
    [~, SUidx] = bootstrp(1,@mean,SUParams);

    %Create the targets for each condition
    tC = Ctargets(LrnStrides,Tmu,1);
    tLV = LVtargets(LrnStrides,Tmu,reprng,1); 
    tHV = HVtargets(LrnStrides,reprng,1);
    
    %Set the parameters from the bootstrap sample
    pB = ABParams(ABidx,:);
    pT = SUParams(SUidx,:);    
 
    for j = 1:size(pB,1)
        %Simulate
        %Constant
        [T_map] = ABsim(pB(j,:),tC);
        [x,w,s] = SUsim(pT(j,:),tC);
        tmapc(j,:) = T_map;
        xc(j,:) = x;  
        wc(j,:) = w;
        sc(j,:) = s;
        %Low variability
        [T_map] = ABsim(pB(j,:),tLV);
        [x,w,s] = SUsim(pT(j,:),tLV);
        tmapLV(j,:) = T_map;
        xLV(j,:) = x;  
        wLV(j,:) = w;
        sLV(j,:) = s;        
        %High Variability
        [T_map] = ABsim(pB(j,:),tHV);
        [x,w,s] = SUsim(pT(j,:),tHV);
        tmapHV(j,:) = T_map;
        xHV(j,:) = x;  
        wHV(j,:) = w;
        sHV(j,:) = s;        
    end

    %Average the bootstrap sample and save
    TMAPc(i,:) = nanmean(tmapc,1);
    Xc(i,:) = nanmean(xc,1);  
    Wc(i,:) = nanmean(wc,1);
    Sc(i,:) = nanmean(sc,1);
    TMAPlv(i,:) = nanmean(tmapLV,1);
    Xlv(i,:) = nanmean(xLV,1);  
    Wlv(i,:) = nanmean(wLV,1);
    Slv(i,:) = nanmean(sLV,1);
    TMAPhv(i,:) = nanmean(tmapHV,1);
    Xhv(i,:) = nanmean(xHV,1);  
    Whv(i,:) = nanmean(wHV,1);
    Shv(i,:) = nanmean(sHV,1);
end

%Concenate all conditions
TMAP = [TMAPc; TMAPlv; TMAPhv];
X = [Xc; Xlv; Xhv];
W = [Wc; Wlv; Whv];
S = [Sc; Slv; Shv];

%Plot the simulations
SimPlot(TMAP,X,W,S,numstr,N);

end