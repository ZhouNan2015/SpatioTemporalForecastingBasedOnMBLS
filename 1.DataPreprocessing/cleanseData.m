function [time, PV, meteor] = cleanseData(time, data)
    % Number of rows corresponding to meterological data
    idxMeteor = [1,2,3];
    % Number of rows corresponding to PV power output data
    idxPV = [19, 24, 27, 33, 36]; 
    NPV = numel(idxPV);

    meteor = data(:, idxMeteor);
    PV = data(:, idxPV);  

    % PV power is set to be non-negative
    [row, col] = find(PV < 0);
    for i = 1 : numel(row)
        PV(row(i), col(i)) = 0;
    end
    sunrise = zeros(NPV, 1);
    sunset = zeros(NPV, 1);
    for i = 1 : NPV
        idx = find(PV(:, i) > 0);
        idx = mod(idx, 288);
        sunrise(i) = min(idx);
        sunset(i) = max(idx);
    end

    % It is assumed that during night time PV power output is 0
    % The NaN data can be modified to be 0 accordingly
    [row, col] = find(isnan(PV));
    for i = 1 : numel(row)
        timestamp = mod(row(i), 288);
        if timestamp <= 67 || timestamp >= 241
            PV(row(i), col(i)) = 0;
        end
    end

     % Count the number of NaN data during daytime
    numNaNP = zeros(365, NPV);
    numNaNM = zeros(365, numel(idxMeteor));
    for i = 1 : NPV
        numNaNP(:, i) = countNaN(PV(:, i));
    end
    for i = 1 : numel(idxMeteor)
        numNaNM(:, i) = countNaN(meteor(:, i));
    end
    % The dates with more than 10 NaNs are considered to be invalid
    [rowP, ~] = find(numNaNP >= 10);
    [rowM, ~] = find(numNaNM >= 10);
    invalidP = unique(rowP);
    invalidM = unique(rowM);
    invalid = union(invalidP, invalidM);

    invalidDates = zeros(numel(invalid), 2);
    for i = 1 : numel(invalid)
        date = datetime(2019,1, invalid(i));
        vec = datevec(date);
        invalidDates(i, :) = vec(2:3);
    end

    % Remove the data of invalid dates
    range = [];
    for i = 1 : numel(invalid)
        idx = invalid(i);
        range = [range, (idx-1) * 288 + 1: idx * 288];
    end
    time(range, :) = [];
    PV(range, :) = [];
    meteor(range, :) = [];

    % There still exists NaN entries in the rest of the dataset
    % Linear interpolation is applied to complement the dataset
    for i = 1 : numel(idxPV)
        arr = PV(:, i);
        idx = find(isnan(arr));
        ptr1 = 1;
        while (ptr1 <= numel(idx))
            ptr2 = ptr1;
            while (ptr2 < numel(idx) && idx(ptr2+1) == idx(ptr2)+1)
                ptr2 = ptr2 + 1;
            end
            x1 = arr(idx(ptr1)-1);
            x2 = arr(idx(ptr2)+1);
            N = ptr2 - ptr1 + 2;

            for j = 1 : N - 1
                arr(idx(ptr1) + j -1) = x1 + (x2 - x1) * j / N;
            end
            ptr1 = ptr2 + 1;
        end
        PV(:, i) = arr;
    end

    for i = 1 : numel(idxMeteor)
        arr = meteor(:, i);
        idx = find(isnan(arr));
        ptr1 = 1;
        while (ptr1 <= numel(idx))
            ptr2 = ptr1;
            while (ptr2 < numel(idx) && idx(ptr2+1) == idx(ptr2)+1)
                ptr2 = ptr2 + 1;
            end
            x1 = arr(idx(ptr1)-1);
            x2 = arr(idx(ptr2)+1);
            N = ptr2 - ptr1 + 2;

            for j = 1 : N - 1
                arr(idx(ptr1) + j -1) = x1 + (x2 - x1) * j / N;
            end
            ptr1 = ptr2 + 1;
        end
        meteor(:, i) = arr;
    end
end