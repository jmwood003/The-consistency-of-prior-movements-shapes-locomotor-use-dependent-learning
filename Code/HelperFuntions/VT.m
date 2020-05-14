function T_Var = VT(LrnStrides,Tmu,reprng,N)

%Create targets for the variable condition
T_Var = [];
for i = 1:N
    targetsVar = [];
    t_sigma = 5;
    while length(targetsVar)<LrnStrides
        numrep = randi(reprng);
        randtrgt = normrnd(Tmu,t_sigma);
        targetsVar = [targetsVar, ones(1,numrep)*randtrgt];
    end
%     T = [zeros(1,250) targetsVar(1:LrnStrides-20) ones(1,20)*22 zeros(1,750)];
    T = [zeros(1,250) targetsVar(1:LrnStrides) zeros(1,750)];
    T_Var = [T_Var; T];
end

end

