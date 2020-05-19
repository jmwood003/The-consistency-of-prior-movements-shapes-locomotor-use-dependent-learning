function T_Rep = RT(LrnStrides,Tmu,N)

%Create targets for the stable condition
T_Rep = [];
for i = 1:N
    stableT = ones(1,LrnStrides)*Tmu;
    T = [zeros(1,250) stableT zeros(1,750)];
    T_Rep = [T_Rep; T];
end


end

