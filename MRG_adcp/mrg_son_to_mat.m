function [sontek_struc] = mrg_son_to_mat(seabedtosen, blankdist, cellsize, varargin)
% TODO: Documentation
% Reads SONTEK ASCII files.  
% Outputs a MATLAB structure and (optionally) a DFS0 file.  
%% Check input
if ~exist('seabedtosen', 'var')
    error('Distance from seabed to sensor (seabedtosen) not defined.')
end

if ~exist('blankdist', 'var')
    error('Blanking distance (blankdist) not defined.')
end

if ~exist('cellsize', 'var')
    error('Cell size (cellsize) not defined.')
end

% Number of optional input arguments must be less than 2 x options...
numvarargs = length(varargin);
if numvarargs > 6
    error('mrg:InputFail', 'Requires at most 3 optional inputs');
end

% Set optional input defualts
dfs0 = 1;
% Read optional inputs
while ~isempty(varargin),
    if ischar(varargin{1})
        switch lower(varargin{1}(1:4))
            case 'dfs0'
                dfs0 = varargin{2};
            case 'file'
                filename = varargin{2};
            case 'beam'
                beamangle = varargin{2};
            otherwise
                error('mrg:InputFail','You provided an optional input not handled by the function.');
        end
    else
        error('mrg:InputFail','Optional inputs must be specified using the (keyword, value) syntax');
    end
    varargin([1 2])=[]; 
end

if ~exist('filename', 'var')
    [filename, path] = uigetfile({'*.hdr','SonTek header files (*.hdr)'}, 'Please select the hdr file');
    old_path = cd();
    cd(path);
else 
    old_path = cd();
end

if ~exist('beamangle', 'var')
    warning('mrg:DefaultValue', 'Beam angle (beamangle) not defined. Defaulting to 25 degrees')
    beamangle = 25;
end

%% Read and process the header file
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

% Now, read the ve (i.e. velocity east) file and add it to the struct
son_ve = dlmread(filename_ve);
sontek_struc.vel_east = son_ve(:,2:end)/100;

% Now, read the vn (i.e. velocity north) file and add it to the struct
son_vn = dlmread(filename_vn);
sontek_struc.vel_north = son_vn(:,2:end)/100;

% Now, read the vu (i.e. velocity up) file and add it to the struct
son_vu = dlmread(filename_vu);
sontek_struc.vel_up = son_vu(:,2:end)/100;

% Warn about unit conversion
warning('mrg:UnitChange', 'The velocity components have been divided by 100 to convert from cm/s to m/s')

%% Trim bins that are out of the water (sidelobe flitering)
cell_distances = 1:1:length(sontek_struc.vel_east(1,:));
cell_distances = cell_distances*cellsize+blankdist;

for n = 1:length(sontek_struc.profile)
    % Test pressure = cutoff depth for cells tested against the
    % cell_distances variable which is the distance from the sensor to the
    % top of the cell
    test_pressure = sontek_struc.mean_pressure(n)*cos(deg2rad(beamangle))-seabedtosen;
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

%% Create a DFS0 File
if dfs0
    variables = {'da_vel_east', 'da_vel_north', 'da_curr_speed', 'da_dir', 'mean_pressure'};
    mrg_mat_to_DFS0(sontek_struc, 'm_dt', variables);
end

%% End
cd(old_path)

end
