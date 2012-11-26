function mrg_dfs2_cart_to_pol(curr_east,curr_north,wind)
% A function to convert U and V velcity data into magnitude and direction
% and output a DFS0 file.
%
% INPUT
%   curr_east   A positive integer defining the column number for the U
%               component in the DFS0 file.
%   curr_north  A positive integer defining the column number for the V 
%               component in the DFS0 file.
%   wind        Is either 1 if the input data is wind data, otherwise 0.  
%               See NOTES.
% 
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Produces a DFS2 file with '_dir' appended to the filename.
%   Resulting file contains ONLY the calculated speed and direction.  
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304.
%
% NOTES
%   Wind directions are typically specifiy as the direction the wind is
%   *coming from*, whereas other directions (e.g. currents) are specified
%   as the direction they are *going to*.  The wind input allows for this,
%   and ensures wind directions are calcuated correctly.
%
% LICENCE
%   Created B. Elsaesser (b.elsaesser@qub.ac.uk)
%   Updated by Daniel Pritchard (www.pritchard.co)
%   Original copyright B. Elsaesser.  Rewritten code distributed under a
%   creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.2   2012-09-12
%           DP. Inital attempt.  
%
% TODO
%   Can we add descriptions to DFS2 files?  Ask for user input, a-la
%   mrg_dfs0_car_to_pol?

%  wind=1;curr_east=1;curr_north=2;

%% Load libraries
% a1 = mrg_load_DHI_assembs();
NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

%% Get file and important info

[file, path] = uigetfile('*.dfs2', 'Choose a DFS2 file to process');
in_filename = [path,file];
out_filename = [path,file(1:end-5),'_dir.dfs2'];
dfs2_in = DfsFileFactory.Dfs2FileOpenEdit(in_filename);
nsteps    = dfs2_in.FileInfo.TimeAxis.NumberOfTimeSteps;
deleteval = double(dfs2_in.FileInfo.DeleteValueFloat);

%% Create the new DFS2 file
%factory = mrg_effing_factory();
factory = DHI.Generic.MikeZero.DFS.DfsFactory;
builder = Dfs2Builder.Create('Matlab dfs2 file','Matlab DFS',0);

% Set up the header
builder.SetDataType(dfs2_in.FileInfo.DataType);
builder.SetGeographicalProjection(dfs2_in.FileInfo.Projection);
builder.SetTemporalAxis(dfs2_in.FileInfo.TimeAxis);
builder.SetSpatialAxis(dfs2_in.SpatialAxis);
builder.DeleteValueFloat = dfs2_in.FileInfo.DeleteValueFloat;

% Add custom block(s) - Probably not needed?
% M21_Misc : {orientation (should match projection), drying depth, -900=has projection, land value, 0, 0, 0}
% builder.AddCustomBlock(dfsCreateCustomBlock(factory, 'M21_Misc', [327, 0.2, -900, 10, 0, 0, 0], 'System.Single'));
for j=1:double(dfs2_in.FileInfo.CustomBlocks.Count)
    custom_vec = zeros(1,7);
    for i=1:7
        custom_vec(i) = double(dfs2_in.FileInfo.CustomBlocks.Item(j-1).Data.Item(i-1));
    end
    custom_name = char(dfs2_in.FileInfo.CustomBlocks.Item(j-1).Name);
    builder.AddCustomBlock(dfsCreateCustomBlock(factory, custom_name, custom_vec, 'System.Single'));
end

% Define and add items items
if wind
    builder.AddDynamicItem('Derived Wind Direction', eumQuantity.Create(eumItem.eumIWindDirection, eumUnit.eumUdegree), DfsSimpleType.Float, DataValueType.Instantaneous);
    builder.AddDynamicItem('Derived Wind Speed', eumQuantity.Create(eumItem.eumIWindSpeed, eumUnit.eumUmeterPerSec), DfsSimpleType.Float, DataValueType.Instantaneous);
else
    builder.AddDynamicItem('Derived Current Direction', eumQuantity.Create(eumItem.eumICurrentDirection, eumUnit.eumUdegree), DfsSimpleType.Float, DataValueType.Instantaneous);
    builder.AddDynamicItem('Derived Current Speed', eumQuantity.Create(eumItem.eumICurrentSpeed, eumUnit.eumUmeterPerSec), DfsSimpleType.Float, DataValueType.Instantaneous);
end

% Create the file ready for data
builder.CreateFile(out_filename);

dfs2_out = builder.GetFile();

%% Do the heavy lifting
% matlab polar coodinates are orientated against the clock and start at
% East with zero, this is taken care of by swapping x,y in the function
% (output)

for i=0:nsteps-1
    east_DFS = dfs2_in.ReadItemTimeStep(curr_east,i);
    north_DFS = dfs2_in.ReadItemTimeStep(curr_north,i);
    east_data = double(east_DFS.Data);
    north_data = double(north_DFS.Data);
    if north_DFS.Time ~= east_DFS.Time
        error('mrg_dfs2_cart_to_pol:timeissue','Time mismatch between objects?!')
    end
    time = east_DFS.Time;
    [dir,speed] = cart2pol(north_data,east_data);
    % Following code shamelessly ripped from mrg_dfs0_cart_to_pol (BE)
    if wind
        dir = dir*180/pi + 180;
    else
        dir = dir*180/pi;
        index = ~(dir > 0);
        dir = dir + index * 360;
    end
    dfs2_out.WriteItemTimeStepNext(1,NET.convertArray(single(dir)));
    dfs2_out.WriteItemTimeStepNext(2,NET.convertArray(single(speed)));
end

%% Finish up
dfs2_in.Close();
dfs2_out.Close();

%% Assembly import
