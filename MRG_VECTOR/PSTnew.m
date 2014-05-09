function [c_text, U_unfilt, num_Outliers_bf, num_Outliers_new, U] = PSTnew(U,c,B,T, pathPST)
%PST Phase-Space Threshold Filter to de-spike data
%  The phase-space threshold method was originally developed by Goring and Nikora (2002), and was modified by Mori et al. (2007), based on suggestions made by Wahl (2003). The
% phase-space threshold filter uses a three dimensional Poincaré map (phase-space
% plot), in which the first (???) and second derivatives (????) of the signal (??) are
% plotted against one another (see Figure 4.1). Data points are assumed to be of good
% quality if they lie within the bounds of an ellipsoid; any points that lie outside are
% deemed to be erroneous and are removed from the data set.

% U=Instantaneous Velocity Measurements
% c=1 %X Velocity component
% c=2 %Y Velocity component
% c=3 %Z Velocity component

if c==1,
    c_text='X Velocity';
elseif c==2,
    c_text='V Velocity';
else
    c_text='Z Velocity';
end

%Copy orginal variable for use in comparing unfiltered and filtered results
U_unfilt=repmat(U,1);


%Calculate the mean of the velocity component to determine the centre point of the
%ellipsoid
m_U=mean(U);
% U=U-m_(U);

%Preallocate matrices to improve performance

delt_U=zeros(length(U),1);

delt_sqU=zeros(length(U),1);


for i=2:(length(U)-1);
    
delt_U(i,1)=((U(i+1)-U(i-1))/2);

end
m_delt_U=mean(delt_U(2:(length(U)-1)));

for i=2:(length(U)-1);
    
delt_sqU(i,1)=((delt_U(i+1)-delt_U(i-1))/2);

end

m_delt_sqU=mean(delt_sqU(2:(length(U)-1)));


N=length(U)-2;

lambda=sqrt(2*log(N));



%Calculate the standard deviation (RMS) of each variable
sd_U=std(U(2:end-1));
sd_delt_U=std(delt_U(2:end-1));
sd_delt_sqU=std(delt_sqU(2:end-1));

xr=lambda*sd_U;
yr=lambda*sd_delt_U;
zr=lambda*sd_delt_sqU;

[x, y, z]=ellipsoid(m_U,0,0,xr,yr,zr);

%Calculate the rotation angle of the principle axis of the ellipsoid
theta=atan(sum(U.*delt_sqU)/sum(U.^2));

u=0;
v=1;
w=0;

cr=cos(theta);
sr=sin(theta);

%Define rotation matrix to transform coordinates
R = [(1-cr)*u^2+cr,(1-cr)*u*v-sr*w,(1-cr)*w*u+sr*v;
(1-cr)*u*v+sr*w,(1-cr)*v^2+cr,(1-cr)*v*w-sr*u;
(1-cr)*w*u-sr*v,(1-cr)*v*w+sr*u,(1-cr)*w^2+cr];

%Preallocate matrices to improve performance

p=zeros(3,length(delt_U));
P=zeros(3,length(delt_U));
sum_eq=zeros(1,length(delt_U));

for i=2:(length(U)-1);

p(:,i)=[U(i);delt_U(i);delt_sqU(i)];

P(:,i)=R*p(:,i);

sum_eq(1,i)=(((P(1,i)-m_U)^2)/xr^2)+((P(2,i)^2)/yr^2)+((P(3,i)^2)/zr^2);

end

%Find the outliers by iddentifying where the sum of the 'ellipsoid
%equation' is greater than 1
Outliers=find(sum_eq>1);

%Count the number of outliers
num_Outliers=length(Outliers);

% % % % %Plot again to check iddentified outlier data
% % % % figure
% % % % scatter3(U,delt_U,delt_sqU)
% % % % hold on
% % % % scatter3(U(Outliers),delt_U(Outliers),delt_sqU(Outliers), 'r')
% % % % 
% % % % axis equal
% % % % xlabel('U')
% % % % ylabel('Delta U')
% % % % zlabel('Delta ^2 U')
% % % % 
% % % % %Plot the ellipsoid
% % % % hold on
% % % % hmesh=mesh(x,y,z)
% % % % %Turn 'hidden' off to reveal scatter data contained within the ellipsoid
% % % % hidden off;
% % % % axis equal
% % % % %Rotate ellipsoid around principle axis
% % % % rotate(hmesh, [0 1 0], theta);
% % % % legend('Valid Data', 'Outliers', 'Ellipsoid')
% % % % % title(sprintf('Before Phase-Space Threshold Filtering: %s Velocity Turbine %d', B, T))
% % % % % h = gcf;
% % % % % fnam=sprintf('Before_Phase_Space_Threshold_Filtering_%s_Velocity_Turbine_%d', B, T);
% % % % % saveas(h,[path,filesep,fnam],'fig');

%Replace the outliers with the mean of the velocity
U(Outliers)=m_U;
num_Outliers_bf=num_Outliers; %Number of outliers before filtering
num_Outliers_old=num_Outliers; %Starting number of outliers for while loop
num_Outliers_new=num_Outliers-1; %Number of outliers after execution of while loop (set to value less than num_Outliers_old to begin while loop)

%Run while loop to repeat the filtering process iteratively until the
%number of outliers ( and therefore valid data points) remains constant

while num_Outliers_new~=num_Outliers_old

num_Outliers_old=num_Outliers

m_U=mean(U);

for i=2:(length(U)-1);
    
delt_U(i,1)=((U(i+1)-U(i-1))/2);

end
m_delt_U=mean(delt_U(2:(length(U)-1)));

for i=2:(length(U)-1);
    
delt_sqU(i,1)=((delt_U(i+1)-delt_U(i-1))/2);

end


N=length(U)-2;

lambda=sqrt(2*log(N));


%Calculate the standard deviation (RMS) of each variable
sd_U=std(U(2:end-1));
sd_delt_U=std(delt_U(2:end-1));
sd_delt_sqU=std(delt_sqU(2:end-1));

xr=lambda*sd_U;
yr=lambda*sd_delt_U;
zr=lambda*sd_delt_sqU;

%[x, y, z]=ellipsoid(m_U,0,0,xr,yr,zr);

%Calculate rotation angle of principal axis
theta=atan(sum(U.*delt_sqU)/sum(U.^2));

%Specify unit rotation vector
u=0;
v=1;
w=0;

cr=cos(theta);
sr=sin(theta);

%Calculate rotation matrix
R = [(1-cr)*u^2+cr,(1-cr)*u*v-sr*w,(1-cr)*w*u+sr*v;
(1-cr)*u*v+sr*w,(1-cr)*v^2+cr,(1-cr)*v*w-sr*u;
(1-cr)*w*u-sr*v,(1-cr)*v*w+sr*u,(1-cr)*w^2+cr];

%Transform coordinates

for i=2:(length(U)-1);

p(:,i)=[U(i);delt_U(i);delt_sqU(i)];

P(:,i)=R*p(:,i);

sum_eq(1,i)=(((P(1,i)-m_U)^2)/xr^2)+((P(2,i)^2)/yr^2)+((P(3,i)^2)/zr^2);

end

Outliers=find(sum_eq>1);
num_Outliers=length(Outliers);

%Replace the outliers with the mean of the velocity
U(Outliers)=m_U;
num_Outliers_new=num_Outliers
end

% % % % %Plot again after PST Filtering
% % % % 
% % % % [x, y, z]=ellipsoid(m_U,0,0,xr,yr,zr);
% % % % 
% % % % figure
% % % % scatter3(U,delt_U,delt_sqU)
% % % % hold on
% % % % scatter3(U(Outliers),delt_U(Outliers),delt_sqU(Outliers), 'r')
% % % % 
% % % % axis equal
% % % % xlabel('U')
% % % % ylabel('Delta U')
% % % % zlabel('Delta ^2 U')
% % % % 
% % % % %Plot the ellipsoid
% % % % hold on
% % % % hmesh=mesh(x,y,z);
% % % % %Turn 'hidden' off to reveal scatter data contained within the ellipsoid
% % % % hidden off;
% % % % axis equal
% % % % %Rotate ellipsoid around principle axis
% % % % rotate(hmesh, [0 1 0], theta);   
% % % % legend('Valid Data', 'Outliers', 'Ellipsoid')
% % % % % title(sprintf('After Phase-Space Threshold Filtering: %s Velocity Turbine %d', B, T))
% % % % % h = gcf;
% % % % % fnam=sprintf('After_Phase_Space_Threshold_Filtering_%s_Velocity_Turbine_%d', B, T);
% % % % % saveas(h,[path,filesep,fnam],'fig');


%Plot instantaneous variation of U before and after filtering

Time=((1:length(U))./64);
figure
plot(Time,U_unfilt)
xlabel('Time (s)')
ylabel('Velocity (m/s)')
hold on
plot(Time,U, 'r')
legend('Unfiltered', 'Filtered')
% title(sprintf('Before and After Phase-Space Threshold Filtering: %s Velocity Turbine %d', B, T))
% h = gcf;
% fnam=sprintf('Before_After_Phase-Space_Threshold_Filtering_%s_Velocity_Turbine_%d', B, T);
% saveas(h,[pathPST,filesep,fnam],'fig');
% 
% PST_filter(c).Velocity_component = c_text;
% PST_filter(c).Before_filtering.data=U_unfilt;
% PST_filter(c).Before_filtering.Outliers.Number_Outliers=num_Outliers_bf;
% PST_filter(c).Before_filtering.Outliers.Percentage_Valid=((length(U)-num_Outliers_bf)/length(U));
% PST_filter(c).Before_filtering.Mean=mean(U_unfilt);
% PST_filter(c).Before_filtering.Standard_deviation=std(U_unfilt);
% 
% PST_filter(c).After_filtering.Outliers.Number_Outliers=num_Outliers_new;
% PST_filter(c).After_filtering.data=U;
% PST_filter(c).After_filtering.Outliers.Percentage_Valid=((length(U)-num_Outliers_new)/length(U));
% PST_filter(c).After_filtering.Mean=mean(U);
% PST_filter(c).After_filtering.Standard_deviation=std(U);


end

