%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% If Neuroblinks is launched from the root directory of the mouse, make a new directory for the session, otherwise leave that up to the user
cwd=regexp(pwd,'\\','split');
if regexp(cwd{end},'[A-Z]\d\d\d')  % Will match anything of the form LDDD, where L is single uppercase letter and DDD is a seq of 3 digits
    mkdir(datestr(now,'yymmdd'))
    cd(datestr(now,'yymmdd'))
end

% ------ Letter for mouse -----
path1=pwd;   
ind1=find(path1=='\');   
metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);

% ------ Initial value of the conditioning table ----

% Search for per-mouse config file and load it if it exists, otherwise default to the paramtable below

mousedir=regexp(pwd,['[A-Z]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

if exist(condfile)
	paramtable.data=csvread(condfile);
else
	paramtable.data=...
    [9,  220,1,200, 20,1,1;...
     1,  220,1,200, 0, 1,0;...
     zeros(2,7)];
end


setappdata(0,'paramtable',paramtable);
setappdata(0,'metadata',metadata);
pause(0.3); 

% Optional support programs to be launched automatically.
% Add more here if you want
button=questdlg('Do you want to launch TDT?');
[basedir,mfile,ext]=fileparts(mfilename('fullpath'));
if strcmpi(button,'Yes')
    winopen(sprintf('%s\\private\\TDTFiles\\TDTFiles.wsp',basedir));
    pause(5);
end
