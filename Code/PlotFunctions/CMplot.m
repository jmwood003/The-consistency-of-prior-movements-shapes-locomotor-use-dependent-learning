function FM = CMplot(CMall,CMAB,CMSU,N,titlestr)

%Plots a confusion matrix using the saved values from the simulated and
%fitted models
%One CM for each condition and all conditions combined 

%CMall = count of the model that was best fit for all the simulations
%CMAB = counts the model that was best fit when the AB model was simulated
%CMSU = counts the model that was best for when the SU model was simulated
%N = number of simulations 
%titlestr = title of the plot

%Indexing variables for each condition (depends on the number of
%simulations)
Cidx = 1:N;
LVidx = N+1:N*2;
HVidx = N*2+1:N*3;

%Condition strongs
Conditions = {'All', 'Constant', 'LV', 'HV'};

%Calculate probabilities of best fit model and save in a structure to make
%plotting easier
FM(1).all = round(100*CMall/sum(CMall(1,:)))/100;
%Constant
CMr = [sum(CMAB(Cidx,:)); sum(CMSU(Cidx,:))];
FM(2).all = round(100*CMr/sum(CMr(1,:)),3)/100;
%Low Variability
CMf = [sum(CMAB(LVidx,:)); sum(CMSU(LVidx,:))];
FM(3).all = round(100*CMf/sum(CMf(1,:)),3)/100;
%High Variability
CMu = [sum(CMAB(HVidx,:)); sum(CMSU(HVidx,:))];
FM(4).all = round(100*CMu/sum(CMu(1,:)),3)/100;

%Plot Confusion Matrices
figure; hold on
clims = [0.3 1];
for i = 1:4
    subplot(2,2,i), imagesc(FM(i).all,clims);
    text(1,1,num2str(FM(i).all(1,1)),'FontSize',15);
    text(2,1,num2str(FM(i).all(1,2)),'FontSize',15);
    text(1,2,num2str(FM(i).all(2,1)),'FontSize',15);
    text(2,2,num2str(FM(i).all(2,2)),'FontSize',15);
    set(gca, 'xtick', [1:2], 'ytick', [1:2], 'fontsize', 10, ...
        'tickdir', 'out','xaxislocation', 'top');
    set(gca,'xticklabel',{'AB', 'S+U'});
    set(gca,'yticklabel',{'AB', 'S+U'});
    xlabel('Fitted Model');
    ylabel('Simulated Model');
    title(Conditions{i});
end
suptitle(['Comparison Criterion: ' titlestr]);
end
