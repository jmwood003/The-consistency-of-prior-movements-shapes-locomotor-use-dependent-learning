function [x,W,S] = SU2sim(params,t,Condidx)

%Simulate modified SU model

C = params(1);
A = params(2);
E = params(3);
Fc = params(4);
gammaLV = params(5);
gammaHV = params(6);

%Inialtize the variables
x(1) = 0;
W(1) = 0;
S(1) = 0;
W0 = 0;

%Simulate
for n = 1:size(t,2)-1

    %Error 
    err(n) = t(n) - x(n);

    %Strategic component
    if t(n+1) == 0       %When the target is 0 this whole term S should also equal 0
        S(n+1) = 0;
    else
        S(n+1) = C*(err(n)) + A*S(n); 
    end

    %Use dependent component 
    %Gain specific learning rate
    if Condidx(n+1)==1
        F = 1 * Fc;
    elseif Condidx(n+1)==2
        F = gammaLV * Fc;
    elseif Condidx(n+1)==3
        F = gammaHV * Fc;
    end
    
    W(n+1) = E*W(n)+F*x(n) + (1-E-F)*W0;

    %Step asymmetry
    x(n+1) = S(n+1)+W(n+1);
    
end


end

