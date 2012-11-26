%% Opening Briggs 101 and processing in AQDdat2mat
[filename, path] = uigetfile('.dat');
cd(path);
[AQDdat_mat_out] = AQDdat2mat(filename);

% GMT Conversion for Briggs 101 only
AQDdat_mat_out.datetime = AQDdat_mat_out.datetime-(1/24);

% Remove unwated dates from end of the file
MAX_ROW = 3495; % For Briggs 101 - Just three readings at the end whilst on DC supply in the office

structure_names = fieldnames(AQDdat_mat_out);
for n = 1:length(structure_names)
    a = ['ndims(AQDdat_mat_out.', char(structure_names(n)), ')'];
    no_dims = eval(a);
    b = ['AQDdat_mat_out.',char(structure_names(n)),' = AQDdat_mat_out.',...
        char(structure_names(n)),'(1:',num2str(MAX_ROW),repmat(',:',1,no_dims-1),')'];
    t = evalc(b);
end

% Clearing up
AQDdat_mat_out_B1 = AQDdat_mat_out;
clearvars -except AQDdat_mat_out_*

% Saving 'raw' data
[fname,path] = uiputfile('briggs_101.mat','Output filename');
cd(path);
save(fname, 'AQDdat_mat_out_B1');

%% Opening Briggs 201 and processing in AQDdat2mat
[filename, path] = uigetfile('.dat');
cd(path);
[AQDdat_mat_out] = AQDdat2mat(filename);

MAX_ROW = 930; % For Briggs 201 - i.e. about 14:30pm - based on dive time and plots of pitch and roll...

structure_names = fieldnames(AQDdat_mat_out);
for n = 1:length(structure_names)
    a = ['ndims(AQDdat_mat_out.', char(structure_names(n)), ')'];
    no_dims = eval(a);
    b = ['AQDdat_mat_out.',char(structure_names(n)),' = AQDdat_mat_out.',...
        char(structure_names(n)),'(1:',num2str(MAX_ROW),repmat(',:',1,no_dims-1),')'];
    t = evalc(b);
end

% Clearing up
AQDdat_mat_out_B2 = AQDdat_mat_out;
clearvars -except AQDdat_mat_out_*

% Saving 'raw' data
[fname,path] = uiputfile('briggs_201.mat','Output filename');
cd(path);
save(fname, 'AQDdat_mat_out_B2');

%% Padding data to equidistant
[AQDdat_mat_out_B1_equi, datetime_name_B1] = padstruct2equidistant(AQDdat_mat_out_B1);
[AQDdat_mat_out_B2_equi, datetime_name_B2] = padstruct2equidistant(AQDdat_mat_out_B2);

%% Filtering data
% For the filtering to work there can't be any large gaps in the data
% (which there will be if I merged the two structures and then pad them to
% equidistant. So for now we need to filter each dataset seperatly.
% Note also that the AQDmatfilt fucntion does some interpolation to fill
% gaps in the data...

AQDdat_mat_out_B1_equi = AQDmatfilt(AQDdat_mat_out_B1_equi);
figure; plot(AQDdat_mat_out_B1_equi.da_speed_interp); hold on; plot(AQDdat_mat_out_B1_equi.da_speed, 'g'); plot(AQDdat_mat_out_B1_equi.da_speed_filt, 'r');
figure; plot(AQDdat_mat_out_B1_equi.da_dir_interp); hold on; plot(AQDdat_mat_out_B1_equi.da_dir, 'g'); plot(AQDdat_mat_out_B1_equi.da_dir_filt, 'r');

AQDdat_mat_out_B2_equi = AQDmatfilt(AQDdat_mat_out_B2_equi);
figure; plot(AQDdat_mat_out_B2_equi.da_speed); hold on; plot(AQDdat_mat_out_B2_equi.da_speed_filt, 'r');
figure; plot(AQDdat_mat_out_B2_equi.da_dir); hold on; plot(AQDdat_mat_out_B2_equi.da_dir_filt, 'r');

%% Saving filtered and padded data (to mat and DFSx formats)
[fname,path] = uiputfile('briggs_101_equidistant.mat','Output filename');
cd(path);
save(fname, 'AQDdat_mat_out_B1_equi');

% Variables is a cell array containing the variable to save to DFS0
variables = {'batt_volt_v','heading_deg','pitch_deg','roll_deg','pressure_dbar','temp_degC','da_u_vel',...
    'da_v_vel','da_speed','da_dir','da_u_vel_interp','da_v_vel_interp','da_u_vel_filt','da_v_vel_filt',...
    'da_speed_interp','da_dir_interp','da_speed_filt','da_dir_filt'};

mat2DFS0(AQDdat_mat_out_B1_equi, datetime_name_B1, variables);
AQDmat2DFS1(AQDdat_mat_out_B1_equi, datetime_name_B1);

% Same for Briggs 201...
[fname,path] = uiputfile('briggs_201_equidistant.mat','Output filename');
cd(path);
save(fname, 'AQDdat_mat_out_B2_equi');
mat2DFS0(AQDdat_mat_out_B2_equi, datetime_name_B2, variables);
AQDmat2DFS1(AQDdat_mat_out_B2_equi, datetime_name_B2);

%% Merge both data sets and save as MAT and DFSx
AQDdat_mat_out_both = [];

names=fieldnames(AQDdat_mat_out_B1_equi);
for i = 1:length(names)
    AQDdat_mat_out_both.(names{i})=[AQDdat_mat_out_B1_equi.(names{i}); AQDdat_mat_out_B2_equi.(names{i})];
end

[AQDdat_mat_out_both, datetime_name_both] = padstruct2equidistant(AQDdat_mat_out_both);

[fname,path] = uiputfile('briggs_both_equidistant.mat','Output filename');
cd(path);
save(fname, 'AQDdat_mat_out_both');

mat2DFS0(AQDdat_mat_out_both, datetime_name_both, variables);


%% Harmonic Analysis of Briggs 101 Data
% Needs to be done on equidistant data
[file, path] = uigetfile('*.mat', 'Load equidistant MAT data for Briggs 101');
cd(path);
load(file);
% Pressure
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B1_equi.pressure_dbar,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B1_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B1_equi.pressure_dbar, tidestruc)

figure; plot(AQDdat_mat_out_B1_equi.datetime,AQDdat_mat_out_B1_equi.pressure_dbar);
hold on; plot(AQDdat_mat_out_B1_equi.datetime,xout+nanmean(AQDdat_mat_out_B1_equi.pressure_dbar), 'r');

% U Component
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B1_equi.da_u_vel,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B1_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B1_equi.da_u_vel, tidestruc)

figure; plot(AQDdat_mat_out_B1_equi.datetime,AQDdat_mat_out_B1_equi.da_u_vel);
hold on; plot(AQDdat_mat_out_B1_equi.datetime,xout+nanmean(AQDdat_mat_out_B1_equi.da_u_vel), 'r');
%hold on; plot(AQDdat_mat_out_B1_equi.datetime,xout-nanmean(AQDdat_mat_out_B1_equi.da_u_vel), 'g');

% V Component
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B1_equi.da_v_vel,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B1_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B1_equi.da_v_vel, tidestruc)

figure; plot(AQDdat_mat_out_B1_equi.datetime,AQDdat_mat_out_B1_equi.da_v_vel);
hold on; plot(AQDdat_mat_out_B1_equi.datetime,xout+nanmean(AQDdat_mat_out_B1_equi.da_v_vel), 'r');


%% Harmonic Analysis of Briggs 201 Data
% Needs to be done on equidistant data
[file, path] = uigetfile('*.mat', 'Load equidistant MAT data for Briggs 201');
cd(path);
load(file);
% Pressure
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B2_equi.pressure_dbar,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B2_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B2_equi.pressure_dbar, tidestruc)

figure; plot(AQDdat_mat_out_B2_equi.datetime,AQDdat_mat_out_B2_equi.pressure_dbar);
hold on; plot(AQDdat_mat_out_B2_equi.datetime,xout+nanmean(AQDdat_mat_out_B2_equi.pressure_dbar), 'r');

% U Component
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B2_equi.da_u_vel,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B2_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B2_equi.da_u_vel, tidestruc)

figure; plot(AQDdat_mat_out_B2_equi.datetime,AQDdat_mat_out_B2_equi.da_u_vel);
hold on; plot(AQDdat_mat_out_B2_equi.datetime,xout+nanmean(AQDdat_mat_out_B2_equi.da_u_vel), 'r');

% V Component
[harm_FName,path] = uiputfile('*.mcon','Output filename');
cd(path);
[tidestruc,xout]=t_tide(AQDdat_mat_out_B2_equi.da_v_vel,...
    'interval',0.25,...
    'start time',min(AQDdat_mat_out_B2_equi.datetime),...
    'output',harm_FName,...
    'latitude',54.6822932);

ttide2mikecon(AQDdat_mat_out_B2_equi.da_v_vel, tidestruc)

figure; plot(AQDdat_mat_out_B2_equi.datetime,AQDdat_mat_out_B2_equi.da_v_vel);
hold on; plot(AQDdat_mat_out_B2_equi.datetime,xout+nanmean(AQDdat_mat_out_B2_equi.da_v_vel), 'r');