%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Adapted by Katie Silverthorne from a code provided by Carl Wunsch, EAPS,
% MIT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [freq,spectrx] = spectra(x,delt,M,plotflag)

x1=x(:);

% Taper the time series with a 20% cosine taper window (minimizes leakage
% due to end effects).  Note the signal is not corrected for taper energy loss (minimal).   
  L=length(x1);
  L10=fix(L/10);
  wind=ones(L,1);
  wind(1:L10,1)=1-cos([1:L10]'*pi/(2*L10));
  wind(L:-1:L-L10+1,1)=wind(1:L10,1);
  x=x1.*wind;
  
  
% Remove the mean from the tapered signals
avgx=mean(x);
x=x-avgx;

% Calculate the Fourier series coefficients for each time series. Normalize such that the amplitude of a unit sine wave is 1 in the frequency domain. 
xhat=fft(x);
N=length(xhat);
xhat=xhat/(N/2);

% Compute periodogram for each signal and the cross power
periodx=xhat.*conj(xhat);

% Compute power spectral estimates for each signal and the cross power
% spectral estimate by averaging over M frequency bands using a rectangular
% (Daniell) window in the frequency domain
window=ones(M,1);
spectx=conv(window,periodx);

% Normalize (divide values by width of the averaging interval) to get power
% spectral density estimates in units of cycles/delta t
spectx=spectx/(M/(delt*N));

s=M:M:N/2;
s1=length(s);
spectrx=spectx(s);

freq(1,1)=(M-1)/2*(1/(N*delt));
freq(2:s1,1)=freq(1)+(M/(N*delt))*[1:s1-1]';

if plotflag == 1
    figure
    loglog(freq,spectrx,'Linewidth',2)
    %plot(freq,spectrx,'Linewidth',2)
    xlabel('Frequency (Hz)'),ylabel('Power Density (units^2/Hz)');
end
