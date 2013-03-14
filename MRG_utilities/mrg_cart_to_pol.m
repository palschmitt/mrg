function [dir,mag] = mrg_cart_to_pol(curr_east,curr_north,wind)
% Converts U and V velcity data into magnitude and direction
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
%   mag         Magnitude
%   dir         Direction (in degrees)
%
%
% NOTES
%   Wind directions are typically specifiy as the direction the wind is
%   *coming from*, whereas other directions (e.g. currents) are specified
%   as the direction they are *going to*.  The wind input allows for this,
%   and ensures wind directions are calcuated correctly.
%
%   This is a generic version of mrg_dfs0_cart_to_pol.  Designed primariliy
%   so that Dan doesn't make so many silly mistakes.
%
% LICENCE
%   Created B. Elsaesser (b.elsaesser@qub.ac.uk)
%   Updated by Daniel Pritchard (www.pritchard.co)
%   Original copyright B. Elsaesser.  Rewritten code distributed under a
%   creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   Feb 2013
%           DP. First version.

if ~all(size(curr_east)==size(curr_north))
    error('curr_east and curr_north must be the same size!')
end

[dir,mag] = cart2pol(curr_north,curr_east);

if wind
    dir = dir*180/pi + 180;
else
    dir = dir*180/pi;
    index = ~(dir > 0);
    dir = dir+index*360;
end

end