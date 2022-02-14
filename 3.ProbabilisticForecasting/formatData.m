function [X, Y] = formatData(PV, meteor, validM, NlagP, NlagM, Nlead)
    N = size(PV, 1); 
    Ndays = N / 288;
    ts = zeros(N, 1);
    for i = 1 : Ndays
        ts((i-1)*288+1: i*288) = 0:287;
    end
    
    X = zeros(N, NlagP + numel(validM)*NlagM + 1);
    Y = zeros(N, Nlead);
    for i = 1 : N
        for j = 1 : NlagP
            if i - j <= 0
                continue
            end
            X(i, j) = PV(i-j);
        end
        for k = 1:numel(validM)
            for j = 1 : NlagM
                if i - j <= 0
                    continue
                end
                X(i, j + NlagP + (k-1) * NlagM) = meteor(i - j, validM(k));
            end
        end
        X(i, end) = ts(i);
    end

    for i = 1 : N
        for j = 1 : Nlead
            if (i + j - 1 > N)
                continue
            end
            Y(i, j) = PV(i + j - 1);
        end
    end
end