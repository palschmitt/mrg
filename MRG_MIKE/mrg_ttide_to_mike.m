function mrg_ttide_to_mike(tidestruc, tidedata, outfname)
% Outputs a .con file which is compatible with MIKE.
%
% INPUT
%   tidestruc   The struct returned by t_tide contining the harmonics,
%               phase and amplitude
%   tidedata    An optional matrix containing the original data used for
%               the harmonic analysis.  Used to calculate Z0 (which is not
%               provided by t_tide).  Assumed to be zero if not supplied.
%   outfname    An optional string specifying the output filename. Prompted
%               if not supplied.
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   User input is required if output filename (outfname) not supplied.
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence.  See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2011-09
%           Initial attempt.  DP
%   v 1.1   2012-09-05
%           Added output filename checking. DP
%           Documentation.  DP

%% Check input
if ~exist('tidedata', 'var')
    warning('ttide2mikecon:assumingZ0', 'You did not supply the orignal tide data.  Assuming a Z0 of zero');
    Z0 = 0;
else
    Z0 = nanmean(tidedata);
end

if ~exist('tidestruc', 'var')
    error('You did not supply the data returned by t_tide.');
end

if ~isstruct(tidestruc)
    error('The "tidestruc" variable supplied is not a structure.  You must supply the object returned by t_tide.');
end

%% Get harmonic names and add 'Z0'
names = cellstr(tidestruc.name);
names = vertcat({'Z0'}, names);

%% Get phase and Amp
phase = [Z0;tidestruc.tidecon(:,1)];
amp = [0;tidestruc.tidecon(:,3)];

%% Contruct a numbered column
no = 1:size(names,1);

%% Write out file
if ~exist('outfname', 'var')
    [fname,path] = uiputfile('*.con','Output filename');
    outfname = [path,fname];
end

fid = fopen(outfname,'w');
fprintf(fid, 'Constituents from t_tide analysis in MATLAB\n');
fprintf(fid, 'Name\tAmp.\tPhase\n');
for i = 1:size(names,1)
    fprintf(fid,'%s \t %s \t %s \t %s\n',num2str(no(i)),names{i},num2str(phase(i)),num2str(amp(i)));
end
fclose(fid);
end
