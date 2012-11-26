function dfs0pol2cart(curr_dir,curr_mag)
% function to convert magnitude direction velocity data into u/v component
% curr_dir is the colum number in the dfs0 file for the direction,
% curr_mag the number for the magnitude
% THIS FUNCTION DOES NOT WORK FOR WIND, SINCE WIND DIRECTION IS DEFINED AS
% WHERE IT IS COMING FROM YET U/V IS ALWAYS THE VECTOR DEFINITION
%
% revised for Mike2011 version and new Read_dfs0 function output
% modified item description
% March 2012 BE

%% read data

RecData = Read_dfs0;

%check defined data columns
if curr_dir > length(RecData.items(:,1))
    msgbox('Column number for direction item is greater than number of items')
    return;
elseif curr_mag > length(RecData.items(:,1))
    msgbox('Column number for magnitude item is greater than number of items')
    return;
end

% check that file is equidistant time axis file
if RecData.dTime(2) < 0
    msgbox('File has a non equidistant time axis, please convert & try again')
    return
end

data = RecData.dData(:,[curr_dir curr_mag]);

%% convert direction and current into cartesian coordinates
% matlab polar coodinates are orientated against the clock and start at
% East with zero, this is taken care of by swapping x,y in the function
% (output)

[new_data(:,2),new_data(:,1)] = pol2cart(data(:,1)*pi/180,data(:,2));

%% write data to dfs0 file
% prepare all inpout parameter to dfs0 file
filename = [RecData.name(1:end-5),'_vec.dfs0'];

dfs0 = dfsTSO(filename,1);

% Set a file title
set(dfs0,'filetitle',RecData.title);

% Set startdate and timestep interval 
set(dfs0,'startdate',datevec(RecData.dTime(4)));
set(dfs0,'timestep',[0 0 0 0 0 RecData.dTime(2)]);

% Add number of timesteps
addTimesteps(dfs0,RecData.dTime(1));

% define item description
idescript1 = inputdlg('Enter item description','u-velocity component',...
    1,cellstr('converted u-velocity'));
idescript2 = inputdlg('Enter item description','v-velocity component',...
    1,cellstr('converted v-velocity'));

% Add Items & define item structure
addItem(dfs0,char(idescript1),'u-velocity component','m/s');
addItem(dfs0,char(idescript2),'v-velocity component','m/s');

% write data to file
dfs0(1)  = single(new_data(:,1));
dfs0(2)  = single(new_data(:,2));

% Save and close files
save(dfs0);
close(dfs0);

