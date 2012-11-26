function [] = mat2DFS0_core(padded_struct, datetime, variables)
% NB: Should not be called directly (call mat2DFS0() instead)
% Takes input from mat2DFS0 and processes it into a DFS0 format suitable for MIKE.

% 04/11/11 Modifications to make it more generic
%% Are the time steps equidistant?  If so then setup the MIKE timestep
t_step = unique(round2(diff(datetime),0.00001));
if length(t_step) ~= 1
    error('The timesteps are not equal (or there has been a rounding error)');
else
    timestep = round(t_step*60*60*24);
end

%% Get variables ready to write to DFS0
% NB: Changing NaNs to delete values not needed!
% fDelete = single(-1E-35);
% dDelete = double(-1E-255); 
% for n = 1:length(variables)
%     var = variables{n};
%     padded_struct.(var)(isnan(padded_struct.(var))) = fDelete;
% end

%% Setup variables to describe the DFS0 file
% Temporal dimension information
start_date = datevec(min(datetime));
% NB: 'timestep' assigned above

%% OK - Where do we save the DFS0 file?
[dfs_name,dfs_path] = uiputfile('*.dfs0','Choose a name for the .dfs0 file');
cd(dfs_path)

%% Here after this is just copied from DHI example...
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

% Create an empty dfs0 file object
dfs0 = dfsTSO(dfs_name,1);

set(dfs0,'filetitle','Data from AquaDopp');
set(dfs0,'startdate',double([start_date(1), start_date(2), start_date(3), start_date(4), start_date(5), start_date(6)]));
set(dfs0,'timestep',[0 0 0 0 0 timestep]);
addTimesteps(dfs0,length(datetime));

% 1 dbar = 0.1 bar = 10 kPa
% 1 mbar = 0.001 bar = 0.1 kPa = 1 hPa (hectopascal)
% 1 dbar = 100 hPa 
DFStypes = {'Pressure', 'Temperature', 'u-velocity component', 'v-velocity component', 'Current Speed', 'Current Direction'};
DFSunits = {'Pascal', 'degree Celsius', 'm/s', 'm/s', 'm/s', 'degree'};

for n = 1:length(variables)
    %addItem(dfs0,variables{n},DFStypes{n},DFSunits{n});
    addItem(dfs0,variables{n});
    %setItemEum(dfs0,n,DFStypes{n},DFSunits{n});
    % Setting item units and types gives errors - why!
end

for j=1:length(variables)
    var = variables{j};
    dfs0(j) = single(padded_struct.(var));
end

save(dfs0);
close(dfs0);
% DFS0 writing complete!

end
