function AQD_sen = AQD_sen2mat(filename)
% this function reads the Aquadopp sen file and returns a matrix containing the data

% read data file
M = dlmread(filename);
%convert time to matlab time axis
AQD_sen.data = datenum(M(:,3),M(:,1),M(:,2),M(:,4),M(:,5),M(:,6));

AQD_sen.data(:,2:12) = M(:,7:17);

% assign items with labels
ADCP.string{1} = 'Date';
ADCP.string{2} = 'Error code';
ADCP.string{3} = 'Status code';
ADCP.string{4} = 'Battery voltage (V)';
ADCP.string{5} = 'Soundspeed (m/s)';
ADCP.string{6} = 'Heading (°)';
ADCP.string{7} = 'Pitch (°)';
ADCP.string{8} = 'Roll (°)';
ADCP.string{9} = 'Pressure (dbar)';
ADCP.string{10} = 'Temperature (°C)';
ADCP.string{11} = 'Analog input 1';
ADCP.string{12} = 'Analog input 2';

% make error check
%error codes
% The bit is set ("1") if there is an error condition and cleared ("0") if ok.
% 
% Bit 7 - Coordinate transformation: If the compass fails and the system is set to ENU the system will output XYZ and this bit will be set.
% Bit 6 - Sensor: Vector: The tilt sensor is not responding. Aquadopp: The CT sensor (serial only - eg Seabird) is not responding.
% Bit 5 - Beam number: A problem has occured with the beam order.
% Bit 4 - Flash: An error has occured in the primary system flash memory and the system may not be able to reboot.
% Bit 3 - Tag bit: There has been an error in the processing, an internal buffer is overflowing.
% Bit 2 - Sensor data: One of the sensors is not operating correctly.
% Bit 1 - Measurement data: An error has occured with some element of the processing, the data is probably corrupted.
% Bit 0 - Compass: The compass does not respond. If the system is in ENU mode it will default to XYZ, and a value of 90 degrees will be displayed.

fig_hand1 = figure; plot(data(:,1),data(:,[4 6 7 8 10])); datetick;
legend(ADCP.string{4},ADCP.string{6},ADCP.string{7},ADCP.string{8},ADCP.string{10});

%pitch roll and heading
%battery voltage