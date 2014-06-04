function mrg_dfsu_apply(fhandle, varargin)
% Applys an arbitary function (specified by fhandle) to a selected item in a DFSU file.  
%
% INPUT
%   fhandle       A function handle, constucted using the '@' syntax. See
%                 'doc function_handle' for more information 
%   ...           Optional items passed verbatium to the function specified
%                 by fhandle
%
% OUTPUT
%   NO OUTPUT TO CONSOLE
%   Modifies a DFSU file directly.
%
% NOTES
%   This function takes a DFSU file and loops through it
%   timestep-by-timestep applying the function specified by fhandle. At
%   each timestep, fhandle is supplied a vector with N values (where N is
%   the number of elements in the domain).  The result, which must also be
%   of length N, is written back to the DFSU file. Everything in varargin
%   gets passed to fhandel, allowing the use of moderatly complex
%   functions.
%
% USAGE
%   func = @mrg_assign;
%   % Every cell greater than -12.5 gets a value of 1
%   mrg_dfsu_apply(func, '>', -12.5, 1);
%   % Every cell less than -12.5 gets a value of 0 
%   mrg_dfsu_apply(func, '<', -12.5, 0);
%   % Every euqal to -12.5 gets a value of 1
%   mrg_dfsu_apply(func, '=', -12.5, 1);
%
% REQUIREMENTS
%   The DHI/MIKE Matlab toolbox 2011/13 (developed with v. 20130222)
%
% WARNING
%  This modifies the DFSU file directly, ensure you copy the file first,
%  before attempting to apply this function.
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   July 2013
%           DP. Initial attempt. 

%% Start!
if ~isa(fhandle, 'function_handle')
    error('fhandle must be a valid function handle!');
end

[filename, path] = uigetfile('.dfsu','Select a DFSU file to process');
cd(path);

choice = questdlg(sprintf('This function WILL modify your DFSU file.\n\nDo you want to continue'), ...
	'Warning!', 'OK', 'Cancel', 'Cancel');
if strcmp(choice, 'Cancel')
    error('Canceled by user')
end

% Load libraries
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

% Get file
dfsu_file = DfsFileFactory.DfsuFileOpenEdit(filename);

% Read some item information
items = {};
for i = 0:dfsu_file.ItemInfo.Count-1
    item = dfsu_file.ItemInfo.Item(i);
    items{i+1,1} = char(item.Name);
    items{i+1,2} = char(item.Quantity.Unit);
    items{i+1,3} = char(item.Quantity.UnitAbbreviation);
end

% Ask the user to select the item to process
choice = menu(sprintf('Which of these objects do you want to process?'),items{:,1}, 'Ummm... None of the above!');
if choice == 0 || choice == length(items(:,1))+1
    error('Do or do not.  There is no try.');
else
    dfsu_item = choice; % A number delimiting the item position in the DFSU file.  The same as mat_item (i.e. no zero indexing).
end

%%
no_timesteps = dfsu_file.NumberOfTimeSteps;
h = waitbar(0,'Please wait...');
for i=0:no_timesteps-1
    % Read a timestep from the file
    itemData = dfsu_file.ReadItemTimeStep(dfsu_item,i);
    data     = double(itemData.Data)';
    % Calculate new values
    data  = fhandle(data, varargin{:});
    % Write to memory
    dfsu_file.WriteItemTimeStep(dfsu_item,i,itemData.Time,NET.convertArray(single(data(:))));
    waitbar(i+1/no_timesteps);
end
close(h)
dfsu_file.Close();

fprintf(1, '\nFile modified!\n\n');


end