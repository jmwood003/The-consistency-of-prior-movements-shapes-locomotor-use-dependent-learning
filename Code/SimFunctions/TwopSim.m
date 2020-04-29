function [x,W,S] = TwopSim(params,t)

%C = strategic correction percentage/learning rate
%A = strategic retention rate
%E = UD retention rate
%F = UD learning rate

C = params(1);
A = params(2);
E = params(3);
F = params(4);

%Inialtize the variables
x(1) = 0;
W(1) = 0;
S(1) = 0;
W0 = 0;

%Simulate
for n = 1:length(t)-1

    %Error 
    err(n) = t(n) - x(n);

    %Strategic component
    if t(n) == 0       %When the target is 0 this whole term S should also equal 0
        S(n+1) = 0;
    else
        S(n+1) = C*(err(n))+A*S(n); 
    end

    %Use dependent component 
    W(n+1) = E*W(n)+F*x(n) + (1-E-F)*W0;

    %Step asymmetry
    x(n+1) = S(n+1)+W(n+1);
    
end

end

