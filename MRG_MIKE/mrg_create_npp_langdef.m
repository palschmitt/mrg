function mrg_create_npp_langdef()
% Creates a language definition file for NotePad++ from some template files.
% 
% Requires userDefineLang_PFS_Template.xml, pfs_static_list.txt and 
% pfs_variable_list.txt which can be found in Dans MIKE PFS respository:
% https://github.com/dpritchard/mike_pfs_npp
% 
% All that being said, you may as well just get the generated XML from the
% above link!

%% Get the Template
% We assume the files with the lists are in same directory
old_dir = cd;
[file, path] = uigetfile('userDefineLang_PFS_Template.xml', 'Get Template');
cd(path)
fileID = fopen(file);
s = textscan(fileID,'%s','Delimiter','\n');
fclose(fileID);
s = s{1};

%% Static Items
fileID = fopen('pfs_static_list.txt');
static_items = textscan(fileID,'%s', 'Delimiter', '\n');
fclose(fileID);

loc_static = 1;
trim_static = 0;
static_items_start_out = cell(1,length(static_items{1}));
static_items_keyword_out = cell(1,length(static_items{1}));
for i = 1:length(static_items{1})
    title_match = regexp(static_items{1}(i),'^<--\s*[\w]+\s*-->');
    if title_match{1}
        disp(static_items{1}(i))
        trim_static = trim_static+1;
    else
        static_items_start_out(loc_static)=(strcat('[',static_items{1}(i), ']'));
        static_items_keyword_out(loc_static)=static_items{1}(i);
        loc_static = loc_static+1;
    end
    
end
static_items_start_out = static_items_start_out(1:end-trim_static);
static_items_keyword_out = static_items_keyword_out(1:end-trim_static);

%% Variable Items
%[file, path] = uigetfile('.txt', 'Get Variable List');
fileID = fopen('pfs_variable_list.txt');
var_items = textscan(fileID,'%s', 'Delimiter', '\n');
fclose(fileID);

var_len = 50;

loc_var = 1;
trim_var = 0;
var_items_start_out = cell(1,length(var_items{1})*var_len);
var_items_keyword_out = cell(1,length(var_items{1})*var_len);
for i = 1:length(var_items{1})
    title_match = regexp(var_items{1}(i),'^<--\s*[\w]+\s*-->');
    if title_match{1}
        disp(var_items{1}(i))
        trim_var = trim_var+1;
    else
        for j = 1:var_len
            var_items_start_out(loc_var) = strcat('[',var_items{1}(i), '_', num2str(j), ']');
            var_items_keyword_out(loc_var) = strcat(var_items{1}(i), '_', num2str(j));
            loc_var = loc_var+1;
        end
    end
end
% Trim to account for headers...
var_items_start_out = var_items_start_out(1:end-trim_var*var_len);
var_items_keyword_out = var_items_keyword_out(1:end-trim_var*var_len);

%% Combine Items
start_out = [static_items_start_out,var_items_start_out];
keyword_out = [static_items_keyword_out,var_items_keyword_out];
start_string = [sprintf('%s ',start_out{1:end-1}),start_out{end}];
keyword_string=[sprintf('%s ',keyword_out{1:end-1}),keyword_out{end}];

%% Populate the template
s = strrep(s,'[MRG_START_FILES]', start_string);
s = strrep(s,'[MRG_KEYWORDS]', keyword_string);

%% Write File
[nrows,~]= size(s);
filename = 'userDefineLang.xml';
fid = fopen(filename, 'w');

for row=1:nrows
    fprintf(fid, '%s\n', s{row,:});
end

fclose(fid);
cd(old_dir);
end