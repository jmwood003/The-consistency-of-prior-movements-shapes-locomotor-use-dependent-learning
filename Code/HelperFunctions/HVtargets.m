function T_HV = HVtargets(LrnStrides,reprng,N)

%Create targets for the high variability condition, always starts with 250 baseline
%strides and ends with 750 washout strides (target is 0).

%LrnStrides = number of strides during the learning phase
%reprng = frequency of target change, specificed as a 2 number array where
%the frequency changes, at an equal probability between x1 and x2 strides.
%N = the number of target sets to make

%Targets a uniformly randomized between 5 and 39% SAI 

%Create targets for the high variability condition
T_HV = [];
for i = 1:N
    %One set of learning targets
    targetsHV = [];
    while length(targetsHV)<LrnStrides
        numrep = randi(reprng);
        randtrgt = 5 + (39-5)*rand(1);
        targetsHV = [targetsHV, ones(1,numrep)*randtrgt];
    end
    T = [zeros(1,250) targetsHV(1:LrnStrides) zeros(1,750)];
    T_HV = [T_HV; T];
end

end
