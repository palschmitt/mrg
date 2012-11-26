%%
[FileName,PathName] = uigetfile({'*.wad','ADCP_wave-files (*.wad)'},'MultiSelect','on');

%%
if ~isempty(FileName);
    cd(PathName);
    for n = 1:length(FileName);
        [M(n,2:4),M(n,1)] = read_wad_data(char(FileName(n)));
    end
    
    M(:,1) = M(:,1) - datenum('30-Dec-1899');
    
    NewName = char(FileName(1));
    NewName = [NewName(1:end-10),'.xls'];
    xlswrite(NewName,M);
    
end