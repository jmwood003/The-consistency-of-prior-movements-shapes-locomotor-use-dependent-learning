function displaystats(sample, subjcode, Data)

%Function that displays stastical analysis for the variables of interest
%Displays stats in this order:
%1. Displays mean and 95% confidence intervals
%2. Performs Shapiro wilks test of nomality
%3. Performs Levenes test of homoscedasticity
%4. Repeated measures ANOVA for the variable across conditions (includes
%partial eta squared)
%5a. If the ANOVA is significant, performs post-hoc paird t-test (bonferoni
%corrected) - incldues cohensdz
%5b. If the ANOVA is non-significant, performs the TOST procedure for
%to determine equivilance

%sample = the sample codes, used as input into ANOVA
%subjcode = all the subjects, used as input into ANOVA
%Data = data on which stats are performed

%Organize data
D = [Data(:,1); Data(:,2); Data(:,3)];

%Means and 95% CIs
disp(['Constant = ' num2str(round(mean(Data(:,1)),2)) ' [' num2str(CI95(Data(:,1))) ']'])
disp(['LV = ' num2str(round(mean(Data(:,2)),2)) ' [' num2str(CI95(Data(:,2))) ']'])
disp(['HV = ' num2str(round(mean(Data(:,3)),2)) ' [' num2str(CI95(Data(:,3))) ']'])
disp(' ');

%Test of normality
disp('Normality tests:');
[~, Pval, ~] = swtest(Data(1,:))
[~, Pval, ~] = swtest(Data(2,:))
[~, Pval, ~] = swtest(Data(3,:))

%Levenes test
disp('Levenes test:');
Xmu = [D, sample];
Levenetest(Xmu)
disp(' ');

%Perform RM ANOVA
disp('ANOVA:');
XanovaMu = [D, ones(length(D),1), sample, subjcode];
[SSQs, DFs, MSQs, Fs, Ps] = mixed_between_within_anova(XanovaMu,1);

%Calculate partial eta squared 
partial_eta2 = round(eta_p2(SSQs{3},SSQs{5}),2);

%Display ANOVA results
disp([' F [' num2str(DFs{3}) ' ' num2str(DFs{2}) '] = '...
    num2str(round(Fs{3},2)) ', p = ' num2str(Ps{3}) ', eta_p^2 = ' num2str(partial_eta2)]);

if Ps{3} < 0.05
    
    %Perform post-hoc ttests if significant
    disp(' ');
    disp('Post hoc tests:');
    BonfCorrect = 3;
    [~, p, ~, stats] = ttest(Data(:,1),Data(:,2));
    CDz = cohensDz(Data(:,1),Data(:,2));
    disp(['Const v LV [df = ' num2str(stats.df) '] t = ' num2str(round(stats.tstat,2))...
        ', p_bonf = ' num2str(p*BonfCorrect) ', Cohens Dz = ' num2str(round(CDz,2))]);

    [~, p, ~, stats] = ttest(Data(:,2),Data(:,3));
    CDz = cohensDz(Data(:,2),Data(:,3));
    disp(['LV v HV [df = ' num2str(stats.df) '] t = ' num2str(round(stats.tstat,2))...
        ', p_bonf = ' num2str(p*BonfCorrect) ', Cohens Dz = ' num2str(round(CDz,2))]);

    [~, p, ~, stats] = ttest(Data(:,1),Data(:,3));
    CDz = cohensDz(Data(:,1),Data(:,3));
    disp(['Const v HV [df = ' num2str(stats.df) '] t = ' num2str(round(stats.tstat,2))...
        ', p_bonf = ' num2str(p*BonfCorrect) ', Cohens Dz = ' num2str(round(CDz,2))]);
else
    
    %Perform equivilance testing if non-significant
    disp(' '); disp('Equivilance Testing:');
    delta = 0.3;
    TOST(Data(:,2), Data(:,3), delta, 'std', 0.05,'No');
    TOST(Data(:,1), Data(:,3), delta, 'std', 0.05,'No');
    TOST(Data(:,1), Data(:,2), delta, 'std', 0.05,'No');

end

end