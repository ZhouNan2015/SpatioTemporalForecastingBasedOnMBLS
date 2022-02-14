function wk = blsSparse(A, b, kappa, itrs)
    AA = (A') * A;
    m = size(A, 2);
    n = size(b, 2);
    x = zeros(m, n);
    wk = x; ok = x; uk = x;
    L1 = eye(m) / (AA + eye(m));
    L2 = L1 * A' * b;

    for i = 1 : itrs
        ck =  L2 + L1 * (ok - uk);
        ok = shrinkage(ck + uk, kappa);
        uk = uk + (ck - ok);
        wk = ck;
    end
end


function z = shrinkage(x, kappa)
    z = max(x-kappa, 0) - max(-x-kappa ,0);
end


