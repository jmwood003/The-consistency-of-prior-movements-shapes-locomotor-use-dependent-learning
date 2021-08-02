function T_LV = LVtargets(LrnStrides,Tmu,reprng,N)

%Create targets for the low variability condition, always starts with 250 baseline
%strides and ends with 750 washout strides (target is 0).

%LrnStrides = number of strides during the learning phase
%Tmu = the mean of the target distribution
%reprng = frequency of target change, specificed as a 2 number array where
%the frequency changes, at an equal probability between x1 and x2 strides.
%N = the number of target sets to make

%The SD of the target distribution is set to 5
t_sigma = 5;
    
%Create targets for the variable condition
T_LV = [];
for i = 1:N
    %One set of target distributions
    targetsVar = [];
    while length(targetsVar)<LrnStrides
        numrep = randi(reprng);
        randtrgt = normrnd(Tmu,t_sigma);
        targetsVar = [targetsVar, ones(1,numrep)*randtrgt];
    end
    T = [zeros(1,250) targetsVar(1:LrnStrides) zeros(1,750)];
    T_LV = [T_LV; T];
end

end

