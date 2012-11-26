% Process mmt file

[filename, path] = uigetfile('.mmt', 'Choose measurement file to guide the analysis');
cd(path);

% Read data
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
    try
        % FIXME: Assuming ADCP data is the first file (error check needed)
        file = transects.(transect_names{a}).mmt_info.files{1};
        no_ensem = transects.(transect_names{a}).mmt_info.TotalNmbEnsembles;
        [transects.(transect_names{a}).adcp] = rdradcp(file, 1, no_ensem);
        summary = [summary, char(transect_names{a}), '\t: OK\n'];
    catch error
        summary = [summary, char(transect_names{a}), '\t: Unable to read ADCP data or information\n'];
    end
end
fprintf(summary)

%% Parse NMEA formatted data
fid = fopen('0_016_000_11-05-17_192324_GPS.TXT');
tline = fgetl(fid);
while ischar(tline)
    disp(tline)
    tline = fgetl(fid);
end
fclose(fid);



