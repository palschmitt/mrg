function mrg_dfsu_standardise(increment)
%% A simple function to standardise values in a DFSU file.  
% The input file is copied to 'filename_mod.dfsu' and values are
% standardised by increment*timestep (i.e. data/increment*0,
% data/increment*1 ... data/increment*n). This function is slow becuase A)
% The whole DFSU file is copied and then B) There are two nested for loops.
% A faster alternative may be to create a DFSU 'template' file (from a mesh
% file, perhaps) and then do the math in the MIKE calculator.  Unfortunatly
% using two DFSU files in this way is not as easy as you might hope in the
% 2011 verison of MIKE.

% TODO
%   Proper documentation

if ~isnumeric(increment)
    error('Increment must be a number!');
end

%%
[filename, path] = uigetfile('.dfsu','Select a DFSU file to standardise');
cd(path);
fprintf('\nThis function can be slow.  Please be patients.\n');
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