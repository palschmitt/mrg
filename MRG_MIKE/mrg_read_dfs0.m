function RecData = mrg_read_dfs0(varargin)
% A function to read all entries from DFS0 files.
%
% INPUT
%   ...         An optional charater string specifying the file name (or
%               full file path) to read.
%
% OUTPUT
%   RecData     A structure with all data and useful information.
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304
%
% LICENCE
%   Created B. Elsaesser @ RPS Consulting Engineers
%   Updated by Daniel Pritchard (www.pritchard.co)
%   Original copyright B. Elsaesser.  Rewritten code distributed under a
%   creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2004-11
%           First version. BE
%   v 1.1   2005-09
%           Updated. BE
%   v 1.2   2007-01
%           Time & date of data added to file structure. BE
%           Converted to proper function. BE
%   v 1.3   2009-09
%           Revised to work with Mike 2009 using latest Matlab toolbox. BE
%   v 1.4   2012-09-05
%           Full code re-write with backwards compatability. DP
%           Compatible with MIKE 2011 and 20110304 toolbox. DP
%           Uses Dfs0Util (from the MIKE toolbox). DP
%           Standard info returned with self-expanatory fieldnames. DP
%           The items field is not 100% backwards compatible (yet). DP
% TODO
%   Although the actual data reading (via Dfs0Util) is faster, this code
%   is slower overall than the orignal Read_dfs0.  This might be
%   unavoidable due to extra data extracted, but maybe it can be optimised
%   a bit...
%   Full backwards compatability on items{}

%%
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;

%% Open File
if isempty(varargin)
    [fname,path] = uigetfile('*.dfs0','Select the .dfs0');
    name = [path,fname];
elseif (~exist(char(varargin),'file'))
    warning('mrg_read_dfs0:filenotfound', 'The file you supplied was not found')
    [fname,path] = uigetfile('*.dfs0','Select the .dfs0');
    name = [path,fname];
else
    name = char(varargin);
end

dfs0File  = DfsFileFactory.DfsGenericOpen(name);

%% Read times and data for all items
% Use the Dfs0Util for bulk-reading all data and timesteps
dd = single(Dfs0Util.ReadDfs0DataDouble(dfs0File));
%t = dd(:,1);
data = dd(:,2:end);

%% Sort out time data
try
    start_date_vec = [dfs0File.FileInfo.TimeAxis.StartDateTime.Year, ...
        dfs0File.FileInfo.TimeAxis.StartDateTime.Month, ...
        dfs0File.FileInfo.TimeAxis.StartDateTime.Day, ...
        dfs0File.FileInfo.TimeAxis.StartDateTime.Hour, ...
        dfs0File.FileInfo.TimeAxis.StartDateTime.Minute, ...
        dfs0File.FileInfo.TimeAxis.StartDateTime.Second];
catch err
    disp(err.message);
    warning('mrg_read_dfs0:startdatefail', 'Start date could not be determined from the DFS0 file.  Using 0000-00-00 00:00:00.')
    start_date_vec = [0,0,0,0,0,0];
end

start_date_num = datenum(double(start_date_vec));

%% Read item information
items = cell(dfs0File.ItemInfo.Count, 3);
for i = 0:dfs0File.ItemInfo.Count-1
   item = dfs0File.ItemInfo.Item(i);
   items{i+1,1} = char(item.Name);
   items{i+1,2} = char(item.Quantity.Unit);
   items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
end

%% Construct the output
RecData = struct();

RecData.dData = data;

% For compatability with old code:
RecData.dTime = NaN(1,4);
RecData.dTime(1) = dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps;
try
    RecData.dTime(2) = dfs0File.FileInfo.TimeAxis.TimeStep;
catch err
    disp(err.message);
    warning('mrg_read_dfs0:timestepfail', 'Timestep length could not be determined from the DFS0 file.  Using NaN.')
    RecData.dTime(2) = NaN;
end
RecData.dTime(3) = RecData.dTime(2)/(60*60*24);
RecData.dTime(4) = start_date_num;
nameinfo = regexp(char(dfs0File.FileInfo.FileName),'\\','split');
RecData.name = char(nameinfo(end));
RecData.title = char(dfs0File.FileInfo.FileTitle);
RecData.DeleteFloat = single(dfs0File.FileInfo.DeleteValueFloat);

% Future proof returning of data
% Removes abiguity on the meaning of 'dTime'
% Adds additional info
RecData.NumberOfTimeSteps = dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps;
RecData.TimeStepSec = RecData.dTime(2);
RecData.TimeStepHour = RecData.dTime(2)/(60*60);
RecData.TimeStepMat = RecData.dTime(2)/(60*60*24);
RecData.StartDateNum = start_date_num;
RecData.StartDateVec = start_date_vec;
RecData.Fullname = char(dfs0File.FileInfo.FileName);
RecData.TimeAxisType = char(dfs0File.FileInfo.TimeAxis.TimeAxisType);
% 'items' is not (yet) strictly backwards compatible, as we are missing
% columns 4, 5 and 6 from Read_dfs0.m (Not sure what these columns are?!)
RecData.items = items;

dfs0File.Close();


