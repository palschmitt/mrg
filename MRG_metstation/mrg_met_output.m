function str = mrg_met_output(out)
% A function to write met data to file(s) and upload to a webpage
%
% INPUT
%   out     A string read from RS232 (by mrg_met_control) that will be 
%           coerced into data
%
% OUTPUT
%   str     A string reporting the outcome of coercing, uploading and 
%           saving the data 
%   This function also produces the following files:
%       met_raw_data_yyyy_mmm.txt - Raw Data provided as 'out'
%       met_data_yyyy_mmm.csv - Nicely formatted data (with header text)
%   Where yyyy and mmm are the year and abbreviated month name, repectivly.
%   The function tries very hard to write something to file each time.  If
%   the data don't pass required checks then MIKE by DHI delete values
%   (-1e-30) are written in place.  
%
% NOTES
%   This function reads a password from a file named
%   'wunderground.password', which is assumed to be in the current working
%   directory.  This must have a single line only with the password for
%   your wunderground account.
%       
% REQUIREMENTS
%   Requires mrg_met_urlread
%
% AUTHORS
%   Bjoern Elsaesser
%   Daniel Pritchard
%
% LICENCE
%   Code distributed as part of the MRG toolbox from the Marine Research
%   Group at Queens Univeristy Belfast (QUB) School of Planning
%   Architecture and Civil Engineering (SPACE). Distributed under a
%   creative commons CC BY-SA licence, retaining full copyright of the
%   original authors.
%
%   http://creativecommons.org/licenses/by-sa/3.0/
%   http://www.qub.ac.uk/space/
%   http://www.qub.ac.uk/research-centres/eerc/
%
% DEVELOPMENT
%   v 1.0   2010
%           First version. BE.
%   v 2.0   02 Sept 2011. BE
%           Raw data output corrected.
%           Some error handling added and a proper output string added.
%   v 2.1   26 Jan 2012 DP
%           Modified the defualt version of urlread to include a timeout.  
%           Old version copied to urlread_old.m
%   v 2.2 	21 March 2012 DP
%           Modified conversion factor for WUnderground windspeed from 
%           1.151 to 2.2369. Raw data is not affected but uploaded 
%           windspeed was too low.
%   v 3.0   August 2013
%           Major re-write.
%           Clean up and document. Move into MRG toolbox.
%           urlread is now included in the toolbox as mrg_met_urlread
%           CSV file now has a header row, indicating what is what
%           Password is now read from file (excluded from toolbox repository)

%% First, dump the raw data to file...
fileID_raw = fopen(['met_raw_data_',datestr(date,'yyyy_mmm'),'.txt'],'a');
fprintf(fileID_raw,[out,'\r\n']);
fclose(fileID_raw);

%% Parse data and prepare to write useful data to a CSV file
[C,position] = textscan(out,'%s %s %f %f %f %f %f %f %f %f %f %f');

% Try to coerce the first two strings to a MATLAB datenum.
% If not we use the current date and time...
try
    K(1) = datenum([char(C{2}),' ',char(C{1})],'dd.mm.yy HH:MM:SS');
catch err
    K(1) = now;
end

% Format a date string for the CSV file...
DateS = datestr(K(1),'dd/mm/yyyy HH:MM:SS');
% Get a filename for the CSV file
fnameCSV = ['met_data_',datestr(date,'yyyy_mmm'),'.csv'];
% If the CSV file doesn't exist, then write a header line...
if ~exist(fnameCSV, 'file')
    csv_hdr = 'DateTime,PAR,WindSpeed,WindDirection,AirPressure,AirTemp,TidalLevel,WaterTemp\r\n';
    fileID_csv = fopen(fnameCSV,'a');
    fprintf(fileID_csv,csv_hdr);
    fclose(fileID_csv);
end
% Create a CSV error string (to fill the gap if an error is found)...
% Needs to be a date an 7 delete values
csv_err = [DateS,',-1e-30,-1e-30,-1e-30,-1e-30,-1e-30,-1e-30,-1e-30\r\n'];

%% Data Checks
if position < 98 % Check length of string. If too short data is missing.
    % Write delete values to file
    fileID_csv = fopen(fnameCSV,'a');
    fprintf(fileID_csv,csv_err);
    fclose(fileID_csv);
    % Report error
    str = [DateS, ': ERROR 01 - The string was too short! Delete values written in place'];
    return
end

if any(cellfun('isempty',C)) % Check if all cells contain a value.
    fileID_csv = fopen(fnameCSV,'a');
    fprintf(fileID_csv,csv_err);
    fclose(fileID_csv);
    str = [DateS, ': ERROR 02 - Some values were missing! Delete values written in place'];
    return
end

%% Data is OK...
K(2:11) = cell2mat(C(3:12));

%% Calibrate wind direction data
% 270 on vane = 318 in reality
% Equals 48 degree offset
% So 'North' equals 312 on vane
if K(5)<312
    K(5) = K(5)+48;
else
    K(5) = K(5)-312;
end

%% Construct CSV string and write to file
% August 2013
% Added K(8) and K(9), which should be tidal level and water temperature.
csv_str = [DateS,',',...
    num2str(K(3)),',',...
    num2str(K(4)),',',...
    num2str(K(5)),',',...
    num2str(K(7)),',',...
    num2str(K(11)),',',...
    num2str(K(8)),',',...
    num2str(K(9)),'\r\n'];

fileID_csv = fopen(fnameCSV,'a');
fprintf(fileID_csv,csv_str);
fclose(fileID_csv);
str = [DateS, ': OK. Data written to CSV file.'];

%% Create a text string for web
try
    passfname = fopen('wunderground.password','r');
    password = fgetl(passfname);
    fclose(passfname);
catch err
    error('Problem reading the password file. \r\n %s', err.message)
end
URL1 = ['http://weatherstation.wunderground.com/weatherstation/updateweatherstation.php?ID=INORTHER18&PASSWORD=',password,'&'];
URL2 = ['dateutc=',datestr(K(1),'yyyy-mm-dd'),'+',datestr(K(1),'HH'),...
    '%3A',datestr(K(1),'MM'),'%3A',datestr(K(1),'SS'),'&'];
URL3 = ['winddir=',num2str(K(5)),'&windspeedmph=',num2str(K(4)*2.2369),...
    '&tempf=',num2str(K(11)*9/5+32),'&baromin=',num2str((K(7)-11.9)*0.029967)];
URL = [URL1,URL2,URL3];

%% Attempt an upload
try
    web_str = deblank(mrg_met_urlread(URL));
    if strcmp(web_str,'success')
        web_str = [DateS, ': OK. mrg_met_urlread returned: ', web_str];
    else
        web_str = [DateS, ': WARNING. mrg_met_urlread returned: ', web_str];
    end
catch err
    web_str = [DateS, ': FAIL. mrg_met_urlread failed (possible timeout?). The error was: \r\n', err.message];
end

str = [str, '\r\n', web_str];

end