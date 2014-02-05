function wave_data = mrg_read_3chan_logger(path,filename)
% DESCRIPTION. What does the function do?
%
% INPUT
%   path       An optional path. 
%   filename   An optional filename.
%
% OUTPUT
%   wave_data  A MATLAB structure with the following fields:
%              path: The path to the file
%              filename: The filename
%              compass: An m x 4 matrix, the status data (3) and data_index
%              time: An m x 4 matrix, with start_time, start_index,
%              end_time and end_index.
%              raw_data: An n x 3 matrix. The raw data
%              burst_data: A structure with m fields containing the bursts
%              (subsets) of the data in raw_data
%               
% NOTES
%   This code is based on several Read_logger*.m files floating about. Some
%   of these codes also calibrate the data using known scale (nee slope)
%   and offset (intercept) for each sensor. This function does not do that,
%   it is up to the user to apply the correct calibration.
%   NB: The general output format is *not* compatible with this old code.
%   Adjust your approach accordingly.  
%
% AUTHORS
%   Bjoern Elsaesser
%   Daniel Pritchard
%
% LICENCE
%   Code distributed as part of the MRG toolbox from the Marine Research
%   Group at Queens University Belfast (QUB) School of Planning
%   Architecture and Civil Engineering (SPACE). Distributed under a
%   creative commons CC BY-SA licence, retaining full copyright of the
%   original authors.
%
%   http://creativecommons.org/licenses/by-sa/3.0/
%   http://www.qub.ac.uk/space/
%   http://www.qub.ac.uk/research-centres/eerc/
%
% DEVELOPMENT
%   v 1.0   2014-02-04
%           First version. DP
%           Brings together several codes from BEs work folder namely:
%           Read_logger3c_data; Read_logger_card.m and;
%           Read_logger_cardv2.m
%           'Compass' information is now read inline, rather than being
%           read into 'data' and then later extracted...
%
%% Function Begin!
% Is path supplied
old_path = cd();
if ~exist('filename', 'var')
    [filename,path] = uigetfile('*.dat','Select a *.dat file from the 3-channel logger');
    cd(path);
    if isempty(filename)
        return
    end
end
% Open file handle
fid = fopen([path filename], 'r');

%% Setup...
n = 1; % An odd-even ticker
m = 1; % The row index for time and compass 
j = 1; % The data row index

% Preallocate some memory:
data = zeros(200000,3);
time = zeros(200,4);
compass = zeros(200,4);

tline = fgetl(fid);
while tline~=-1
    % If it degins with 'H' is is the status line, with date/time info...
    if tline(1) == 'H'
        % If 'n' is odd (1,3,5,...) then it is a 'start' time so it gets
        % written to column 1 and the index gets writen to column 2.
        % Furthermore, the next line is 'compass' / status information...
        % We read this now with a new call to fgetl, rather than have it
        % get mixed up the with other data and have to extract it later
        
        % If 'n' is even then it is a 'end' time. This gets written to
        % column 3 and the index to column 4. Also we increment 'm' so that
        % the next encounter gets writen to the correct row.
        if(bitget(abs(n),1)) % Is odd
            time(m,1) = datenum(tline(6:end),'dd:mm:HH:MM:SS');
            time(m,2) = j; % j is an index into the 'data' object
            tline = fgetl(fid);
            compass(m,1:3) = str2num(tline);
            compass(m,4) = j;
        else % Is even
            time(m,3) = datenum(tline(6:end),'dd:mm:HH:MM:SS');
            time(m,4) = j-1; % j is an index into the 'data' object
            m = m + 1; % Increment 'm'
        end
        % Increment n (this needs to happen everytime to keep the odd/even
        % marker ticking over
        n = n + 1;
    else
        data(j,1:3) = str2num(tline);
        j = j + 1;
    end
    % If preallocated space is getting low, top it up!
    % NB: This is probably not needed as MATLAB dynmically exapnd matrixes
    % that are indexed beyond their limits (e.g. x=[];x(3,2)=2;) but it
    % might be more efficient
    if j > length(data)
        data(j:j+199999,1:3) = zeros(200000,3); % Add more data if needed...
    end
    if m > length(time) % NB: 'time' and 'compass' should be the same length!
        time(n:n+199,1:4) = zeros(200,4);
        compass(m:m+199,1:4) = zeros(200,4);
    end
    % Read a new line and repeat!
    tline = fgetl(fid);
end
fclose(fid);

% Clean up unused pre-allocated space!
data = data(1:j-1,:);
time = time(1:m-1,:);
compass = compass(1:m-1,:);

disp('All data read from file...')

%% Setup return object
wave_data.path = path;
wave_data.filename = filename;
wave_data.compass = compass;
wave_data.time = time;
wave_data.raw_data = data;


%% Split into separate files and write out
for n = 1:length(time); 
    M = data(time(n,2):time(n,4),1:3); % Use the start/stop time indexes
    %name = [filename(1:end-4),'_chunk_',num2str(n),'.dat'];
    %dlmwrite(name, M, 'precision', '%.6f','newline', 'pc');
    wave_data.burst_data.(['burst_',num2str(n)]) = M;
end;
disp('Individual bursts extracted...')

%% Finally, be a good lad: Go home...
cd(old_path)
disp('Done!')
end
