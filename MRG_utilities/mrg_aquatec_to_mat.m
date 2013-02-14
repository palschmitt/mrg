function tide_data = mrg_aquatec_to_mat(filename)
% Read aquatec data into MATLAB
%
% INPUT
%   filename    Optional string specifying the name of the file to read.
%
% OUTPUT
%   tide_data   A MATLAB matrix with three columns:
%                   tide_data(:,1) - MATLAB datetime
%                   tide_data(:,2) - temperature
%                   tide_data(:,2) - pressure
%
% NOTES
%   This function will fail if there are non-equidistant time steps in the
%   input file.
%
% DEVELOPMENT
%   v 1.0   2012
%           BE.  Initial development (as Aquatec2dfs0.m)
%   v 1.1   02/2013
%           Modfied to return MATLAB structure
%           DP.  Documentation. 
%
% TODO
%   Include DFS0 functionality

%% Get file to read
old_path = cd();
if ~exist('filename', 'var')
    [filename,path] = uigetfile('*.csv','Open *.csv AQUATEC file');
    cd(path);
    if isempty(filename)
        return
    end
end
%%  Imports data from the specified file
DELIMITER = ',';
HEADERLINES = 18;
% Import the file
newData1 = importdata(filename, DELIMITER, HEADERLINES);
warning('mrg:DefaultValue', [mfilename ' is assuming you have 18 header rows.']);
%% read date and time if possible
try
    tide_data = datenum(newData1.textdata(HEADERLINES+1:end,2),'HH:MM:SS dd/mm/yyyy');
catch
    error('Error reading date/time from file');
end
% Check time step for equidistant spacing
timestep = round((tide_data(2,1) - tide_data(1,1))*24*60);
t_steps = diff(tide_data(:,1))*24*60;
if any(abs(t_steps - timestep)>=1/60)
    error('Timestep is not equidistant in file!');
end
%% read data
tide_data(:,2:3) = newData1.data(:,[2 4]);
cd(old_path);
end