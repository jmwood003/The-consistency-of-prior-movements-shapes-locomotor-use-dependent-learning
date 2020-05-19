function [SAImean, SAIstd] = UDPVgrpLrn(T)

Conditions = unique(T.Condition);
SAImean = nan(10,length(Conditions));
SAIstd = nan(10,length(Conditions));


for c = 1:length(Conditions)
    
    currCond = Conditions{c};
    Condidx = find(ismember(T.Condition,currCond)==1);
    Subjs = unique(T.Subject_ID(Condidx));
    
    for s = 1:length(Subjs)
        
        currSubj = Subjs{s};
        Subjidx = find(ismember(T.Subject_ID,currSubj)==1 & ...
            ismember(T.Condition,currCond)==1 & ...
            ismember(T.Trial_name,'learning')==1);
        
        %Index actual SAI
        curSAI = T.Step_asymmetry_idx(Subjidx);
        
        %Find SAI for both learning phases
        SAImean(s,c) = nanmean(curSAI);
        SAIstd(s,c) = nanstd(curSAI);

    end
    
end

figure; hold on
% subplot(1,2,1); hold on
for i = 1:size(SAImean,2)
    p1 = plot(i-0.2,nanmean(SAImean(:,i)),'ro');
    errorbar(i-0.2,nanmean(SAImean(:,i)),nanstd(SAImean(:,i)),'r');
    plot(i-0.1,SAImean(:,i),'Marker','.','MarkerSize',10,'Color','r');
end
xlim([0 size(SAImean,2)+1]);
ylim([0 25]);
ylabel('SAI (%)');
xlabel('Condition');
% ax = gca;
% ax.XTick = [1 size(SAImean,2)];
% ax.XTickLabel = Conditions;
title('Learning SAI Mean');

% subplot(1,2,2); hold on
for i = 1:size(SAIstd,2)
    p2 = plot(i+0.2,nanmean(SAIstd(:,i)),'bo');
    errorbar(i+0.2,nanmean(SAIstd(:,i)),nanstd(SAIstd(:,i)),'b');
    plot(i+0.3,SAIstd(:,i),'Marker','.','MarkerSize',10,'Color','b');
end
xlim([0 size(SAIstd,2)+1]);
% ylim([0 15]);
% ylabel('SAI Learning STD (%)');
xlabel('Condition');
ax = gca;
ax.XTick = [1 size(SAIstd,2)];
ax.XTickLabel = Conditions;
legend([p1 p2], 'SAI Mean', 'SAI STD');
legend('boxoff');
title('Learning SAI Mean and Standard Deviation');

end