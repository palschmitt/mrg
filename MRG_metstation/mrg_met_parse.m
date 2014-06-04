function [out, outhead] = mrg_met_parse(fname, verify)
% Parses weatherstation data using regular expressions

% TODO: Documentation
% 01/02/2013 - Intial atempt DP

if ~exist('verify', 'var')
    verify = 1;
end

expressn = ['^'...
    '(?<time>\d{2}:\d{2}:\d{2})\s+'...
    '(?<date>\d{2}\.\d{2}\.\d{2})\s+(\d{1,2}\s+)?'...
    '(?<ligh>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<wspd>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<wdir>\d{3,6})?\s+(\d{1,2}\s+)?'...
    '(?<pres>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<vol1>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<vol2>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<digi>\d+\.\d+)?\s+(\d{1,2}\s+)?'...
    '(?<temp>\d+\.\d+)?'];

%outhead = {'Line', 'Date', 'Time', 'Light', 'WSpeed', 'WDir', 'Pressure', 'Volt1', 'Vol2', 'Digi', 'Temp'};
%out = repmat({NaN, ' ', ' ', NaN, NaN, NaN, NaN, NaN, NaN, NaN, NaN}, 5000, 1); % 5000 seems like enough
outhead = {'Line', 'DateTime', 'Light', 'WSpeed', 'WDir', 'Pressure', 'Volt1', 'Vol2', 'Digi', 'Temp'};
out = NaN(5000, 10);
%fileID = fopen('minicom111212_data.txt','r');
fileID = fopen(fname,'r');
tline = fgetl(fileID);
line = 1;
while ischar(tline)
    tline = strtrim(tline);
    %disp(tline)
    [outline] = regexp(tline,expressn,'names');
    if ~isempty(outline)
        %disp(outline)
        try
            mtime = datenum([outline.date, ' ', outline.time], 'dd.mm.yy HH:MM:SS');
        catch
            disp([outline.date, ' ', outline.time, ' - Conversion Failed (Line ', line,' of original file. Substituting NaN']);
            mtime = NaN;
        end
        light = str2double(outline.ligh);
        wspeed = str2double(outline.wspd);
        wdir = str2double(outline.wdir);
        pressure = str2double(outline.pres);
        volt1 = str2double(outline.vol1);
        volt2 = str2double(outline.vol2);
        digi = str2double(outline.digi);
        temp = str2double(outline.temp);
        
        if verify
            % Light: If more than 2500, NaN.  If less -10, NaN.  If -5 to 0, then zero.
            if light > 2500 || light < -5
                light = NaN;
            elseif light < 0
                light = 0;
            end
            
            % Windspeed: Between 0 and 100 m/s
            if wspeed < -0.5 || wspeed > 100
                wspeed = NaN;
            elseif wspeed < 0
                wspeed = 0;
            end
            
            % WindDirection: Between 0 and 360
            if wdir < 0 || wdir > 360
                wspeed = NaN;
            end
            
            % Pressure: Between 600 and 2000
            if pressure < 600 || pressure > 2000
                pressure = NaN;
            end
            
            % Temp between -50 and 50
            if temp < -50 || temp > 50
                temp = NaN;
            end
        end
        out(line,:) = [line, mtime, light, wspeed, wdir, pressure, volt1, volt2, digi, temp];
    else
        out(line,:) = [line,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN,NaN];
    end
    
    tline = fgetl(fileID);
    line = line+1;
end
out(all(isnan(out(:,2:end)), 2),:) = [];
fclose(fileID);
end