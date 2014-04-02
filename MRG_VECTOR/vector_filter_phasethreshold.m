

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
theta=rad2deg(theta);

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


rotate(hmesh, [1 0 0], theta);



