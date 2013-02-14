function data_out = mrg_read_WRII_ascii(path,fnames)
% A function to read ASCII files from WinRiver II. 
% Assumes a VERY specific output format as produced by the 
% mrg_enu_v4.ttf ASCII template.
%
% USAGE
%   [fnames, path] = uigetfile('.txt', 'Select ASCII text files to process', 'MultiSelect', 'on');
%   data_out = mrg_read_WRII_ascii(path, fnames);
%
% INPUT
%   path        A string specifiying the path to the files. 
%   fnames      A string, or cell array of strings (for multiple files)
% 
% OUTPUT
%   A MATLAB structure, containing a nested structure for each transect named (t0, t1, ..., tn).  
%   Each nested structure has field corresponding to the data in the ASCII
%   output. 
%
% REQUIREMENTS
%   Requires a very specific ASCII output structure.  This output is
%   produced by WinRiver II using the 'Generic ASCII Output' function, and
%   using the template named 'mrg_enu_v4.ttf'.  
%
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   September 2012
%           DP.  First version.  Put in place as a replacement to the exisiting
%           binary-reading code becuase I'm too stupid to do the Ship to
%           ENU transformation properly.  
%   v 1.1   2012-09-12
%           DP. Documentation.  
%           DP. Added flexibility surrounding output that varies with the number of bins.
%
% TODO
%   Catch input.  Prompt user for files names with multiselect on if not
%   present.  


%% Setup output
data_out = struct();

if iscell(fnames)
    fnames = sort(fnames);
else 
    fnames = {fnames};
end


for i = 1:length(fnames)
    if ~strfind(fnames{i}, 'mrg_enu_v4')
        warning(['The string "mrg_enu_v4" was not found in the input filename for ',fnames{i},'.  Are you ABSOLUTELY SURE the file was produced by the correct template?'])
    end
    data = dlmread([path fnames{i}]);
    data(data==-32768) = NaN;
    sname = ['t', num2str(i-1)];
    data_out.(sname) = struct();
    data_out.(sname).fname = fnames{i};
    data_out.(sname).mtime = datenum(data(:,1)+2000,data(:,2),data(:,3),data(:,4),data(:,5),data(:,6)+data(:,7)/100)';
    data_out.(sname).latitude = data(:,8)';
    data_out.(sname).longitude = data(:,9)';
    
    if range(data(:,10)) == 0
        data_out.(sname).nbins = data(1,10);
    else
        error(['Multiple different bin numbers in the same dataset ',fnames{i}])
    end
    
    if range(data(:,11)) == 0
        data_out.(sname).beamangle = data(1,11);
    else
        error(['Multiple different beam angles in the same dataset ',fnames{i}])
    end
    
    if range(data(:,12)) == 0
        data_out.(sname).blank = data(1,12);
    else
        error(['Multiple different blanking distances in the same dataset ',fnames{i}])
    end
    
    if range(data(:,13)) == 0
        data_out.(sname).bin1range = data(1,13);
    else
        error(['Multiple different bin 1 ranges in the same dataset ',fnames{i}])
    end
    
    if range(data(:,14)) == 0
        data_out.(sname).binsize = data(1,14);
    else
        error(['Multiple different bin size settings in the same dataset ',fnames{i}])
    end
    
    data_out.(sname).heading = data(:,15)';
    data_out.(sname).pitch = data(:,16)';
    data_out.(sname).roll = data(:,17)';
    
    if range(data(:,18)) == 0
        data_out.(sname).firmware = data(1,18);
    else
        error(['Multiple different firmwares in the same dataset ',fnames{i}])
    end
    
    data_out.(sname).beam1depth = data(:,19)';
    data_out.(sname).beam2depth = data(:,20)';
    data_out.(sname).beam3depth = data(:,21)';
    data_out.(sname).beam4depth = data(:,22)';
    data_out.(sname).beamsaveragedepth = data(:,23)';
    data_out.(sname).meanwaterdepth_GGA = data(:,24)';
    data_out.(sname).meanwaterdepth_BT = data(:,25)';
    
    % Selection matrix (the following 11 objects are bin-number dependent)
    begin = [26:data_out.(sname).nbins:size(data,2)];
    fin = begin+data_out.(sname).nbins-1;
    
    data_out.(sname).eastvelocity_GGA       = data(:,begin(1):fin(1))';
    data_out.(sname).northvelocity_GGA      = data(:,begin(2):fin(2))';
    data_out.(sname).earthupvelocity_GGA    = data(:,begin(3):fin(3))';
    data_out.(sname).eartherrorvelocity_GGA = data(:,begin(4):fin(4))';
    data_out.(sname).eastvelocity_BT        = data(:,begin(5):fin(5))';
    data_out.(sname).northvelocity_BT       = data(:,begin(6):fin(6))';
    data_out.(sname).earthupvelocity_BT     = data(:,begin(7):fin(7))';
    data_out.(sname).eartherrorvelocity_BT  = data(:,begin(8):fin(8))';
    data_out.(sname).averagecorrelation     = data(:,begin(9):fin(9))';
    data_out.(sname).averagebackscatter     = data(:,begin(10):fin(10))';
    data_out.(sname).averageintensity       = data(:,begin(11):fin(11))';
end





end
