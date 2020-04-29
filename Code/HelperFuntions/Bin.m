function [ Binned_array ] = Bin( Array,nBins,dim,fun )
%Jonathan Wood
%8/25/19
%--------------------------------------------------------------------------
%General:
%This is a sub function which bins an array
%--------------------------------------------------------------------------
%Input:
%Array: any size array. Does not have to be a single dimension because the
%dimension will be specified

%nBins: the number of bins desired

%dim: dimension desired to compress the data into bins. 
%If dim = 1, the function will bin columns
%If dim = 2, the function will bin rows

%fun: function desired. Input is in the form of a string.
%Currently this function only does mean or standard deviation. 
%Example: 'mean' or 'std'
%--------------------------------------------------------------------------
%Output: 
%an array with the same dimensions as the input array but compressed by
%nbins
%--------------------------------------------------------------------------
%This function is called in several scripts
%--------------------------------------------------------------------------



Binned_array = [];
[row, col] = size(Array);

if strcmp(fun,'mean')==1
    if dim == 1
        %This for loop is used to bin columns 
        for vector_i = 1:row
            current_array = Array(vector_i,:);
            start_idx = 1;  end_idx = nBins;
            single_binned_array = [];
            for i = 1:(round(col/nBins))
                if end_idx > length(current_array)
                   current_idx = start_idx:length(current_array);
                else
                    current_idx = start_idx:end_idx;
                end
                bin_mean = mean(current_array(current_idx));
                single_binned_array = [single_binned_array, bin_mean];
                start_idx = start_idx + nBins; end_idx = end_idx + nBins;
            end
            Binned_array = [Binned_array; single_binned_array];
        end

    elseif dim == 2
        %This for loop is used to bin rows 
        for vector_i = 1:col
            current_array = Array(:,vector_i);
            start_idx = 1;  end_idx = nBins;
            single_binned_array = [];
            for i = 1:(round(row/nBins))
                if end_idx > length(current_array)
                   current_idx = start_idx:length(current_array);
                else
                    current_idx = start_idx:end_idx;
                end
                bin_mean = mean(current_array(current_idx));
                single_binned_array = [single_binned_array; bin_mean];
                start_idx = start_idx + nBins; end_idx = end_idx + nBins;
            end
            Binned_array = [Binned_array, single_binned_array];
        end    

    end

elseif strcmp(fun,'std')==1
    
    if dim == 1
        %This for loop is used to bin columns 
        for vector_i = 1:row
            current_array = Array(vector_i,:);
            start_idx = 1;  end_idx = nBins;
            single_binned_array = [];
            for i = 1:(round(col/nBins))
                if end_idx > length(current_array)
                   current_idx = start_idx:length(current_array);
                else
                    current_idx = start_idx:end_idx;
                end
                bin_mean = std(current_array(current_idx));
                single_binned_array = [single_binned_array, bin_mean];
                start_idx = start_idx + nBins; end_idx = end_idx + nBins;
            end
            Binned_array = [Binned_array; single_binned_array];
        end

    elseif dim == 2
        %This for loop is used to bin rows 
        for vector_i = 1:col
            current_array = Array(:,vector_i);
            start_idx = 1;  end_idx = nBins;
            single_binned_array = [];
            for i = 1:(round(row/nBins))
                if end_idx > length(current_array)
                   current_idx = start_idx:length(current_array);
                else
                    current_idx = start_idx:end_idx;
                end
                bin_mean = std(current_array(current_idx));
                single_binned_array = [single_binned_array; bin_mean];
                start_idx = start_idx + nBins; end_idx = end_idx + nBins;
            end
            Binned_array = [Binned_array, single_binned_array];
        end    

    end

else
    disp('Fun must be a string and must be either mean or std. No other funtions are accpeted at this time')
end
    

end

