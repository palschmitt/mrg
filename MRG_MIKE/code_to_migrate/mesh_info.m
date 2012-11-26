NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

[filename, path] = uigetfile('.dfsu');

dfsu2 = DfsFileFactory.DfsuFileOpen([path filename]);
area = double(dfsu2.ReadItemTimeStep(1,0).Data);

char(item.Name)
char(item.Quantity.Unit)
char(item.Quantity.UnitAbbreviation)

disp(['Number of elements: ',num2str(length(area))])
disp(['Total area: ',num2str(sum(area)/1000000),' km^2'])
disp(['Mean area: ',num2str(mean(area)), ' m^2'])
disp(['Mean area: ',num2str(mean(area)/1000000), ' km^2'])