function [params,error,AIC,BIC] = SU2fit(Data,Target,Condidx)

%Fit modified SU model

cnstrnt = 5;
SIM = [Data;Target;Condidx];

%Set options
options = optimoptions('fmincon','Display','off','Algorithm','sqp','MaxFunctionEvaluations',1e6,'OptimalityTolerance',1e-16);

%Set initials
C = rand(1);
Fs = 0+((C/7)-0)*rand;
x0 = [C, rand(1,2), Fs, rand(1,2)];

%Set linear constraints including constraints for UD learning rates
Ac = [eye(6); eye(6)*-1;...
    -1, 0, 0, cnstrnt, 0, 0;...
    0, 0, 0, 0, -1, 1];
bc = [ones(6,1); zeros(8,1)];
    
%fit
[params, error] = fmincon(@sq_err, x0, Ac, bc, [], [], [], [], [], options, SIM);

%Calculate AIC and BIC
AIC = 2*length(x0) + length(SIM(1,:))*log(error/length(SIM(1,:)));
BIC = (length(x0)*log(length(SIM)))-(2*log(error/length(SIM(1,:))));

end

function [sq_err, simulations] = sq_err(params, X)

%Cost function for fmincon 

%Simulate behavior from initial parameters
simulations = SU2sim(params, X(2,:), X(3,:));

%Calculate Squared Error - between data and simulation
sq_err = nansum((X(1,:) - simulations).^2); 

end