function assemb = AQDmat2DFS1(padded_struct, datetime_name, profile_name)
% A wrapper function for AQDmat2DFS1_core.
% Loads requiered MIKE dot net libraries and does some data checking

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

%% Is profile_name supplied?  If not, get it...
if ~exist('profile_name')
    profile_name = get_prof_name(padded_struct);
elseif ~ischar(profile_name)
    error('The profile_name must be a string');
end

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

%% Checks on the profile variable
profile = padded_struct.(profile_name);
% Is the length of the first dim that same as that of the datetime
% variable?
if size(profile,1) ~= size(datetime,1)
    error('The size of the first dimension of the datetime and profile objects do not match.');
end

% TODO:
% Check orientation...

%% Go time
AQDmat2DFS1_core(padded_struct, datetime_name, profile_name, datetime, profile);

%% Begin nested functions for AQDmat2DFS1 function...
    function datetime_name = get_dt_name(padded_struct)
        gdn_names = fieldnames(padded_struct);
        gdn_options = gdn_names;
        gdn_options{end+1} = 'None of the above!';
        gdn_choice = menu(sprintf('Which object contains the MATLAB datetime information? \nAll other objects will be padded with blanks to match.'),gdn_options);
        if strcmp(gdn_options(gdn_choice), 'None of the above!')
            error('No, that is not an option');
        else
            datetime_name = char(gdn_names(gdn_choice));
        end
    end

    function profile_name = get_prof_name(padded_struct)
        gpn_names = fieldnames(padded_struct);
        gpn_options = gpn_names;
        gpn_options{end+1} = 'None of the above!';
        gpn_choice = menu(sprintf('Which object contains the profile information?'),gpn_options);
        if strcmp(gpn_options(gpn_choice), 'None of the above!')
            error('No, that is not an option');
        else
            profile_name = char(gpn_names(gpn_choice));
        end
    end

end
