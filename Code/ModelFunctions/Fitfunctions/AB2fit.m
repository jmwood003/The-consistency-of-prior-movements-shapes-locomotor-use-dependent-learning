function [params,error,AIC,BIC] = AB2fit(Data,Target)

%Fit the modified AB model

SIM = [Data;Target];

%Set options
options = optimoptions('fmincon','Display','off','MaxFunctionEvaluations',1e16,'OptimalityTolerance',1e-16);

%Initialize parameters
x0 = [rand(1,2), 0+(100-0).*rand, 0+(100-0).*rand];

%Set constraints 
Ac = [eye(4); eye(4)*-1;];
bc = [1; 1; 100; 100; 0; 0; 0; 0];

%Fit
[params, error] = fmincon(@sq_err, x0, Ac, bc, [], [], [], [], [], options, SIM);

%Calculate AIC and BIC
AIC = 2*length(x0) + length(SIM(1,:))*log(error/length(SIM(1,:)));
BIC = (length(x0)*log(length(SIM)))-(2*log(error/length(SIM(1,:))));

end

function [sq_err, simulations] = sq_err(params, X)

%Cost function for fmincon 

%Simulate behavior from initial parameters
simulations = AB2sim(params, X(2,:));

%Calculate Squared Error - between data and simulation
sq_err = nansum((X(1,:) - simulations).^2); 

end