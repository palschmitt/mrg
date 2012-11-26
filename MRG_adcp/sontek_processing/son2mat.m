function [sontek_struc] = son2mat()
% A simple funtion to read SONTEK ASCII files and output a MATLAB structure

%% Default (user definable) variables
% COLUMN_PERC = 0.9;  % NONONONO - Change this - DP 2012-09-06
% COLUMN_PERC is the arbitrary depth correction for sidelobe filtering
% Storm (Nortek software) uses 90% as a default value
% Cuan says this is an industry default

% Deployment variables (in m)
SEABED_TO_SENSOR = 0.4; 
BLANKING_DIST = 0.75; 
CELL_SIZE = 0.5; 

disp('NOTE: Remember there are some variables hard-coded into the son2mat function.')
disp('      To view and edit these variables type "edit son2mat" (no quotes) into the command prompt.')

%% Read and process the header file
[filename, path] = uigetfile({'*.hdr','SonTek header files (*.hdr)'}, 'Please select the hdr file');
cd(path);
son_hdr = dlmread(filename);
hdr_names = {'profile', 'year', 'month', 'day', 'hour', 'min', 'sec',...
    'no_samples', 'speed', 'mean_heading', 'mean_pitch', 'mean_roll', ...
    'mean_temp', 'mean_pressure', 'stdev_heading', 'stdev_pitch', ...
    'stdev_roll', 'stdev_temp', 'stdev_pressure', 'volts'};
sontek_struc = struct();
for n=1:length(hdr_names)
    sontek_struc.(hdr_names{n}) = son_hdr(:,n);
end

%% Create a MATLAB DT Object
sontek_struc.m_dt = datenum(sontek_struc.year, sontek_struc.month,...
    sontek_struc.day, sontek_struc.hour, sontek_struc.min, sontek_struc.sec);

%% Read and process the 've', 'vn' and 'vu' files
filename_ve = [filename(1:end-3),'ve'];
filename_vn = [filename(1:end-3),'vn'];
filename_vu = [filename(1:end-3),'vu'];

% Warn about unit conversion
disp('NOTE: The velocity components have been divided by 100 to convert from cm/s to m/s (which is the format the MIKE expects)')


% Now, read the ve (i.e. velocity east) file and add it to the struct
son_ve = dlmread(filename_ve);
sontek_struc.vel_east = son_ve(:,2:end)/100;

% Now, read the vn (i.e. velocity north) file and add it to the struct
son_vn = dlmread(filename_vn);
sontek_struc.vel_north = son_vn(:,2:end)/100;

% Now, read the vu (i.e. velocity up) file and add it to the struct
son_vu = dlmread(filename_vu);
sontek_struc.vel_up = son_vu(:,2:end)/100;

%% Trim bins that are out of the water
cell_distances = [1:1:length(sontek_struc.vel_east(1,:))];
cell_distances = cell_distances*CELL_SIZE+BLANKING_DIST;

for n = 1:length(sontek_struc.profile)
    % Test pressure = cutoff depth for cells Tested against the
    % cell_distances variable which is the distance from the sensor to the
    % top of the cell
    test_pressure = sontek_struc.mean_pressure(n)*COLUMN_PERC*cos(25)-SEABED_TO_SENSOR;
    above = cell_distances > test_pressure;
    sontek_struc.vel_east(n,above) = NaN;
    sontek_struc.vel_north(n,above) = NaN;
    sontek_struc.vel_up(n,above) = NaN;
end

%% Calculate Depth Averaged U and V components
for n = 1:length(sontek_struc.profile)
    sontek_struc.da_vel_east(n,:) = nanmean(sontek_struc.vel_east(n,:));
    sontek_struc.da_vel_north(n,:) = nanmean(sontek_struc.vel_north(n,:));
end

%% Calculate some depth averaged speed and directions
[theta, rho] = cart2pol(sontek_struc.da_vel_north, sontek_struc.da_vel_east);
sontek_struc.da_curr_speed = rho;
dir = theta*180/pi;
index = ~(dir > 0);
sontek_struc.da_dir = dir + index * 360;

%% Save a matlab file
filename_mat = [filename(1:end-3),'mat'];
save(filename_mat, 'sontek_struc');

%% Create a DFS0 File
variables = {'da_vel_east', 'da_vel_north', 'da_curr_speed', 'da_dir', 'mean_pressure'};
mat2DFS0(sontek_struc, 'm_dt', variables);

end
