function mrg_met_control(verbosity)
% The core Metstation control file... This function opens a serial
% connection and generates an infinite loop that reads incomming data and
% processes it as required.
%
% INPUT
%   verbosity   An integer specifying the level of output to the console.
%               This only effects output to screen and has no effect on 
%               the logging to file.
%               0 = No output
%               1 = Minimal output (The default)
%               2 = Outputs every time a string is read
%               3 = Also reports the size of data in the buffer
%
% OUTPUT
%   This function reports information to the console and to a file named:
%       met_log_yyyy_mmm.txt
%   Where yyyy and mmm are the year and abbreviated month name, repectivly.
%   Other heavy lifting is done by mrg_met_output and further details can
%   be found there.
%
% REQUIREMENTS
%   Requires mrg_met_test_string and mrg_met_output
%
% AUTHORS
%   Bjoern Elsaesser
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
%   v 1.0   2010
%           First version. BE.
%   v 2.1   24/01/2012 - DP
%           Removed useless RS232 reset capabilities.
%   v 3.0   August 2013. DP
%           Major re-write.
%           Clean up and document. Move into MRG toolbox.
%
%% Open serial connection
s = serial('/dev/ttyS0');
set(s,'BaudRate',9600);
fopen(s);

disp('Serial port connected. Starting mrg_met_control...')

%% Set default verbosity (1)
if nargin < 1
    verbosity = 1;
end
% Setting verbosity to 0 silences all output to the screen (but log files
% are still generated)

%% The loop of doom...
while 1
    ser_out = fgetl(s);
    out = mrg_met_test_string(ser_out);

    if out ~= 0;
        % The length of the data suggest we have something to process
        try
            msg = mrg_met_output(out); 
        catch err
            msg = [datestr(now,'HH:MM:SS dd/mm/yyyy'), ': FAIL. Failure to convert, save, or upload data. The error was:\n', err];
        end
        % Regardless of the outcome, write the msg to file
        fileID2 = fopen(['met_log_',datestr(date,'yyyy_mmm'),'.txt'],'a');
        fprintf(fileID2,[msg,'\r\n']);
        fclose(fileID2);
        if verbosity > 0
            fprintf([msg,'\n\nNB: If you are reading this, do not touch this computer!\n\n']);
        end
        % Create post-processed figures
        mrg_met_pp
        % End post-processing
    elseif length(ser_out) < 23
        % ser_out is not long enough to be real data, so we have the option
        % to get chatty to the user, if set in the call to
        % mrg_met_control.m
        if verbosity > 1 
            msg = ['Logging Weather Station @ ', ser_out];
            fprintf(msg);
        end
        if verbosity > 2
            msg = ['Bytes in Buffer : ', num2str(s.BytesAvailable), '\n'];
            fprintf(msg);
        end
    end
    
    % If we get to this stage and there are few than 23 bytes to read, we
    % should wait for 10 seconds...
    if s.BytesAvailable < 23 
        pause(10)
    end
end
end