function YPred = QRMBLS(trainX, trainY, testX, testY, numFea, numWin, numEnhan, ...
    idxM, taus, capacity, threshold, lamVM, lamWM, lamWI, batchsize)
    N = size(trainX, 1);
    K = numel(taus);
    
    trainXM = trainX(:, idxM);
    trainXI = trainX; trainXI(:, idxM) = [];
   
    % Feature nodes
    F = zeros(size(trainXI, 1), numWin * numFea);
    Xbias = [trainXI, 0.1 * ones(size(trainXI,1),1)];
    for i = 1:numWin
        weightFea = 2 * rand(size(trainXI,2)+1,numFea) - 1;
        T1 = Xbias * weightFea;
        T1 = mapminmax(T1);
        clear weightFea;

        weightFeaSparse = blsSparse(T1,Xbias,1e-3,50)';
        WFSparse{i} = weightFeaSparse;

        Fi = Xbias * weightFeaSparse;
        [Fi, psi] = mapminmax(Fi',0,1);    
        Fi = Fi';   ps(i) = psi;
        F(:, numFea*(i-1)+1:numFea*i) = Fi;
    end
    clear XBias; clear Fi;

    % Enhancement nodes
    weightEnhan = 2 * rand(numWin*numFea, numEnhan) - 1;
    
    VM = 2 * rand(1, numEnhan) - 1;
    WI = 2 * rand(numFea * numWin, 1) - 1;
    WM = 2 * rand(numEnhan, 1) - 1;
    alpha = 2 * rand(1, numEnhan) - 1;
    beta = 2 * rand() - 1;
    
    mWI = zeros(numFea * numWin, 1);
    mWM = zeros(numEnhan, 1);
    mBeta = 0;
    mVM = zeros(1, numEnhan);
    mAlpha = zeros(1, numEnhan);
    
    vWI = zeros(numFea * numWin, 1);
    vWM = zeros(numEnhan, 1);
    vBeta = 0;
    vVM = zeros(1, numEnhan);
    vAlpha = zeros(1, numEnhan);
    
    lr = 0.001;
    beta1 = 0.9; beta2 = 0.999; 
    eps = 1e-8;
    epochs = 5000;
    gamma = 1e-10;
    
    tmp = F * weightEnhan;
    batch_size = K * batchsize;
    batches = N / batch_size;
    batch_size_pertau = batch_size / K;
    N_pertau = N / K;
    
    loss = zeros(epochs, 1);
    minLoss = 1e8;
    maxNotImp = 20;
    notImp = 0;
    WMopt = WM;
    WIopt = WI;
    betaopt = beta;
    VMopt = VM;
    alphaopt = alpha;
    C = capacity;
        
    for itr = 1 :epochs
        for b = 1 : batches
            range = [];
            for i = 1 : K
                range = [range (b-1)*batch_size_pertau + 1 + (i-1)*N_pertau :...
                    b*batch_size_pertau + (i-1)*N_pertau];
            end
            XM = trainXM(range, :);
            Y = trainY(range, :);
            F_batch = F(range, :);
            E = tansig(tmp(range, :) + XM * VM.^2 + alpha);
            YPred = F(range, :) * WI + E * WM.^2 + beta;

            gradWI = zeros(numFea * numWin, 1);
            gradWM = zeros(numEnhan, 1);
            gradBeta = 0;
            gradVM = zeros(1, numEnhan);
            gradAlpha = zeros(1, numEnhan);

            for t = 1 : batch_size
                tau = XM(t);
                err = Y(t) - YPred(t);

                if err >= 0 && err <= gamma
                    coeff1 = tau * err / gamma;
                elseif err > gamma
                    coeff1 = tau;
                elseif err < -gamma
                    coeff1 = tau-1;
                else
                    coeff1 = (1-tau) * err / gamma;
                end
                
                if YPred(t) < 0 || YPred(t) > C + gamma
                    coeff2 = 0;
                elseif YPred(t) >= 0 && YPred(t) <= gamma
                    coeff2 = YPred(t) / gamma;
                elseif YPred(t) > gamma && YPred(t) < C
                    coeff2 = 1;
                else
                    coeff2 = (C + gamma - YPred(t)) / gamma;
                end

                for i = 1 : numFea * numWin
                    gradWI(i, 1) = gradWI(i, 1) - coeff1 * coeff2 * F_batch(t, i) / batch_size + ...
                        lamWI * WI(i, 1) / numFea / numWin;
                end
                for i = 1 : numEnhan
                    gradWM(i, 1) = gradWM(i, 1) - coeff1 * coeff2 * 2 * E(t, i) * WM(i, 1) / batch_size + ...
                        lamWM * WM(i, 1) / numEnhan;
                end
                gradBeta = gradBeta - coeff1 * coeff2 / batch_size;
                for i = 1 : numEnhan
                    gradVM(1, i) = gradVM(1, i) - coeff1 * coeff2 *  WM(i, 1)^2 * ...
                            (1 - E(t, i)^2) * 2 * XM(t, 1) * VM(1, i) / batch_size + ...
                            lamVM * VM(1, i) / numEnhan; 
                end
                for i = 1 : numEnhan
                    gradAlpha(1, i) = gradAlpha(1, i) - coeff1 * coeff2 * WM(i, 1).^2 * ...
                            (1 - E(t, i)^2) / batch_size;
                end
            end

            mWI = beta1 * mWI + (1-beta1) * gradWI;
            vWI = beta2 * vWI + (1-beta2) * gradWI.^2;
            mhatWI = mWI / (1 - beta1 ^ itr);
            vhatWI = vWI / (1 - beta2 ^ itr);
            deltaWI = lr * mhatWI ./ (sqrt(vhatWI) + eps);

            mWM = beta1 * mWM + (1-beta1) * gradWM;
            vWM = beta2 * vWM + (1-beta2) * gradWM.^2;
            mhatWM = mWM / (1 - beta1 ^ itr);
            vhatWM = vWM / (1 - beta2 ^ itr);
            deltaWM = lr * mhatWM ./ (sqrt(vhatWM) + eps);

            mBeta = beta1 * mBeta + (1-beta1) * gradBeta;
            vBeta = beta2 * vBeta + (1-beta2) * gradBeta.^2;
            mhatBeta = mBeta / (1 - beta1 ^ itr);
            vhatBeta = vBeta / (1 - beta2 ^ itr);
            deltaBeta = lr * mhatBeta ./ (sqrt(vhatBeta) + eps);

            mVM = beta1 * mVM + (1-beta1) * gradVM;
            vVM = beta2 * vVM + (1-beta2) * gradVM.^2;
            mhatVM = mVM / (1 - beta1 ^ itr);
            vhatVM = vVM / (1 - beta2 ^ itr);
            deltaVM = lr * mhatVM ./ (sqrt(vhatVM) + eps);

            mAlpha = beta1 * mAlpha + (1-beta1) * gradAlpha;
            vAlpha = beta2 * vAlpha + (1-beta2) * gradAlpha.^2;
            mhatAlpha = mAlpha / (1 - beta1 ^ itr);
            vhatAlpha = vAlpha / (1 - beta2 ^ itr);
            deltaAlpha = lr * mhatAlpha ./ (sqrt(vhatAlpha) + eps);

            WM = WM - deltaWM;
            WI = WI - deltaWI;
            beta = beta - deltaBeta;
            VM = VM - deltaVM;
            alpha = alpha - deltaAlpha;
            
        end
        [loss(itr), pureLoss] = lossFunc(trainXM, F, tmp, VM, alpha, ...
                WI, WM, beta, trainY, lamVM, lamWM, lamWI,capacity);
        if loss(itr) < minLoss
            minLoss = loss(itr);
            notImp = 0;
            WMopt = WM;
            WIopt = WI;
            betaopt = beta;
            VMopt = VM;
            alphaopt = alpha;
        else
            notImp = notImp + 1;
        end
%         plot(loss)
        if notImp >= maxNotImp
            WM = WMopt;
            WI = WIopt;
            beta = betaopt;
            VM = VMopt;
            alpha = alphaopt;
            disp("No improvements!")
            disp(minLoss)
            break;
        end
        if itr > 1 && abs(loss(itr)  - loss(itr - 1)) < threshold
                disp("Converge!")
                disp(loss(itr))
                disp(pureLoss)
                break
        end
    end


    
    Ntest = size(testX, 1);
    testXM = testX(:, idxM);
    testXI = testX; testXI(:, idxM) = [];
    
    
    XbiasTest = [testXI 0.1 * ones(size(testXI,1),1)];
    FTest = zeros(size(testXI, 1), numWin * numFea);
    for i = 1:numWin
        weightFeaSparse = WFSparse{i};   ps1=ps(i);
        FiTest = XbiasTest * weightFeaSparse;
        FiTest = mapminmax('apply', FiTest', ps1)';

        clear weigthSparse; clear ps1;
        FTest(:, numFea*(i-1)+1:numFea*i) = FiTest;
    end
    clear XbiasTest; clear FiTest;
     
    YPred = FTest * WI + ...
        tansig(testXM * VM.^2 + FTest * weightEnhan + ones(Ntest, 1) * alpha) * WM.^2 + beta;
    for i = 1 : size(YPred, 1)
        if YPred(i) > capacity
            YPred(i) = capacity;
        elseif YPred(i) < 0
            YPred(i) = 0;
        end
    end
end