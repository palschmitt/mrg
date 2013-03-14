function mrg_dfs0_cart_to_pol(curr_east,curr_north,wind)
% Converts U and V velcity data into magnitude and direction in a DFSO file
%
% INPUT
%   curr_east   A positive integer defining the column number for the U
%               component in the DFS0 file.
%   curr_north  A positive integer defining the column number for the V 
%               component in the DFS0 file.
%   wind        Is either 1 if the input data is wind data, otherwise 0.  
%               See NOTES.
% 
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Produces a DFS0 file with '_dir' appended to the filename.
%   Resulting file contains ONLY the calculated speed and direction.  
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304.
%   Requires mrg_read_dfs0
%
% NOTES
%   Wind directions are typically specifiy as the direction the wind is
%   *coming from*, whereas other directions (e.g. currents) are specified
%   as the direction they are *going to*.  The wind input allows for this,
%   and ensures wind directions are calcuated correctly.
%
% LICENCE
%   Created B. Elsaesser (b.elsaesser@qub.ac.uk)
%   Updated by Daniel Pritchard (www.pritchard.co)
%   Original copyright B. Elsaesser.  Rewritten code distributed under a
%   creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   March 2012
%           BE. Revised for Mike2011 version and new Read_dfs0 function output.
%           BE. Modified item description & additional check in input (equidistance time axis)
%   v 1.1   2012-09-12
%           DP. Documentation.  Name change.  
%           DP. Uses modified mrg_read_dfs0 function.  Modified to account
%           for the fact that mrg_read_dfs0 no longer CD's the MATLAB
%           working directory in the original directory.
% TODO
%   Update to use .NET frameworks for writing files.  Better yet, create a
%   generic mrg_write_dfs0 function and pass the file saving on to this
%   function.   

%% read data

RecData = mrg_read_dfs0;

%check defined data columns
if curr_east > length(RecData.items(:,1))
    msgbox('Column number for east item is greater than number of items')
    return;
elseif curr_north > length(RecData.items(:,1))
    msgbox('Column number for north item is greater than number of items')
    return;
end

% check that file is equidistant time axis file
if RecData.dTime(2) < 0
    msgbox('File has a non equidistant time axis, please convert & try again')
    return
end

data = RecData.dData(:,[curr_east curr_north]);

%% convert direction and current into polar coordinates
% matlab polar coodinates are orientated against the clock and start at
% East with zero, this is taken care of by swapping x,y in the function
% (output)
[new_data(:,1),new_data(:,2)] = cart2pol(data(:,2),data(:,1));

if wind
    new_data(:,1) = new_data(:,1)*180/pi + 180;
else
    new_data(:,1) = new_data(:,1)*180/pi;
    index = ~(new_data(:,1) > 0);
    new_data(:,1) = new_data(:,1)+ index * 360;
end

%% write data to dfs0 file
% prepare all inpout parameter to dfs0 file
filename = [RecData.Fullname(1:end-5),'_dir.dfs0'];

dfs0 = dfsTSO(filename,1);

% Set a file title
set(dfs0,'filetitle',RecData.title);

% Set startdate and timestep interval 
set(dfs0,'startdate',datevec(RecData.dTime(4)));
set(dfs0,'timestep',[0 0 0 0 0 RecData.dTime(2)]);

% Add number of timesteps
addTimesteps(dfs0,RecData.dTime(1));

% define item description
if wind
    def_descript1 = cellstr('derived wind direction');
    def_descript2 = cellstr('derived wind speed');
else
    def_descript1 = cellstr('derived current direction');
    def_descript2 = cellstr('derived current speed');
end

idescript1 = inputdlg('Enter item description','Direction component',...
    1,def_descript1);
idescript2 = inputdlg('Enter item description','Magnitude component',...
    1,def_descript2);

% Add Items & define item structure
if wind
    addItem(dfs0,char(idescript1),'Wind direction','deg');
    addItem(dfs0,char(idescript2),'Wind Speed','m/s');
else
    addItem(dfs0,char(idescript1),'Current direction','deg');
    addItem(dfs0,char(idescript2),'Current magnitude','m/s');
end

% write data to file
dfs0(1)  = single(new_data(:,1));
dfs0(2)  = single(new_data(:,2));

% Save and close files
save(dfs0);
close(dfs0);