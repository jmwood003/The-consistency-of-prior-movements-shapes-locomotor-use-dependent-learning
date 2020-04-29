function Rates = RateRegress(RateData,numstr)

[r c] = size(RateData);

for i=1:r
   x = RateData(i,1:numstr);
   y = x(2:end);
   X = [ones(length(y),1) , x(1:end-1)'];
   b = regress(y',X);

   Rates(i) = 1-b(2);
end
% plot(x(1:end-1),x(2:end),'k.')
% plot(RateData(1,:))

end