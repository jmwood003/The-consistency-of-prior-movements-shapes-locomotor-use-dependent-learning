function T_Stable = ST(LrnStrides,Tmu,N)

%Create targets for the stable condition
T_Stable = [];
for i = 1:N
    stableT = ones(1,LrnStrides)*Tmu;
    T = [zeros(1,250) stableT zeros(1,750)];
    T_Stable = [T_Stable; T];
end


end

