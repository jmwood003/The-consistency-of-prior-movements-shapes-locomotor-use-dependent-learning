function plotrecovtp(SimParams,FitParams,thresh)

%Plot bayesian model parameter recovery
%C A E F

%Index bad parameters (less than 25%)
badidxC = find(abs(SimParams(:,1)-FitParams(:,1)) >= thresh == 1);
GoodidxC = find(abs(SimParams(:,1)-FitParams(:,1)) >= thresh == 0);
badidxA = find(abs(SimParams(:,2)-FitParams(:,2)) >= thresh == 1);
GoodidxA = find(abs(SimParams(:,2)-FitParams(:,2)) >= thresh == 0);
badidxE = find(abs(SimParams(:,3)-FitParams(:,3)) >= thresh == 1);
GoodidxE = find(abs(SimParams(:,3)-FitParams(:,3)) >= thresh == 0);
badidxF = find((abs(SimParams(:,4)-FitParams(:,4)))./max(FitParams(:,4)) >= thresh == 1);
GoodidxF = find((abs(SimParams(:,4)-FitParams(:,4)))./max(FitParams(:,4)) >= thresh == 0);

%Plot C
figure; hold on
subplot(2,2,1); hold on
plot(SimParams(GoodidxC,1),FitParams(GoodidxC,1),'ro');
plot(SimParams(badidxC,1),FitParams(badidxC,1),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Stragetic Learning Rate (C)');
axis equal

%Plot A
subplot(2,2,2); hold on
plot(SimParams(GoodidxA,2),FitParams(GoodidxA,2),'ro');
plot(SimParams(badidxA,2),FitParams(badidxA,2),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Strategic Retention Rate (A)');
axis equal

%Plot E
subplot(2,2,3); hold on
plot(SimParams(GoodidxE,3),FitParams(GoodidxE,3),'ro');
plot(SimParams(badidxE,3),FitParams(badidxE,3),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Use-depenent Retention Rate (E)');
axis equal

%Plot F
subplot(2,2,4); hold on
plot(SimParams(GoodidxF,4),FitParams(GoodidxF,4),'ro');
plot(SimParams(badidxF,4),FitParams(badidxF,4),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Use-dependent Learning Rate (F)');
axis equal


end
