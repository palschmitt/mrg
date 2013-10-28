function mrg_dfsu_alter_time(starttime, endtime)
% Modfies the selected DFSU file so that it begins at starttime and ends at
% endtime, with equally space timesteps inbetween
%
% INPUT
%   starttime   A MATLAB datetime vector
%   endtime     A MATLAB datetime vector
%
% OUTPUT
%   NO OUTPUT AT CONSOLE. 
%   Modifies the timestep information of the selected DFSU file.
%
% USAGE
%   mrg_dfsu_alter_time([2013 10 28 15 30 00], [2014 01 01 00 00 00])
%
% REQUIREMENTS
%   MIKE by DHI toolbox. Tested / developed with 20130222
%
% REFERENCES
%   Please list references here in a consistent, human readable format.
%
% AUTHORS
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
%   v 1.0   2013-10-28
%           First version. DP
%
% TODO
%   Allow string input for filename
%% Function Begin!
oldpath = cd;
[infile, path] = uigetfile('.dfsu','Select a DFSU file to process');
cd(path);

% Load libraries
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

% Caculate times
timesec = (datenum(endtime)-datenum(starttime))*24*60*60;
newstart = System.DateTime(starttime(1), starttime(2), starttime(3), starttime(4), starttime(5), starttime (6));

% Write data
dfsu_file = DfsFileFactory.DfsuFileOpenEdit(infile);
dfsu_file.StartDateTime = newstart;
dfsu_file.TimeStepInSeconds = timesec;

% Close
dfsu_file.Close();

% Return
cd(oldpath);

end
