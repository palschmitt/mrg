function mrg_dfsu_duplicate_ts
% Takes the first step from a DFSU file and apends it to the end of the
% file
%
% INPUT
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Copys the selected DFSU file with a '_ts_added' suffix. 
%
% REQUIREMENTS
%   MIKE by DHI toolbox. Tested / developed with 20130222
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
%   Modify to allow copying of timestep n to the end?
%   Allow string input for filename
%
%
%% Function Begin!
oldpath = cd;
[filename, path] = uigetfile('.dfsu','Select a DFSU file to process');
cd(path);
new_file =  [filename(1:end-5), '_ts_added.dfsu'];
copyfile(filename, new_file);

% Load libraries
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

% Get file
dfsu_file = DfsFileFactory.DfsuFileOpenEdit(new_file);
% Get data from first timestep
itemData = dfsu_file.ReadItemTimeStep(1,0);
data     = double(itemData.Data)';
% Write data to a new appended timestep
dfsu_file.WriteItemTimeStepNext(0, NET.convertArray(single(data)));
% Close file
dfsu_file.Close();

% Return
cd(oldpath);


end
