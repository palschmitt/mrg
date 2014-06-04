function mrg_met_cnc
% Cleanup the metstation RS232 connection
% cnc = close and clear
newobjs = instrfind;
fclose(newobjs);
delete(newobjs);
clear newobjs
end