function eta = eta_p2(sseffect,sse)

%Calculate partial eta squared 

%sseffect = sum of squares effect
%sse = sum of squared error

eta = (sseffect)/(sseffect+sse);

end