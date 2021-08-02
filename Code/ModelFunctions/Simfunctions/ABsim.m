function [T_map] = ABsim(params,t)

%Simulates the adaptive bayesian model using the targets and parameter
%values provided in the input

%Set the parameters
Beta = params(1);
sigma_L = params(2);

%Inialtize the variables
mu_prior = 0; 
prior_var = 1;
T_map = 0; 

%Loop through each target
for n = 1:size(t,2)
    
    %Posterior
    T_map(n) = (sigma_L/(prior_var(n)+sigma_L))*mu_prior(n) + (prior_var(n)/(prior_var(n)+sigma_L))*t(n);

    %Prior updates
    mu_prior(n+1) = (1 - Beta)*mu_prior(n) + Beta*t(n); 
    prior_var(n+1) = (1 - Beta)*prior_var(n) + Beta*((mu_prior(n)-t(n))^2);
 
end

end

