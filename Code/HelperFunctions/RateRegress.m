function Rates = RateRegress(RateData,numstr)

%Calculates the washout rate as the autoregression

%Input: 
%RateData = data to autoregress, needs to be set up such that columns are
%the data and rows are subjects 
%numstr = number of strides to consider for the data

%Size of the data (rows are subjects, columns are the data to autoregress)
[r c] = size(RateData);

%Loop through each subject
for i=1:r
   %Set up regression
   x = RateData(i,1:numstr);
   y = x(2:end);
   X = [ones(length(y),1) , x(1:end-1)'];
   
   %Regress
   b = regress(y',X);

   %Calculate forgetting 
   Rates(i) = 1-b(2);
end
end