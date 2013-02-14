function mrg_dfs2_to_radians(item_no, filename)
% Convert directions in a dfs2 file to radians.
%
% INPUT
%   item_no     An non-zero integer specifying the item in the DFS2 file
%               containing the direction data.
%   filename    An optional string specifying the name of the DFS2 to convert.
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   This function copies the original file and converts item specified by
%   'item_no' to radians.  It creates a DFS2 file with '_radians' 
%   appended to the filename.
%
% NOTES
%   Created to address a bug in the DHI software which has now been fixed.
%
% REQUIREMENTS
%   The DHI/MIKE Matlab toolbox 2011 (developed with v. 20110304)
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2012
%           DP. Initial attempt and distribution. 
%   v 1.1   14/02/2013
%           DP. Documentation. 
% TODO 
%   Better parsing of input number.  Optional select of input item.
%   Do something about delete value handeling.  At the moment they are not
%       handeled at all, which is OK for ERA data only...

%% Load libraries
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

%% Sort out files
if (~exist('filename', 'var'))
    [file, path] = uigetfile('*.dfs2', 'Select a DFS2 file to convert');
    filename = [path, file];
end

out_filename = [filename(1:end-5),'_radians', filename(end-4:end)];

copyfile(filename, out_filename, 'f');

dfs2_in = DfsFileFactory.Dfs2FileOpen(filename);
dfs2_out = DfsFileFactory.Dfs2FileOpenEdit(out_filename);

%% Get some basic info
nsteps = dfs2_in.FileInfo.TimeAxis.NumberOfTimeSteps;

%% Do the conversion and write out data
for i=0:nsteps-1
    itemData = dfs2_in.ReadItemTimeStep(item_no,i);
    out_data = degtorad(double(itemData.Data));
    dfs2_out.WriteItemTimeStep(item_no,i,itemData.Time,NET.convertArray(single(out_data(:))));
end

%% Finish up
dfs2_in.Close();
dfs2_out.Close();

end
