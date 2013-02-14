function mrg_dfsu_standardise(increment)
% Standardises values in a DFSU file.  
%
% INPUT
%   increment       An integer specifying the increment at each timestep to
%                   standardise the DFSU file with.  See NOTES.
%
% OUTPUT
%   NO OUTPUT TO CONSOLE
%   Produces a DFSU file with a '_mod' suffix 
%
% REQUIREMENTS
%   The DHI/MIKE Matlab toolbox 2011 (developed with v. 20110304)
%   mrg_struct_to_csv.m function (assuming you want csv output, else it will be skipped)
%
% NOTES
%   The input file is copied to 'filename_mod.dfsu' and values at each
%   timestep are are standardised using the following formula:
%       increment*(timestep-1)
%   i.e. 
%       data/increment*0 at timestep 1
%       data/increment*1 at timestep 2 
%       data/increment*n at timestep n+1
%   This function is slow becuase
%       A) The whole DFSU file is copied and then 
%       B) There are two nested for loops.
%   A faster alternative may be to create a DFSU 'template' file (from a
%   mesh file, perhaps) and then do the math in the MIKE calculator.
%   Unfortunatly using two DFSU files in this way is not as easy as you
%   might hope in the 2011 verison of MIKE.
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
%           Proper documentation

%% Start!
if ~isnumeric(increment)
    error('Increment must be a number!');
end

[filename, path] = uigetfile('.dfsu','Select a DFSU file to standardise');
cd(path);
fprintf('\nThis function can be slow.  Please be patient.\n');
new_filename = [filename(1:end-5),'_mod.dfsu'];

%% Gah!
% I would prefer to add a new item to the existing DFSU and do the math in
% MIKE, but that doesn't seem to be easy.
% Strangely this is the method the toolbox examples use!
copyfile(filename, new_filename, 'f');
fprintf('\nFile copied to: ''%s''\n',new_filename);

%%
NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

dfsu2 = DfsFileFactory.DfsuFileOpenEdit(new_filename);

no_items = dfsu2.ItemInfo.Count;
no_timesteps = dfsu2.NumberOfTimeSteps;

for j=1:no_items
    for i=0:no_timesteps-1
        % Read first time step from file
        itemData = dfsu2.ReadItemTimeStep(1,i);
        data     = double(itemData.Data)';
        % Calculate new values
        data  = data/(increment*double(i));
        % Write to memory
        dfsu2.WriteItemTimeStep(j,i,itemData.Time,NET.convertArray(single(data(:))));
    end
end

dfsu2.Close();

fprintf('\nFile modified!\n\n');


end