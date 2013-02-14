function mrg_mat_to_DFS0(padded_struct, datetime_name, variables)
% Process MATLAB data to a DFS0 file.
% 
% INPUT
%   padded_struct   A MATLAB structure with an equidistant timestep
%   datetime        A string which identified the MATLAB datenum object in the
%                   structure
%   variables       A cell array containing strings which identify the
%                   objects in the structure to write to the DFS0 file
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Outputs a DFS0 file
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304.
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.1   Unknown
%           DP. Inital attempt.  
%   v 1.2   04/11/11 
%           DP. Modifications to make it more generic.
%   v 1.3   14/02/2013
%           DP. Documentation!

%% Is the input a structured array
if ~isstruct(padded_struct)
    error('You must provide a MATLAB structured array')
end

%% Is a datetime name supplied?  If not, get one.
if ~exist('datetime_name', 'var')
    datetime_name = get_dt_name(padded_struct);
elseif ~ischar(datetime_name)
    error('The datetime_name must be a string');
end

%% Is variables supplied?  If not error
if ~exist('variables', 'var') 
    error('You did not supply any variables.');
end

%% Is it a cell array
if ~iscell(variables)
    error('The variables must be suppled as a MATLAB cell array.');
end

%% Are all the variables there?
if any(~isfield(padded_struct, variables))
    error('Some of the expected variables are missing from the supplied structured array');
end

%% Check all variables the same length?

%% Checks on the datetime variable
datetime = padded_struct.(datetime_name);
% Are there 2 dimentions?
dt_dims = ndims(datetime);
if dt_dims ~= 2
    error('The datetime object does not have 2 dimensions.');
end

% Put the longest dimension first
if size(datetime,1) < size(datetime,2)
    datetime = datetime.';
end

%% Are the time steps equidistant?  If so then setup the MIKE timestep
% Check time step for equidistant spacing
timestep = round((datetime(2) - datetime(1))*24*60);
t_steps = diff(datetime)*24*60;

if any(abs(t_steps - timestep)>=1/60)
    error('Timestep is not equidistant in file!');
end

%% Setup variables to describe the DFS0 file
% Temporal dimension information
start_date = datevec(min(datetime));
% NB: 'timestep' assigned above

%% OK - Where do we save the DFS0 file?
[dfs_name,dfs_path] = uiputfile('*.dfs0','Choose a name for the .dfs0 file');
cd(dfs_path)

%% Here after this is just copied from DHI example...
% Load libraries
assemb = NET.addAssembly('DHI.Generic.MikeZero');
import DHI.Generic.MikeZero.*
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;

% Create an empty dfs0 file object
dfs0 = dfsTSO(dfs_name,1);

set(dfs0,'filetitle','Data from MATLAB');
set(dfs0,'startdate',double([start_date(1), start_date(2), start_date(3), start_date(4), start_date(5), start_date(6)]));
set(dfs0,'timestep',[0 0 0 0 0 timestep]);
addTimesteps(dfs0,length(datetime));

% 1 dbar = 0.1 bar = 10 kPa
% 1 mbar = 0.001 bar = 0.1 kPa = 1 hPa (hectopascal)
% 1 dbar = 100 hPa 

for n = 1:length(variables)
    addItem(dfs0,variables{n});
end

for j=1:length(variables)
    var = variables{j};
    dfs0(j) = single(padded_struct.(var));
end

save(dfs0);
close(dfs0);
% DFS0 writing complete!

%% Begin nested functions for mat2DFS0 function...
    function datetime_name = get_dt_name(padded_struct)
        gdn_names = fieldnames(padded_struct);
        gdn_options = gdn_names;
        gdn_options{end+1} = 'None of the above!';
        gdn_choice = menu(sprintf('Which object contains the MATLAB datetime information?'),gdn_options);
        if strcmp(gdn_options(gdn_choice), 'None of the above!')
            error('No, that is not an option');
        else
            datetime_name = char(gdn_names(gdn_choice));
        end
    end
end
