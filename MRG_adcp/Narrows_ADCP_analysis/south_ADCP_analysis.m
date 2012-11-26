%S5348000 = rdradcp('S5348000.000',1);
%save('S5348000.mat', 'S5348000', '-v7.3');

load('S5348000.mat');
indata = S5348000;
clear('S5348000');


figure(1)
p1(1) = subplot(4,1,1);
plot(indata.mtime(end-150000:end-125300), indata.pitch(end-150000:end-125300));
title('Pitch')
datetick('x');
p1(2) = subplot(4,1,2);
plot(indata.mtime(end-150000:end-125300), indata.roll(end-150000:end-125300));
title('Roll')
datetick('x');
p1(3) = subplot(4,1,3);
plot(indata.mtime(end-150000:end-125300), indata.heading(end-150000:end-125300));
title('Heading')
datetick('x');
p1(4) = subplot(4,1,4);
plot(indata.mtime(end-15000:end-125300), indata.pressure(end-200000:end-125300));
title('Pressure')
datetick('x');
linkaxes(p1,'x');

figure(2)
p2(1) = subplot(2,1,1);
plot(indata.mtime(1:end-125300), indata.pressure(1:end-125300));
title('Pressure')
datetick('x');
p2(2) = subplot(2,1,2);
plot(indata.mtime(1:end-125300), indata.depth(1:end-125300));
title('Depth')
datetick('x');
linkaxes(p2,'x');


% Suggest ditching all ensembles beyond end-125300 (i.e ensemble 658865)
% Only keeping a subset of data
data_trim = struct();
fields = {'mtime', 'depth', 'pressure', 'east_vel', 'north_vel', 'vert_vel'};
for a = 1:length(fields)
    data_trim.(fields{a}) = indata.(fields{a})(:,1:658865);
end

data_trim.config = indata.config;

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


% Distance from bed, as a proportion of current water depth (0-1)
% TODO - Again crude depth conversion...
binmaxrep = repmat(bin_maximum,1,length(data_trim.pressure));
binmidrep = repmat(bin_mid,1,length(data_trim.pressure));
presrep = repmat(data_trim.pressure,length(bin_maximum),1);
data_trim.bin_from_bed_max = binmaxrep./(presrep/1000);
data_trim.bin_from_bed_mid = binmidrep./(presrep/1000);

% Saving trimmed and processed data
save('S5348000_clean.mat','data_trim', '-v7.3')

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

% Some checks...
[histo,x] = hist(time_averaged.nensm);


time_averaged.info = ['These data are 2 min averages (approx 60 ensembles).\n',...
    'Bins contaminated by sidelobes were removed prior to analysis.\n\n',...
    'mtime:\t\t\t\tThe centroid of the time axis (i.e. the data are 1 min either side of the time specified in "mtime").\n',...
    'nensm:\t\t\t\tThe number of ensembles in the average (usually 60)\n',...
    'pressure:\t\t\tAverage pressure as recorded by the ADCP\n',...
    'speed:\t\t\t\tAverage speed.  Calculated using cart2pol from u and v velocity components in the raw data.  Averaged using nanmean().\n',...
    'speed_n_nans:\t\tThe number of NaN values in each over the averging period (removed implicitly by nanmean()).\n',...
    'bin_from_bed_max:\tThe (time-averaged) maximum bin distance from the bed, as a proportion of water depth (0 = on benthos, 1 = at surface).\n',...
    'bin_from_bed_mid:\tThe (time-averaged) center of the bin from the bed, as a proportion of water depth (0 = on benthos, 1 = at surface).\n\n',...
    'Caveat emptor: Processed by Dan on 15/05/2012 using a horribly inefficient, largely experimental, MATLAB script.'];

save('S5348000_2minAv.mat','time_averaged', '-v7.3')
load('S5348000_2minAv')

S5348000_profiles = struct;
S5348000_profiles.mtime = time_averaged.mtime(:,390:450:end);
S5348000_profiles.nensm = time_averaged.nensm(:,390:450:end);
S5348000_profiles.pressure = time_averaged.pressure(:,390:450:end);
S5348000_profiles.speed = time_averaged.speed(:,390:450:end);
S5348000_profiles.speed_n_nans = time_averaged.speed_n_nans(:,390:450:end);
S5348000_profiles.bin_from_bed_max = time_averaged.bin_from_bed_max(:,390:450:end);
S5348000_profiles.bin_from_bed_mid = time_averaged.bin_from_bed_mid(:,390:450:end);
S5348000_profiles.info = time_averaged.info;

save('S5348000_2minAv_subset.mat','S5348000_profiles', '-v7.3')

load('S5348000_2minAv_subset.mat')
sprintf(S5348000_profiles.info)

%% Plotting
clear all
load('S5348000_clean.mat');


% Single profile - not wise!
plot(data_trim.speed(:,valid), data_trim.config.ranges, 'o', 'MarkerEdgeColor', [0.9,0.9,0.9], 'MarkerSize', 3)
hold on
plot(time_averaged.speed, data_trim.config.ranges)
hold off

% Several 2min profiles
profile = 20;
figure(1)
for n = 1:20
    subplot(2,10,n)
    plot(S5348000_profiles.speed(:,profile+n-1), S5348000_profiles.bin_from_bed_mid(:,profile+n-1))
end

% Plotting NaN bins
plotting_nans = raw_south;
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
figure(4)
h = image(xlim,ylim,plotting_nans.speed);

set(gca,'YDir','normal')

% Why???? Manual Colour Map

hold on
plot(plotting_nans.pressure/1000, 'w')














mode(diff(data_trim.mtime))

datestr(data_trim.mtime)
