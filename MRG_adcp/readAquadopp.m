function ADPdata=readAquadopp(filename)
%Function to read Aquadopp ASCII files into mrg adp field structure

if (exist(filename, 'file')) 
  disp(['Found ',filename,' !'])
else
  % File does not exist.
  error('mrg:readAquadopp:fileNotFound','Could not find ADCP data file')
end

inputfile = fopen(filename);

ADPdata=struct([]);
% Get a line from the input file


%[Z:\Projects\Marinet DeviceComparison\01. Copelends March 2014\Nortek\Aquadopp\Aquad101.prf]
tline = fgetl(inputfile);
ADPdata(1).Config(1).Path=tline;

%---------------------------------------------------------------------
tline = fgetl(inputfile);


%Number of measurements                44379
tline = fgetl(inputfile);
ADPdata(1).Config(1).Nmeasurments=strread(tline,'%*s %*s %*s  %u')
%Number of checksum errors             0
tline = fgetl(inputfile);
ADPdata(1).Config(1).NchecksumErrors=strread(tline, '%*s %*s %*s %*s  %u');


%Time of first measurement             04/04/2014 12:00:00
tline = fgetl(inputfile);
[ADPdata(1).Config(1).TfirstMeasurmentDate,ADPdata(1).Config(1).TfirstMeasurmentTime]=strread(tline, '%*s %*s %*s %*s  %s %s');



%%Time of last measurement              05/04/2014 00:19:38
tline = fgetl(inputfile);
[ADPdata(1).Config(1).TlastMeasurmentDate,ADPdata(1).Config(1).TlastMeasurmentTime]=strread(tline, '%*s %*s %*s %*s  %s %s');
%ADPdata(1).Config(1).TlastMeasurmentTime=strread(tline, '%*s %*s %*s %*s  %*s %s');

%User setup
%---------------------------------------------------------------------
tline = fgetl(inputfile);
tline = fgetl(inputfile);
tline = fgetl(inputfile);
%Profile interval                      1 sec
tline = fgetl(inputfile);
ADPdata(1).Setup(1).ProfileInterval=strread(tline, '%*s %*s %u %*s ');

%Number of cells                       20
tline = fgetl(inputfile);
ADPdata(1).Setup(1).NCells=strread(tline, '%*s %*s %*s %u');
%%Cell size                             50 cm
tline = fgetl(inputfile);
ADPdata(1).Setup(1).CellSize=strread(tline, '%*s %*s %u %*s');
%Average interval                      1 sec
tline = fgetl(inputfile);
ADPdata(1).Setup(1).AverageInterval=strread(tline, '%*s %*s %u %*s');
%Measurement load                      65 %
tline = fgetl(inputfile);
ADPdata(1).Setup(1).MeasurementLoad=strread(tline, '%*s %*s %u %*s');
%Transmit pulse length                 0.55 m
tline = fgetl(inputfile);
ADPdata(1).Setup(1).TransmitPulseLength=strread(tline, '%*s %*s %*s %f %*s');
%Blanking distance                     0.20 m
tline = fgetl(inputfile);
ADPdata(1).Setup(1).BlankingDistance=strread(tline, '%*s %*s %f %*s');
%Compass update rate                   1 sec
tline = fgetl(inputfile);
ADPdata(1).Setup(1).CompassUpdateRate=strread(tline, '%*s %*s %*s %u %*s');
%Distance measurements                 DISABLED
tline = fgetl(inputfile);
ADPdata(1).Setup(1).DistanceMeasurment=strread(tline, '%*s %*s %s');
%Wave measurements                     DISABLED
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WaveMeasurment=strread(tline, '%*s %*s %s');
%Wave - Powerlevel                     LOW
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WavePowerLevel=strread(tline, '%*s %*s %*s %s');
%Wave - Interval                       6 sec
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WaveInterval=strread(tline, '%*s %*s %*s %u %*s');
%Wave - Number of samples              1024
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WaveNSamples=strread(tline, '%*s %*s %*s %*s %*s %u');
%Wave - Sampling rate                  1 Hz
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WaveSamplingRate=strread(tline, '%*s %*s %*s %*s %u %*s');
%Wave - Cell size                      1.00 m
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WaveCellSize=strread(tline, '%*s %*s %*s %*s %f %*s');
%Analog input 1                        NONE
tline = fgetl(inputfile);
ADPdata(1).Setup(1).AnalogInput1=strread(tline, '%*s %*s %*s %s');
%Analog input 2                        NONE
tline = fgetl(inputfile);
ADPdata(1).Setup(1).AnalogInput2=strread(tline, '%*s %*s %*s %s');
%Power output                          DISABLED
tline = fgetl(inputfile);
ADPdata(1).Setup(1).PowerOutput=strread(tline, '%*s %*s %s');
%Powerlevel                            HIGH
tline = fgetl(inputfile);
ADPdata(1).Setup(1).PowerLevel=strread(tline, '%*s %s');
%Coordinate system                     BEAM
tline = fgetl(inputfile);
ADPdata(1).Setup(1).CoordinateSystem=strread(tline, '%*s %*s %s');
%Sound speed                           MEASURED
tline = fgetl(inputfile);
ADPdata(1).Setup(1).SoundSpeed=strread(tline, '%*s %s');
%Salinity                              35.0 ppt
tline = fgetl(inputfile);
ADPdata(1).Setup(1).Salinity=strread(tline, '%*s %f %*s');
%Distance between pings                15.88 m
tline = fgetl(inputfile);
ADPdata(1).Setup(1).DistancebetweenPings=strread(tline, '%*s %*s %*s %f %*s');
%Number of beams                       3
tline = fgetl(inputfile);
ADPdata(1).Setup(1).NumberBemas=strread(tline, '%*s %*s %*s %u');
%Number of pings per burst             15
tline = fgetl(inputfile);
ADPdata(1).Setup(1).NPingsperBurst=strread(tline, '%*s %*s %*s %*s %*s %u');
%Software version                      1.35
tline = fgetl(inputfile);
ADPdata(1).Setup(1).SoftwareVersion=strread(tline, '%*s %*s %s');
%Deployment name                       Aquad1
tline = fgetl(inputfile);
ADPdata(1).Setup(1).DeploymentName=strread(tline, '%*s %*s %s');
%Wrap mode                             OFF
tline = fgetl(inputfile);
ADPdata(1).Setup(1).WrapMode=strread(tline, '%*s %*s %s');
%Deployment time                       04/04/2014 12:00:00
tline = fgetl(inputfile);
[ADPdata(1).Setup(1).DeploymentDate,ADPdata(1).Setup(1).DeploymentTime]=strread(tline, '%*s %*s  %s %s');
%Comments                              Copelands device comparison deployment
tline = fgetl(inputfile);
ADPdata(1).Setup(1).Comments=tline;
%System1                               92
tline = fgetl(inputfile);
%System2                               34
tline = fgetl(inputfile);
%System3                               24
tline = fgetl(inputfile);
%System4                               694
tline = fgetl(inputfile);
%System5                               512
tline = fgetl(inputfile);
%System9                               16386
tline = fgetl(inputfile);
%System10                              96
tline = fgetl(inputfile);
%System11                              0
tline = fgetl(inputfile);
%System12                              0
tline = fgetl(inputfile);
%System13                              0
tline = fgetl(inputfile);
%System14                              1
tline = fgetl(inputfile);
%System16                              20
tline = fgetl(inputfile);
%System17                              5908
tline = fgetl(inputfile);
%System22                              6
tline = fgetl(inputfile);
%System28                              1
tline = fgetl(inputfile);
%System29                              1
tline = fgetl(inputfile);
%System30                              15
tline = fgetl(inputfile);
%System31                              15618 15646 15673 15699
tline = fgetl(inputfile);
%System32                              0
tline = fgetl(inputfile);
%System33                              0
tline = fgetl(inputfile);
%System34                              167
tline = fgetl(inputfile);
%System35                              53
tline = fgetl(inputfile);
%System36                              10709
tline = fgetl(inputfile);
%System38                              0
tline = fgetl(inputfile);
%System39                              0
tline = fgetl(inputfile);
%System40                              0
tline = fgetl(inputfile);
%System41                              0
tline = fgetl(inputfile);
%System42                              0
tline = fgetl(inputfile);
%System43                              0
tline = fgetl(inputfile);
%System44                              0
tline = fgetl(inputfile);
%System45                              6
tline = fgetl(inputfile);
%Start command                         Recorder deployment
tline = fgetl(inputfile);
%CRC download                          ON
tline = fgetl(inputfile);
ADPdata(1).Setup(1).CRC=strread(tline, '%*s %*s %s');
tline = fgetl(inputfile);
%Hardware configuration
%---------------------------------------------------------------------
tline = fgetl(inputfile);
tline = fgetl(inputfile);
%Serial number                         AQD 5164
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).SerialNumber=[strread(tline, '%*s %*s %s %*s'), strread(tline, '%*s %*s %*s %s')];      
%Internal code version                 0
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).InternalCodeVersion=strread(tline, '%*s %*s %*s %s');
%Revision number                       1
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).Revision=strread(tline, '%*s %*s %s');
%Recorder size                         9 MByte
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).RecorderSize=strread(tline, '%*s %*s %f %*s');
%Firmware version                      3.39
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).FirmwareVersion=strread(tline, '%*s %*s %s');
%Velocity range                        HIGH
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).VelocityRange=strread(tline, '%*s %*s %s');
%Power output                          BATTERY
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).PowerOutput=strread(tline, '%*s %*s %s');
%Sync signal data out delay            0 sec
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).SyncSignalDataoutdelay=strread(tline, '%*s %*s %*s %*s %*s %u %*s');
%Sync signal power down delay          0 sec
tline = fgetl(inputfile);
ADPdata(1).Hardware(1).SyncSignalPowerDowndelay=strread(tline, '%*s %*s %*s %*s %*s %u %*s');

tline = fgetl(inputfile);
%Head configuration
%---------------------------------------------------------------------
tline = fgetl(inputfile);
tline = fgetl(inputfile);
%Pressure sensor                       YES
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).PressureSensor=strread(tline, '%*s %*s %s');
%Compass                               YES
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).Compass=strread(tline, '%*s %s');
%Tilt sensor                           YES
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).TiltSensor=strread(tline, '%*s %*s %s');
%System 1                              1
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).System1=strread(tline, '%*s %*s %u');
%Head frequency                        2000 kHz
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).HeadFrequency=strread(tline, '%*s %*s %u %*s');
%Serial number                         ASP 2980
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).SerialNumber=[strread(tline, '%*s %*s %s %*s'), strread(tline, '%*s %*s %*s %s')];
%Transformation matrix                 1.5774 -0.7891 -0.7891
                                      %0.0000 -1.3662 1.3662
                                      %0.3677 0.3677 0.3677
tline = fgetl(inputfile);
[A B C]=strread(tline, '%*s %*s %f %f %f');
tline = fgetl(inputfile);
[D E F]=strread(tline, ' %f %f %f');
tline = fgetl(inputfile);
[G H I]=strread(tline, ' %f %f %f');
ADPdata(1).HeadConfig(1).TransformationMatrix=[A B C; D E F; G H I];                           
%Pressure sensor calibration           0 0 4043 11392
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).PressureSensorCalibration=[strread(tline, '%*s %*s %*s %f %*f %*f %*f'),strread(tline, '%*s %*s %*s %*f %f %*f %*f'),strread(tline, '%*s %*s %*s %*f %*f %f %*f'),strread(tline, '%*s %*s %*s %*f %*f %*f %f')];
%Number of beams                       3
tline = fgetl(inputfile);
ADPdata(1).HeadConfig(1).NBeams=strread(tline, '%*s %*s %*s %f');
%System5                               25 25 25 0
tline = fgetl(inputfile);                            
ADPdata(1).HeadConfig(1).BeamAngles=[strread(tline, '%*s  %f %*f %*f %*f') strread(tline,  '%*s %*f %f %*f %*f') strread(tline,  '%*s  %*f %*f %f %*f') strread(tline,  '%*s %*f %*f %*f %f')];
%System7                               -20040 326 12127 0
                                      %-25309 -972 12146 0
%System8                               1 0 0
                                      %0 -1 0
                                      %0 0 -1
%System9                               1 0 0
                                      %0 1 0
                                      %0 0 1
%System10                              0 1 -1 0
%System11                              0 1 1 0
%System13                              1481 259 7128 10848
%System14                              -22043 -404 12061 -189
                                      %-22071 309 11883 -120
%System15                              31994 0 -308 0
                                      %32322 -52 0 0
                                      %32767 143 -53 0
                                      %0 0 0 0
%System16                              0 0 0 0
%System17                              4550
%System18                              3600
%System19                              3600
%System20                              10000
%Ignoring all system matrices until known what they mean

%Read sensor infromation
 %1   Month                            (1-12)
 %2   Day                              (1-31)
 %3   Year
 %4   Hour                             (0-23)
 %5   Minute                           (0-59)
 %6   Second                           (0-59)
 %7   Error code
 %8   Status code
 %9   Battery voltage                  (V)
%10   Soundspeed                       (m/s)
%11   Heading                          (degrees)
%12   Pitch                            (degrees)
%13   Roll                             (degrees)
%14   Pressure                         (dbar)
%15   Temperature                      (degrees C)
%16   Analog input 1
%17   Analog input 2

sensorfilename=[filename(1:end-3) 'sen']
if (exist(sensorfilename, 'file')) 
  disp(['Found ',sensorfilename,' !'])
else
  % File does not exist.
  error('mrg:readAquadopp:fileNotFound',['Could not find ADCP sensor file',sensorfilename])
end

sensorfile = fopen(sensorfilename);
SensorData=load(sensorfilename);
ADPdata(1).Data(1).SenMonth=SensorData(:,1);
ADPdata(1).Data(1).SenDay=SensorData(:,2);
ADPdata(1).Data(1).SenYear=SensorData(:,3);
ADPdata(1).Data(1).SenHour=SensorData(:,4);
ADPdata(1).Data(1).SenMinute=SensorData(:,5);
ADPdata(1).Data(1).SenSecond=SensorData(:,6);
ADPdata(1).Data(1).SenErrorCode=SensorData(:,7);
ADPdata(1).Data(1).SenSatusCode=SensorData(:,8);
ADPdata(1).Data(1).SenBatteryVoltage=SensorData(:,9);
ADPdata(1).Data(1).SenSoundspeed=SensorData(:,10);
ADPdata(1).Data(1).SenHeading=SensorData(:,11);
ADPdata(1).Data(1).SenPitch=SensorData(:,12);
ADPdata(1).Data(1).SenRoll=SensorData(:,13);
ADPdata(1).Data(1).SenPressure=SensorData(:,14);
ADPdata(1).Data(1).SenTemperature=SensorData(:,15);
ADPdata(1).Data(1).SenAnalogInput1=SensorData(:,16);
ADPdata(1).Data(1).SenAnalogInput2=SensorData(:,17);
clear SensorData

for i=(1:ADPdata.HeadConfig.NBeams)
	velocityfilename=[filename(1:end-3) 'v' num2str(i)]
	if (exist(velocityfilename, 'file')) 
		disp(['Found ',velocityfilename,' !'])
	else
	%File does not exist.
	error('mrg:readAquadopp:fileNotFound',['Could not find ADCP data file',velocityfilename])
	end
	ADPdata.Data.(['Velocity' num2str(i)])=load(velocityfilename);
end

for i=(1:ADPdata.HeadConfig.NBeams)
	amplitudefilename=[filename(1:end-3) 'a' num2str(i)]
	if (exist(amplitudefilename, 'file')) 
		disp(['Found ',amplitudefilename,' !'])
	else
	%File does not exist.
	error('mrg:readAquadopp:fileNotFound',['Could not find ADCP data file',amplitudefilename])
	end
	ADPdata.Data.(['Amplitude' num2str(i)])=load(amplitudefilename);
end

end
