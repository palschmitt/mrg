function mrg_create_npp_langdef()
% Creates a language definition file for NotePad++ 
%
% This function scans a user-selected directory (e.g. the DHI installation
% directory) and extracts the information from the files it finds there.
%
% INPUT
%   None. The user is prompted to select the
%   userDefineLang_PFS_Template.xml file.  
%
% OUTPUT
%   NO OUTPUT AT CONSOLE.
%   Three files are generated:
%       userDefineLang.xml: The language definition file
%       pfs_static_list.txt: A list of 'static' PFS keywords
%       pfs_variable_list.txt: The 'variable' PFS keywords
%
% NOTES
%   The three files will be written to the same folder as the
%   userDefineLang_PFS_Template.xml file, and will overwirte any files with
%   the same name.  
%
% REQUIREMENTS
%   Requires userDefineLang_PFS_Template.xml which can be found in Dans 
%   MIKE PFS respository: https://github.com/dpritchard/mike_pfs_npp
%   
%   All that being said, you may as well just get the generated XML from 
%   the above link!
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
%   v 1.0   2013-03-??
%           First version. DP
%   v 1.1   2013-09-16
%           Updated across the board and refactored to use mrg_oswalk() 
%           and mrg_PFS_keywords()  
%
%% Get the Template
% We assume the files with the lists are in same directory
old_dir = cd;
[file, path] = uigetfile('userDefineLang_PFS_Template.xml', 'Get Template');
cd(path)
fileID = fopen(file);
s = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);
s = s{1};

%% Get the header keywords
keywords = mrg_PFS_keywords;
keystring = [keywords.fixed_len, keywords.variable_len];

%% Combine Items
keyword_string = sprintf('%s ',keystring{:});

%% Populate the template
s = strrep(s,'[MRG_KEYWORDS]', keyword_string);

%% Write File
[nrows,~]= size(s);
filename = 'userDefineLang.xml';
fid = fopen(filename, 'w');
for row=1:nrows
    fprintf(fid, '%s\r\n', s{row,:});
end
fclose(fid);

filename = 'pfs_static_list.txt';
fid = fopen(filename, 'w');
fprintf(fid, '%s\r\n', keywords.fixed_len{:});
fclose(fid);

filename = 'pfs_variable_list.txt';
fid = fopen(filename, 'w');
fprintf(fid, '%s\r\n', keywords.variable_len{:});
fclose(fid);

cd(old_dir);
end