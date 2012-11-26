


% Load libraries
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

%% Simple changing for a two-time-step file
% Get file
[filename,filepath] = uigetfile('*.dfsu','Select the .dfsu file to analyse');
infile = [filepath,filename];
%Note use of 'OpenEdit' (vs 'Open'):
dfsu_file = DfsFileFactory.DfsuFileOpenEdit(infile);
dfsu_file.TimeStepInSeconds = 7862400;
dfsu_file.Close();

%% More Complex: Adding timesteps and cloning the first time step data to the new timesteps
% NOTE: This only *adds* timesteps - you need to ensure that all exisiting
% timesteps in the file are also correct.
% November 2012: Really?  Seems to over-write 
[filename,filepath] = uigetfile('*.dfsu','Select the .dfsu file to analyse');
infile = [filepath,filename];
dfsu_file = DfsFileFactory.DfsuFileOpenEdit(infile);

% The time step you want:
dfsu_file.TimeStepInSeconds = 21600;
% The number of timesteps (total) that you want:
desired_n_ts = 855;
exisiting_n_ts = dfsu_file.NumberOfTimeSteps;

n_items = dfsu_file.ItemInfo.Count;

% Get data from first TS for all items
data = struct();
for i=1:n_items
    itemData = dfsu_file.ReadItemTimeStep(i,0);
    data.(['item_', num2str(i)]) = double(itemData.Data)';
end

%for j=0:desired_n_ts-exisiting_n_ts
for j=1:desired_n_ts-1
    for i=1:n_items
        dfsu_file.WriteItemTimeStepNext(0, NET.convertArray(single(data.(['item_', num2str(i)])))); 
    end
end

dfsu_file.Close();