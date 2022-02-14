function [time, data] = loadData(filepath)
    [data, str] = xlsread(filepath, 1);

    N = size(data, 1);
    timestr = str(2:end, 1);
    time = zeros(N, 4);
    
    % Transfer date & time from strings to integer arrays
    for i = 1 : N
        temp = timestr(i); temp = temp{1};
        if numel(find(temp == ':')) == 0
            temp = [temp ' 00:00:00'];
        end
        dt = datetime(temp, 'InputFormat','yyyy/MM/dd HH:mm:ss');
        dtvec = datevec(dt);
        time(i, :) = dtvec(1, 2:5);
    end

    % There are redundant entries in the raw data, where the same time 
    % apears several times, with only one entry having valid data while 
    % the rest are empty lines
    % The codes below means to get rid of these redundant entries
    dofm = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    N = size(time, 1);
    month = 1; date = 1; hour = 0; minute = 0;
    redundant = [];
    for i = 1 : N
        if ~isequal(time(i, :), [month, date, hour, minute])
            redundant(end+1) = i;
            continue
        end
        minute= minute + 5;
        if minute == 60
            minute = 0;
            hour = hour + 1;
            if hour == 24
                hour = 0;
                date = date + 1;
                if date == dofm(month) + 1
                    date = 1;
                    month = month + 1;
                end
            end
        end
    end

    time(redundant, :) = [];
    data(redundant, :) = [];
end