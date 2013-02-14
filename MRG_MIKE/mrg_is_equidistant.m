function tf = mrg_is_equidistant(varargin)
% Checks if an object is has an eqidistant timestep.
%
% INPUT
%   ...     Either a MATLAB vector or a MATLAB structure.  See NOTES.
%
% OUTPUT
%   tf      A logical (0 or 1) indicating if the object is equidistant.
%
% REQUIREMENTS
%   Requires the MIKE Matlab toolbox.  Tested with v. 20110304
%
% NOTES
%   If a vector is supplied, then a diff() is performed and the check
%   proceeds via testing the uniqueness of this diff.  If a structure is
%   provided, it is tested to see if it contains a field 'TimeAxisType'.
%   If it is we assume it is a structure returned by one of the core MRG
%   functions and we test the values the timeaxis type for known equidstant
%   values.
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2012
%           DP. First version
%   v 1.1   14/02/2013
%           DP. Documentation
%
% TODO
%   Extend to allow for some flexability in timestep diff (e.g. within 1 sec)...
%   Migrate other code to use this function
%% Check input
if isempty(varargin)
    error('Input is required.');
end

if length(varargin)>1
    error('This function only takes one input.');
end

object = varargin{1};

%% Check if object is a standard MRG output...
if (isstruct(object) && isfield(object, 'TimeAxisType'))
    if any(strcmp(object.TimeAxisType, {'CalendarEquidistant', 'TimeEquidistant'}))
        tf = 1;
        return
    else
        tf = 0;
        return
    end
end

%% Object is not a structure, just do a diff
if ndims(object) > 2
    error('Unless the input is a structure, this function can only take a 2D MATLAB matrix.');
end

if ~any(size(object)==1)
    error('Unless the input is a structure, this function can only take a MATLAB matrix with either a single row, or a single column.');
end

diffs = diff(object);
if length(unique(diffs)) == 1
    tf = 1;
    return
else
    tf = 0;
    return
end
end