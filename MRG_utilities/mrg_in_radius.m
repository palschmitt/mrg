function radius_index = mrg_in_radius(targetx, targety, x, y, radius)
% Are points within a specified radius of a target point?
%
% INPUT
%   targetx     Target X value
%   targety     Target Y value
%   x           Vector of x values to test
%   y           Vector of y values to test (must be same length as x)
%   radius      The radius of the circle around [targetx, targety]
%
% OUTPUT
%   radius_index    An index the same length as x and y, specifying the
%                   points within the specified radius.  
% 
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   2012
%           DP.  Initial development
%   v 1.1   14/02/2013
%           DP.  Documentation.   

%% Go!
if length(x)~=length(y)
    error('x and y must be equal length')
end
zeroed_x = x-targetx;
zeroed_y = y-targety;
% Not worried about east vs north here becuase all we need is magnitude...
[~, mag] = cart2pol(zeroed_x, zeroed_y);
radius_index = mag<radius;
end