function fileList = mrg_oswalk(dirName)
% Walks a directory and returns a cell array of file names
% 
% INPUT
%   dirName   A string. The directory to walk.  
%
% OUTPUT
%   fileList  DESCRIPTION
%
% NOTES
%   Additional (more verbose) documentation can go here.
%
% REFERENCES
% Originally from:
%  http://stackoverflow.com/questions/2652630/how-to-get-all-files-under-a-specific-directory-in-matlab
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
%% Function Begin!
dirData = dir(dirName);      % Get the data for the current directory
dirIndex = [dirData.isdir];  % Find the index for directories
fileList = {dirData(~dirIndex).name}';  % Get a list of the files
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),...  % Prepend path to files
        fileList,'UniformOutput',false);
end
subDirs = {dirData(dirIndex).name};  % Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  % Find index of subdirectories that are not '.' or '..'
for iDir = find(validIndex)                  % Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    % Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  % Recursively call getAllFiles
end
end
