function CI = CI95(data)

%This function calculates the mean and 95% CI by using the mean and
%standard error

%Calculate degrees of freedom
n = length(data);
df = n-1;

%Mean
Mu = mean(data);

%Standard error
SE = std(data) / sqrt(n);

%index t-score
ts = tinv([0.025  0.975],df);      

%caluclate CI and round
ci = Mu + (ts*SE);
CI = round(ci,2);

end