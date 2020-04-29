function [params, error, AIC] = BysFit(Data,Target)

SIM = [Data;Target];

%Set options
options = optimoptions('fmincon','MaxFunctionEvaluations',1e16,'OptimalityTolerance',1e-16);

%Initialize parameters
x0 = [rand(1) 0+(25-0).*rand];
%Set parameter bounds
LB = [0 0];
UB = [1 25];

[params, error] = fmincon(@sq_err, x0, [], [], [], [], LB, UB, [], options, SIM);

AIC = 2*length(x0) + length(params(1,:))*log(error/length(params(1,:)));

end

function [sq_err, simulations] = sq_err(params, X)

%Cost function for fmincon 

%Simulate behavior from initial parameters
simulations = BayesSim(params, X(2,:));

%Calculate Squared Error - between data and simulation
sq_err = nansum((X(1,:) - simulations).^2); 

end