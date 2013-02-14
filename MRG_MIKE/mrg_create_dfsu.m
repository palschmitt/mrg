function mrg_create_dfsu(start_date, ntimesteps, timestep_sec, varargin)
% Takes a mesh file and produces a DFSU file filled with very simple data.
%
% INPUT
%   start_date      A date vector (e.g. [2012, 12, 01, 23, 35, 00] specifying
%                   the start date for the DFSU output
%   ntimesteps      A numeric value specifying the number of timesteps in
%                   the output.
%   timestep_sec    A numeric value specifying the timestep in seconds
%
%   ...             Optional input specified using the ('keyword', value)
%                   syntax.  Can be any of:
%       nitems      An optional integer specifying the number of items in
%                   the output file.  Defualts to 1.  See NOTES.
%       base        An optional numerical value specifying the baseline
%                   value at each time point. Also specifys the value at
%                   timestep 1.  Defaults to 0. See NOTES.
%       increment   An optional numerical value specifying the increment to add at
%                   each timestep.  Defaults to 0.  See NOTES.
%       isarea      A logical indicating if the file is to be used as a
%                   decoupled area file
%
% OUTPUT
%   NO OUTPUT AT CONSOLE
%   Produces a DFSU file with the layout prescribed by the mesh file.
%
% NOTES
%   This function will create a DFSU file with the spatial dimensions
%   specified by a .mesh file.  Each element is filled with:
%
%       base+increment*timestep
%
%   Timestep in this instance is the zero-indexed timestep in the DFSU
%   file.  So so using, base = 10 and increment=1:
%       The first timestep  = 10
%       The second timestep = 11
%       The third timestep  = 12
%       ...
%       The nth timestep    = 10+(n-1)
%
%   Note all output items are undefined, but this can esily be changed in
%   the data utility tool in MIKE Zero.
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304
%   mrg_effing_factory from the MRG_MIKE_toolbox
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence.  See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2011-09-01
%           Initial attempt.  DP
%   v 1.1   2012-09-05
%           Documentation.  DP
%   v 1.2   2012-09-18
%           Using varargin, adding 'base', adding 'nitems'. DP
%           Changed defualts to zero everywhere at all timesteps. DP
%           Syntax changes.  DP
%
% TODO
%   Item types.
%   Different data for different items

%% Checking input
% Number of optional input arguments must be less than 2 x options...
numvarargs = length(varargin);
if numvarargs > 8
    error('mrg_create_dfsu:TooManyInputs', 'Requires at most 4 optional inputs');
end

% Set defaults on optional inputs
nitems = 1;
base = 0;
increment = 0;
isarea = 0;

while ~isempty(varargin),
    if ischar(varargin{1})
        switch lower(varargin{1}(1:3))
            case 'nit'
                nitems = varargin{2};
            case 'bas'
                base = varargin{2};
            case 'inc'
                increment = varargin{2};
            case 'isa'
                isarea = 1;
            otherwise
                error('mrg_create_dfsu:VariableInputNotHandled','You provided an optional input not handled by the function.');
        end
    else
        error('mrg_create_dfsu:VariableInputFail','Optional inputs must be specified using the (keyword, value) syntax');
    end
    varargin([1 2])=[]; 
end

% Input checks
if ~(isnumeric(start_date)&&length(start_date)==6);
    error('mrg:InputFail','start_date must be date vector!');
end

if ~isnumeric(increment)
    error('mrg:InputFail','increment must be a number!');
end
%%
NET.addAssembly('DHI.Generic.MikeZero');
import DHI.Generic.MikeZero.*
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;

%% Get mesh
return_path = cd;
[filename, path] = uigetfile('.mesh','Select a MESH file to act as DFSU template');
cd(path);

[Elmts,Nodes,proj] = mzReadMesh(filename);
X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);
code = Nodes(:,4);

%% If area is requested, calculate element centered waterdepths
% There is some discrepenacy here between this and the values form the
% model...  Anyway.  It'll do for now.
if isarea
    [~,~,ze] = mzCalcElmtCenterCoords(Elmts,X,Y,Z);
    twd = ze*-1;
    twd(twd<0) = 0;
end

%% Create a new empty dfsu file object
factory = mrg_effing_factory();
builder = DfsuBuilder.Create(DfsuFileType.Dfsu2D);

% Create a temporal definition matching input file
start = System.DateTime(start_date(1),start_date(2),start_date(3),start_date(4),start_date(5),start_date(6));
builder.SetTimeInfo(start, timestep_sec);

% Create a spatial defition based on mesh input file
builder.SetNodes(NET.convertArray(single(X)),NET.convertArray(single(Y)),NET.convertArray(single(Z)),NET.convertArray(int32(code)));
builder.SetElements(mzNetToElmtArray(Elmts));
builder.SetProjection(factory.CreateProjection(proj))

% Add item(s)
for a = 1:nitems
    builder.AddDynamicItem(['MATLAB_generated_',num2str(a)],DHI.Generic.MikeZero.eumQuantity(eumItem.eumIItemUndefined,eumUnit.eumUUnitUndefined));
end

% Create the file - make it ready for data
new_filename = [filename(1:end-5),'_mod.dfsu'];
[filename, path] = uiputfile('.dfsu', 'Select a location for the DFSU file', new_filename);
cd(path)
dfs = builder.CreateFile(filename);

%% Put some data in the file
for i=0:ntimesteps-1
    % NB: The first timestep is just filled with base (becuase the
    % increment is multiplied by 'i' which is zero)
    data = repmat(base,dfs.NumberOfElements,1)+increment*i;
    for j=1:nitems
        % NB: All items get the same data, unless isarea is true!
        if j==1&&isarea==1
            dfs.WriteItemTimeStepNext(0, NET.convertArray(single(twd)));
        else
            dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data)));
        end
    end
end

% Close the file
dfs.Close();
cd(return_path)
end