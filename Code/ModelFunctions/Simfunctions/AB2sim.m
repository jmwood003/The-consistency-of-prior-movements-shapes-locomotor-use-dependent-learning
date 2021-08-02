function [T_map] = AB2sim(params,t)

%Simluates modified AB model

%Set the parameters
Beta_lrn = params(1);
Beta_wsh = params(2);
sigma_L_lrn = params(3);
sigma_L_wsh = params(4);

%Inialtize the variables
mu_prior = 0; 
prior_var = 1;
T_map = 0; 

%Loop through each target
for n = 1:size(t,2)
    
    %Set the beta and sigma depending on phase
    if t(n) == 0 
        sigma_L = sigma_L_wsh;
        Beta = Beta_wsh;
    else
        sigma_L = sigma_L_lrn;
        Beta = Beta_lrn;        
    end
    
    T_map(n) = (sigma_L/(prior_var(n)+sigma_L))*mu_prior(n) + (prior_var(n)/(prior_var(n)+sigma_L))*t(n);

    %Prior updates
    mu_prior(n+1) = (1 - Beta)*mu_prior(n) + Beta*t(n); 
    prior_var(n+1) = (1 - Beta)*prior_var(n) + Beta*((mu_prior(n)-t(n))^2);
 
end

end