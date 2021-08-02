function [new3mkr1, new3mkr2] = CorrectMarkers(mkr1,mkr2,direction,curtrl,sub,pltstr)
%This function finds flipped markers in motion monitor kinematic data and
%flips them back. It should be robust enough to deal with any markers as
%long as a few assumptions are followed: 
% 1. Marker 1 should always be larger (in terms of position) than marker 2
% 2. Markers are compared to each other (only 2 at a time)
% 3. Markers are checked only along one axis at a time
%--------------------------------------------------------------------------

%Sets a certain threshold for specific axis, also sets the indexing
%variable for that axis
if strcmp(direction,'X')==1
    dirnum = 1;
elseif strcmp(direction,'Y')==1
    dirnum = 2;
elseif strcmp(direction,'Z')==1
    dirnum = 3;
else
    error('Input X Y or Z for direction');
end

%Get the names of the markers:
mkr1str = inputname(1);
mkr2str = inputname(2);
%Initialize the legend
l = {mkr1str,mkr2str};

%Sets the titles for plotting
t1 = [mkr1str ' and ' mkr2str ' FLIPPED markers - ' curtrl];
t2 = [mkr1str ' and ' mkr2str ' CORRECTED markers - ' curtrl];

%-------------------------------------
%Flips markers where both have flipped sides

%Pre-allocate the new marker positions: 
newmkr1 = mkr1;
newmkr2 = mkr2;

%Correct markers where bother have flipped (1 should be greater than 2):
bothflpd = find(newmkr1(:,dirnum) < newmkr2(:,dirnum));
%Correct if both flipped:
newmkr1(bothflpd,:) = mkr2(bothflpd,:);
newmkr2(bothflpd,:) = mkr1(bothflpd,:);
%-------------------------------------
%This flips just a single marker (sometimes there are gaps in one marker
%while the other is flipped)
%Acomplishes this by making sure the marker does not enter the average peak
%or trough of the other marker

%Pre-allocate the newest marker positions: 
new2mkr1 = newmkr1;
new2mkr2 = newmkr2;

%Find the deviation from the mean for each frame
newmkr1mean = nanmean(newmkr1);   newmkr2mean = nanmean(newmkr2);
newmkr1mdev = abs(newmkr1(:,dirnum)-newmkr1mean(dirnum));    
newmkr2mdev = abs(newmkr2(:,dirnum)-newmkr2mean(dirnum)); 

%To make the threshold generalizable, take the mean local minima of marker 1 and
%the mean local maxima of marker 2. Get the difference and add a bit more
%that is manually set depending on the standard distance between the two. 
mrk1minima = abs(findpeaks(-new2mkr1(:,dirnum),'MinPeakProminence',0.005));
mkr2maxima = findpeaks(new2mkr2(:,dirnum),'MinPeakProminence',0.005);
thresh = (nanmean(mrk1minima) - nanmean(mkr2maxima)) - sub;

%Using threshold which depends on the axis we are working with, find
%markers that lie outside of this threshold.
mkr1flp = find(newmkr1mdev > thresh);
mkr2flp = find(newmkr2mdev > thresh);

%Make marker 1 marker 2 
new2mkr1(mkr1flp,:) = nan;
new2mkr2(mkr1flp,:) = newmkr1(mkr1flp,:);

%Make marker 2 marker 1 
new2mkr2(mkr2flp,:) = nan;
new2mkr1(mkr2flp,:) = newmkr2(mkr2flp,:);

%-------------------------------------
%If markers are way off delete them using the same threshold as above

new3mkr1 = new2mkr1;
new3mkr2 = new2mkr2;

%Find the deviation from the mean for each frame
newmkr1mean2 = nanmean(new2mkr1);   newmkr2mean2 = nanmean(new2mkr2);
newmkr1mdev2 = abs(new2mkr1(:,dirnum)-newmkr1mean2(dirnum));    
newmkr2mdev2 = abs(new2mkr2(:,dirnum)-newmkr2mean2(dirnum)); 
mkr1del = find(newmkr1mdev2 > thresh);
mkr2del = find(newmkr2mdev2 > thresh);

new3mkr1(mkr1del,:) = nan;
new3mkr2(mkr2del,:) = nan;

%-------------------------------------

% Plot if there were errors 
if isempty(bothflpd)==0 || isempty(mkr1flp)==0 || isempty(mkr2flp)==0 || isempty(mkr1del)==0 || isempty(mkr2del)==0

    %Set the legend depending on what has been corrected:
    if isempty(bothflpd)==0
        l{end+1} = 'Both Flipped';
    end
    if isempty(mkr1flp)==0
        l{end+1}= [mkr1str ' Flipped'];
    end
    if isempty(mkr2flp)==0
        l{end+1} = [mkr2str ' Flipped'];
    end
    if isempty(mkr1del)==0
        l{end+1} = [mkr1str ' Deleted'];
    end
    if isempty(mkr2del)==0
        l{end+1} = [mkr2str ' Deleted'];
    end
    
    %Find the mean difference between markers for plotting
    mkrdiff = nansum([mkr1(:,dirnum),-mkr2(:,dirnum)],2);
    meandiff = nanmean(mkrdiff);   

    if strcmp(pltstr,'Yes');
        figure; subplot(2,1,1); hold on
        plot(mkr1(:,dirnum));
        plot(mkr2(:,dirnum));
        plot(bothflpd,ones(length(bothflpd),1)*meandiff,'m*');
        plot(mkr1flp,ones(length(mkr1flp),1)*meandiff,'r*');
        plot(mkr2flp,ones(length(mkr2flp),1)*meandiff,'k*');  
        plot(mkr1del,ones(length(mkr1del),1)*meandiff,'c*');  
        plot(mkr2del,ones(length(mkr2del),1)*meandiff,'b*');  
        legend(l);
        title(t1);
        ylabel([direction ' direction']); xlabel('Sample');

        %Plot the corrected markers
        subplot(2,1,2); hold on
        plot(new3mkr1(:,dirnum));
        plot(new3mkr2(:,dirnum));
        plot(bothflpd,ones(length(bothflpd),1)*meandiff,'m*');
        plot(mkr1flp,ones(length(mkr1flp),1)*meandiff,'r*');
        plot(mkr2flp,ones(length(mkr2flp),1)*meandiff,'k*'); 
        plot(mkr1del,ones(length(mkr1del),1)*meandiff,'c*');  
        plot(mkr2del,ones(length(mkr2del),1)*meandiff,'b*'); 
        title(t2);
%         savefig(t2);
    end
end
end