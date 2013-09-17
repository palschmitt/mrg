function keywords = mrg_PFS_keywords
% Reads all the ecolab, m21fm and plc files in a directory and returns the [header] keywords
%
% INPUT
%   None. The user is prompted to select a directory which can be the DHI
%   installation directory or any folder with a whole heap of PFS formatted
%   files from which to extract the keywords.  
%
% OUTPUT
%   keywords    A MATLAB structure with fields:
%                   variable_len: PFS keywords which might be variable in
%                   length (e.g. STATE_VARIABLE_X; where X is an integer)
%                   fixed_len: PFS keywords which are probably not variable
%                   in length (e.g. ECO_LAB_SETUP)
%
% NOTES
%   This can be called directly, if needed, but it is designed to work
%   alongside mrg_create_npp_langdef.m
%
% AUTHORS
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
%   v 1.0   2013-09-16
%           First version. DP
%
% TODO
%   Allow variable extensions at run time.
%
%% Function Begin!
folder_name = uigetdir('C:/', 'Please select the DHI installation directory');
fileList = mrg_oswalk(folder_name);

x1 = regexp(fileList, '.*\.ecolab$', 'match');
y1 = x1(~cellfun('isempty',x1));

x2 = regexp(fileList, '.*\.m21fm$', 'match');
y2 = x2(~cellfun('isempty',x2));

x3 = regexp(fileList, '.*\.plc$', 'match');
y3 = x3(~cellfun('isempty',x3));

a1 = [y1;y2;y3];

allout = {};
for a = 1:length(a1)
    text = fileread(char(a1{a}));
    matches = regexp(text, '\[(\w+)\]\s+', 'tokens');
    allout = [allout;matches.'];
end

varlen = regexp([allout{:}].', '(\w+_)\d+', 'tokens');
index = ~cellfun('isempty',varlen);

varlen = varlen(index);
varlen = [varlen{:}];

notvarlen = allout(~index);

varlenout = unique([varlen{:}]);
notvarlenout = unique([notvarlen{:}]);

keywords = struct();
keywords.variable_len = varlenout;
keywords.fixed_len = notvarlenout;
end
