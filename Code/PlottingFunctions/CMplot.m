function FM = CMplot(CMall,CMAB,CMSU,N,titlestr)

%Indexing variables
Ridx = 1:N;
Fidx = N+1:N*2;
Uidx = N*2+1:N*3;

%Conditions
Conditions = {'All', 'Repeated', '5\sigma', 'Uniform'};

%Create Final CMs for each condition
FM(1).all = round(100*CMall/sum(CMall(1,:)))/100;
%Repeated
CMr = [sum(CMAB(Ridx,:)); sum(CMSU(Ridx,:))];
FM(2).all = round(100*CMr/sum(CMr(1,:)),3)/100;
%5% sigma
CMf = [sum(CMAB(Fidx,:)); sum(CMSU(Fidx,:))];
FM(3).all = round(100*CMf/sum(CMf(1,:)),3)/100;
%Uniform
CMu = [sum(CMAB(Uidx,:)); sum(CMSU(Uidx,:))];
FM(4).all = round(100*CMu/sum(CMu(1,:)),3)/100;

figure; hold on
%Plot all Confusion Matrices
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
