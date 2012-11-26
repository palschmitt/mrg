function TF = mrg_is_equidistant(varargin)
% TODO: DOCUMENTATION
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
        TF = 1;
        return
    else
        TF = 0;
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
    TF = 1;
    return
else
    TF = 0;
    return
end
end