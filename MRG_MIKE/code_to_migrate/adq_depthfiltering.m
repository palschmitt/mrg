%% 'Sidelobe' (read: depth) filtering
if length(AQDdat_mat_out.pressure_dbar) ~= length(AQDdat_mat_out.datetime)
    error('mrgAQDdat2mat:pressureDTmismatch',...
        ['The number of pressure values does not match the number of datetime values.\n'...
        'mrg_AQDdat2mat cannot automatically remove bins that are out of the water.']);
end

% Keeping the removed bins (This could be removed later...)
% Being lazy - copying the entire profile object and blanking it with NaNs
AQDdat_mat_out.bins_removed = AQDdat_mat_out.profile;
AQDdat_mat_out.bins_removed(:) = NaN;

% Using the formula in the profiler manual
for n = 1:length(AQDdat_mat_out.datetime)
    cell_size = mode(diff(AQDdat_mat_out.profile(n,:,2)));
    % Test pressure = depth minus half of the cell size...
    % i.e. if any part of the cell is above water the whole cell gets
    % dropped
    test_pressure = (AQDdat_mat_out.pressure_dbar(n)*cos(25))-(cell_size/2);
    
    above = find(AQDdat_mat_out.profile(n,:,2) > test_pressure);
    if ~isempty(above)
        AQDdat_mat_out.bins_removed(n,above,:) = AQDdat_mat_out.profile(n,above,:);
        AQDdat_mat_out.profile(n,above,:) = NaN;
    end
end

% Some data for the final print out to screen
num_bin_total = length(AQDdat_mat_out.profile(:));
num_bins_removed = sum(sum(isnan(AQDdat_mat_out.profile(:,:,2))));
percent_removed = num_bins_removed/num_bin_total*100;

%% Depth averaged velocity...
% This is a first attmept only and does not deal with the fact that
% sometimes the whole water column isn't included in the velocity profile.
% Note also that we are re-calculating the speed here from the U and V
% components.  This is becuase the 'speed' reported by the AquaDopp ASCII
% file apprears to be sqrt(u^2+v^2) rounded to 3 decimal places.  Given
% that the U and V components appear to already be rounded to 3 d.p. it
% dosen't make a great deal of sense to round it again (alhtough this is
% what the Nortek software seems to do)

% Surely I can do this without a for loop...  
% Gah...  Save it for version 1.01! - Yep use nanmean(x, dim)
for n = 1:length(AQDdat_mat_out.profile)
    AQDdat_mat_out.da_u_vel(n,:) = nanmean(AQDdat_mat_out.profile(n,:,3));
    AQDdat_mat_out.da_v_vel(n,:) = nanmean(AQDdat_mat_out.profile(n,:,4));
    [theta, rho] = cart2pol(AQDdat_mat_out.da_v_vel(n,:), AQDdat_mat_out.da_u_vel(n,:));
    AQDdat_mat_out.da_speed(n,:) = abs(rho);
    dir = theta*180/pi;
    index = ~(dir > 0);
    AQDdat_mat_out.da_dir(n,:) = dir + index * 360;
end

%% A quick message about the above code chunk...
disp('    ');
disp(['Please check the source code for the assumptions underlying the calculation of depth averaged speed and direction!'])

%% Finishing up...
disp('   ')
disp(['Note: AQDdat2mat has processed ', num2str(length(AQDdat_mat)+num_doubles), ' profiles.'])
disp('      Confirm that this is correct by inspecting the ".hdr" file produced by the Nortek software.')
if num_doubles > 0
    disp(['      This includes ', num2str(num_doubles), ' profiles with duplicate timestamps which have not been included in the output.'])
end
if num_bins_removed > 0
    disp(['      ', num2str(percent_removed,2), ' % of bins were removed becuase the probably contined inteference from "sidelobes". See pg 76 of the AquaDopp manual.'])
end
disp('  ');