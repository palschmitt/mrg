function radius_index = mrg_in_radius(targetx, targety, x, y, radius)
% A function to find out which points are within a specified radius of a target point
% targetx = 
% targety = 
% x = vector of x values to test
% y = vector of y values to test
% radius = 
if length(x)~=length(y)
    error('x and y must be equal length')
end
zeroed_x = x-targetx;
zeroed_y = y-targety;
% Not worried about east vs north here becuase all we need is magnitude...
[~, mag] = cart2pol(zeroed_x, zeroed_y);
radius_index = mag<radius;
end