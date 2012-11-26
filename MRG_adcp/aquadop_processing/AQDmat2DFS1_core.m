function [] = AQDmat2DFS1_core(padded_struct, datetime_name, profile_name, datetime, profile)
% Takes input from AQDmat2DFS1 and processes it into a DFS1 format suitable for MIKE.

%% Are the time steps equidistant?  If so then setup the MIKE timestep
t_step = unique(round2(diff(datetime),0.00001));
if length(t_step) ~= 1
    error('The timesteps are not equal (or there has been a rounding error)');
else
    timestep = round(t_step*60*60*24);
end

%% Get variables ready to write to DFS1
% For now we will just hard code some columns...
% Could use some kind of UI to choose columns, but I'm not in the mood...

current_speed = profile(:,:,12);
current_direction = profile(:,:,13);

% Replace NaNs with MIKE 'delete values'...
fDelete = single(-1E-35);
dDelete = double(-1E-255); % Not needed?
current_speed(isnan(current_speed)) = fDelete;
current_direction(isnan(current_direction)) = fDelete;

%% Setup variables to describe the DFS1 file
% Temporal dimension information
start_date = datevec(min(padded_struct.(datetime_name)));
% NB: 'timestep' assigned above

% Spatial dimension information
number_of_dims = length(padded_struct.(profile_name)(1,:,1));
spacing_of_dims = mode(diff(padded_struct.(profile_name)(1,:,2)));

%% OK - Where do we save the DFS1 file?
[dfs_name,dfs_path] = uiputfile('*.dfs1','Choose a name for the .dfs1 file');
cd(dfs_path)

%% Here after this is just copied from DHI create_dfs1.m example...
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

% Create an empty dfs1 file object
factory = DfsFactory();
builder = Dfs1Builder.Create('Matlab dfs1 file','Matlab DFS',0);
builder.SetDataType(0);

% Create a temporal definition
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(...
    start_date(1), start_date(2), start_date(3), start_date(4), start_date(5), start_date(6)...
    ),0,timestep));

% Create a spatial defition
builder.SetSpatialAxis(factory.CreateAxisEqD1(eumUnit.eumUmeter,number_of_dims,0,spacing_of_dims));
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-33',12,54,2.6));

% Add two items
builder.AddDynamicItem('Current Speed',eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec),DfsSimpleType.Float,DataValueType.Instantaneous);
builder.AddDynamicItem('Current Direction',eumQuantity(eumItem.eumICurrentDirection,eumUnit.eumUdegree),DfsSimpleType.Float,DataValueType.Instantaneous);

% Create the file - make it ready for data
builder.CreateFile(dfs_name);
dfs = builder.GetFile();

for i=0:length(datetime)-1,
    dfs.WriteItemTimeStepNext(0, NET.convertArray(single(current_speed(i+1,:))));
    dfs.WriteItemTimeStepNext(0, NET.convertArray(single(current_direction(i+1,:))));
end

dfs.Close();
% DFS1 writing complete!

end
