load('N9527000.mat');
indata = N9527000;
clear('N9527000');



figure(1)
p1(1) = subplot(4,1,1);
plot(indata.mtime(end-150000:end-82800), indata.pitch(end-150000:end-82800));
title('Pitch')
datetick('x');
p1(2) = subplot(4,1,2);
plot(indata.mtime(end-150000:end-82800), indata.roll(end-150000:end-82800));
title('Roll')
datetick('x');
p1(3) = subplot(4,1,3);
plot(indata.mtime(end-150000:end-82800), indata.heading(end-150000:end-82800));
title('Heading')
datetick('x');
p1(4) = subplot(4,1,4);
plot(indata.mtime(end-200000:end-82800), indata.pressure(end-200000:end-82800));
title('Pressure')
datetick('x');
linkaxes(p1,'x');

figure(2)
p2(1) = subplot(2,1,1);
plot(indata.mtime(1:end-82880), indata.pressure(1:end-82880));
title('Pressure')
datetick('x');
p2(2) = subplot(2,1,2);
plot(indata.mtime(1:end-82880), indata.depth(1:end-82880));
title('Depth')
datetick('x');
linkaxes(p2,'x');


% Suggest ditching all ensembles beyond end-82900 (i.e ensemble 703456)
% Only keeping a subset of data
data_trim = struct();
fields = {'mtime', 'depth', 'pressure', 'east_vel', 'north_vel', 'vert_vel'};
for a = 1:length(fields)
    data_trim.(fields{a}) = indata.(fields{a})(:,1:703456);
end

data_trim.config = indata.config;

% The arbitrary depth correction for sidelobe filtering
% Storm (Nortek software) uses 90% as a default value
% Gah!  The reason for this is that Nortek devices have a beam angle of 25
% degrees and cos(25*pi/180) = 0.9063.  Therefore this is not arbitary at
% all!
% COLUMN_PERC = 0.9; % Not needed

% Height above bed
HAB = 0.5; % TODO: Check this - and make this variable!!!

% Bin distance from bed
% TODO: Check RDI 'ranges' equal maximum extent of bin (suspect it does)...
bin_maximum = data_trim.config.ranges+HAB;
bin_mid = bin_maximum-data_trim.config.cell_size;
bin_mid(1) = (data_trim.config.ranges(1)-data_trim.config.blank)/2;
bin_mid(1) = bin_mid(1)+data_trim.config.blank+HAB;


% TODO: Need to get RDI manual and check beam angles provided is correct
beam_angle = data_trim.config.beam_angle;
cell_size = data_trim.config.cell_size;

for n = 1:length(data_trim.mtime)
    % Test pressure = depth (m)
    % Test is depth < bin maximum - if any part of the cell is within the
    % test depth it is dropped
    
    % TODO: Check this formula
    % TODO: Crude pressure to depth conversion - FIXME
    test_pressure = data_trim.pressure(n)/1000*cos(beam_angle*pi/180);
    
    above = find(bin_maximum > test_pressure);
    if ~isempty(above)
        data_trim.east_vel(above,n) = NaN;
        data_trim.north_vel(above,n) = NaN;
        data_trim.vert_vel(above,n) = NaN;
    end
end

% Speed and Direction....
[theta, rho] = cart2pol(data_trim.north_vel, data_trim.east_vel);
data_trim.speed = rho;
dir = theta*180/pi;
index = ~(dir > 0);
data_trim.dir = dir + index * 360;


%Distance from bed, as a proportion of current water depth (0-1)
% TODO - Again crude depth conversion...
binmaxrep = repmat(bin_maximum,1,length(data_trim.pressure));
binmidrep = repmat(bin_mid,1,length(data_trim.pressure));
presrep = repmat(data_trim.pressure,length(bin_maximum),1);
data_trim.bin_from_bed_max = binmaxrep./(presrep/1000);
data_trim.bin_from_bed_mid = binmidrep./(presrep/1000);

% Saving trimmed and processed data
save('N9527000_clean.mat','data_trim', '-v7.3')

% Time averging
time_window_min = 2;
time_window_mat = datenum([0,0,0,0,time_window_min,0]);
min_time = data_trim.mtime(1)+time_window_mat;
max_time = data_trim.mtime(end)-time_window_mat;

valid_times = find(data_trim.mtime >= min_time & data_trim.mtime <= max_time);

time_averaged = struct;
time_averaged.mtime = ones(1,length(valid_times));
time_averaged.nensm = ones(1,length(valid_times));
time_averaged.pressure = ones(1,length(valid_times));
dtss = size(data_trim.speed);
time_averaged.speed = ones(dtss(1),length(valid_times));
time_averaged.speed_n_nans = ones(dtss(1),length(valid_times));
time_averaged.bin_from_bed_max = ones(dtss(1),length(valid_times));
time_averaged.bin_from_bed_mid = ones(dtss(1),length(valid_times));

% Soooooo Slooooooow....
tic
for a = 1:length(valid_times)
    mint = data_trim.mtime(valid_times(a))-time_window_mat/2;
    maxt = data_trim.mtime(valid_times(a))+time_window_mat/2;
    valid = find(data_trim.mtime >= mint & data_trim.mtime <= maxt);
    time_averaged.mtime(a) = data_trim.mtime(valid_times(a));
    time_averaged.nensm(a) = length(valid);
    time_averaged.pressure(a) = nanmean(data_trim.pressure(valid_times(a)));
    time_averaged.speed(:,a) = nanmean(data_trim.speed(:,valid),2);
    time_averaged.speed_n_nans(:,a) = sum(isnan(data_trim.speed(:,valid)),2);
    time_averaged.bin_from_bed_max(:,a) = nanmean(data_trim.bin_from_bed_max(:,valid),2);
    time_averaged.bin_from_bed_mid(:,a) = nanmean(data_trim.bin_from_bed_mid(:,valid),2);
end
toc

time_averaged.info = ['These data are 2 min averages (approx 60 ensembles).\n',...
    'Bins contaminated by sidelobes were removed prior to analysis.\n\n',...
    'mtime:\t\t\t\tThe centroid of the time axis (i.e. the data are 1 min either side of the time specified in "mtime").\n',...
    'nensm:\t\t\t\tThe number of ensembles in the average (usually 60)\n',...
    'pressure:\t\t\tAverage pressure as recorded by the ADCP\n',...
    'speed:\t\t\t\tAverage speed.  Calculated using cart2pol from u and v velocity components in the raw data.  Averaged using nanmean().\n',...
    'speed_n_nans:\t\tThe number of NaN values in each over the averging period (removed implicitly by nanmean()).\n',...
    'bin_from_bed_max:\tThe (mean) maximum bin distance from the bed, as a proportion of water depth (0 = on benthos, 1 = at surface).\n',...
    'bin_from_bed_mid:\tThe (mean) center of the bin from the bed, as a proportion of water depth (0 = on benthos, 1 = at surface).\n\n',...
    'Caveat emptor: Processed by Dan on 13/05/2012 using a horribly inefficient, largely experimental, MATLAB script.'];

save('N9527000_2minAv.mat','time_averaged', '-v7.3')
load('N9527000_2minAv')


N9527000_profiles = struct;
N9527000_profiles.mtime = time_averaged.mtime(:,390:450:end);
N9527000_profiles.nensm = time_averaged.nensm(:,390:450:end);
N9527000_profiles.pressure = time_averaged.pressure(:,390:450:end);
N9527000_profiles.speed = time_averaged.speed(:,390:450:end);
N9527000_profiles.speed_n_nans = time_averaged.speed_n_nans(:,390:450:end);
N9527000_profiles.bin_from_bed_max = time_averaged.bin_from_bed_max(:,390:450:end);
N9527000_profiles.bin_from_bed_mid = time_averaged.bin_from_bed_mid(:,390:450:end);
N9527000_profiles.info = time_averaged.info;

save('N9527000_2minAv_subset.mat','N9527000_profiles', '-v7.3')

load('N9527000_2minAv_subset.mat')
sprintf(N9527000_profiles.info)

%% Plotting
clear all
load('N9527000_clean.mat');


% Single profile
plot(data_trim.speed(:,valid), data_trim.config.ranges, 'o', 'MarkerEdgeColor', [0.9,0.9,0.9], 'MarkerSize', 3)
hold on
plot(time_averaged.speed, data_trim.config.ranges)
hold off

% Several 2min profiles
profile = 10;
figure(2)
subplot(2,10,[1 10])
plot(N9527000_profiles.mtime(:,[profile:profile+10]), N9527000_profiles.pressure(:,[profile:profile+10]), 'o-k');
datetick('x');
for n = 1:10
    subplot(2,10,n+10)
    plot(N9527000_profiles.speed(:,profile+n-1), N9527000_profiles.bin_from_bed_mid(:,profile+n-1))
    ylim([0,1]);
    xlim([0,4]);
end

% Plotting NaN bins
%plotting_nans = data_trim;
plotting_nans=north_raw;
HAB = 0.5; 
bin_maximum = plotting_nans.config.ranges+HAB;
beam_angle = plotting_nans.config.beam_angle;
maxspeed = max(plotting_nans.speed(:));
outofwatercol = maxspeed*2;
for n = 1:length(plotting_nans.mtime)
    test_pressure = plotting_nans.pressure(n)/1000*cos(beam_angle*pi/180);
    above = find(bin_maximum > test_pressure);
    if ~isempty(above)
        plotting_nans.speed(above,n) = outofwatercol;
    end
end

ylim = [min(plotting_nans.config.ranges), max(plotting_nans.config.ranges)];
xlim = [1, length(plotting_nans.speed)];
nan_index = find(isnan(plotting_nans.speed));
inwaternancol = maxspeed*1.5;
plotting_nans.speed(nan_index) = inwaternancol;
figure(3)
image(xlim,ylim,plotting_nans.speed);
set(gca,'YDir','normal')

% Why???? Manual Colour Map

hold on
plot(plotting_nans.pressure/1000, 'w')












mode(diff(data_trim.mtime))

datestr(data_trim.mtime)
