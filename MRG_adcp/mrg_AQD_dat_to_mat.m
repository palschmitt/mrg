function [AQDdat_mat_out] = mrg_AQD_dat_to_mat(filename, n_header_items)
% Reads .dat files from the Aquadopp
% Outputs a structured array containing the data.
%   TODO:
%       Add compass correction (have as input)
%       Add pressure correction (also as input)
%       Allow header items as input (currently hard-coded below)
%       Allow side-lobe depth correction as an input (also hard-coded
%       below)
%       Optimise / speed up!
%       Deal with testing for equidistances
%   V2 DP 4/7/2012
%       - Removed all reference to the 'arbitary' percentage of the water
%       column cut-off (which is totally bollocks).  The correct number is
%       always cos(deg2rad(angle_of_the_beam)) - which for Nortek equipment
%       happens to be approx 90%
%       - Added 'header_items' as input (assumes 19 as the default if not supplied).

%% Check input variables

% Check that the supplied file exists
if ~exist(filename, 'file')
    error(['The filename you passed to ' mfilename ' does not exists, or is not accessible by MATLAB']);
end

% The number of header items (find this in the AquaDopp .hdr file).
if ~exist('n_header_items', 'var')
    n_header_items = 19;
    warning('mrg:DefaultValue', ['The function ' mfilename ' is assuming you have 19 header items']);
end

%% Try to open a file connection
fid = fopen(filename, 'r');
% Check that the file was opened
if fid == -1
    error(['MATLAB was unable to open the file supplied to ' mfilename]);
end

%% Check compass correction input


%% Check pressure correction input


%% Get started

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
        error(['The header on line ', num2str(text_line_no), ' did not have ', num2str(n_header_items), ' items.  This is probably an error.']);
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

fclose(fid);

%% Converting to MATLAB datetime and finding duplicates
datevector = cell2mat(AQDdat_raw_meta(:,[3,1,2,4,5,6]));
datetime = datenum(double(datevector));
% Looking for double ups in datetimes...
% This is probably caused by the wavebursts (profiles can't be taken while
% the wavebursts are underway)
% The ASCII output function of AquaPro seems to just duplicate the next 'good' profile to fill the gap. 
% e.g. if 1715 is missing, there will be two (identical) readings for 1730.
[~, m, ~] = unique(datetime, 'last');

% Dropping double ups before processing...
datetime = datetime(m);
datevector = datevector(m,:);

AQDdat_mat = AQDdat_mat(m,:,:);
AQDdat_raw_meta = AQDdat_raw_meta(m,:,:);

%% Generating output
% Ideally this would be dymanic i.e. read from the .hdr file.  Oh well.
AQDdat_mat_out = struct(...
    'datetime', datetime, ...
    'datevector', datevector, ...
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

end