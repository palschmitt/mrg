function dfs0cart2pol(curr_east,curr_north,wind)
% function to convert uv velcity data inot magnitude and direction
% curr_east is the colum number in the dfs0 file for the u component,
% curr_north the number for the v component
% if data file is wind file, wind = 1 otherwise 0,
% this is to get the wind direction corrected
%
% revised for Mike2011 version and new Read_dfs0 function output
% modified item description & additional check in input (equidistance time
% axis)
% March 2012 BE

%% read data

RecData = Read_dfs0;

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
filename = [RecData.name(1:end-5),'_dir.dfs0'];

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