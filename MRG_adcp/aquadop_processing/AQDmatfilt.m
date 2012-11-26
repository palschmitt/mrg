function [padded_struct] = AQDmatfilt(padded_struct)
% A function to filter the depth averaged U and V components in the padded
% (i.e. equidistant timesteps) structured array produced by AQDdat2mat and
% padstruct2equidistant.  Will not work unless there is a 'da_u_vel' and a
% 'da_u_vel' object in the structured array.  

%% Filter Design
h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.378,0.5,1,60); 
% Passband frequency (Fp) of 2*15min (sample interval) / 0.378 (i.e. 80 minutes) 
% Stopband frequency (Fst) of 2*15min (sample interval) / 0.5 (i.e. 60 minutes)  
% Filter with damping of 1dB for pass (Ap) and 60 dB for stopband (Ast)
d=design(h,'equiripple');  % Lowpass FIR filter with equiripple

%% Lowpass filtering (engineer speak for "moving average") of U and V
% Here we 'smooth' the data by passing a low band pass filter of the depth
% averaged U and V components and then re-calculate the speed and
% direction.  It is important to filter the U and V components and then
% re-calculate becuase if you filter the speed directly you get a diferent
% result.  
% The design of the filter requires some skill and knowledge.  It is
% defined above (by Bjoern).
% Here we use a forward and backward 'zero phase' filter which dosen't
% result in a phase shift (engineer speak for 'a change in the position of the
% peaks').  This is important for the subsequent harmonic analysis (which
% is the reason we are filtering the data anyway).  

% Filtering... 
% NaNs are not welcome in the filtering alogrithim.  We need
% to interpolate them with a meaningful value.  Here we use 'linear'
% interpolation (i.e. the defualt options). 
% Note this will interpolate over all NaN values, so make sure you are
% happy there are no large gaps in your data.

disp('Starting...');

u_interp = padded_struct.da_u_vel;
u_interp(isnan(u_interp)) = interp1(find(~isnan(u_interp)), ...
    u_interp(~isnan(u_interp)), find(isnan(u_interp)), 'linear'); 

v_interp = padded_struct.da_v_vel;
v_interp(isnan(v_interp)) = interp1(find(~isnan(v_interp)), ...
    v_interp(~isnan(v_interp)), find(isnan(v_interp)), 'linear'); 

padded_struct.da_u_vel_interp = u_interp;
padded_struct.da_v_vel_interp = v_interp;

% Use numerator from filter design (above).  Denominator is 1 due to FIR
% filter.
padded_struct.da_u_vel_filt = filtfilt(d.Numerator,1,u_interp); 
padded_struct.da_v_vel_filt = filtfilt(d.Numerator,1,v_interp);

% ReCalculating Speed and Direction
[theta, rho] = cart2pol(padded_struct.da_v_vel_interp, padded_struct.da_u_vel_interp);
padded_struct.da_speed_interp = abs(rho);
dir = theta*180/pi;
index = ~(dir > 0);
padded_struct.da_dir_interp = dir + index * 360;

[theta, rho] = cart2pol(padded_struct.da_v_vel_filt, padded_struct.da_u_vel_filt);
padded_struct.da_speed_filt = abs(rho);
dir = theta*180/pi;
index = ~(dir > 0);
padded_struct.da_dir_filt = dir + index * 360;

%% A quick message about the above code chunk...
disp('Complete!');
disp(['Please check the source code for the assumptions underlying the filtering of depth averaged speed and direction!'])

end