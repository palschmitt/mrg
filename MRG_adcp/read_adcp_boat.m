function transects = read_adcp_boat(filename)
% A function to process the output from mmt file.
% INPUT
%   filename    An optional string specifying the location of the
%               measurment (*.mmt) file.  Prompted if missing.
%
% OUTPUT
%   transects   A nested structure.  Ugly.  Needs proper documentation.  
% 
% REQUIREMENTS
%   Requires the rdradcp function from Rich Pawlowicz's toolbox.  Tested
%   with version 13/Mar/2010. 
%   
%   Requires the nmealineread function by Adam Leadbetter from the MATLAB
%   file exchange. See here:
%   http://www.mathworks.com/matlabcentral/fileexchange/24100-nmea-0183-sentence-reader
%
% NOTES
%
%   IMPORTANT INFORMATION ABOUT COORDINATE SYSTEMS
%   This function WILL NOT stransform your coordinate system.  This is
%   often probelmatice as vessel-mounted ADCP data is often collected in
%   'ship' coordinates.  If this is too much to handel then it is
%   recomended that you check out 'mrg_read_WRII_ascii.m' instead.
%
%   IMPORTANT INFORMATION ABOUT GPS DATA
%   This script tries to deal with NMEA (i.e. GPS data) from encoded in
%   text files. This information IS encoded in the ADCP binary (*.PD0)
%   file, but is not read in by rdradcp due to poor documentation of the
%   format by RDI (according to Rich Pawlowicz).
%   To achieve this, the function hunts in the transect information
%   (mmt_info) for a file with 'GPS' in the filename.  If an appropriate
%   file reference isn't found, or more than 1 file reference is found,
%   then this is reported in the summary and the NMEA data parsing will
%   fail.
%   If the parsing the NMEA data fails for any reason then no lat / long
%   information will be added to the adcp structure (adcp).  Currently
%   (2012-09) this will mean that the lat / long information will be
%   uindefined (NaN) (see above regarding limitations reading NMEA data
%   from PDO files).
%   If parsing of NMEA data is successful, then the ADCP ensembles and NMEA
%   data are merged together (into the adcp structure) based on the
%   adcp.nav_mtime and nmea_GPGGA.BODCTime fields.
%   
%   IMPORTANT ASSUMPTION
%   This function assumes that the number ensembles reported by the MMT
%   file is correct and 'forces' the rdradcp function to only read this
%   number of ensembles.  
%
%   IMPLEMENTATION NOTES
%   Essentially this function proceeds through four important 'conceptual phases'.
%       1) Read the MMT file.  Parse this information.
%       2) Use data in the parsed MMT file to find and read adcp data from
%       PDO files.  
%       3) Use data in the parsed MMT file to find and read NMEA data from
%       text files.
%       4) Merge the ADCP and NMEA data
%   In principle step 1 must succeed.  Step 2 or 3 may (optionally)
%   succeed, but if either of these fail then so will step 4.
%
% DEVELOPMENT
%   v 1.0   2011-09-01
%           Initial attempt.  DP
%   v 1.1   2012-09-26
%           NMEA Text file parsing.  DP
%   v 1.2   2012-09-28
%           Merging of GPS data and NMEA data.  DP and BE.
%   v 1.2.1 November 2012
%           Note added about the now fully operational 'mrg_read_WRII_ascii.m'
%           (Now witness the firepower of this fully armed and operational battle station!)
%
% TODO 
%   Output a proper log, or a logical array.  Not a 'summary' string.  


%% Find the mmt file
old_path = pwd;
if ~exist('filename')
    [filename, path] = uigetfile('.mmt', 'Choose measurement file to guide the analysis');
    cd(path);
end

%% Read data
mmt_data = xmlread(filename);
% Get discharge data
discharge_data = mmt_data.getElementsByTagName('Site_Discharge');
if discharge_data.getLength ~= 1
    error('More than one Site_Discharge node in MMT file.  Not good.');
end
% A blank output structure
transects = struct; 
% Get transects and discharge summary
transects_xml = discharge_data.item(0).getElementsByTagName('Transect');
transect_summary_xml = discharge_data.item(0).getElementsByTagName('Discharge_Summary').item(0).getFirstChild;
% These should be the same length
if transects_xml.getLength ~= transect_summary_xml.getLength
    error('Transect information and summary nodes have different lengths.  Not good.')
end

for a = 0:transects_xml.getLength-1
    % Get filenames...
    files_data = transects_xml.item(a).getElementsByTagName('File');
    files = cell(1, files_data.getLength);
    for b = 0:files_data.getLength-1
       files{b+1} = char(files_data.item(b).getTextContent);
    end
    transects.(['transect_', num2str(a)]).mmt_info.files = files;
    % Get other info...
    other_info = transect_summary_xml.item(a);
    for b = 0:other_info.getLength-1
        key = char(other_info.item(b).getTagName);
        value = char(other_info.item(b).getTextContent);
        % Type the values (they are returned as char, which is not
        % helpful).  
         if all(isstrprop(value, 'digit'))
             transects.(['transect_', num2str(a)]).mmt_info.(key) = str2num(value);
         elseif ~isnan(str2double(value));
             transects.(['transect_', num2str(a)]).mmt_info.(key) = str2double(value);
         else
             transects.(['transect_', num2str(a)]).mmt_info.(key) = value;
         end
    end
end

%% Cycle through the transecs and read ADCP data
transect_names = fieldnames(transects);
summary = '\n\nSummary\n-------\n';
for a = 1:length(transect_names)
%for a = 38
    nmea_parse_ok = 0;
    adcp_parse_ok = 0;
    file = transects.(transect_names{a}).mmt_info.files{1};
    [~, ~, ext] = fileparts(file);
    if ~strcmp(lower(ext), '.pd0')
        error('First file in the mmt_info struct is not a PDO file')
        % FIXME: This is ugly! Warn, maybe?
        % Maybe not... 
    end
    try
        no_ensem = transects.(transect_names{a}).mmt_info.TotalNmbEnsembles;
        [transects.(transect_names{a}).adcp] = rdradcp(file, 1, no_ensem-1);
        if isfield(transects.(transect_names{a}).adcp, 'nav_mtime')
            summary = [summary, char(transect_names{a}), ' ADCP\t: OK\n'];
            adcp_parse_ok = 1;
        else
            summary = [summary, char(transect_names{a}), ' ADCP\t: Data read OK. But nav_mtime is missing. NMEA merge will fail.\n'];
        end
    catch
        summary = [summary, char(transect_names{a}), ' ADCP\t: Unable to read ADCP data or information\n'];
    end
    % Try to parse the GPS info from the NMEA strings...
    gpsfiles = strfind(lower(transects.(transect_names{a}).mmt_info.files), 'gps');
    if all(cellfun('isempty',gpsfiles))
        summary = [summary, char(transect_names{a}), ' NMEA\t: There is no GPS file to process.\n'];
    elseif sum(~cellfun('isempty',gpsfiles)) ~= 1
        summary = [summary, char(transect_names{a}), ' NMEA\t: There is are more than 1 GPS file to process. Nothing done!\n'];
    else
        gpsfile_loc = find(cellfun('isempty',gpsfiles)==0);
        try
            file = transects.(transect_names{a}).mmt_info.files{gpsfile_loc};
            transects.(transect_names{a}).nmea_GPGGA = struct('BODCTime', [], 'latitude', [], 'longitude', []);
            transects.(transect_names{a}).nmea_GPZDA = struct('BODCTime', []);
            fid = fopen(file);
            tline = fgetl(fid);
            while ischar(tline)
                %disp(tline)
                if strcmp(tline(1:6),'$GPGGA')
                    nmea_GPGGA = nmealineread(tline);
                    transects.(transect_names{a}).nmea_GPGGA.BODCTime = [transects.(transect_names{a}).nmea_GPGGA.BODCTime,nmea_GPGGA.BODCTime];
                    transects.(transect_names{a}).nmea_GPGGA.latitude = [transects.(transect_names{a}).nmea_GPGGA.latitude,nmea_GPGGA.latitude];
                    transects.(transect_names{a}).nmea_GPGGA.longitude = [transects.(transect_names{a}).nmea_GPGGA.longitude,nmea_GPGGA.longitude];
                    clearvars('nmea_GPGGA')
                elseif strcmp(tline(1:6),'$GPZDA')
                    nmea_GPZDA = nmealineread(tline);
                    transects.(transect_names{a}).nmea_GPZDA.BODCTime = [transects.(transect_names{a}).nmea_GPZDA.BODCTime,nmea_GPZDA.BODCTime];
                    clearvars('nmea_GPZDA')
                end
                tline = fgetl(fid);
            end
            fclose(fid);
            summary = [summary, char(transect_names{a}), ' NMEA\t: OK\n'];
            nmea_parse_ok = 1;
        catch except
            summary = [summary, char(transect_names{a}), ' NMEA\t: There was an error parsing the NMEA txt file. ',char(file),'.  The last line was: ',char(tline),'\n'];
        end
    end
    % Merge NMEA data and ADCP ensembles
    if ~all([adcp_parse_ok, nmea_parse_ok])
        summary = [summary, char(transect_names{a}), ' COMB\t: Merging of NMEA and ADCP not attempted\n'];
    else
        % Some crap matlab code written by Björn
        % Dan thinks this is fine since we found adcp.nav_mtime ... the holy grail!!
        % Find GPS readings within 0.5 seconds of the adcp.nav_mtime value
        index = NaN(1,length(transects.(transect_names{a}).adcp.nav_mtime));
        for n = 1:length(transects.(transect_names{a}).adcp.nav_mtime)
            temp_index = find(abs(transects.(transect_names{a}).nmea_GPGGA.BODCTime - ...
                transects.(transect_names{a}).adcp.nav_mtime(n)) <= 0.5 /(24*3600),1,'first');
            if isempty(temp_index)
                index(n) = NaN;
            else
                index(n) = temp_index;
            end
        end
        % Try and write NMEA lat / long into the ADCP structure
        try
            no_nan_index = index(~isnan(index));
            transects.(transect_names{a}).adcp.nav_latitude(~isnan(index)) = transects.(transect_names{a}).nmea_GPGGA.latitude(no_nan_index);
            transects.(transect_names{a}).adcp.nav_longitude(~isnan(index)) = transects.(transect_names{a}).nmea_GPGGA.longitude(no_nan_index);
            if any(isnan(index))
                summary = [summary, char(transect_names{a}), ' COMB\t: OK.  But ',num2str(length(index)-length(no_nan_index)), ' lats(s) or long(s) could not be filled (NaNs left in place)\n'];
            else
                summary = [summary, char(transect_names{a}), ' COMB\t: OK\n'];
            end
        catch except
            summary = [summary, char(transect_names{a}), ' COMB\t: Merging of NMEA and ADCP data failed\n'];
        end
    end
end

fprintf(summary)

%% Back to the original path
cd(old_path)

end


