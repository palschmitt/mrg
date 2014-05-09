 U= repmat(x,1);

%Preallocate matrices to improve performance

delt_U=zeros(length(U),1);

delt_sqU=zeros(length(U),1);

for i=2:(length(U)-1);
    
delt_U(i,1)=((U(i+1)-U(i-1))/2);

end

for i=2:(length(U)-1);
    
delt_sqU(i,1)=((delt_U(i+1)-delt_U(i-1))/2);

end

figure


plot(delt_U,delt_sqU, '+')

N=length(U)-2;

lambda=sqrt(2*log(N));

sd_U=std(U(2:end-1));
sd_delt_U=std(delt_U(2:end-1));
sd_delt_sqU=std(delt_sqU(2:end-1));

xr=lambda*sd_U;
yr=lambda*sd_delt_U;
zr=lambda*sd_delt_sqU;

[x, y, z]=ellipsoid(0,0,0,xr,yr,zr);


theta=atan((sum(U.*delt_sqU))/(sum(U.^2)));
%Convert angle to degrees?
% theta=rad2deg(theta);

figure
surf(x, y, z)
xlabel('U')
ylabel('Delta U')
zlabel('Delta ^2 U')
axis equal




figure


scatter3(U,delt_U,delt_sqU)
axis equal
xlabel('U')
ylabel('Delta U')
zlabel('Delta ^2 U')

hold on

hmesh=mesh(x,y,z)

axis equal

%Rotate ellipsoid around principle axis
rotate(hmesh, [1 0 0], theta);

xNew = get(hmesh, 'XData');  %# Get the rotated x points
yNew = get(hmesh, 'YData');  %# Get the rotated y points
zNew = get(hmesh, 'ZData');  %# Get the rotated z points

%transform new coordinate into ellipsoidal coordinates
[lat,lon,h]=xyz2ell(X,Y,Z,a,e2)

 X = (x-x0)*cos(t)+(y-y0)*sin(t); % Translate and rotate coords.
 Y = -(x-x0)*sin(t)+(y-y0)*cos(t); % to align with ellipse
 
  x = R*cosd(theta)*cosd(phi)
> y = R*cosd(theta)*sind(phi)
> z = R*sind(theta)

%Translate and rotate coords to align with ellipse


sum=xNew^2/xr^2+yNew^2/yr^2+zNew^2/zr^2


%Determine if the point lies within the ellipsoid

%(x-sx)^2/a^2 + (y-sy)^2/b^2 + (z-sz)^2/c^2 <= 1 (1)
(x-sx)^2/a^2 + (y-sy)^2/b^2 + (z-sz)^2/c^2 <= 1 (1)

function d = ellipsoid_distance(U,y,z,p)


X^2/a^2+Y^2/b^2+Z^2/c^2<=1


xyz2ell

 ell2xyz

 
%  a = sqrt(6);
%  b = sqrt(8);
%  c = sqrt(6);
%  [theta,phi] = ndgrid(linspace(0,pi),linspace(0,2*pi));
%  x = a*sin(theta).*cos(phi);
%  y = b*sin(theta).*sin(phi);
%  z = c*cos(theta);
%  surf(x,y,z)
 
% http://www.mathworks.co.uk/matlabcentral/newsreader/view_thread/166615
%  P = dot(r,p)*r + cos(rho)*cross(cross(r,p),r) +
% sin(rho)*cross(r,p);
% > 
% > This can be rewritten in terms of a fixed 3 x 3 rotation
% matrix, R, to be 
% > multiplied by any p:
% > 
% > cr = cos(rho); sr = sin(rho);
% > R = [(1-cr)*u^2+cr,(1-cr)*u*v-sr*w,(1-cr)*w*u+sr*v;
% > (1-cr)*u*v+sr*w,(1-cr)*v^2+cr,(1-cr)*v*w-sr*u;
% > (1-cr)*w*u-sr*v,(1-cr)*v*w+sr*u,(1-cr)*w^2+cr];
% > 
% > P = R*p

u=0
v=1
w=0

cr=cos(theta)
sr=sin(theta)

%Calculate rotation matrix
R = [(1-cr)*u^2+cr,(1-cr)*u*v-sr*w,(1-cr)*w*u+sr*v;
(1-cr)*u*v+sr*w,(1-cr)*v^2+cr,(1-cr)*v*w-sr*u;
(1-cr)*w*u-sr*v,(1-cr)*v*w+sr*u,(1-cr)*w^2+cr];

%Transform coordinates

for i=2:(length(U)-1);

p(:,i)=[U(i);delt_U(i);delt_sqU(i)];

P(:,i)=R*p(:,i);

sum(1,i)=((P(1,i)^2)/

end


%(x-sx)^2/a^2 + (y-sy)^2/b^2 + (z-sz)^2/c^2 <= 1 (1)




