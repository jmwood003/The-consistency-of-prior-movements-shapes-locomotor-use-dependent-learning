function [T_map] = ABsim(params,t)

%Set the parameters
Beta = params(1);
sigma_L = params(2);

%Inialtize the variables
mu_prior = 0; 
prior_var = 1;
T_map = 0; 

%Loop through each target
for n = 1:size(t,2)
    
    %Prior updates
    mu_prior(n+1) = (1 - Beta)*mu_prior(n) + Beta*t(n); 
    prior_var(n+1) = (1 - Beta)*prior_var(n) + Beta*((mu_prior(n)-t(n))^2);

    %Posterior
%     sigmaSq_post(n) = (prior_var(n)^-1 + sigma_L^-1)^-1;
%     T_map(n) = (sigmaSq_post(n)/prior_var(n))*mu_prior(n) + (sigmaSq_post(n)/sigma_L)*t(n);
    T_map(n) = (sigma_L/(prior_var(n)+sigma_L))*mu_prior(n) + (prior_var(n)/(prior_var(n)+sigma_L))*t(n);

    
%     prior_var(n+1) = (1 - Beta)*prior_var(n) + Beta*((mu_prior(n)-t(n))^2);  
%     sigmaSq_post(n) = (prior_var(n)^-1 + sigma_L^-2);
%     T_map(n+1) = (sigmaSq_post(n)^-1/prior_var(n))*mu_prior(n) + (sigmaSq_post(n)^-1/sigma_L^2)*t(n);

end

end

