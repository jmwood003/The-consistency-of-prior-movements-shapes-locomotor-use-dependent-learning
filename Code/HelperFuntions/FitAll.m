function [BEST,iBest,AIC] = FitAll(Data,target)

%Fit data to both models

%Bayes model:
[~,~,BysAIC] = BysFit(Data,target);
%Two process model:
[~,~,TpAIC] = TpFit(Data,target);

%Which has better AIC
AIC = [BysAIC, TpAIC];
[M, iBest] = min(AIC);
BEST = AIC==M;

end

