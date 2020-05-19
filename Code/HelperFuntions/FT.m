function T_5sig = FT(LrnStrides,Tmu,reprng,N)

%Create targets for the variable condition
T_5sig = [];
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
    T_5sig = [T_5sig; T];
end

end

