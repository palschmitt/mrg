function RecData = Read_dfs0(varargin);
% tool to read all entries from dfs0 file
% programmed by B. Elsaesser @ RPS Consulting Engineers
% © November 2004 updated September 2005
% © Jan 2007    time & date of data added to file structure
%               and converted to proper function
% revised Sept 2009 to work with Mike 2009 using latest matlab toolbox

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

if isempty(varargin)
    [name,path] = uigetfile('*.dfs0','Open dfs file');
    cd(path);
else
    %if varaging
    name = char(varargin);
end

% read header info
%dm = dfsTSO(name);
dm  = DfsFileFactory.DfsGenericOpen(name);


numitems = dm.ItemInfo.Count;



for n = 0:numitems-1
    item = dm.ItemInfo.Item(n);
    RecData.dData(:,n) = readItem(dm,n);
end
RecData.dTime(1) = datenum(get(dm,'numtimesteps'));
RecData.dTime(2) = datenum(get(dm,'timestepsec'));
RecData.dTime(3) = datenum(get(dm,'timestep'));
RecData.dTime(4) = datenum(get(dm,'startdate'));
RecData.name = dm.FileName;
RecData.title = dm.FileInfo.FileTitle;
RecData.DeleteFloat = dm.FileInfo.DeleteValueFloat;
RecData.items = get(dm,'items');


