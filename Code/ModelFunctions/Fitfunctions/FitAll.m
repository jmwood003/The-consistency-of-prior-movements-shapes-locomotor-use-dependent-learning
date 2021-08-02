function [BESTaic,BESTbic] = FitAll(Data,target)

%Fit data to both the adaptive bayesian and the strategy plus use-dependent
%models. Determines which model objectively fit the data better using the
%AIC and BIC

%Adaptive Bayesian model:
[~,~,abAIC,abBIC] = ABfit(Data,target);
%strategy plus use-dependent model:
[~,~,suAIC,suBIC] = SUfit(Data,target);

%Which has better AIC
AIC = [abAIC, suAIC];
[M, iBest] = min(AIC);
BESTaic = AIC==M;
%Which has better BIC
BIC = [abBIC, suBIC];
[Mb, iBestbic] = min(BIC);
BESTbic = BIC==Mb;

end

