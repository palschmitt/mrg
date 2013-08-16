function out = mrg_met_test_string(inp)
% Routine called by mrg_met_control to check the string for real data
% Version 2 modified BE 02 Sept 2011
% Extended the length of the accepatble input string

if length(inp) > 80;
    out = inp;
else    
    out = false;
end