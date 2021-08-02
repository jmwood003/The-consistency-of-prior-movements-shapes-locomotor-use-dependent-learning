function h = TOST(D1, D2, delta, deltastr, alpha, pltstr)

%Two-once sided test procedure. 

%Decription from Lakens et al., 2018 and Lakens 2017:
% "In the TOST procedure, the null hypothesis is the presence of
% a true effect of DL or DU, and the alternative hypothesis is an
% effect that falls within the equivalence bounds or the absence
% of an effect that is worthwhile to examine. The observed data
% are compared against DL and DU in two one-sided tests."

% "The goal in the TOST approach is to specify a lower and upper bound, such
% that results falling within this range are deemed equivalent to
% the absence of an effect that is worthwhile to examine."

% The two one-sided tests are rejected if tU <= -t(df, alpha),
% and tL >= t(df, alpha), where t(alpha, df) is the upper 100alpha
% percentile of a t-distribution (Berger & Hsu, 1996). "
%--------------------------------------------------------------------------

%D1 = data 1
%D2 = data 2
%delta = difference to consider as 'uninteresting'
%deltastr = string, 'raw' or 'std', to tell if the delta is in terms of the
%raw data or if it is in terms of a standardized effect size
%alpha = alpha value to consider
%pltstr = string, either 'Yes' or 'No' for plotting the differences or not,
%respectively.

%make sure data is the same length
if length(D1) ~= length(D2)
   error('Data arrrays must be the same length'); 
end

%Calcualte mean and SD of difference
difference = D1 - D2;
Mudiff = mean(difference);
SDdiff = std(difference);

%If the delta is in terms of the data, do nothing to delta, if no make the
%standardized difference in terms of the data
if strcmp(deltastr,'raw')
    deltaL = delta*-1;
    deltaU = delta;
elseif strcmp(deltastr,'std')
    deltaL = delta*SDdiff*-1;
    deltaU = delta*SDdiff;    
else
    error('deltastr must either be "raw" or "std" to tell which form detla should take');
end

%Calculate the degrees of freedom 
n = length(D1);
df = n-1;

%index the t-value
tval = abs(tinv(alpha,df));

%Calculate r (the correlation between the paired data)
ss = sum(((D1-mean(D1)).*(D2-mean(D2))));
r = ss / (df * std(D1) *std(D2));

%calculate the pooled standard deviation
SDpool = sqrt(std(D1)^2 + std(D2)^2 - 2 * r * std(D1) * std(D2)) / sqrt(n);

%calculate the upper and lower bounds using the delta values
diffL = Mudiff - deltaL;
diffU = Mudiff - deltaU;
tL = diffL / SDpool;
tU = diffU / SDpool;

%calculate the p-value for the upper and lower bound, both have to be
%significant for the test to be positive (D1 and D2 are equalivant)
pUp = tcdf(tU,df);
pLow = 1-tcdf(tL,df);
%Determine equalivance and display
if tU <= -tval && tL >= tval
    h = 1;
    disp('Null rejected - equivalence accepted');
    disp(['tU_' num2str(df) ' = ' num2str(tU) ', p = ' num2str(pUp)]);
    disp(['tL_' num2str(df) ' = ' num2str(tL) ', p = ' num2str(pLow)]);
else
    h = 0;
    disp('Null accepted - equivalence rejected');
    disp(['tU_' num2str(df) ' = ' num2str(tU) ', p = ' num2str(pUp)]);
    disp(['tL_' num2str(df) ' = ' num2str(tL) ', p = ' num2str(pLow)]);
end


%Calculate the 95% CIs for the difference
CI = CI95(difference);

%Plot the difference if desired
if strcmp(pltstr,'Yes')==1
    figure; hold on
    line([deltaL deltaL], [0 2], 'Color','k', 'LineStyle', '--');
    plot(Mudiff, 1, 'bo', 'MarkerSize',5,'MarkerFaceColor','b');
    plot(difference, 1.1, 'b.');
    line([deltaU deltaU], [0 2], 'Color','k', 'LineStyle', '--');
    herrorbar(Mudiff,1,CI(1)-Mudiff,CI(2)-Mudiff,'b');
    xlabel('Difference (SAI%)');
    legend(['Eq bounds (' num2str(delta) ')'], 'Mean [95% CI]', 'Individuals');
    set(gca,'ytick',[]);
    title('TOST');
end
end