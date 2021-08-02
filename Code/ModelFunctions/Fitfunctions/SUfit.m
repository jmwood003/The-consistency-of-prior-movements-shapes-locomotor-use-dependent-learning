function [params,error,AIC,BIC] = SUfit(Data,Target)

%Fits the strategy + use-depenent model to the inputed data using the provided
%targets

%Outputs the best fit parameters, the corresponding squared error, AIC and
%BIC values. 

%Constraint for the use-dependent and strategic learning rate. F must be at
%least 5x smaller than C
cnstrnt = 5;

%Combine the data and target into one variable
SIM = [Data;Target];

%Set options
optionsTp = optimoptions('fmincon','Display','off','Algorithm','sqp','MaxFunctionEvaluations',1e6,'OptimalityTolerance',1e-16);

%Set initials (C A E F)
%Fot the initiliazation, set the constraint to 6 so the function isnt
%undefined at the inital point
C = rand(1);
F = 0+((C/6)-0)*rand;
x0 = [C, rand(1,2), F];

%Set linear constraints
Ac = [-1 0 0 cnstrnt; eye(4); eye(4)*-1];
bc = [0; 1; 1; 1; 1; 0; 0; 0; 0];

%fit
[params, error] = fmincon(@sq_err, x0, Ac, bc, [], [], [], [], [], optionsTp, SIM);

%Calculate AIC and BIC
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