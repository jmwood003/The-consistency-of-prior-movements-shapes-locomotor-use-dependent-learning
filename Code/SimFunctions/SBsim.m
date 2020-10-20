function SBsim
%Simulate Roemmich and bastian 2014

addpath('C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions');
grpnames = {'abrupt','grad','gradwsh','extgrad','shortab'};

%Different phases of experiment
A1abrupt = ones(1,500);
A1gradual = linspace(0,1,500);
A1gradwsh = [ones(1,500), linspace(1,0,500)];
A1extgrad = [linspace(0,1,500), ones(1,500)];
A1srtab = ones(1,100);
Bsl = zeros(1,100);
Wsh = zeros(1,500);
A2 = ones(1,500);

%Target for each group
T = struct;
T.abrupt = [Bsl, A1abrupt, Wsh, A2];
T.grad = [Bsl, A1gradual, Wsh, A2];
T.gradwsh = [Bsl, A1gradwsh, A2];
T.extgrad = [Bsl, A1extgrad, Wsh, A2];
T.shortab = [Bsl, A1srtab, Wsh, A2];

%--------------------------------------------------------------------------
%Set the parameters:
%AB model [beta, sigmaL]
ABparams = [0.0256, 2.545];
%SU model [C, A, E, F]
SUparams = [0.1, 0.8, 0.91, 0.003];
%--------------------------------------------------------------------------
abplots = [1,3,5,7, 9];
suplots = [2,4,6,8, 10];
figure; hold on
for i = 1:length(grpnames)
    
    CT = T.(grpnames{i});
    
    [T_map] = ABsim(ABparams,CT);
    [x,W,S] = SUsim(SUparams,CT);
    
    subplot(5,2,abplots(i)); hold on
    plot(CT,'k');
    plot(T_map,'b');
    title(['AB model', grpnames{i}]);
    ylim([0 1.5]);
    
    subplot(5,2,suplots(i)); hold on
    plot(CT,'k');
    plot(x,'b');
    plot(W,'r');
    plot(S,'m');
    title(['S+U model', grpnames{i}]);
    ylim([0 1.5]);
    
    

end


end

