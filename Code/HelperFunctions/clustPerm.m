function clustPerm(D1, D2)

%Cluster permutation test between two continuous sets of variables: D1 and D2
%Returns a plot and the longest cluster
%If there are no clusters longer than the mincluster (set to 1 here), then
%it does not perform a comparison to randompermutations of the data

%Set the min cluster length
minclust = 3; 

%Set the alpha values
alpha = 0.05;

%Extract the condition names from the varibale
condstr1 = strrep(inputname(1),'Wsh','');
condstr2 = strrep(inputname(2),'Wsh','');

%Set the colors depending on the condition
colors = lines(3);
if strcmp(condstr1,'Constant')==1
    C1 = colors(1,:);
elseif strcmp(condstr1,'LV')==1  
    C1 = colors(2,:);
elseif strcmp(condstr1,'HV')==1    
    C1 = colors(3,:);
end
if strcmp(condstr2,'Constant')==1
    C2 = colors(1,:);
elseif strcmp(condstr2,'LV')==1  
    C2 = colors(2,:);
elseif strcmp(condstr2,'HV')==1    
    C2 = colors(3,:);
end

%Bin data by 3
D1bin = Bin(D1,3,1,'mean');
D2bin = Bin(D2,3,1,'mean');

%Calculate emperical tests for each value
for i = 1:size(D1bin,2)
    [~,p(i),~,stats] = ttest(D1bin(:,i),D2bin(:,i));
    tstat_emp(i) = stats.tstat;
end
sigPval = p < alpha;

%Find the longest string of sig tests for each:
pval_emp_pad = [0 sigPval 0];
edges = diff(pval_emp_pad);
rising = find(edges==1);
falling = find(edges==-1);
ClusterLen = falling - rising;

%Make sure it is long enough
WideEnough = ClusterLen > minclust;
%Mark the beginning and end of the clusters
startpos = rising(WideEnough);
endpos = falling(WideEnough)-1;

%If the emperical data have no clusters greater than the min, plot and 
%quit the funciton
if sum(WideEnough) < 1
    disp([condstr1 ' vs ' condstr2 ': No Clusters > ' num2str(minclust)]);
    figure; hold on
    shadedErrorBar(1:size(D1bin,2),mean(D1bin),std(D1bin),'lineprops',{'-','LineWidth',1.5,'color',C1},'transparent',1);
    shadedErrorBar(1:size(D2bin,2),mean(D2bin),std(D2bin),'lineprops',{'-','LineWidth',1.5,'color',C2},'transparent',1);
    PltClusters = nan(1,length(sigPval));
    PltClusters(sigPval==1) = 0;
    plot(1:length(PltClusters),PltClusters,'r','LineWidth',6);
    ylim([-2 6]);
    plot(1:size(D1bin,2),zeros(1,size(D1bin,2)),'k','LineWidth',1.5);
    xlabel('Stride Bins');
    ylabel('SAI (%)');
    title('Emperical Clusters - Washout');
    legend([condstr1 ' data'], [condstr2 ' data'], 'Custers');
    return
end
    
%Sum the t-stat of each cluster to obtain the cluster mass
for i = 1:length(startpos)
    ClusterMass(i) = sum(abs(tstat_emp(startpos(i):endpos(i))));
end
[clust_max_emp, max_cluster_idx] = max(ClusterMass);

%Plot the emperical data
figure; hold on
shadedErrorBar(1:size(D1bin,2),mean(D1bin),std(D1bin),'lineprops',{'-','LineWidth',1.5,'color',Cs(1,:)},'transparent',1);
shadedErrorBar(1:size(D1bin,2),mean(D2bin),std(D2bin),'lineprops',{'-','LineWidth',1.5,'color',Cs(10,:)},'transparent',1);
PltClusters = nan(1,length(sigPval));
PltClusters(sigPval==1) = 0;
plot(1:length(PltClusters),PltClusters,'r','LineWidth',5);
ylim([-2 6]);
plot([startpos(max_cluster_idx), startpos(max_cluster_idx)],[min(ylim) max(ylim)],'--k');
plot([endpos(max_cluster_idx), endpos(max_cluster_idx)],[min(ylim) max(ylim)],'--k');
plot(1:size(D1bin,2),zeros(1,size(D1bin,2)),'k','LineWidth',1.5);
text(50,5,['Largest Cluster Length = ' num2str(max(ClusterLen))]);
xlabel('Stride Bins');
ylabel('SAI (%)');
title('Emperical Clusters - Washout');
legend('Condition 1','Condition 2', 'All Custers', 'Largest Cluster');

%Plot the significant p values
figure; hold on
plot(p,'k','linewidth',1.5);
plot(xlim,[0.05 0.05],'-r');
xlabel('Stride Bins');
ylabel('p-value');

%Build a null distribution (shuffle without replacement 10k times)
grps = [ones(size(D1bin,1),1); ones(size(D2bin,1),1)*2];
permD = [D1bin;D2bin];
ndist = 10e2;
for n = 1:ndist

    %Shuffle groups
    permgrps = grps(randperm(size(grps,1)));
    %Reassign
    permD1 = permD(permgrps==1,:);
    permD2 = permD(permgrps==2,:); 

    %Obtain largest clusters for this new distribution 
    for nn = 1:size(permD1,2)
        [~,p_perm(nn),~,stats] = ttest(permD1(:,i),permD2(:,i));
        tstat_perm(nn) = stats.tstat;
    end
    sigP_perm = p_perm < alpha;

    %Find the longest string of sig tests for each:
    pval_perm_pad = [0 sigP_perm 0];
    edges_perm = diff(pval_perm_pad);
    rising_perm = find(edges_perm==1);
    falling_perm = find(edges_perm==-1);
    ClusterLen_perm = falling_perm - rising_perm;
    WideEnough_perm = ClusterLen_perm > minclust;

    %Mark the beginning and end of the clusters
    startpos_perm = rising_perm(WideEnough_perm);
    endpos_perm = falling_perm(WideEnough_perm)-1;

    %Sum the t-stat of each cluster to obtain the cluster mass
    if startpos_perm
        for ii = 1:length(startpos_perm)
            ClusterMass_perm(ii) = sum(abs(tstat_perm(startpos_perm(ii):endpos_perm(ii))));
        end
        tsum_null(n) = max(ClusterMass_perm);
    else
        tsum_null(n) = 0;
    end

end

%Calculate the exact p-value
exact_pval = sum(tsum_null>clust_max_emp)/ndist;

%plot null distribution
figure; hold on
histogram(tsum_null);
plot([clust_max_emp clust_max_emp],ylim,'--r');
xlabel('Cluster masses of null distribution');
ylabel('Frequency');
title(['P-val: ',num2str(exact_pval)]);

end