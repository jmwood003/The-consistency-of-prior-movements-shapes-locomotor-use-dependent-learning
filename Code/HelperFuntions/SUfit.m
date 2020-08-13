function [params,error,AIC,BIC] = SUfit(Data,Target)
cnstrnt = 5;
SIM = [Data;Target];

%Set options
optionsTp = optimoptions('fmincon','Algorithm','sqp','MaxFunctionEvaluations',1e16,'OptimalityTolerance',1e-16);

%Set initials (C A E F); F must be at least 5 times lower than C;
C = rand(1);
F = 0+((C/cnstrnt)-0)*rand;
x0 = [C, rand(1,2), F];

%Set linear constraints
Ac = [-1 0 0 cnstrnt; eye(4); eye(4)*-1];
bc = [0; 1; 1; 1; 1; 0; 0; 0; 0];

[params, error] = fmincon(@sq_err, x0, Ac, bc, [], [], [], [], [], optionsTp, SIM);

AIC = 2*length(x0) + length(SIM(1,:))*log(error/length(SIM(1,:)));
BIC = (length(x0)*log(length(SIM)))-(2*log(error/length(SIM(1,:))));

end

function [sq_err, simulations] = sq_err(params, X)

%Cost function for fmincon 

%Simulate behavior from initial parameters
simulations = SUsim(params, X(2,:));

%Calculate Squared Error - between data and simulation
sq_err = nansum((X(1,:) - simulations).^2); 

end