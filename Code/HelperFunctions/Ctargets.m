function T_Constant = Ctargets(LrnStrides,Tmu,N)

%Create targets for the constant condition, always starts with 250 baseline
%strides and ends with 750 washout strides (target is 0).

%LrnStrides = number of strides during the learning phase
%Tmu = the mean of the target distribution
%N = the number of target sets to make

T_Constant = [];
for i = 1:N
    T = [zeros(1,250) ones(1,LrnStrides)*Tmu zeros(1,750)];
    T_Constant = [T_Constant; T];
end

end

