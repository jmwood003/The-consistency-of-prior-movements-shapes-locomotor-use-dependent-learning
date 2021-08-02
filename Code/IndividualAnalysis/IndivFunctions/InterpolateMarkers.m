function T = InterpolateMarkers(T,savestr,pltstr)
%This function interpolates marker data 

%Pick which markers to plot (Y direction with the primary markers matter
%most)
pltmkrs = {'RHLBY','LHLBY','RMALY','LMALY','RTRCY','LTRCY'};

%Extract the corrected marker names
Allvars = T.Properties.VariableNames;
Cmkrsidx = find(not(cellfun('isempty',strfind(Allvars,'_cor'))));
mkr_names = Allvars(Cmkrsidx);

%Loop through each marker
for mkr_i = 1:length(mkr_names)
    
    %Extract current marker data
    curmkr = mkr_names{mkr_i};
    newmkrStr = [curmkr(1:6) 'interp'];
    phases = unique(T.phase);
    
    %Loop through each phase
    interp_mkr = [];
    for phase_i = 1:length(phases)
    
        %Index marker
        phaseidx = find(strcmp(phases{phase_i},T.phase)==1);
        mkr = T.(curmkr)(phaseidx);
        origmkr = mkr; %Save the orignal values for plotting
        
        %Find the gaps 
        misvals = find(isnan(mkr)==1);
        
        %Make sure there are values at the beginning and end if not,
        %do not interpolate these values
        if misvals(1) == 1
            realnums = find(isnan(mkr)~=1);
            includeidx = find(misvals>realnums(1));
            misvals = misvals(includeidx);
            mkr(1:realnums(1)) = mkr(realnums(1));
        end
        if misvals(end) == length(mkr)
            realnums = find(isnan(mkr)~=1);
            includeidx = find(misvals<realnums(end));
            misvals = misvals(includeidx);
            mkr(realnums(end):end) = mkr(realnums(end)); %replace 
        end
        
        if length(misvals)==length(mkr)
            T.(newmkrStr)(phaseidx) = mkr;  
        else
            
        %Interpolate and replace missing values with interpolated values
        interpvals = spline(1:length(mkr),mkr,misvals);
        mkr(misvals) = interpvals;
        %Save new marker positions
        interp_mkr = [interp_mkr; mkr];
        end
        
        %Plot
        if ismember(curmkr(1:5),pltmkrs)==1 && strcmp(pltstr,'Yes')==1
            figure; hold on
            plot(origmkr);
            plot(misvals,interpvals,'r*');
            savename = ['Interpolation - ' phases{phase_i} ' (' curmkr(1:5) ') new'];
            title(savename);
            legend('original data','interpolated data');
            xlabel('Frames');
            ylabel('Position');
            if strcmp(savestr,'Yes')==1
                savefig(savename)
            end
        end
    
    end
    
    %Save interpolated markers back into table
    T.(newmkrStr) = interp_mkr;  

end
end