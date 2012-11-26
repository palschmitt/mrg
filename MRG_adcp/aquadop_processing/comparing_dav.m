% Gah

test = squeeze(AQDdat_mat_out.profile(1,:,:));
test(:,14) = sqrt(test(:,3).^2+test(:,4).^2);
test(:,15) = round2(sqrt(test(:,3).^2+test(:,4).^2),0.001);
test(:,16) = test(:,12)==test(:,15);



c = complex(AQDdat_mat_out_B1.profile(:,:,3),AQDdat_mat_out_B1.profile(:,:,4));

% Orginal Way - U and V only
test = nanmean(c,2);
magn_dav = abs(test);

% Same as above, but 
test2 = abs(c);
magn_dav_2 = nanmean(test2,2);

% Including W
uvw_sq_srt = sqrt(AQDdat_mat_out_B1.profile(:,:,3).^2+AQDdat_mat_out_B1.profile(:,:,4).^2+AQDdat_mat_out_B1.profile(:,:,5).^2);
dav3D = nanmean(uvw_sq_srt,2);

hold on;
plot(AQDdat_mat_out_B1.depth_averaged_velocity,magn_dav,'.', 'MarkerEdgeColor','g');
plot(AQDdat_mat_out_B1.depth_averaged_velocity,magn_dav_2,'.')
plot(AQDdat_mat_out_B1.depth_averaged_velocity,dav3D,'.')
hline = refline(1,0);
