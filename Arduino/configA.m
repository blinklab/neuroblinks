%%%% This is configuration file for each user. %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

metadata.cam.recdurA=1000;

% ------ Letter for mouse -----
path1=pwd;   ind1=find(path1=='\');   metadata.mouse=path1(ind1(end-1)+1:ind1(end)-1);

% --- camera settings ----
metadata.cam.init_ExposureTime=1900;

% -- specify the location of bottomleft corner of MainWindow & AnalysisWindow  --
ghandles.pos_mainwin=[0,50];     ghandles.size_mainwin=[840 600]; 
ghandles.pos_anawin= [570 45];    ghandles.size_anawin=[1030 840]; 
ghandles.pos_oneanawin=[0 45];    ghandles.size_oneanawin=[560 380];   
ghandles.pos_lfpwin= [570 45];    ghandles.size_lfpwin=[600 380];

% ------ Initial value of the conditioning table ----
mousedir=regexp(pwd,['[A-Z]:\\.*\\', metadata.mouse],'once','match');
condfile=fullfile(mousedir,'condparams.csv');

if exist(condfile)
	paramtable.data=csvread(condfile);
else
    paramtable.data=...
    [3,  500,1,200, 10,1,10;...
     1,  500,1,200, 0, 1,0;...
     0,  500,6,200, 0, 2,1;...
     120,500,1,200, 0, 3,1;...
     20, 500,1,200, 5, 4,1;...
     3,  500,1,200, 10,6,100;...
     1,  500,1,200, 0, 6,0;...
     zeros(3,7)];
end
 
comport={'COM6' 'COM6'};







