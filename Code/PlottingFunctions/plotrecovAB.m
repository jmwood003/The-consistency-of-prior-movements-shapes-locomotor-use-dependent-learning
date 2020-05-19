function plotrecovAB(SimParams,FitParams,thresh)

%Plot bayesian model parameter recovery
%Beta,Sigma L

%Index bad parameters (less than 25%)
badidxB = find(abs(SimParams(:,1)-FitParams(:,1)) >= thresh == 1);
GoodidxB = find(abs(SimParams(:,1)-FitParams(:,1)) >= thresh == 0);
badidxS = find((abs(SimParams(:,2)-FitParams(:,2)))./25 >= thresh == 1);
GoodidxS = find((abs(SimParams(:,2)-FitParams(:,2)))./25 >= thresh == 0);

%Plot beta
figure; hold on
subplot(1,2,1); hold on
plot(SimParams(GoodidxB,1),FitParams(GoodidxB,1),'ro');
plot(SimParams(badidxB,1),FitParams(badidxB,1),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Beta');
axis equal

%Plot sigma L
subplot(1,2,2); hold on
plot(SimParams(GoodidxS,2),FitParams(GoodidxS,2),'ro');
plot(SimParams(badidxS,2),FitParams(badidxS,2),'ko','MarkerFaceColor','k');
xlabel('Simulated');
ylabel('Fit');
title('Sigma Likelihood');
axis equal

end
