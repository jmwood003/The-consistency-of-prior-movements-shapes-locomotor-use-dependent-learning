function T = FilterMarkers(T)

%Extract trial names
Allvars = T.Properties.VariableNames;
Cmkrsidx = find(not(cellfun('isempty',strfind(Allvars,'_interp'))));
mkr_names = Allvars(Cmkrsidx);

%Loop through all the markers
for mkr_i = 1:length(mkr_names)

    %Index current marker name
    curmkr = mkr_names{mkr_i};
    newmkrStr = [curmkr(1:6) 'filt'];
    phases = unique(T.phase);
    
    %Loop through each phase
    filt_mkr = [];
    %Loop through each trial
    for phase_i = 1:length(phases)
        
        %Index marker
        phaseidx = find(strcmp(phases{phase_i},T.phase)==1);
        mkr = T.(curmkr)(phaseidx);
    
        %Filter data
        mkrfilt = lowpassfilter(mkr,10,4,100);
        filt_mkr = [filt_mkr; mkrfilt];
    end
    %Save back into table
    T.(newmkrStr) = filt_mkr;
end
end