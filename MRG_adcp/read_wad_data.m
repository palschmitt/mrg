function [K,date_time] = read_wad_data(filename)
%%
M = dlmread(filename);

%% Try to read the corresponding .hdr file
splitted = regexp(char(filename),'\.','split');
hdr_file = [char(splitted(1)),'.hdr'];
try
    fid = fopen(hdr_file, 'r');
    % Check that the file was opened
    if fid == -1
        error('The .hdr file exists, but MATLAB is unable to open it');
    end
    % Read WAD info from HDR.
catch err
    warning(['Unable to find .hdr file in the same directory as your .wad file.  Using defaults (which might be incorrect)']);
    % DEFAULTS
    header = {'Month', 'Day', 'Year', 'Hour', 'Minute', 'Second', 'Pressure', 'Spare', 'Analog input',...
        'Velocity (Beam1|X|East)' ,'Velocity (Beam2|Y|North)', 'Velocity (Beam3|Z|Up)', 'Velocity (Beam4)',...
        'Amplitude (Beam1)', 'Amplitude (Beam2)', 'Amplitude (Beam3)', 'Amplitude (Beam4)'};
    units = {'1-12','1-31','','0-23','0-59','0-59','dbar','','',...
        'm/s','m/s','m/s','m/s',...
        'counts','counts','counts','counts'};
end

if length(header) ~= size(M,2)
    error('More columns in data than headers in the header file.  Huston, I think we got a problem')
end
%% 
date_time = datenum(M(:,3),M(:,1),M(:,2),M(:,4),M(:,5),M(:,6));
sec_diff = 5/60/60/24; % Time (in fractional days) to use to cut up the bursts
breaks = find(diff(date_time)>sec_diff);

%% Test Data
data = M(1:breaks(1),:);



%% Some kind of time-integrated measure (Bjoern?)
vel = sqrt(M(:,10).^2+M(:,11).^2);

K = mean(abs(vel));
K(1,2) = sqrt(sum(vel.^2)/2048);
K(1,3) = (sum(vel.^3)/2048)^(1/3);
date_time = datenum(M(1,3),M(1,1),M(1,2),M(1,4),M(1,5),0);

%plot(vel)
%figure
%plot(M(:,7))

%% filter pressure data to get moving average
% windowSize = 48;
% mean_press = filtfilt(ones(1,windowSize)/windowSize,1,M(:,7));
% press = M(:,7) - mean_press;
% 
% figure
% plot(M(:,7))
% plot(press)
% figure; plot(mean_press);
% hold on; plot(press,'r');
