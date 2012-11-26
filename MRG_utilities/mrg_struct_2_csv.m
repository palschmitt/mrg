function mrg_struct_2_csv(in, outfile)
% A function to output a structure to csv.  Currently can only deal with a
% limited number of data types, and only deals with 'square' structures.
%
% INPUT
%   in          A structure with equal-length fields of either cell arrays
%               or things that test true for is isnumeric(). Other things
%               will fail.  
%   outfile     A character string giving the (possibly fully qualified)
%               output filename.
% 
% LICENCE
%   Created by Daniel Pritchard (www.pritchard.co)
%   Distributed under a creative commons CC BY-SA licence. See here:
%   http://creativecommons.org/licenses/by-sa/3.0/
%
% DEVELOPMENT
%   v 1.0   Time Immemorial
%           DP.  Why does MATLAB not do this by defualt?
%   v 1.1   November 2012
%           DP.  Documentation.   
%
% TODO
%   Catch input.  Prompt user for filesname if not present.  

%% Go
if ~isstruct(in)
    error('Input must be a structure')
end

if ~ischar(outfile)
    error('Outfile must be a charater string')
end

names = fieldnames(in);
ncol = length(names);

lengths = ones(1,length(names),'int32');
for n = 1:length(names)
    lengths(1,n) = length(in.(names{n}));
end

if~(all(lengths==lengths(1)))
    error('All variables in the input structure must have the same length')
end

nrow = unique(lengths);

fid = fopen(outfile, 'w');

for n = 1:length(names)-1
    fprintf(fid, '%s,', names{n});
end
fprintf(fid, '%s\n', names{length(names)});

for n = 1:nrow
    % Do something for each of the columns
    for m = 1:length(names)-1
        val = in.(names{m})(n);
        if iscell(val)
            if isnumeric(val{:})
                fprintf(fid, '%d,', val{:});
            elseif ischar(val{:})
                fprintf(fid, '%s,', val{:});
            else
                error('Cannot handle a cell array which does not evaluate to either a number or a character')
            end
        elseif isnumeric(val)
            fprintf(fid, '%d,', val(:));
        else
            error('Cannot handle something that contains things other than cell or numeric arrays')
        end
    end
    % Do something different for the last column
    val = in.(names{length(names)})(n);
    if iscell(val)
        if isnumeric(val{:})
            fprintf(fid, '%d\n', val{:});
        elseif ischar(val{:})
            fprintf(fid, '%s\n', val{:});
        else
            error('Cannot handle a cell array which does not evaluate to either a number or a character')
        end
    elseif isnumeric(val)
        fprintf(fid, '%d\n', val(:));
    else
        error('Cannot handle something that contains things other than cell or numeric arrays')
    end
    
    
end

fclose(fid);

end