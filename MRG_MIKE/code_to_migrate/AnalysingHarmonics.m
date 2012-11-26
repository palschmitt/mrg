% Fitting Tidal Harmonics
% Daniel Pritchard
% 2012-09-06

%% Load data from a DFS0 file
RecData = mrg_read_dfs0;

% Inspect the resulting file to determine which object to analyse (e.g. elevation)
%% Filter the data
% This assumes that the data are equidistant
if mrg_is_equidistant(RecData)
    % Gave up on making functon here...
    h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.378,0.5,1,60);
    d=design(h,'equiripple');
    filt_data = filtfilt(d.Numerator,1,double(RecData.dData(:,1)));
end



%% Process with t-tide 
% In this case, this first column of data is the elevation.
sha_const = ['2PO1';'ST36';'2NS2';'ST37';'ST1 ';'ST2 ';'ST3 ';...
    'O2  ';'ST4 ';'SNK2';'OP2 ';'ST5 ';'ST6 ';'2SK2';...
    'ST7 ';'2SM2';'ST38';'SKM2';'2SN2';'NO3 ';'NK3 ';...
    'SP3 ';'ST8 ';'N4  ';'3MS4';'ST39';'ST40';'ST9 ';...
    'ST10';'KN4 ';'SL4 ';'MNO4';'2MO5';'3MP5';'MNK5';...
    '2MP5';'MSK5';'3KM5';'ST11';'2NM6';'ST12';'ST41';...
    'ST13';'MSN6';'MKN5';'NSK6';'ST42';'S6  ';'ST14';...
    'ST15';'M7  ';'ST16';'ST17';'ST18';'3MN8';'ST19';...
    'ST20';'ST21';'3MS8';'3MK8';'ST22';'ST23';'ST24';...
    'ST25';'ST26';'4MK9';'ST27';'ST28';'M10 ';'ST29';...
    'ST30';'ST31';'ST32';'ST33';'M12 ';'ST34';'ST35'];


[tidestruc1,xout1]=t_tide(RecData.dData(:,1), 'interval', RecData.TimeStepHour, 'start time', double(RecData.StartDateVec), 'latitude', 54);
[tidestruc2,xout2]=t_tide(filt_data, 'interval', RecData.TimeStepHour, 'start time', double(RecData.StartDateVec), 'latitude', 54);
[tidestruc3,xout3]=t_tide(RecData.dData(:,1), 'interval', RecData.TimeStepHour, 'start time', double(RecData.StartDateVec), 'latitude', 54, 'shallow', sha_const);
[tidestruc4,xout4]=t_tide(filt_data, 'interval', RecData.TimeStepHour, 'start time', double(RecData.StartDateVec), 'latitude', 54, 'shallow', sha_const);

%% Plotting
plot([1:length(xout1)], RecData.dData(:,1)-nanmean(RecData.dData(:,1)), 'k')
hold on
plot([1:length(xout1)], xout1, 'r')
plot([1:length(xout2)], xout2, 'g')
plot([1:length(xout3)], xout3, 'm')
plot([1:length(xout4)], xout4, 'y')

legend('Raw Data', 'Unfiltered', 'Filtered', 'Unfiltered + Shallow Harmonics', 'Filtered + Shallow Harmonics')


% Write MIKE con file