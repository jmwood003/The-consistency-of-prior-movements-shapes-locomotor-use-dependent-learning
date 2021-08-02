function ET = CheckEvents(ET)
% This function makes sure the events calculated by velocity, marker
% position and motion monitor stride detector live line up correctly. 

%Index and loop through each phase of the experiment
phases = unique(ET.phase);
NewEvents = [];
for p = 1:length(phases)
    
    %Index current phase
    phaseidx = find(strcmp(phases{p},ET.phase)==1);
    
    %Index event names (LHS, RHS, LTO, RTO) and loop through each of them
    Allvars = ET.Properties.VariableNames;
    Vmkrsidx = find(not(cellfun('isempty',strfind(Allvars,'V'))));
    Pmkrsidx = find(not(cellfun('isempty',strfind(Allvars,'pos'))));
    Velnms = Allvars(Vmkrsidx);
    Pkrnms = Allvars(Pmkrsidx);

    %Loop through each event
    CorEventsArray = nan(length(phaseidx),5);    
    newStr = {};
    for mkrsi = 1:length(Velnms)
         
        %Index each type of event for this phase
        Vevents = ET.(Velnms{mkrsi})(phaseidx); %velocity events
        Vevents = Vevents(isnan(Vevents)==0);
        Pevents = ET.(Pkrnms{mkrsi})(phaseidx); %Position events
        Pevents = Pevents(isnan(Pevents)==0);        
        Mevents = ET.StrideChange(phaseidx);   %Events from live detection
        Mevents = Mevents(isnan(Mevents)==0);
        
        
        %Delete extra events-----------------------------------------------
        %First determine if there are any extra events in the velocity
        %event calculation by comparing the deviation from the mean
        %number of frames between events
        meandevV = nanmean(diff(Vevents));
        
        %Set threshold
        lowtresh = meandevV/1.5;
        
        %Events that occur too soon after each other will be removed
        earlyidxV = find(diff(Vevents) < lowtresh);
        earlyidxP = find(diff(Pevents) < lowtresh);
        Vevents(earlyidxV) = [];
        Pevents(earlyidxP) = [];
        
        %Compare each type of events to make sure they line up properly----
        %Initiate a varible to adjust indexing when an event has been added
        addidx = 0;
        %Reset variable
        newVevents = [];
        for i = 1:length(Pevents)
            %Makes sure we dont over-index
            if i-addidx > length(Vevents)
                Vevents(end+1) = Pevents(i);
            end
            %Calculate difference between events             
            Vstrdiff = Vevents(i-addidx) - Pevents(i);
            %If events are too far add the velocity event to the stride count 
            if Vstrdiff > 50
                newVevents(i,1) = Pevents(i);
                addidx = addidx + 1; %adjusts the index to keep up with the change
            elseif Vstrdiff < -100
                newVevents(i,1) = Pevents(i);
                addidx = addidx - 1;
            else
                newVevents(i,1) = Vevents(i-addidx); %otherwise keep the same event
            end
        end      
        
        %For LHS events correct the live detection events (these are based
        %on left heel strikes)
        
        if strcmp(Velnms{mkrsi},'LHSV_Frames')==1
            
            %Delete any extra events in the live detection 
            meandevM = nanmean(diff(Mevents));            
            earlyidxM = find(diff(Mevents) < (meandevM/1.5));
            Mevents(earlyidxM) = [];
             
            %Initiate a varible to adjust indexing when an event has been added
            addidx = 0;
            %Reset variable
            newstrcount = [];
            %Loop through each event
            for i = 1:length(newVevents)
                
                %Calculate difference between events
                if i-addidx > length(Mevents)
                    LiveEvent = Mevents(end);
                else
                    LiveEvent = Mevents(i-addidx);
                end
                Vstrdiff = LiveEvent - newVevents(i);
                %If events are too far add the velocity event to the stride
                %count under a different variable name 
                if Vstrdiff > 50
                    newstrcount(i,1) = newVevents(i);
                    addidx = addidx + 1; %adjusts the index to keep up with the change
                elseif Vstrdiff < -50
                    newstrcount(i,1) = newVevents(i);
                    addidx = addidx - 1;                    
                else
                    newstrcount(i,1) = LiveEvent; %otherwise keep the same event
                end
            end
            %Add back into structure 
            CorEventsArray(1:length(newVevents),5) = newstrcount;
            dblcheck = sum((newstrcount-newVevents)>50);
            if dblcheck > 0
                disp('Live and Vel events not lined up perfectly');
            else
                disp('Live and Vel events are lined up');
            end
            
        end
        %Add back into Array 
        CorEventsArray(1:length(newVevents),mkrsi) = newVevents;
        newStr = [newStr, [Velnms{mkrsi} '_cor']];

    end
    
    NewEvents = [NewEvents; CorEventsArray];

end

newStr{5} = 'StrideChange_cor';
ET = [ET, array2table(NewEvents,'VariableNames',newStr)];

end
