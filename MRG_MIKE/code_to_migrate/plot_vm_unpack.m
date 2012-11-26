% Stretching a transect...

% Struct 28 is a good one (labelled transect_27)
xx = 'transect_30';

zone = utmzone(March2010.(xx).adcp.nav_latitude(1), March2010.(xx).adcp.nav_longitude(1));
% 30U
[ellipsoid,estr] = utmgeoid(zone);
utmstruct = defaultm('utm');
utmstruct.zone = '30U';
utmstruct.geoid = ellipsoid;
utmstruct = defaultm(utmstruct);
[east,north] = mfwdtran(utmstruct,March2010.(xx).adcp.nav_latitude,March2010.(xx).adcp.nav_longitude);

% Get distance between points, Euclidian distance...
d = NaN(1,length(east)-1);
for a =1:(length(east)-1)
    d(a) = sqrt((east(a)-east(a+1))^2+(north(a)-north(a+1))^2);
end
d = [0,d];
ind = d== 0;
%d(ind) = NaN;
d(1) = 0;

dcumulative = cumsum(d);
dcumulative(ind) = NaN;
dcumulative(1) = 0;
dcumulative = naninterp(dcumulative);

x_coords = repmat(dcumulative,40,1);

y = 1:1:40;
y_coords = flipud(repmat(y',1,length(east)));

z_coords = March2010.(xx).adcp.east_vel;

figure(3)
scatter(x_coords(:),y_coords(:), 5, z_coords(:), 'filled')

xlim([10,20])
