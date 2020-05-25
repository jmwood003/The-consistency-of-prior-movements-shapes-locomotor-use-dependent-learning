function AccEmp

close all; clear all; clc;

%Set paths
directory = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code';
helpdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\HelperFuntions';
simdir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Code\SimFunctions';
datadir = 'C:\Users\Jonathan\Documents\GitHub\UDPV\Data';
addpath(helpdir);
addpath(simdir);
addpath(directory);
cd(datadir);

load('UDPVT.mat','UDPVT');
T = UDPVT;

%Plot and display accuracy for different conditions
[Racc, Lacc, Tacc] = UDPVgrpAcc(T);
disp('Uniform Condition Accuracy (m):');
disp(['RSL Accuracy (m) = ' num2str(nanmean(Racc(:,2)))]);
disp(['LSL Accuracy (m) = ' num2str(nanmean(Lacc(:,2)))]);
disp(['Total SL Accuracy (m) = ' num2str(nanmean(Tacc(:,2)))]);

%Regress Step lengths vs targets for the Uniform condition only.
%Order: (1) All SL vs all targets, (2) RSL vs Rtrgt, (3) LSL vs Ltrgt
[D CorR CorL] = TrgtvSL(T);
meancorR = mean(CorR(:,1))
meancorL = mean(CorL(:,1))
maxpvalR = max(CorR(:,2))
maxpvalL = max(CorL(:,2))
 
% [Rr, Rpval] = corrplot(D.Uniform.Right,'varNames',{'TrgtRun','RSLun'})
% [Lr, Lpval] = corrplot(D.Uniform.Left,'varNames',{'TrgtLun','LSLun'})

%Plot mean and std SAI for the entire learning phase 
[SAImean, SAIstd] = UDPVgrpLrn(T);

end