function [filtered_data] = mrg_filter_data(data, d)
% TODO: Documentation

% A function to filter equidistantly-spaced data.
% Returns a matrix, the same dimensions as the input, but filtered
% Assumes data are in columns

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

%% Check input, setup output
filtered_data = NaN(size(data));


%% Filter Design
% If d isn't supplied, we use a defualt 
if ~exist('d', 'var')
    % Passband frequency (Fp) of 2*15min (sample interval) / 0.378 (i.e. 80 minutes) 
    % Stopband frequency (Fst) of 2*15min (sample interval) / 0.5 (i.e. 60 minutes)  
    % Filter with damping of 1dB for pass (Ap) and 60 dB for stopband (Ast)
    h=fdesign.lowpass('Fp,Fst,Ap,Ast',0.378,0.5,1,60); 
    d=design(h,'equiripple');  % Lowpass FIR filter with equiripple
end

%% Dealing with the NaNs
% NaNs are not welcome in the filtering alogrithim.  We need
% to interpolate them with a meaningful value.  Here we use 'linear'
% interpolation (i.e. the defualt options). 
% Note this will interpolate over all NaN values, so make sure you are
% happy there are no large gaps in your data.






end
