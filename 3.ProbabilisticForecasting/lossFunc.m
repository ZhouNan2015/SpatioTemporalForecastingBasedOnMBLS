function [loss,pureLoss] = lossFunc(XM, F, tmp, VM, alpha, WI, WM, beta, Y, ...
    lamVM, lamWM, lamWI, capacity)
    N = size(XM, 1);

    Z = tmp + XM * VM.^2 + alpha;
    E = tansig(Z);
    YPred = F * WI + E * WM.^2 + beta;
    
    loss = 0;
    for i = 1 : N
        tau = XM(i);
        if YPred(i) > capacity
            censored = capacity;
        elseif YPred(i) < 0
            censored = 0;
        else
            censored = YPred(i);
        end
            
        if Y(i) - censored >= 0
            loss = loss + tau * (Y(i) - censored);
        else
            loss = loss + (tau - 1) * (Y(i) - censored);
        end
    end
    loss = loss / N;
    
    pureLoss = loss;
    
    NI = size(WI, 1);
    NM = size(WM, 1);
    for i = 1 : NI
        loss = loss + lamWI * WI(i, 1)^2 / NI / 2;
    end
    for i = 1 :NM
        loss = loss + lamWM * WM(i, 1)^2 / NM / 2;
        loss = loss + lamVM * VM(1, i)^2 / NM / 2;
    end
end