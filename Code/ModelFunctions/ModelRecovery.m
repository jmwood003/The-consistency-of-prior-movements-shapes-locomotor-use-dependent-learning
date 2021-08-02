function ModelRecovery(N)

%Performs and plots model recovery analysis 

%N = Number of simulations per condition

%Set experiment parameters
reprng = [1 5]; %randomized frequency of target changes
LrnStrides = 500; %length of the learning phase
Tmu = 22; %Mean targets

%Set the targets for each condition 
t = [Ctargets(LrnStrides,Tmu,N); LVtargets(LrnStrides,Tmu,reprng,N);...
    HVtargets(LrnStrides,reprng,N)];

%Initialze confusion matrices
%Aic
CMallaic = zeros(2);
%Bic
CMallbic = zeros(2);

%Loop through the number of simulations for each condition
for i = 1:N*3

    i
    
    %Simulate Adaptive Bayes Model using randomized parameter values
    ParamsAB = [rand, 0+(100-0).*rand];
    [T_map] = ABsim(ParamsAB,t(i,:)); 
    %Fit the simulated AB model 
    [BESTaic,BESTbic] = FitAll(T_map,t(i,:));
    %Save results to confusion matrices
    BESTaic = BESTaic/sum(BESTaic);
    CMallaic(1,:) = CMallaic(1,:)+BESTaic;
    CMABaic(i,:) = BESTaic; 
    BESTbic = BESTbic/sum(BESTbic);
    CMallbic(1,:) = CMallbic(1,:)+BESTbic;
    CMABbic(i,:) = BESTbic; 

    %Simulate Strategy + UD Model using randomized parameter values
    C = rand(1);
    F = 0+((C/5)-0)*rand;
    ParamsT = [C, rand(1,2), F];
    [x,~,~] = SUsim(ParamsT,t); 
    %Fit the simulated SU model
    [BESTaic,BESTbic] = FitAll(x,t(i,:));
    %Save results to confusion matrices
    BESTaic = BESTaic/sum(BESTaic);
    CMallaic(2,:) = CMallaic(2,:)+BESTaic;
    CMSUaic(i,:) = BESTaic;
    BESTbic = BESTbic/sum(BESTbic);
    CMallbic(2,:) = CMallbic(2,:)+BESTbic;
    CMSUbic(i,:) = BESTbic; 

end

%Plot the results of model recovery analysis using confusion matrices
%-----------------AIC----------------------
FMaic = CMplot(CMallaic,CMABaic,CMSUaic,N,'AIC');
%-----------------BIC----------------------
FMbic = CMplot(CMallbic,CMABbic,CMSUbic,N,'BIC');

end

