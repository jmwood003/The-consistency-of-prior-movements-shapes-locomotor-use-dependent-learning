function [params,error,AIC,BIC] = ABfit(Data,Target)

%Fits the adaptive bayesian model to the inputed data using the provided
%targets

%Outputs the best fit parameters, the corresponding squared error, AIC and
%BIC values. 

%Combine the data and targets into one variable 
SIM = [Data;Target];

%Set options
options = optimoptions('fmincon','Display','off','MaxFunctionEvaluations',1e16,'OptimalityTolerance',1e-16);

%Initialize parameters
x0 = [rand(1) 0+(100-0).*rand];
%Set parameter bounds
LB = [0 0];
UB = [1 100];

%Fit
[params, error] = fmincon(@sq_err, x0, [], [], [], [], LB, UB, [], options, SIM);

%Calculate AIC and BIC
AIC = 2*length(x0) + length(SIM(1,:))*log(error/length(SIM(1,:)));
BIC = (length(x0)*log(length(SIM)))-(2*log(error/length(SIM(1,:))));
end

function [sq_err, simulations] = sq_err(params, X)

%Cost function for fmincon 

%Simulate behavior from initial parameters
simulations = ABsim(params, X(2,:));

%Calculate Squared Error - between data and simulation
sq_err = nansum((X(1,:) - simulations).^2); 

end