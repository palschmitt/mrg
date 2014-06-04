function mrg_met_pp(days)
% Plots metstation data for display by an external web application
%
% INPUT
%   days    The number of days to display (defualt is 1)
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Generates figures for wind-speed, wind direction, air temperature,
%   water temperature, 
%
% REQUIREMENTS
%   Assumes you have MRG-metation formatted CSV files in the current
%   working directory.
%
% AUTHORS
%   Daniel Pritchard
%
% LICENCE
%   Code distributed as part of the MRG toolbox from the Marine Research
%   Group at Queens Univeristy Belfast (QUB) School of Planning
%   Architecture and Civil Engineering (SPACE). Distributed under a
%   creative commons CC BY-SA licence, retaining full copyright of the
%   original authors.
%
%   http://creativecommons.org/licenses/by-sa/3.0/
%   http://www.qub.ac.uk/space/
%   http://www.qub.ac.uk/research-centres/eerc/
%
% DEVELOPMENT
%   v 1.0   2013-08-16
%           First version. DP
%
%% Function Begin!
if nargin < 1
    days = 1;
end

fnameCSV = ['met_data_',datestr(date,'yyyy_mmm'),'.csv'];
f = fopen(fnameCSV);
dat = textscan(f, '%s %f %f %f %f %f %f %f', 'HeaderLines',1, 'delimiter', ',');
%Old data:
%dat = textscan(f, '%s %f %f %f %f %f', 'delimiter', ',');
fclose(f);

dnum = datenum(char(dat{1}), 'dd/mm/yyyy HH:MM:SS');
ctime = now;
mintime = ctime-days;
ind = dnum > mintime;

for a = 2:8
    nanind = dat{a}==-1e-30;
    dat{a}(nanind) = NaN;
end

imgsize = [0 0 6*5 2*5];

% Light
par = figure(1);
plot(dnum(ind), dat{2}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
maxpar = max(dat{2}(ind));
ylim([0 max(400,maxpar*1.1)]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('PAR (\mumol photons m^{-2} s^{-1})')

set(par,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/light.png');

% WindSpeed
ws = figure(1);
plot(dnum(ind), dat{3}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
maxws = max(dat{3}(ind));
ylim([0 max(1,maxws*1.1)]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Windspeed (m^{-1} s^{-1})')

set(ws,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/ws.png');

% WindDir
wd = figure(1);
plot(dnum(ind), dat{4}(ind), 'o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
ylim([0 360]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Wind Direction (\circ)')

set(wd,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/wd.png');

% AirPressure
ap = figure(1);
plot(dnum(ind), dat{5}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
ylim([800 1700]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Air Pressure (units)')

set(ap,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/ap.png');

% AirTemp
at = figure(1);
plot(dnum(ind), dat{6}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
ylim([-10 30]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Air Temperature (\circ)')

set(at,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/at.png');

% Tidal Level
tl = figure(1);
plot(dnum(ind), dat{7}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Tidal Level (units)')

set(tl,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/tl.png');

% Water Temp
wt = figure(1);
plot(dnum(ind), dat{8}(ind), '-o', 'MarkerFaceColor', 'b'); 
xlim([mintime ctime]); 
%ylim([-5 20]); 
dateaxis('x', 15);
xlabel([datestr(mintime, 'dd/mm/yyyy'), ' - ', datestr(ctime, 'dd/mm/yyyy')])
ylabel('Water Temperature (\circ)')

set(wt,'PaperUnits','centimeters ','PaperPosition',imgsize)
print('-dpng', '-r300', 'web/images/wt.png');

end
