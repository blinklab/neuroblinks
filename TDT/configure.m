%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tank='conditioning'; % The tank should be registered using TankMon, call it whatever you want

% ------ Letter for mouse -----
path1=pwd;   ind1=find(path1=='\');   metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);

% --- camera settings ----
metadata.cam.init_ExposureTime=4900;

% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
ghandles.pos_mainwin=[8,450];     ghandles.size_mainwin=[840 720]; 
ghandles.pos_anawin=[470 50];     ghandles.size_anawin=[1030 840]; 
ghandles.pos_oneanawin=[8,48];    ghandles.size_oneanawin=[840,364];   
ghandles.pos_lfpwin=[470 50];    ghandles.size_lfpwin=[600 380];

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
 

% Optional support programs to be launched automatically.
% Add more here if you want
button=questdlg('Do you want to launch TDT?');
if strcmpi(button,'Yes')
    winopen(sprintf('%s\\TDT\\private\\TDTFiles\\TDTFiles.wsp',basedir));
    pause(5);
end
