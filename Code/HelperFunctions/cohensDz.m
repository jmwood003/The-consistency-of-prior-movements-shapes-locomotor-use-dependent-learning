function CDz = cohensDz(D1, D2)

%Calculates cohens dz: the effect size for paired differences between
%groups

%Difference between groups
Ddiff = D1 - D2;

%sum of squared error
sse = sum((Ddiff - mean(Ddiff)).^2);
%pooled standard deviation
SD = sqrt(sse/(length(Ddiff)-1));

%cohens dz
CDz = mean(Ddiff) / SD;

end