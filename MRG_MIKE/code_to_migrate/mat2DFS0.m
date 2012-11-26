function assemb = mat2DFS0(padded_struct, datetime_name, variables)
% A wrapper function for mat2DFS0_core()
% Loads requiered MIKE dot net libraries and does some data checking
% padded_struct : A MATLAB structure with an equidistant timestep
% datetime      : A string which identified the MATLAB datenum object in the
%                   structure
% variables     : A cell array containing strings which identify the
%                   objects in the sturcutre to write to the DFS0 file

% 04/11/11 Modifications to make it more generic
%% Load dot net libraries
% This is requiered (along with the output in the function above) to make
% the DHI toolbox work.  Don't ask me why!
assemb = NET.addAssembly('DHI.Generic.MikeZero');

%% Is the input a structured array
if ~isstruct(padded_struct)
    error('You must provide a MATLAB structured array')
end

%% Is a datetime name supplied?  If not, get one.
if ~exist('datetime_name')
    datetime_name = get_dt_name(padded_struct);
elseif ~ischar(datetime_name)
    error('The datetime_name must be a string');
end

%% Is variables supplied?  If not error
if ~exist('variables') 
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

%% Check all vartiables the same length?

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

%% Go time
mat2DFS0_core(padded_struct, datetime, variables);

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
