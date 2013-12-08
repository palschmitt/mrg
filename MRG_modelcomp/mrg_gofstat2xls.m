function mrg_gofstat2xls(gofstat)
% this function provides a simple output of the goodness-of-fit statistics 
% as given by mrg_gofstat in structure format to xlsx file in a simple 
% sheet format with some commenting and headers. 
%
% not pretty but works
%
% INPUT
%   gofstat as provided by mrg_gofstat
%
% OUTPUT
%    the excel file with two colums if one data set is used, or else more
%
% USAGE
%   simply gte the gofstat output from mrg_gofstat and run the function
%
% NOTES
%   Additional (more verbose) documentation can go here.
%
% REQUIREMENTS
%   a structure of the same format as produced by mrg_gofstat
%
% OCTAVE COMPATIBILITY
%   Untested.
%
%
% AUTHORS
%   Bjoern Elsaesser @ QUB
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
%   v 1.0   2013-11-28
%           First version. BE
%
% TODO
%   make code prettier and faster...
%
%
%% not much to it!

% define the excel file for the data to be written to
[FileName,PathName,FilterIndex] = uiputfile('*.xlsx','Choose filename for data','GoF_Stat.xlsx');

cd(PathName);

% write correlation data
text = {'Correlation coefficient (R)'};
xlswrite(FileName,text,'Corr','A1');
text = {'Lower 95% confidence limit on R'};
xlswrite(FileName,text,'Corr','A2');
text = {'Upper 95% confidence limit on R'};
xlswrite(FileName,text,'Corr','A3');
text = {'p-value on R'};
xlswrite(FileName,text,'Corr','A4');
xlswrite(FileName,gofstat.corr.','Corr','B1');

% write bias data
text = {'NaN Mean of the pairwise differences'};
xlswrite(FileName,text,'Corr','A5');
text = {'NaN Mean of the absolute pairwise differences'};
xlswrite(FileName,text,'Corr','A6');
text = {'Standard Deviation of pairwise differences'};
xlswrite(FileName,text,'Corr','A7');
text = {'Bias-index - bias / mean'};
xlswrite(FileName,text,'Corr','A8');
xlswrite(FileName,gofstat.bias.','Corr','B5');

% write RMS data
text = {'root mean square'};
xlswrite(FileName,text,'Corr','A9');
text = {'scatter index (RMS/Obar)'};
xlswrite(FileName,text,'Corr','A10');
text = {'scatter index using abs of signal (RMS/abs(Obar))'};
xlswrite(FileName,text,'Corr','A11');
text = {'stdev of the differences (different to bias stdev)'};
xlswrite(FileName,text,'Corr','A12');
xlswrite(FileName,gofstat.RMS.','Corr','B9');

% write remaining stats of means
xlswrite(FileName,gofstat.Pbar.','Corr','B13');
text = {'Pbar : The nanmean of Pred'};
xlswrite(FileName,text,'Corr','A13');
xlswrite(FileName,gofstat.Obar.','Corr','B14');
text = {'Obar : The nanmean of Obs'};
xlswrite(FileName,text,'Corr','A14');
xlswrite(FileName,gofstat.absPbar.','Corr','B15');
text = {'absPbar : The nanmean of abs(Pred)'};
xlswrite(FileName,text,'Corr','A15');
xlswrite(FileName,gofstat.absObar.','Corr','B16');
text = {'absObar : The nanmean of abs(Obs)'};
xlswrite(FileName,text,'Corr','A16');

% write remaining stats of goodness of fit
xlswrite(FileName,gofstat.MEF.','Corr','B17');
text = {'MEF  : The modelling efficency as per Stow 2009'};
xlswrite(FileName,text,'Corr','A17');
xlswrite(FileName,gofstat.skill.','Corr','B18');
text = {'skill: The modelling skill as per Dias 2009'};
xlswrite(FileName,text,'Corr','A18');
xlswrite(FileName,gofstat.RI.','Corr','B19');
text = {'RI   : The reliability index'};
xlswrite(FileName,text,'Corr','A19');

end
