function Rates = RateRegress(RateData,numstr)

[r c] = size(RateData);

for i=1:r
   x = RateData(i,1:numstr);
   y = x(2:end);
   X = [ones(length(y),1) , x(1:end-1)'];
   b = regress(y',X);

   Rates(i) = b(2);
end
% figure; hold on
% plot(x(1:end-1),x(2:end),'k.');
% xfit = min(x):max(x);
% yfit = b(1)+b(2)*xfit;
% p1 = plot(xfit,yfit,'b-');
% xlabel('Stride N');
% ylabel('Stride N+1');
% slopestr = ['b = ' num2str(b(2))];
% legend([p1],slopestr);

%the slope is the amount held on from one stride to the next (the amount
%remembered), 1- the slope is the amount forgotton.
%So for 1-b, higher means faster forgetting, lower means slower forgetting

% figure; hold on
% plot(RateData(1,:));

end