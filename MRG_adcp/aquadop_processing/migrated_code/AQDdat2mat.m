function [AQDdat_mat_out] = AQDdat2mat(filename, n_header_items)
% Reads .dat files from the AquaDopp
% Outputs a structuered array containing the data.
%   TODO:
%       Add compass correction (have as input)
%       Add pressure correction (also as input)
%       Allow header items as input (currently hard-coded below)
%       Allow side-lobe depth correction as an input (also hard-coded
%       below)
%   V2 DP 4/7/2012
%       - Removed all reference to the 'arbitary' percentage of the water
%       column cut-off (which is totally bollocks).  The correct number is
%       always cos(deg2rad(angle_of_the_beam)) - which for Nortek equipment
%       happens to be approx 90%
%       - Added 'header_items' as input (assumes 19 as the default if not supplied).

%% User-definable variables
% For printing errors and notes...
FUNCTION_NAME = 'AQDdat2mat';
% The number of header items (find this in the AquaDopp .hdr file).
if ~exist('n_header_items', 'var')
    n_header_items = 19;
end

%% Check that the supplied file exists and attempt to open it
if ~exist(filename, 'file')
    error(['The filename you passed to ', FUNCTION_NAME, ' does not exists, or is not accessible by MATLAB']);
end
% Try to open a file connection
fid = fopen(filename, 'r');
% Check that the file was opened
if fid == -1
    error(['MATLAB was unable to open the file supplied to ', FUNCTION_NAME]);
end

%% Check compass correction input


%% Check pressure correction input


%% Get started
disp(['  '])
disp(['Note: ', FUNCTION_NAME, ' is running under the assumption that there are ', num2str(n_header_items), ' items in each header row.'])
disp(['      This can be changed by modifiying the "n_header_items" variable in ', FUNCTION_NAME, '.m.'])

AQDdat_mat = [];
AQDdat_raw_meta = {};

% Setup some counters and internal variables
text_line_no = 1;
meta_dim = 1;

% Read a line of text.  The first line should be a header
text_line = fgetl(fid);

while text_line ~= -1 % i.e. Until the end of the file
    header = textscan(text_line, '%d %d %d %d %d %d %s %s %f %f %f %f %f %f %f %f %f %f %f');
    % Is a floating point number the best way to read this?
    if length(header) ~= n_header_items
        errordlg(['The header on line ', num2str(text_line_no), ' did not have ', num2str(n_header_items), ' items.  This is probably an error.'], 'Header Error');
        return
    else
        % Write the header to the meta object
        AQDdat_raw_meta(meta_dim,:) = header;
        % Now we need to read the actual profile data...
        % First, lets figure out how many lines to read...
        nread = header{n_header_items};
        % n_read should be the last object in the header
        % i.e. it should be the number of bins and therefore the number of
        % lines to read
        data_line_no = 1; % Set (or re-set) a new line counter...
        while data_line_no <= nread
            text_line = fgetl(fid);
            text_line_no = text_line_no+1; % Increment the whole-file line counter
            data_line = textscan(text_line, '%f');
            AQDdat_mat(meta_dim,data_line_no,:) = data_line{1};
            data_line_no = data_line_no + 1; % Increment the local data_line counter
        end
       
        text_line = fgetl(fid); % Get a new line to feed back into the while loop test
        text_line_no = text_line_no+1; % Increment the whole-file line counter
        meta_dim = meta_dim+1; % and increment the meta_dim counter
    end
end

%% Converting to MATLAB datetime and dropping duplicates
dn = cell2mat([AQDdat_raw_meta(:,[3,1,2,4,5,6])]);
datetime = datenum(double(dn));
% Looking for double ups in datetimes...
[~, n, ~] = unique(datetime, 'last');
num_doubles = length(AQDdat_mat)-length(n);

% Dropping double ups before processing...
datetime = datetime(n);
AQDdat_mat = AQDdat_mat(n,:,:);
AQDdat_raw_meta = AQDdat_raw_meta(n,:,:);

%% Generating output
% Ideally this would be dymanic i.e. read from the .hdr file.  Oh well.
AQDdat_mat_out = struct(...
    'datetime', datetime, ...
    'error_code', {AQDdat_raw_meta(:,7)}, ...
    'status_code', {AQDdat_raw_meta(:,8)}, ...
    'batt_volt_v', cell2mat(AQDdat_raw_meta(:,9)), ...
    'heading_deg', cell2mat(AQDdat_raw_meta(:,11)), ...
    'pitch_deg', cell2mat(AQDdat_raw_meta(:,12)), ...
    'roll_deg', cell2mat(AQDdat_raw_meta(:,13)), ...
    'pressure_dbar', cell2mat(AQDdat_raw_meta(:,14)), ...
    'temp_degC', cell2mat(AQDdat_raw_meta(:,15))...
    );
% Appending the profile data from above...
AQDdat_mat_out.profile = AQDdat_mat;

%% 'Sidelobe' (read: depth) filtering
if length(AQDdat_mat_out.pressure_dbar) ~= length(AQDdat_mat_out.datetime)
    disp(['Warning: The number of pressure values does not match the number of datetime values.']);
    disp(['         ', FUNCTION_NAME, ' cannot automatically remove bins that are out of the water.']);
    disp(['Error: ', FUNCTION_NAME, ' quit before completing']);
    return
end

% Keeping the removed bins (This could be removed later...)
% Being lazy - copying the entire profile object and blanking it with NaNs
AQDdat_mat_out.bins_removed = AQDdat_mat_out.profile;
AQDdat_mat_out.bins_removed(:) = NaN;

% Using the formula in the profiler manual
for n = 1:length(AQDdat_mat_out.datetime)
    cell_size = mode(diff(AQDdat_mat_out.profile(n,:,2)));
    % Test pressure = depth minus half of the cell size...
    % i.e. if any part of the cell is above water the whole cell gets
    % dropped
    test_pressure = (AQDdat_mat_out.pressure_dbar(n)*cos(25))-(cell_size/2);
    
    above = find(AQDdat_mat_out.profile(n,:,2) > test_pressure);
    if ~isempty(above)
        AQDdat_mat_out.bins_removed(n,above,:) = AQDdat_mat_out.profile(n,above,:);
        AQDdat_mat_out.profile(n,above,:) = NaN;
    end
end

% Some data for the final print out to screen
num_bin_total = length(AQDdat_mat_out.profile(:));
num_bins_removed = sum(sum(isnan(AQDdat_mat_out.profile(:,:,2))));
percent_removed = num_bins_removed/num_bin_total*100;

%% Depth averaged velocity...
% This is a first attmept only and does not deal with the fact that
% sometimes the whole water column isn't included in the velocity profile.
% Note also that we are re-calculating the speed here from the U and V
% components.  This is becuase the 'speed' reported by the AquaDopp ASCII
% file apprears to be sqrt(u^2+v^2) rounded to 3 decimal places.  Given
% that the U and V components appear to already be rounded to 3 d.p. it
% dosen't make a great deal of sense to round it again (alhtough this is
% what the Nortek software seems to do)

% Surely I can do this without a for loop...  
% Gah...  Save it for version 1.01! - Yep use nanmean(x, dim)
for n = 1:length(AQDdat_mat_out.profile)
    AQDdat_mat_out.da_u_vel(n,:) = nanmean(AQDdat_mat_out.profile(n,:,3));
    AQDdat_mat_out.da_v_vel(n,:) = nanmean(AQDdat_mat_out.profile(n,:,4));
    [theta, rho] = cart2pol(AQDdat_mat_out.da_v_vel(n,:), AQDdat_mat_out.da_u_vel(n,:));
    AQDdat_mat_out.da_speed(n,:) = abs(rho);
    dir = theta*180/pi;
    index = ~(dir > 0);
    AQDdat_mat_out.da_dir(n,:) = dir + index * 360;
end

%% A quick message about the above code chunk...
disp('    ');
disp(['Please check the source code for the assumptions underlying the calculation of depth averaged speed and direction!'])

%% Finishing up...
disp('   ')
disp(['Note: AQDdat2mat has processed ', num2str(length(AQDdat_mat)+num_doubles), ' profiles.'])
disp('      Confirm that this is correct by inspecting the ".hdr" file produced by the Nortek software.')
if num_doubles > 0
    disp(['      This includes ', num2str(num_doubles), ' profiles with duplicate timestamps which have not been included in the output.'])
end
if num_bins_removed > 0
    disp(['      ', num2str(percent_removed,2), ' % of bins were removed becuase the probably contined inteference from "sidelobes". See pg 76 of the AquaDopp manual.'])
end
disp('  ');

fclose(fid);

end