function gofstat = mrg_gofstat(Pred,Obs)
% A function to calculate correlation statistics used for comparision of model
% data to observations or between two different models
%
% INPUT
%   Pred    Data to compare. An m by n matrix with m timesteps and n 
%           items or points
%   Obs     The reference values. An m by n matrix the same size as Pred.
%
% OUTPUT
%   gofstat A MATLAB structure. See NOTES
%
% NOTES
%   This function returns a number of useful model comparision statitics,
%   calculated from pair-wise comparisions the columns in each of the
%   matrixes Pred and Obs.  Column 1 in Pred is compared against column 1
%   in Obs; Column 2 with column 2; and so-on up to column n.
%
%   The returned structure contains the following information:
%       corr : An n-by-4 matrix with
%               : The correlation coefficient (R)
%               : The lower 95% confidence limit on R
%               : The upper 95% confidence limit on R
%               : The p-value on R
%       Pbar : An n-by-1 vector. The nanmean of Pred
%       Obar : An n-by-1 vector. The nanmean of Obs
%       bias : An n-by-4 matrix with
%               : The nanmean of the pairwise differences
%               : The nanmean of the absolute pairwise differences 
%               : The standard deviation of pairwise differences
%               : The so-called bias-index
%       RMS  : An n-by-3 matrix with
%               : The root mean square
%               : The scatter index (RMS/Obar)
%               : The stdev of the differences (same as bias(:,3), above?)
%       MEF  : An n-by-1 vector. The modelling efficency
%       RI   : An n-by-1 vector. The reliability index
%
%   Note that this uses the nanmean and nanstd functions to calculate the
%   mean of the two datasets, which will implicitly ignore missing values.
%   Note that this function relies on linear correlations. If your data are
%   circular, you might consider a circular correlation coefficient.
%
% OCTAVE COMPATIBILITY
%   Untested.
%
% REFERENCES
%   Stow, C. A., Jolliff, J., McGillicuddy, D. J., Doney, S. C., Allen, J. I., 
%       Friedrichs, M. A. M., Rose, K. A., and Wallhead, P.  2009.  Skill 
%       assessment for coupled biological/physical models of marine systems.  
%       Journal of Marine Systems, 76: 4--15.
%
% AUTHORS
%   Clare Duggan
%   Daniel Pritchard
%
% LICENCE
%   Code distributed as part of the MRG toolbox from the Marine Research
%   Group at Queens Univeristy Belfast (QUB) School of Planning
%   Architecture and Civil Engineering (SPACE). Distributed under a
%   creative commons CC BY-SA licence, retaining full copyright of the
%   original authors.
%
%   http://creativecommons.org/licenses/by-sa/3.0/
%   http://www.qub.ac.uk/space/
%   http://www.qub.ac.uk/research-centres/eerc/
%
% DEVELOPMENT
%   v 1.0   2011-10-01
%           First version. Clare Duggan
%   v 1.1   2012-10-01
%           Modified. Clare Duggan
%   v 1.2   2013-07-28
%           Documentation. Cleanup. Daniel Pritchard
%   v 1.3   2013-08-15 DP.
%           Fixed error in upper confidence interval.
%           More documentation.
%
%% Function Begin!
k1 = size(Pred);
k2 = size(Obs);

if k1~=k2
    msgbox('Data sets are not the same size!');
    return
end

gofstat = struct();

%% Performing Statistical Calculations
for n = 1:k1(2);
    % Correlation coefficent with the 95% upper and lower confidence limit
    [R,P,RLO,RUP]=corrcoef(Pred(1:end,n),Obs(1:end,n),'rows','pairwise');
    gofstat.corr(n,1) = R(2);
    gofstat.corr(n,2) = RLO(2);
    gofstat.corr(n,3) = RUP(2);
    gofstat.corr(n,4) = P(2);
    
    % mean of the different data sets
    gofstat.Pbar(n,1) = nanmean(Pred(1:end,n));
    gofstat.Obar(n,1) = nanmean(Obs(1:end,n));
    
    % difference of the data sets
    delta = Pred(1:end,n) - Obs(1:end,n);
    delta2 = abs(Pred(1:end,n) - Obs(1:end,n));
    % mean of difference
    gofstat.bias(n,1) = nanmean(delta);
    % average absolute error
    gofstat.bias(n,2) = nanmean(delta2);
    % standard deviation of difference
    gofstat.bias(n,3) = nanstd(delta);
    % bias index of the data set
    gofstat.bias(n,4) = gofstat.bias(n,1)/gofstat.Obar(n,1);

    % RMS
    gofstat.RMS(n,1) = sqrt(nanmean(delta.^2));
    % Scatter index
    gofstat.RMS(n,2) = gofstat.RMS(n,1)/gofstat.Obar(n,1);
    % Standard deviation of the differences
    gofstat.RMS(n,3) = sqrt(nanmean((delta - nanmean(delta)).^2));
    
    % MEF - the modeling efficiency
    % observations minus average of observations
    difme = (Obs(1:end,n) - gofstat.Obar(n,1)).^2;
    % predictions minus average of predictions
    difmo = (Pred(1:end,n) - Obs(1:end,n)).^2;
    difme2 = nansum(difme);
    difmo2 = nansum(difmo);
    % MEF
    gofstat.MEF(n,1) =(difme2-difmo2)/difme2;
    
    % RI - Reliability Index
    rel = (log(Obs(1:end,n)./Pred(1:end,n))).^2;
    rel2 = nanmean(rel);
    rel3 = sqrt(rel2);
    gofstat.RI(n,1) = exp(rel3);
end
