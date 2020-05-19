function [BESTaic,BESTbic] = FitAll(Data,target)

%Fit data to both models

%Bayes model:
[~,~,abAIC,abBIC] = ABfit(Data,target);
%Two process model:
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

