function ptstruc = mrg_ptxml_read()
% Reads a MIKE-formatted PT xml file
%
% OUTPUT
%   ptstruc  A MATLAB strcture with items:
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
%   v 1.0   2013-11-06
%           First version. DP
%   v 1.1   2013-11-26
%           Multiple classes + Compressed data
%
% TODO
%   Check the order of items in compressed particle clases
%
%% Function Begin!
if (nargin == 0)
    [filename, path] = uigetfile('.xml','Select an XML file to read');
    filename = [path, filename];
    cd(path);
end

fid = fopen(filename,'rt');
if fid == -1
    error(id('mrg:FileNotFound'),['Could not find file: ' filename]);
end

%% Get Items
% Get Items...
disp('Looking for particle classes and item types...')
line = 0;
codeloc = 1;
ptstruc = struct();
while ~strcmp(line, '</DataAttributes>')
    line = fgetl(fid);
    % Check if it is a line (and not EOF)
    if ~ischar(line)
        break
    end
    % Match Class ID
    if strncmpi(line,'<ClassID>',9)
        classno = regexpi(line,'<ClassID>\s?(\d+){1}','tokens');
        classnonum = str2double(classno{:});
        line = fgetl(fid);
        % Match Class Name and propogate items...
        if strncmpi(line,'<Name>',6)
            classname = regexpi(line,'<Name>([\s\w\d]+){1}','tokens');
            classname = char(classname{:});
            classidname = [classname, '_ID',  num2str(classnonum)];
            ptstruc.(classidname).classID = classnonum;
            ptstruc.(classidname).classname = classname;
            ptstruc.(classidname).codes = cell(1,50); 
            % Assuming that there will be less than 50 types per particle class
        end
    end
    
    % Trim leading and trailing spaces
    line = strtrim(line);
    % Match 'code'
    if strncmpi(line,'<code>',6)
        code = regexpi(line,'<code>(\w+){1}</code>','tokens');
        code = char(code{:});
        ptstruc.(classidname).codes(codeloc) = {code};
        %codes(codeloc) = {code};
        codeloc = codeloc+1;
    end
end

itemnames = fieldnames(ptstruc);
for a = 1:length(itemnames)
    cc = cellfun(@isempty,ptstruc.(itemnames{a}).codes);
    ptstruc.(itemnames{a}).codes = ptstruc.(itemnames{a}).codes(~cc);
    codetemp = ptstruc.(itemnames{a}).codes;
    disp(['Id: ', num2str(ptstruc.(itemnames{a}).classID), ...
        '; Name: ', ptstruc.(itemnames{a}).classname, ... 
        '; Items (', num2str(length(codetemp)),'): ', ...
        sprintf('%s', codetemp{1}), sprintf(', %s', codetemp{2:end})])
end
% and rewind...
frewind(fid);

%% Estimate partcles and TS's
%numlines = str2num(perl('countlines.pl', filename) );
disp('Estimating number of timesteps and particles')

s = dir(filename);
filebits = [0.01, 0.1, 0.2, 0.5, 1]; % Read the last 10%, 20%, 50% of the file
bit = 1;
while 1
    disp(['Trying last ', num2str(filebits(bit)*100), '% of file...'])
    fseek(fid,-floor(s.bytes*filebits(bit)),'eof'); % Seek to the last n percent of the file
    C = textscan(fid, '%s', 'Delimiter', '\n');
    C = C{1};
    lastpt = 'NOTFOUND';
    lastts = 'NOTFOUND';
    %lastpc = 'NOTFOUND'; % pc = 'particle class', not needed now
    iscompressed = 0;
    for a = 1:length(C)
        if strncmpi(C(a,:),'<Particle Nr',12)
            lastpt = C(a,:);
        end
        if strncmpi(C(a,:),'<TimeStep nr',12)
            lastts = C(a,:);
        end
        %if strncmpi(C(a,:),'<ParticleClass id',17)
        %    lastpc = C(a,:);
        %end
        if strncmpi(C(a,:),'<![CDATA[',9)
            iscompressed =  1;
        end
    end
    if(any([strcmp(lastpt,'NOTFOUND'), strcmp(lastts,'NOTFOUND')]))
        bit = bit+1;
    else
        break
    end
end
frewind(fid);

pstr = regexpi(lastpt,'<Particle Nr="(\d+){1}">','tokens');
pstr = char(pstr{1}{1});
pnum = str2double(pstr);

tsstr = regexpi(lastts,'<TimeStep nr="(\d+){1}">','tokens');
tsstr = char(tsstr{1}{1});
tsnum = str2double(tsstr);
% TS are zero-indexed, correct that here
tsnum = tsnum+1;
tsstr = num2str(tsnum);

% Not needed now, due to reading the header data (above)
%pcstr = regexpi(lastpc,'<ParticleClass id="(\d+){1}">','tokens');
%pcstr = char(pcstr{1}{1});
%pcnum = str2double(pcstr);

%if(pcnum > 1)
%    error('mrg:NotImplemented', 'This function does not handle more than 1 particle class per file')
%end

%if(iscompressed)
%    error('mrg:NotImplemented', 'This function does not handle compressed particle files (yet)')
%end

disp(['Est. no. timesteps: ', tsstr])
disp(['Est. no. particles per class: ', pstr])

%% Pre allocate space and setup
ptitemnames = fieldnames(ptstruc);
% Make a simple lookup table
lookuptbl = cell(length(ptitemnames),3);
% Make a list of all posisble items
allitems = cell(1,1);
% Allocate some space for DTs
ptstruc.dtstr = repmat({''},1,tsnum);

for a = 1:length(ptitemnames)
    codes = ptstruc.(ptitemnames{a}).codes;
    for b = 1:length(codes)
        ptstruc.(ptitemnames{a}).(codes{b}) = NaN(pnum,tsnum);
    end
    lookuptbl{a,1} = ptstruc.(ptitemnames{a}).classID;
    lookuptbl{a,2} = ptstruc.(ptitemnames{a}).classname;
    lookuptbl{a,3} = ptitemnames{a};
    allitems = [allitems, ptstruc.(ptitemnames{a}).codes];
end
allitems = unique(allitems(2:end)); % Needed later...

currtsnum = 0;
currptnum = 0;
h = waitbar(0,'Please wait...');

%% Read compressed data
if iscompressed
    disp('Reading data (Compressed format)')
    % Loop through reding line by line (potentially slow, but hard to think how else to do this!)
    while 1
        line = fgetl(fid);
        % Check if it is a line (and not EOF)
        if ~ischar(line)
            break
        end
        % Trim leading and trailing spaces
        line = strtrim(line);
        % Match the timestep
        if strncmpi(line,'<TimeStep nr',12)
            currts = regexpi(line,'<TimeStep nr="(\d+){1}">','tokens');
            currtsnum = str2double(currts{:});
            currtsnum = currtsnum+1;
        end       
        % Match the DT
        if strncmpi(line,'<DateTime>',10)
            currdt = regexpi(line,'<DateTime>([\d-\s:]+)</DateTime>','tokens');
            currdtstr = char(currdt{:});
            ptstruc.dtstr(1,currtsnum) = {currdtstr};
            waitbar(currtsnum/tsnum, h, sprintf(['Timestep ', num2str(currtsnum),' of ', num2str(tsnum), '\n', currdtstr]))
        end
        % Match the class 
        if strncmpi(line,'<ParticleClass id',17)
            currpcid = regexpi(line,'<ParticleClass id="(\d+){1}">','tokens');
            currpcidnum = str2double(currpcid{:});
            % Lookup name
            indx = cell2mat(lookuptbl(:,1))==currpcidnum;
            currfname = lookuptbl{indx,3};
        end
        % Match the particle number
        if strncmpi(line,'<Particle Nr',12)
            currpt = regexpi(line,'<Particle Nr="(\d+){1}">','tokens');
            currptnum = str2double(currpt{:});
        end
        % Match compressed data
        if strncmpi(line,'<![CDATA[',9)
            % <![CDATA[1020.000000,55.00000000,0.4968643188E-01,0.000000000,0.4029122053E-02,0.6749004142,0.000000000,0.000000000]]>
            pattern = ['<!\[CDATA\[(-?\d+\.*\d*[eE]?[\+\-]?\d*,?){',num2str(length(codes)),'}\]\]>'];
            dat = regexpi(line,pattern,'tokens');
            dat = regexpi(dat{1}{1},'(-?\d+\.*\d*[eE]?[\+\-]?\d*),?','tokens');           
            codetemp = ptstruc.(currfname).codes;
            for a = 1:length(codetemp)
                ptstruc.(currfname).(codetemp{a})(currptnum,currtsnum) = str2double(dat{a}); 
                % TODO: This assumes that they are written in the same order! 
            end
        end
    end
end
%% Read uncompressed data
if ~iscompressed
    disp('Reading data (Uncompressed format)')
    % Loop through reding line by line (potentially slow, but hard to think how else to do this!)
    while 1
        line = fgetl(fid);
        % Check if it is a line (and not EOF)
        if ~ischar(line)
            break
        end
        % Trim leading and trailing spaces
        line = strtrim(line);
        % Match the timestep
        if strncmpi(line,'<TimeStep nr',12)
            currts = regexpi(line,'<TimeStep nr="(\d+){1}">','tokens');
            currtsnum = str2double(currts{:});
            currtsnum = currtsnum+1;
        end
        % Match the DT
        if strncmpi(line,'<DateTime>',10)
            currdt = regexpi(line,'<DateTime>([\d-\s:]+)</DateTime>','tokens');
            currdtstr = char(currdt{:});
            ptstruc.dtstr(1,currtsnum) = {currdtstr};
            waitbar(currtsnum/tsnum, h, sprintf(['Timestep ', num2str(currtsnum),' of ', num2str(tsnum), '\n', currdtstr]))
        end
        % Match the class 
        if strncmpi(line,'<ParticleClass id',17)
            currpcid = regexpi(line,'<ParticleClass id="(\d+){1}">','tokens');
            currpcidnum = str2double(currpcid{:});
            % Lookup name
            indx = cell2mat(lookuptbl(:,1))==currpcidnum;
            currfname = lookuptbl{indx,3};
        end
        % Match the particle number
        if strncmpi(line,'<Particle Nr',12)
            currpt = regexpi(line,'<Particle Nr="(\d+){1}">','tokens');
            currptnum = str2double(currpt{:});
        end
        % Match items
        matchers = strcat('<',allitems,'>');   
        matched =  regexpi(line, sprintf('(%s)?', matchers{:}),'tokens');
        if ~isempty(matched)
            matchedno =  find(~cellfun(@isempty,matched{:}));
            if length(matchedno) > 1
                error('More than one match between item names and xml tags');
            end
            if length(matched) == 1
                pattern = [matched{1}{matchedno}, '(-?\d+\.*\d*[eE]?[\+\-]?\d*)</'];       
                dat = regexpi(line,pattern,'tokens');
                ptstruc.(currfname).(allitems{matchedno})(currptnum,currtsnum) = str2double(dat{:});
            end
        end
    end
end

%% Finished!
disp('Done!')
close(h);
fclose(fid);

end