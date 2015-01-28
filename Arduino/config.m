%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: In the future this should be dynamically set based on pre and post time
metadata.cam.recdurA=1000;

% basedir='D:\shane\matlab\neuroblinks v 1.1';
tank='optoelectrophys'; % The tank should be registered using TankMon

% If Neuroblinks is launched from the root directory of the mouse, make a new directory for the session, otherwise leave that up to the user
cwd=regexp(pwd,'\\','split');
if regexp(cwd{end},'[A-Z]\d\d\d')  % Will match anything of the form LDDD, where L is single uppercase letter and DDD is a seq of 3 digits
    mkdir(datestr(now,'yymmdd'))
    cd(datestr(now,'yymmdd'))
end

% ------ Letter for mouse -----
path1=pwd;   ind1=find(path1=='\');   metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);

% --- camera settings ----
metadata.cam.init_ExposureTime=4900;

% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
ghandles.pos_mainwin=[5,50];     ghandles.size_mainwin=[840 600]; 
ghandles.pos_anawin= [570 45];    ghandles.size_anawin=[1030 840]; 
ghandles.pos_oneanawin=[5 45];    ghandles.size_oneanawin=[560 380];   
ghandles.pos_lfpwin= [570 45];    ghandles.size_lfpwin=[600 380];

% ------ Initial value of the conditioning table ----

% Search for per-mouse config file and load it if it exists, otherwise default to the paramtable below

mousedir=regexp(pwd,['[A-Za-z]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

if exist(condfile)
	paramtable.data=csvread(condfile);
else
	paramtable.data=...
    [9,  200,1,200, 20,3,1,10;...
     1,  200,1,200, 0, 3,1,0;...
     ];
 end
 
% comport={'COM4', 'COM5'};
comport={'COM4', 'COM8'};

setappdata(0,'paramtable',paramtable);
setappdata(0,'metadata',metadata);
pause(0.3);





