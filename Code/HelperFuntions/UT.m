function T_Uniform = UT(LrnStrides,reprng,N)

%Create targets for the uniform condition
T_Uniform = [];
for i = 1:N
    targetsUnif = [];
    while length(targetsUnif)<LrnStrides
        numrep = randi(reprng);
        randtrgt = 5 + (39-5)*rand(1);
        targetsUnif = [targetsUnif, ones(1,numrep)*randtrgt];
    end
<<<<<<< Updated upstream
    T = [zeros(1,250) targetsUnif(1:LrnStrides) zeros(1,750)];
=======
%     T = [zeros(1,250) targetsUnif(1:LrnStrides-20) ones(1,20)*22 zeros(1,750)];
    T = [zeros(1,250) targetsUnif(1:LrnStrides) zeros(1,750)];   
>>>>>>> Stashed changes
    T_Uniform = [T_Uniform; T];
end

end
