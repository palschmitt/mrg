load('S5348000_clean.mat')
south_raw = data_trim;
clear('data_trim')

load('N9527000_clean.mat')
north_raw = data_trim;
clear('data_trim')

max_s = max(south_raw.speed(:));
max_n = max(north_raw.speed(:));

% Maplength - defines the colour map length, but also the value applied to
% the NaNs (otherwise they are lumped with the zeros)
maplength = ceil(max([max_s,max_n]))+1;

HAB = 0.5; 

% Quick check...
all(south_raw.config.ranges == north_raw.config.ranges)
all(south_raw.config.beam_angle == north_raw.config.beam_angle)
%OK

bin_maximum = south_raw.config.ranges+HAB;
beam_angle = south_raw.config.beam_angle;

srs = south_raw.speed;
nrs = north_raw.speed;

% Setting Window For Figure Averages
prof_min = 543000;
prof_max = 543120;

s_prof_vel = nanmean(srs(:,prof_min:prof_max),2);
s_prof_height = south_raw.config.ranges;

n_prof_vel = nanmean(nrs(:,prof_min:prof_max),2);
n_prof_height = north_raw.config.ranges;

% Setting NANs to plot-able values

% South out of water correction
for n = 1:length(south_raw.mtime)
    test_pressure = south_raw.pressure(n)/1000*cos(beam_angle*pi/180);
    above = find(bin_maximum > test_pressure);
    if ~isempty(above)
        south_raw.speed(above,n) = maplength;
    end
end
% North out of water correction
for n = 1:length(north_raw.mtime)
    test_pressure = north_raw.pressure(n)/1000*cos(beam_angle*pi/180);
    above = find(bin_maximum > test_pressure);
    if ~isempty(above)
        north_raw.speed(above,n) = maplength;
    end
end


figylim = [min(south_raw.config.ranges), max(south_raw.config.ranges)];
figxlim = [1, max([length(north_raw.mtime), length(south_raw.mtime)])];

sindex = find(isnan(south_raw.speed));
south_raw.speed(sindex) = maplength;
nindex = find(isnan(north_raw.speed));
north_raw.speed(nindex) = maplength;



x_patch = [prof_min;prof_min;prof_max;prof_max];
y_patch = [figylim(1);figylim(2);figylim(2);figylim(1)];


figure(7);

h(1) = subplot(1,6,2:3);
image(1,figylim,south_raw.speed);
patch(x_patch,y_patch, maplength)
set(gca,'YDir','normal')

h(2) = subplot(1,6,4:5);
image(1,figylim,north_raw.speed);
patch(x_patch,y_patch, maplength)
set(gca,'YDir','normal')

colormap(cmap)

h(3) = subplot(1,6,1);
plot(s_prof_vel, s_prof_height)
ylim(figylim);
xlim([0, max(max(s_prof_vel(:)), max(s_prof_vel(:)))*1.10])

h(4) = subplot(1,6,6);
plot(n_prof_vel, n_prof_height)
ylim(figylim);
xlim([0, max(max(s_prof_vel(:)), max(s_prof_vel(:)))*1.10])

linkaxes(h(1:2), 'x')


%%
colormap(hot(maplength))
cmap = colormap;

